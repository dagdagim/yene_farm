import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._();

  static final SupabaseService instance = SupabaseService._();

  SupabaseClient? client;

  bool get isInitialized => client != null;

  Future<void> init({required String url, required String anonKey}) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      // Optionally set debug mode when developing
      debug: false,
    );
    client = Supabase.instance.client;
  }

  // Convenience getters
  dynamic get currentUser => client?.auth.currentUser;

  Stream<dynamic>? get onAuthStateChange => client?.auth.onAuthStateChange;

  Future<dynamic> signUp({required String email, required String password}) async {
    return await client!.auth.signUp(email: email, password: password);
  }

  Future<dynamic> signIn({required String email, required String password}) async {
    // Using the modern signInWithPassword API
    return await client!.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await client!.auth.signOut();
  }
}
