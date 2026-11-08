/// Centralized Configuration for Cloudflare and Firebase Integration
class AppConfig {
  /// Cloudflare Worker Edge API URL
  static const String workerBaseUrl = 'https://prm-project.agrilog.workers.dev';

  /// Cloudflare R2 Storage Endpoint
  static const String r2StorageEndpoint =
      'https://d83b40f9ba48c1a0952568b9620ee62f.r2.cloudflarestorage.com/prm-project';

  /// Cloudflare R2 Bucket Name
  static const String r2BucketName = 'prm-project';

  /// Cloudflare Account ID
  static const String r2AccountId = 'd83b40f9ba48c1a0952568b9620ee62f';

  /// Firebase Project ID
  static const String firebaseProjectId = 'prm-projects';

  /// Firebase Project Number
  static const String firebaseProjectNumber = '213546833802';

  /// Firebase Storage Bucket
  static const String firebaseStorageBucket = 'prm-projects.firebasestorage.app';
}
