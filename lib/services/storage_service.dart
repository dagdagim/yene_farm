import 'package:hive/hive.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _appDataBox = 'appData';
  static const String _chatHistoryBox = 'chatHistory';
  static const String _userPreferencesBox = 'userPreferences';

  // App Data Keys
  static const String _authTokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static const String _languageKey = 'app_language';
  static const String _themeKey = 'app_theme';

  Future<void> init() async {
    await Hive.openBox(_appDataBox);
    await Hive.openBox(_chatHistoryBox);
    await Hive.openBox(_userPreferencesBox);
  }

  // Auth Token Management
  Future<void> saveAuthToken(String token) async {
    final box = Hive.box(_appDataBox);
    await box.put(_authTokenKey, token);
  }

  String? getAuthToken() {
    final box = Hive.box(_appDataBox);
    return box.get(_authTokenKey);
  }

  Future<void> clearAuthToken() async {
    final box = Hive.box(_appDataBox);
    await box.delete(_authTokenKey);
  }

  // User Data Management
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final box = Hive.box(_appDataBox);
    await box.put(_userDataKey, userData);
  }

  Map<String, dynamic>? getUserData() {
    final box = Hive.box(_appDataBox);
    return box.get(_userDataKey);
  }

  Future<void> clearUserData() async {
    final box = Hive.box(_appDataBox);
    await box.delete(_userDataKey);
  }

  // Language Preferences
  Future<void> saveLanguage(String languageCode) async {
    final box = Hive.box(_userPreferencesBox);
    await box.put(_languageKey, languageCode);
  }

  String getLanguage() {
    final box = Hive.box(_userPreferencesBox);
    return box.get(_languageKey, defaultValue: 'am');
  }

  // Theme Preferences
  Future<void> saveTheme(bool isDark) async {
    final box = Hive.box(_userPreferencesBox);
    await box.put(_themeKey, isDark);
  }

  bool getTheme() {
    final box = Hive.box(_userPreferencesBox);
    return box.get(_themeKey, defaultValue: false);
  }

  // Clear all data (logout)
  Future<void> clearAllData() async {
    await clearAuthToken();
    await clearUserData();
    
    final appDataBox = Hive.box(_appDataBox);
    final chatBox = Hive.box(_chatHistoryBox);
    
    await appDataBox.clear();
    await chatBox.clear();
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return getAuthToken() != null && getUserData() != null;
  }
}