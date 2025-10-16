import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:yene_farm/providers/auth_provider.dart';
import 'package:yene_farm/providers/marketplace_provider.dart';
import 'package:yene_farm/providers/language_provider.dart';
import 'package:yene_farm/providers/chatbot_provider.dart';
import 'package:yene_farm/screens/splash_screen.dart';
import 'package:yene_farm/services/storage_service.dart';
import 'package:yene_farm/services/translation_service.dart';
import 'package:yene_farm/utils/colors.dart';
import 'package:yene_farm/utils/constants.dart';
import 'package:yene_farm/services/supabase_service.dart';
import 'package:yene_farm/screens/auth/signin.dart';
import 'package:yene_farm/screens/auth/signup.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await StorageService().init();
  await TranslationService().loadTranslations();
  // Load environment variables from .env (optional)
  try {
    await dotenv.load();
  } catch (_) {
    // ignore missing .env
  }

  // Initialize Supabase if configured either via .env or AppConstants
  final supaUrl = dotenv.isInitialized ? (dotenv.env['SUPABASE_URL'] ?? AppConstants.supabaseUrl) : AppConstants.supabaseUrl;
  final supaKey = dotenv.isInitialized ? (dotenv.env['SUPABASE_ANON_KEY'] ?? AppConstants.supabaseAnonKey) : AppConstants.supabaseAnonKey;
  try {
    if (supaUrl.isNotEmpty && supaKey.isNotEmpty) {
      await SupabaseService.instance.init(url: supaUrl, anonKey: supaKey);
    }
  } catch (e) {
    // Ignore initialization errors here; AuthProvider will fallback to mock behavior
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) {
          final p = AuthProvider();
          // attempt to load saved session immediately
          p.loadSavedSession();
          return p;
        }),
        ChangeNotifierProvider(create: (_) => MarketplaceProvider()),
        ChangeNotifierProvider(create: (_) => ChatBotProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            title: 'YeneFarm',
            theme: ThemeData(
              // Color Scheme
              primaryColor: YeneFarmColors.primaryGreen,
              primarySwatch: Colors.green,
              scaffoldBackgroundColor: YeneFarmColors.background,
              cardColor: YeneFarmColors.cardBackground,
              
              // Typography
              fontFamily: 'Inter',
              textTheme: const TextTheme(
                displayLarge: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: YeneFarmColors.textDark,
                ),
                displayMedium: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: YeneFarmColors.textDark,
                ),
                displaySmall: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: YeneFarmColors.textDark,
                ),
                titleLarge: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: YeneFarmColors.textDark,
                ),
                titleMedium: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: YeneFarmColors.textDark,
                ),
                bodyLarge: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: YeneFarmColors.textDark,
                ),
                bodyMedium: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: YeneFarmColors.textMedium,
                ),
                bodySmall: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: YeneFarmColors.textLight,
                ),
              ),
              
              // App Bar Theme
              appBarTheme: const AppBarTheme(
                backgroundColor: YeneFarmColors.primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
                titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              
              // Input Decoration Theme
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                  borderSide: const BorderSide(color: YeneFarmColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                  borderSide: const BorderSide(color: YeneFarmColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                  borderSide: const BorderSide(color: YeneFarmColors.primaryGreen),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                  borderSide: const BorderSide(color: YeneFarmColors.warningRed),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              
              // Button Themes
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: YeneFarmColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  elevation: 2,
                ),
              ),
              
              // Card/Dialog theme entries removed to avoid SDK type mismatch. Re-add with correct types if needed.
            ),
            darkTheme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: const Color(0xFF121212),
              cardColor: const Color(0xFF1E1E1E),
              appBarTheme: const AppBarTheme(
                backgroundColor: YeneFarmColors.primaryDarkGreen,
                foregroundColor: Colors.white,
              ),
            ),
            locale: languageProvider.currentLocale,
            supportedLocales: const [
              Locale('am', 'ET'), // Amharic
              Locale('en', 'US'), // English
              Locale('om', 'ET'), // Afan Oromo
              Locale('ti', 'ET'), // Tigrigna
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const SplashScreen(),
            routes: {
              '/signin': (context) => const SignInPage(),
              '/signup': (context) => const SignUpPage(),
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}