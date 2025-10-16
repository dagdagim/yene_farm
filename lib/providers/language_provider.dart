import 'package:flutter/material.dart';

class LanguageProvider with ChangeNotifier {
  Locale _currentLocale = const Locale('am', 'ET');
  Map<String, String> _translations = {};

  Locale get currentLocale => _currentLocale;
  String get currentLanguage => _currentLocale.languageCode;

  void setLanguage(String languageCode) {
    _currentLocale = Locale(languageCode);
    loadTranslations(languageCode);
    notifyListeners();
  }

  void loadTranslations(String languageCode) {
    if (languageCode == 'am') {
      _translations = {
        'welcome': 'እንኳን ደህና መጡ',
        'marketplace': 'ገበያ',
        'prices': 'ዋጋዎች',
        'ai_assistant': 'AI አማካሪ',
        'profile': 'መገለጫ',
        'login': 'ግባ',
        'register': 'ይመዝገቡ',
        'phone_number': 'ስልክ ቁጥር',
        'password': 'የይለፍ ቃል',
        'confirm_password': 'የይለፍ ቃል አረጋግጥ',
        'full_name': 'ሙሉ ስም',
        'email': 'ኢሜይል',
        'role': 'ሚና',
        'region': 'ክልል',
        'language': 'ቋንቋ',
        'farmer': 'ገበሬ',
        'buyer': 'ገዢ',
        'driver': 'ሹፌር',
        'continue': 'ቀጥል',
        'forgot_password': 'የይለፍ ቃል ረሳኽ?',
        'dont_have_account': 'መለያ የሎትም?',
        'already_have_account': 'የተመዘገቡት ነዎት?',
        'create_account': 'አዲስ መለያ ይፍጠሩ',
        'welcome_back': 'እንኳን ደህና መጡ!',
        'sign_in_to_continue': 'ለመቀጠል ወደ መለያዎ ይግቡ',
      };
    } else {
      _translations = {
        'welcome': 'Welcome',
        'marketplace': 'Marketplace',
        'prices': 'Prices',
        'ai_assistant': 'AI Assistant',
        'profile': 'Profile',
        'login': 'Login',
        'register': 'Register',
        'phone_number': 'Phone Number',
        'password': 'Password',
        'confirm_password': 'Confirm Password',
        'full_name': 'Full Name',
        'email': 'Email',
        'role': 'Role',
        'region': 'Region',
        'language': 'Language',
        'farmer': 'Farmer',
        'buyer': 'Buyer',
        'driver': 'Driver',
        'continue': 'Continue',
        'forgot_password': 'Forgot Password?',
        'dont_have_account': 'Don\'t have an account?',
        'already_have_account': 'Already have an account?',
        'create_account': 'Create Account',
        'welcome_back': 'Welcome Back!',
        'sign_in_to_continue': 'Sign in to continue',
      };
    }
  }

  String translate(String key) {
    return _translations[key] ?? key;
  }
}