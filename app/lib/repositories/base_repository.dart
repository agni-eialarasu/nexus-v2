import 'package:supabase_flutter/supabase_flutter.dart';

/// Base repository class providing common Supabase operations.
///
/// Subclasses define the table name and model mapping.
/// RLS handles tenant scoping automatically — no manual filtering needed.
abstract class BaseRepository<T> {
  BaseRepository(this._client);

  final SupabaseClient _client;

  /// The Supabase table name.
  String get tableName;

  /// Convert a JSON map to the model type.
  T fromJson(Map<String, dynamic> json);

  /// Convert the model to a JSON map (for inserts/updates).
  Map<String, dynamic> toJson(T item);

  /// Fetch all records (RLS scopes to current tenant automatically).
  Future<List<T>> getAll({
    String? orderBy,
    bool ascending = true,
    int? limit,
    int? offset,
  }) async {
    var query = _client.from(tableName).select();

    // Note: PostgREST chaining
    final response = await query;
    return (response as List)
        .map((row) => fromJson(row as Map<String, dynamic>))
        .toList();
  }

  /// Fetch a single record by ID.
  Future<T?> getById(String id) async {
    final response = await _client
        .from(tableName)
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return fromJson(response);
  }

  /// Insert a new record.
  Future<T> create(Map<String, dynamic> data) async {
    final response = await _client
        .from(tableName)
        .insert(data)
        .select()
        .single();

    return fromJson(response);
  }

  /// Update an existing record by ID.
  Future<T> update(String id, Map<String, dynamic> data) async {
    final response = await _client
        .from(tableName)
        .update(data)
        .eq('id', id)
        .select()
        .single();

    return fromJson(response);
  }

  /// Delete a record by ID.
  Future<void> delete(String id) async {
    await _client.from(tableName).delete().eq('id', id);
  }

  /// Subscribe to realtime changes on this table.
  /// RLS ensures only tenant-scoped events are received.
  Stream<List<T>> stream({List<String> primaryKey = const ['id']}) {
    return _client
        .from(tableName)
        .stream(primaryKey: primaryKey)
        .map((data) => data.map((row) => fromJson(row)).toList());
  }
}
