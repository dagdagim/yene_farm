import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yene_farm/providers/auth_provider.dart';
import 'package:yene_farm/providers/language_provider.dart';
import 'package:yene_farm/screens/shared/chat_bot_screen.dart';
import 'package:yene_farm/screens/shared/price_tracker_screen.dart';
import 'package:yene_farm/screens/shared/profile_screen.dart';
import 'package:yene_farm/screens/farmer/farmer_dashboard.dart';
import 'package:yene_farm/screens/buyer/marketplace_screen.dart';
import 'package:yene_farm/utils/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Widget> _farmerScreens = [
    const FarmerDashboard(),
    const MarketplaceScreen(),
    const PriceTrackerScreen(),
    const ChatBotScreen(),
    const ProfileScreen(),
  ];

  final List<Widget> _buyerScreens = [
    const MarketplaceScreen(),
    const PriceTrackerScreen(),
    const ChatBotScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Widget> get _currentScreens {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.currentUser?.role == 'farmer' 
        ? _farmerScreens 
        : _buyerScreens;
  }

  List<BottomNavigationBarItem> get _farmerNavItems {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    return [
      BottomNavigationBarItem(
        icon: _buildAnimatedIcon(Icons.dashboard_rounded, 0),
        activeIcon: _buildActiveIcon(Icons.dashboard_rounded, 0),
        label: languageProvider.currentLanguage == 'am' ? 'መግቢያ' : 'Dashboard',
      ),
      BottomNavigationBarItem(
        icon: _buildAnimatedIcon(Icons.shopping_cart_rounded, 1),
        activeIcon: _buildActiveIcon(Icons.shopping_cart_rounded, 1),
        label: languageProvider.currentLanguage == 'am' ? 'ገበያ' : 'Market',
      ),
      BottomNavigationBarItem(
        icon: _buildAnimatedIcon(Icons.analytics_rounded, 2),
        activeIcon: _buildActiveIcon(Icons.analytics_rounded, 2),
        label: languageProvider.currentLanguage == 'am' ? 'ዋጋዎች' : 'Prices',
      ),
      BottomNavigationBarItem(
        icon: _buildAnimatedIcon(Icons.chat_rounded, 3),
        activeIcon: _buildActiveIcon(Icons.chat_rounded, 3),
        label: languageProvider.currentLanguage == 'am' ? 'AI አማካሪ' : 'AI Assistant',
      ),
      BottomNavigationBarItem(
        icon: _buildAnimatedIcon(Icons.person_rounded, 4),
        activeIcon: _buildActiveIcon(Icons.person_rounded, 4),
        label: languageProvider.currentLanguage == 'am' ? 'መገለጫ' : 'Profile',
      ),
    ];
  }

  List<BottomNavigationBarItem> get _buyerNavItems {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    return [
      BottomNavigationBarItem(
        icon: _buildAnimatedIcon(Icons.shopping_cart_rounded, 0),
        activeIcon: _buildActiveIcon(Icons.shopping_cart_rounded, 0),
        label: languageProvider.currentLanguage == 'am' ? 'ገበያ' : 'Market',
      ),
      BottomNavigationBarItem(
        icon: _buildAnimatedIcon(Icons.analytics_rounded, 1),
        activeIcon: _buildActiveIcon(Icons.analytics_rounded, 1),
        label: languageProvider.currentLanguage == 'am' ? 'ዋጋዎች' : 'Prices',
      ),
      BottomNavigationBarItem(
        icon: _buildAnimatedIcon(Icons.chat_rounded, 2),
        activeIcon: _buildActiveIcon(Icons.chat_rounded, 2),
        label: languageProvider.currentLanguage == 'am' ? 'AI አማካሪ' : 'AI Assistant',
      ),
      BottomNavigationBarItem(
        icon: _buildAnimatedIcon(Icons.person_rounded, 3),
        activeIcon: _buildActiveIcon(Icons.person_rounded, 3),
        label: languageProvider.currentLanguage == 'am' ? 'መገለጫ' : 'Profile',
      ),
    ];
  }

  List<BottomNavigationBarItem> get _currentNavItems {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.currentUser?.role == 'farmer' 
        ? _farmerNavItems 
        : _buyerNavItems;
  }

  Widget _buildAnimatedIcon(IconData icon, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _currentIndex == index 
            ? YeneFarmColors.primaryGreen.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: 24,
        color: _currentIndex == index 
            ? YeneFarmColors.primaryGreen 
            : YeneFarmColors.textLight,
      ),
    );
  }

  Widget _buildActiveIcon(IconData icon, int index) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: YeneFarmColors.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: YeneFarmColors.primaryGreen.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 24,
        color: Colors.white,
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _currentScreens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: List.generate(
                _currentNavItems.length,
                (index) => Expanded(
                  child: GestureDetector(
                    onTap: () => _onTabTapped(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: _currentIndex == index 
                            ? YeneFarmColors.primaryGreen.withOpacity(0.05)
                            : Colors.transparent,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _currentIndex == index
                              ? _currentNavItems[index].activeIcon
                              : _currentNavItems[index].icon,
                          const SizedBox(height: 4),
                          Text(
                            _currentNavItems[index].label!,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: _currentIndex == index 
                                  ? FontWeight.w600 
                                  : FontWeight.normal,
                              color: _currentIndex == index
                                  ? YeneFarmColors.primaryGreen
                                  : YeneFarmColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}