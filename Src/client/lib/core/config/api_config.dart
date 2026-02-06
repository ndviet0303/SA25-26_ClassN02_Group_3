/// API Configuration for microservices
class ApiConfig {
  // Base URLs for different environments
  static const String _devBaseUrl = 'http://192.168.1.20:8080';
  static const String _prodBaseUrl = 'https://api.nozie.app';
  
  // Current environment
  static const bool isDev = true;
  
  // Base URL based on environment
  static String get baseUrl => isDev ? _devBaseUrl : _prodBaseUrl;
  
  // Service URLs - Following API Gateway routing patterns
  static String get authServiceUrl => '$baseUrl/api/auth';
  static String get movieServiceUrl => '$baseUrl/api'; // Base path, endpoints add /movies
  static String get customerServiceUrl => '$baseUrl/api/customers';
  static String get subscriptionServiceUrl => '$baseUrl/api/subscriptions';
  static String get notificationServiceUrl => '$baseUrl/api/notifications';
  
  // Legacy URLs (for backward compatibility)
  static String get identityServiceUrl => authServiceUrl;
  static String get paymentServiceUrl => subscriptionServiceUrl;
  static String get wishlistServiceUrl => customerServiceUrl;
  static String get purchaseServiceUrl => subscriptionServiceUrl;
  static String get ratingServiceUrl => movieServiceUrl;
  static String get searchServiceUrl => movieServiceUrl;
  static String get storageServiceUrl => '$baseUrl/api/storage';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}
