/// Tenant (organization) model.
class Tenant {
  const Tenant({
    required this.id,
    required this.slug,
    required this.name,
    required this.code,
    this.createdAt,
  });

  final String id;
  final String slug;
  final String name;
  final String code;
  final DateTime? createdAt;

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      code: json['code'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'slug': slug,
        'name': name,
        'code': code,
      };
}
