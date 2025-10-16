import 'package:flutter/foundation.dart';

class PaymentProvider with ChangeNotifier {
  bool _isProcessing = false;
  String _selectedPaymentMethod = 'telebirr';
  
  bool get isProcessing => _isProcessing;
  String get selectedPaymentMethod => _selectedPaymentMethod;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'telebirr',
      'name': 'Telebirr',
      'icon': 'assets/icons/telebirr.png',
      'color': 0xFF2E7D32,
    },
    {
      'id': 'chapa',
      'name': 'Chapa',
      'icon': 'assets/icons/chapa.png',
      'color': 0xFF1976D2,
    },
    {
      'id': 'cbebirr',
      'name': 'CBE Birr',
      'icon': 'assets/icons/cbe.png',
      'color': 0xFFD32F2F,
    },
  ];

  List<Map<String, dynamic>> get paymentMethods => _paymentMethods;

  void setPaymentMethod(String method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  Future<bool> processPayment(double amount, String phoneNumber) async {
    _isProcessing = true;
    notifyListeners();

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 3));

    // Mock payment success (replace with real payment gateway integration)
    final success = phoneNumber.isNotEmpty && amount > 0;

    _isProcessing = false;
    notifyListeners();
    
    return success;
  }

  Future<bool> requestPayment(double amount, String merchantPhone) async {
    _isProcessing = true;
    notifyListeners();

    // Simulate payment request
    await Future.delayed(const Duration(seconds: 2));

    _isProcessing = false;
    notifyListeners();
    
    return true;
  }
}