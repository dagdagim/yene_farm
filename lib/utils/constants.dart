class AppConstants {
  // App Info
  static const String appName = 'YeneFarm';
  static const String appTagline = 'Empowering Ethiopian Farmers';
  static const String appTaglineAmharic = 'የኢትዮጵያ ገበሬዎች ማንገብገቢያ';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'https://api.yenefarm.com';
  // Supabase (fill these with your Supabase project's values or set via env)
  static const String supabaseUrl = '';
  static const String supabaseAnonKey = '';
  static const String productsEndpoint = '/api/products';
  static const String usersEndpoint = '/api/users';
  static const String ordersEndpoint = '/api/orders';
  static const String pricesEndpoint = '/api/prices';
  static const String chatEndpoint = '/api/chat';
  
  // Local Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String languageKey = 'app_language';
  static const String themeKey = 'app_theme';
  
  // Crop Categories
  static const List<String> cropCategories = [
    'All',
    'Cereals',
    'Vegetables',
    'Fruits',
    'Coffee',
    'Spices',
    'Legumes',
    'Oil Seeds',
    'Root Crops',
    'Cash Crops'
  ];
  
  // Ethiopian Regions
  static const List<String> ethiopianRegions = [
    'Addis Ababa',
    'Afar',
    'Amhara',
    'Benishangul-Gumuz',
    'Dire Dawa',
    'Gambela',
    'Harari',
    'Oromia',
    'Sidama',
    'Somali',
    'SNNPR',
    'Tigray',
  ];
  
  // Measurement Units
  static const List<String> measurementUnits = [
    'kg',
    'quintal',
    'ton',
    'piece',
    'bundle',
    'liter',
    'hectare'
  ];
  
  // App Settings
  static const double defaultBorderRadius = 16.0;
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 24.0;
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 16.0;
  
  // Animation Durations
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
  static const Duration buttonPressDuration = Duration(milliseconds: 100);
  static const Duration shimmerDuration = Duration(milliseconds: 1500);
}