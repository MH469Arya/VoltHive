/// App-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'VoltHive';
  static const String appTagline = 'Energy as a Service';
  
  // API (for future use)
  static const String baseUrl = '';
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Debounce Duration
  static const Duration debounceDuration = Duration(milliseconds: 500);
}
