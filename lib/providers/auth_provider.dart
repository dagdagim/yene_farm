import 'package:flutter/foundation.dart';
import 'package:yene_farm/models/user_model.dart';
import 'package:yene_farm/services/supabase_service.dart';
import 'package:yene_farm/services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  // Initialize Supabase (call this early in app startup)
  Future<void> initSupabase({required String url, required String anonKey}) async {
    try {
      await SupabaseService.instance.init(url: url, anonKey: anonKey);
    } catch (e) {
      if (kDebugMode) print('Supabase init failed: $e');
    }
  }

  // Load saved session (if any) and map to current user
  Future<void> loadSavedSession() async {
    try {
      final token = StorageService().getAuthToken();
      final userMap = StorageService().getUserData();
      if (token != null && userMap != null) {
        _currentUser = UserModel.fromJson(Map<String, dynamic>.from(userMap));
        _isAuthenticated = true;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print('Failed to load saved session: $e');
    }
  }

  // Login using Supabase if available, otherwise fall back to mock
  Future<bool> login(String emailOrPhone, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final supa = SupabaseService.instance;
      if (supa.isInitialized) {
        // Prefer email login; if phone provided, caller should normalize
        final resp = await supa.signIn(email: emailOrPhone, password: password);
        if (resp != null && (resp.session != null)) {
          // Map to local user model minimally
          _currentUser = UserModel(
            id: resp.user?.id ?? 'unknown',
            name: resp.user?.userMetadata?['name'] ?? '',
            phone: resp.user?.userMetadata?['phone'] ?? '',
            email: resp.user?.email ?? emailOrPhone,
            role: resp.user?.userMetadata?['role'] ?? 'buyer',
            location: resp.user?.userMetadata?['location'] ?? '',
            language: resp.user?.userMetadata?['language'] ?? 'en',
            isVerified: true,
            rating: 0.0,
            totalTransactions: 0,
            createdAt: DateTime.now(),
          );
          _isAuthenticated = true;
          // persist session minimally
          try {
            final token = resp.session?.accessToken;
          if (token != null) await StorageService().saveAuthToken(token);
          await StorageService().saveUserData(_currentUser!.toJson());
          } catch (_) {}
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      if (kDebugMode) print('Supabase login failed: $e');
    }

    // Fallback mock behavior
    await Future.delayed(const Duration(seconds: 1));
    if (emailOrPhone.isNotEmpty && password.isNotEmpty) {
      _currentUser = UserModel(
        id: 'user_001',
        name: 'Alemayehu Tesfaye',
        phone: emailOrPhone,
        email: 'alemayehu@yenefarm.com',
        role: 'farmer',
        location: 'Debre Zeit',
        language: 'am',
        isVerified: true,
        rating: 4.5,
        totalTransactions: 12,
        createdAt: DateTime.now(),
      );
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Register using Supabase if available, otherwise fallback
  Future<bool> register(UserModel user, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final supa = SupabaseService.instance;
      if (supa.isInitialized) {
        final resp = await supa.signUp(email: user.email ?? '', password: password);
        if (resp != null && resp.user != null) {
          _currentUser = user;
          _isAuthenticated = true;
          // persist user for fallback
          try {
            await StorageService().saveUserData(_currentUser!.toJson());
          } catch (_) {}
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      if (kDebugMode) print('Supabase signUp failed: $e');
    }

    // Fallback mock register
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = user;
    _isAuthenticated = true;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    try {
      final supa = SupabaseService.instance;
      if (supa.isInitialized) await supa.signOut();
    } catch (e) {
      if (kDebugMode) print('Supabase signOut failed: $e');
    }

    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  void updateProfile(UserModel updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }
}