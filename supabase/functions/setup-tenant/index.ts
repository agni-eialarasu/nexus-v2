// Edge Function: setup-tenant
// Called after user registration to create or join a tenant.
//
// Request body:
// { "action": "create", "name": "Acme Corp" }
// or
// { "action": "join", "code": "ACME2026" }

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Create Supabase admin client (service_role bypasses RLS)
    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    // Get the user from the JWT
    const authHeader = req.headers.get("Authorization")!;
    const token = authHeader.replace("Bearer ", "");
    const {
      data: { user },
      error: authError,
    } = await supabaseAdmin.auth.getUser(token);

    if (authError || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const { action, name, code } = await req.json();
    let tenantId: string;
    let isOrgAdmin = false;

    if (action === "create") {
      // Create a new tenant
      const slug = name
        .toLowerCase()
        .replace(/[^a-z0-9]+/g, "-")
        .replace(/^-+|-+$/g, "");
      const joinCode = `${slug.slice(0, 4).toUpperCase()}${Date.now().toString(36).slice(-4).toUpperCase()}`;

      const { data: tenant, error: createError } = await supabaseAdmin
        .from("tenants")
        .insert({ slug, name, code: joinCode })
        .select()
        .single();

      if (createError) throw createError;
      tenantId = tenant.id;
      isOrgAdmin = true;

      // Seed default roles
      await supabaseAdmin.from("tenant_roles").insert([
        {
          tenant_id: tenantId,
          name: "Project Manager",
          permissions: {
            pages: {
              dashboard: { view: true, edit: true, viewMode: "global" },
              projects: { view: true, edit: true, viewMode: "global" },
              portfolios: { view: true, edit: true, viewMode: "global" },
            },
          },
          is_default: false,
        },
        {
          tenant_id: tenantId,
          name: "Team Member",
          permissions: {
            pages: {
              dashboard: { view: true, edit: false, viewMode: "own" },
              projects: { view: true, edit: false, viewMode: "team" },
              timesheets: { view: true, edit: true, viewMode: "own" },
            },
          },
          is_default: true,
        },
      ]);
    } else if (action === "join") {
      // Join existing tenant by code
      const { data: tenant, error: lookupError } = await supabaseAdmin
        .from("tenants")
        .select("id")
        .eq("code", code)
        .single();

      if (lookupError || !tenant) {
        return new Response(
          JSON.stringify({ error: "Invalid organization code" }),
          {
            status: 404,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          }
        );
      }
      tenantId = tenant.id;
    } else {
      return new Response(JSON.stringify({ error: "Invalid action" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Create user record in public.users
    const displayName =
      user.user_metadata?.display_name ||
      user.email?.split("@")[0] ||
      "User";

    await supabaseAdmin.from("users").upsert({
      id: user.id,
      tenant_id: tenantId,
      email: user.email,
      display_name: displayName,
      is_org_admin: isOrgAdmin,
    });

    // Add tenant membership
    await supabaseAdmin.from("tenant_members").upsert({
      tenant_id: tenantId,
      user_id: user.id,
    });

    // Update user's app_metadata with org_id (sets JWT claim)
    await supabaseAdmin.auth.admin.updateUserById(user.id, {
      app_metadata: { org_id: tenantId },
    });

    return new Response(
      JSON.stringify({
        success: true,
        tenant_id: tenantId,
        is_org_admin: isOrgAdmin,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
