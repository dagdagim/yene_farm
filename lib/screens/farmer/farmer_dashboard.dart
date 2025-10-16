import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yene_farm/providers/auth_provider.dart';
import 'package:yene_farm/providers/language_provider.dart';
import 'package:yene_farm/providers/marketplace_provider.dart';
import 'package:yene_farm/screens/farmer/add_product_screen.dart';
import 'package:yene_farm/screens/farmer/my_products_screen.dart';
import 'package:yene_farm/utils/colors.dart';
import 'package:yene_farm/utils/constants.dart';

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({super.key});

  @override
  _FarmerDashboardState createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MarketplaceProvider>(context, listen: false).loadProducts();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final marketplaceProvider = Provider.of<MarketplaceProvider>(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: Scaffold(
        backgroundColor: YeneFarmColors.background,
        body: CustomScrollView(
          slivers: [
            // App Bar with Gradient
            SliverAppBar(
              backgroundColor: YeneFarmColors.primaryGreen,
              expandedHeight: 200,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: YeneFarmColors.primaryGradient,
                  ),
                  child: Stack(
                    children: [
                      // Background Pattern
                      Positioned(
                        right: -50,
                        top: -50,
                        child: Icon(
                          Icons.agriculture,
                          size: 200,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.all(AppConstants.defaultPadding),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'YeneFarm',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              languageProvider.currentLanguage == 'am' 
                                  ? 'የእርስዎ እርሻ ማንገብገቢያ'
                                  : 'Your Farming Companion',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_rounded, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),

            // Dashboard Content
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    children: [
                      // Welcome Card
                      _buildWelcomeCard(context, authProvider, languageProvider),
                      
                      const SizedBox(height: 24),
                      
                      // Quick Actions
                      _buildQuickActions(context, languageProvider),
                      
                      const SizedBox(height: 24),
                      
                      // Market Prices
                      _buildMarketPrices(context, languageProvider),
                      
                      const SizedBox(height: 24),
                      
                      // Recent Activity
                      _buildRecentActivity(context, languageProvider),
                    ],
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, AuthProvider authProvider, LanguageProvider languageProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: YeneFarmColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: YeneFarmColors.primaryGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 30,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Welcome Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  languageProvider.currentLanguage == 'am' ? 'እንኳን ደህና መጡ!' : 'Welcome Back!',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  authProvider.currentUser?.name ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, size: 14, color: Colors.yellow),
                      SizedBox(width: 4),
                      Text(
                        '4.5 ★',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, LanguageProvider languageProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          languageProvider.currentLanguage == 'am' ? 'ፈጣን እርምጃዎች' : 'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildActionCard(
              context,
              Icons.add_circle_rounded,
              languageProvider.currentLanguage == 'am' ? 'ምርት ይጨምሩ' : 'Add Product',
              YeneFarmColors.primaryGreen,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddProductScreen()),
                );
              },
            ),
            _buildActionCard(
              context,
              Icons.inventory_2_rounded,
              languageProvider.currentLanguage == 'am' ? 'ምርቶቼ' : 'My Products',
              YeneFarmColors.skyBlue,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyProductsScreen()),
                );
              },
            ),
            _buildActionCard(
              context,
              Icons.analytics_rounded,
              languageProvider.currentLanguage == 'am' ? 'ትንታኔ' : 'Analytics',
              YeneFarmColors.accentYellow,
              () {},
            ),
            _buildActionCard(
              context,
              Icons.account_balance_wallet_rounded,
              languageProvider.currentLanguage == 'am' ? 'ክፍያዎች' : 'Payments',
              YeneFarmColors.soilBrown,
              () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, IconData icon, String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                icon,
                size: 30,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: YeneFarmColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketPrices(BuildContext context, LanguageProvider languageProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up_rounded, color: YeneFarmColors.primaryGreen),
              const SizedBox(width: 8),
              Text(
                languageProvider.currentLanguage == 'am' ? 'የዛሬ የገበያ ዋጋዎች' : 'Today\'s Market Prices',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPriceItem('🌾', 'Teff', 'ETB 85/kg', '+5%', true),
          _buildPriceItem('☕', 'Coffee', 'ETB 120/kg', '0%', false),
          _buildPriceItem('🌽', 'Maize', 'ETB 45/kg', '-2%', false),
          _buildPriceItem('🥔', 'Potato', 'ETB 28/kg', '+3%', true),
        ],
      ),
    );
  }

  Widget _buildPriceItem(String emoji, String crop, String price, String change, bool isPositive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(crop, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isPositive 
                  ? YeneFarmColors.successGreen.withOpacity(0.1) 
                  : YeneFarmColors.warningRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              change,
              style: TextStyle(
                color: isPositive ? YeneFarmColors.successGreen : YeneFarmColors.warningRed,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, LanguageProvider languageProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            languageProvider.currentLanguage == 'am' ? 'የቅርብ ተግባራት' : 'Recent Activity',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildActivityItem('Sold 50kg Teff to Restaurant ABC', '2 hours ago', Icons.shopping_cart_rounded),
          _buildActivityItem('New buyer inquiry for Coffee', '5 hours ago', Icons.chat_rounded),
          _buildActivityItem('Payment received for Maize order', '1 day ago', Icons.payment_rounded),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String activity, String time, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: YeneFarmColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              size: 20,
              color: YeneFarmColors.primaryGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: const TextStyle(
                    color: YeneFarmColors.textLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}