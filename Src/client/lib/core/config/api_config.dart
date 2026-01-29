/// API Configuration for microservices
class ApiConfig {
  // Base URLs for different environments
  static const String _devBaseUrl = 'http://localhost:8080';
  static const String _prodBaseUrl = 'https://api.nozie.app';
  
  // Current environment
  static const bool isDev = true;
  
  // Base URL based on environment
  static String get baseUrl => isDev ? _devBaseUrl : _prodBaseUrl;
  
  // Service URLs
  static String get identityServiceUrl => '$baseUrl/identity';
  static String get movieServiceUrl => '$baseUrl/movies';
  static String get paymentServiceUrl => '$baseUrl/payments';
  static String get notificationServiceUrl => '$baseUrl/notifications';
  static String get wishlistServiceUrl => '$baseUrl/wishlists';
  static String get purchaseServiceUrl => '$baseUrl/purchases';
  static String get ratingServiceUrl => '$baseUrl/ratings';
  static String get searchServiceUrl => '$baseUrl/search';
  static String get storageServiceUrl => '$baseUrl/storage';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}
