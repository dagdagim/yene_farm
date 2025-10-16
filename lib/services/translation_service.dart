class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  Future<void> loadTranslations() async {
    // For now, we'll use the translations from LanguageProvider
    // In a real app, you would load from JSON files
    await Future.delayed(const Duration(milliseconds: 100));
  }
}