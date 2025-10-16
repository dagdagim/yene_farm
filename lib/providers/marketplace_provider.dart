import 'package:flutter/foundation.dart';
import 'package:yene_farm/models/product_model.dart';

class MarketplaceProvider with ChangeNotifier {
  List<ProductModel> _products = [];
  List<ProductModel> _featuredProducts = [];
  bool _isLoading = false;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  List<ProductModel> get products => _products;
  List<ProductModel> get featuredProducts => _featuredProducts;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<ProductModel> get filteredProducts {
    return _products.where((product) {
      final matchesCategory = _selectedCategory == 'All' || 
          product.category == _selectedCategory;
      final matchesSearch = product.name.toLowerCase()
          .contains(_searchQuery.toLowerCase()) ||
          product.description.toLowerCase()
          .contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock data
    _products = [
      ProductModel(
        id: '1',
        farmerId: 'farmer1',
        farmerName: 'Alemayehu Tesfaye',
        name: 'Teff',
        category: 'Cereals',
        price: 85.0,
        quantity: 500,
        unit: 'kg',
        images: ['assets/images/teff.jpg'],
        description: 'High quality white teff, freshly harvested from Debre Zeit. Organic farming methods used.',
        harvestDate: DateTime.now().subtract(const Duration(days: 7)),
        location: 'Debre Zeit',
        isOrganic: true,
        farmerRating: 4.5,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ProductModel(
        id: '2',
        farmerId: 'farmer2',
        farmerName: 'Meron Abebe',
        name: 'Coffee',
        category: 'Coffee',
        price: 120.0,
        quantity: 200,
        unit: 'kg',
        images: ['assets/images/coffee.jpg'],
        description: 'Premium Yirgacheffe coffee beans, sun-dried and carefully processed.',
        harvestDate: DateTime.now().subtract(const Duration(days: 14)),
        location: 'Yirgacheffe',
        isOrganic: true,
        farmerRating: 4.8,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ProductModel(
        id: '3',
        farmerId: 'farmer3',
        farmerName: 'Kebede Mulu',
        name: 'Maize',
        category: 'Cereals',
        price: 45.0,
        quantity: 1000,
        unit: 'kg',
        images: ['assets/images/maize.jpg'],
        description: 'Fresh yellow maize, perfect for consumption and animal feed.',
        harvestDate: DateTime.now().subtract(const Duration(days: 5)),
        location: 'Jimma',
        farmerRating: 4.2,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];

    _featuredProducts = _products.take(2).toList();
    _isLoading = false;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addProduct(ProductModel product) async {
    _products.add(product);
    notifyListeners();
  }
}