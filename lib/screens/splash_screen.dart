import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yene_farm/providers/auth_provider.dart';
import 'package:yene_farm/providers/language_provider.dart';
import 'package:yene_farm/screens/auth/login_screen.dart';
import 'package:yene_farm/screens/home_screen.dart';
import 'package:yene_farm/utils/colors.dart';
import 'package:yene_farm/utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();
  }

  Future<void> _initializeApp() async {
    // Initialize app data
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    // Load language preferences
    languageProvider.loadTranslations('am');
    
    // Wait for animations to complete
    await Future.delayed(const Duration(milliseconds: 2000));
    
    // Check if user is authenticated
    if (authProvider.isAuthenticated) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: AppConstants.pageTransitionDuration,
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: AppConstants.pageTransitionDuration,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YeneFarmColors.primaryGreen,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: YeneFarmColors.primaryGradient,
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo Container
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Background Pattern
                      Positioned(
                        right: -10,
                        bottom: -10,
                        child: Icon(
                          Icons.agriculture,
                          size: 60,
                          color: YeneFarmColors.primaryGreen.withOpacity(0.1),
                        ),
                      ),
                      // Main Icon
                      const Center(
                        child: Icon(
                          Icons.agriculture,
                          size: 60,
                          color: YeneFarmColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // App Name with Typing Effect
                Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Tagline
                Text(
                  AppConstants.appTagline,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.5,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Amharic Tagline
                Text(
                  AppConstants.appTaglineAmharic,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w300,
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Animated Progress Indicator
                Container(
                  width: 200,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Stack(
                    children: [
                      // Progress Bar
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 2000),
                        width: 200 * _controller.value,
                        decoration: BoxDecoration(
                          gradient: YeneFarmColors.sunsetGradient,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Loading Text with Pulsing Animation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 1000),
                  child: Text(
                    'Loading...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7 + (0.3 * _controller.value)),
                      fontSize: 14,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Features Icons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFeatureIcon(Icons.shopping_cart, 'Market'),
                    const SizedBox(width: 20),
                    _buildFeatureIcon(Icons.analytics, 'Prices'),
                    const SizedBox(width: 20),
                    _buildFeatureIcon(Icons.chat, 'AI Help'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}