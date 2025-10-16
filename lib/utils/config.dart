class Config {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000',
  );
  
  static const String socketUrl = String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: 'http://localhost:5000',
  );
  
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
}