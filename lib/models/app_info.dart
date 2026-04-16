class AppInfo {
  final String appName;
  final String description;
  final String? logoUrl;
  final String? whatsapp;
  final String? instagram;

  AppInfo({
    required this.appName,
    required this.description,
    this.logoUrl,
    this.whatsapp,
    this.instagram,
  });

  factory AppInfo.fromJson(Map<String, dynamic> json) => AppInfo(
        appName: json['app_name'] as String? ?? 'Paraiba Lanches',
        description: json['app_description'] as String? ?? '',
        logoUrl: json['app_logo_url'] as String?,
        whatsapp: json['app_contact_whatsapp'] as String?,
        instagram: json['app_contact_instagram'] as String?,
      );
}
