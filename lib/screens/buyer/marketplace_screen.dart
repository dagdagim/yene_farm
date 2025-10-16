import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yene_farm/providers/marketplace_provider.dart';
import 'package:yene_farm/providers/language_provider.dart';
import 'package:yene_farm/widgets/product_card.dart';
import 'package:yene_farm/models/product_model.dart';
import 'package:yene_farm/utils/colors.dart';
import 'package:yene_farm/utils/constants.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  _MarketplaceScreenState createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    
    // Load products
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MarketplaceProvider>(context, listen: false).loadProducts();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showSearchDialog(BuildContext context) {
    final marketplaceProvider = Provider.of<MarketplaceProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                languageProvider.currentLanguage == 'am' ? 'ፈልግ' : 'Search',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: (value) {
                  marketplaceProvider.setSearchQuery(value);
                },
                decoration: InputDecoration(
                  hintText: languageProvider.currentLanguage == 'am' 
                      ? 'ምርት ይፈልጉ...' 
                      : 'Search products...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(languageProvider.currentLanguage == 'am' ? 'አጥፋ' : 'Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: YeneFarmColors.primaryGreen,
                      ),
                      child: Text(languageProvider.currentLanguage == 'am' ? 'ፈልግ' : 'Search'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final marketplaceProvider = Provider.of<MarketplaceProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: YeneFarmColors.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // App Bar
              SliverAppBar(
                backgroundColor: YeneFarmColors.primaryGreen,
                expandedHeight: 120,
                floating: true,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    languageProvider.currentLanguage == 'am' ? 'ገበያ' : 'Marketplace',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: YeneFarmColors.primaryGradient,
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search_rounded, color: Colors.white),
                    onPressed: () => _showSearchDialog(context),
                  ),
                ],
              ),

              // Categories Sliver
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Info
                      if (marketplaceProvider.searchQuery.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Text(
                                languageProvider.currentLanguage == 'am' 
                                    ? 'የተፈለገው: "${marketplaceProvider.searchQuery}"'
                                    : 'Search: "${marketplaceProvider.searchQuery}"',
                                style: const TextStyle(
                                  color: YeneFarmColors.primaryGreen,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  marketplaceProvider.setSearchQuery('');
                                },
                                child: Text(
                                  languageProvider.currentLanguage == 'am' ? 'አጥፋ' : 'Clear',
                                  style: const TextStyle(
                                    color: YeneFarmColors.warningRed,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Categories
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: AppConstants.cropCategories.map((category) {
                            final isSelected = marketplaceProvider.selectedCategory == category;
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(category),
                                selected: isSelected,
                                onSelected: (selected) {
                                  marketplaceProvider.setCategory(selected ? category : 'All');
                                },
                                selectedColor: YeneFarmColors.primaryGreen,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : YeneFarmColors.textDark,
                                  fontWeight: FontWeight.w500,
                                ),
                                backgroundColor: Colors.white,
                                shape: StadiumBorder(
                                  side: BorderSide(
                                    color: isSelected 
                                        ? YeneFarmColors.primaryGreen 
                                        : YeneFarmColors.border,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: marketplaceProvider.isLoading
              ? _buildLoadingState()
              : marketplaceProvider.filteredProducts.isEmpty
                  ? _buildEmptyState(languageProvider)
                  : _buildProductsList(marketplaceProvider),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
              // Shimmer for image
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppConstants.cardBorderRadius),
                    topRight: Radius.circular(AppConstants.cardBorderRadius),
                  ),
                ),
              ),
              // Shimmer for content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 20,
                      width: 150,
                      color: Colors.grey[200],
                      margin: const EdgeInsets.only(bottom: 8),
                    ),
                    Container(
                      height: 16,
                      width: double.infinity,
                      color: Colors.grey[200],
                      margin: const EdgeInsets.only(bottom: 8),
                    ),
                    Container(
                      height: 16,
                      width: 200,
                      color: Colors.grey[200],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(LanguageProvider languageProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 80,
            color: YeneFarmColors.textLight,
          ),
          const SizedBox(height: 20),
          Text(
            languageProvider.currentLanguage == 'am' 
                ? 'ምንም ምርት አልተገኘም'
                : 'No products found',
            style: const TextStyle(
              fontSize: 18,
              color: YeneFarmColors.textMedium,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            languageProvider.currentLanguage == 'am'
                ? 'የተለየ ፍለጋ ይሞክሩ'
                : 'Try a different search',
            style: const TextStyle(
              color: YeneFarmColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(MarketplaceProvider marketplaceProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: marketplaceProvider.filteredProducts.length,
      itemBuilder: (context, index) {
        final product = marketplaceProvider.filteredProducts[index];
        return ProductCard(
          product: product,
          showActions: true,
          onTap: () {
            _showProductDetails(context, product);
          },
        );
      },
    );
  }

  void _showProductDetails(BuildContext context, ProductModel product) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Drag Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: YeneFarmColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: ProductCard(
                      product: product,
                      showActions: true,
                    ),
                  ),
                ),
              ),
              // Action Buttons
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: YeneFarmColors.primaryGreen),
                        ),
                        child: Text(
                          languageProvider.currentLanguage == 'am' ? 'ዝጋ' : 'Close',
                          style: const TextStyle(color: YeneFarmColors.primaryGreen),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: YeneFarmColors.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          languageProvider.currentLanguage == 'am' ? 'ይግዙ' : 'Buy Now',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}