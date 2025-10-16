import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yene_farm/providers/payment_provider.dart';
import 'package:yene_farm/providers/language_provider.dart';
import 'package:yene_farm/utils/colors.dart';
import 'package:yene_farm/utils/constants.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final String productName;
  final String farmerName;

  const PaymentScreen({
    Key? key,
    required this.amount,
    required this.productName,
    required this.farmerName,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _processPayment() async {
    if (_phoneController.text.isEmpty) {
      _showErrorDialog('Please enter your phone number');
      return;
    }

    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    final success = await paymentProvider.processPayment(widget.amount, _phoneController.text);
    
    if (success) {
      _showSuccessDialog(languageProvider);
    } else {
      _showErrorDialog('Payment failed. Please try again.');
    }
  }

  void _showSuccessDialog(LanguageProvider languageProvider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                size: 80,
                color: YeneFarmColors.successGreen,
              ),
              const SizedBox(height: 16),
              Text(
                languageProvider.currentLanguage == 'am' ? 'ክፍያ ተሳክቷል!' : 'Payment Successful!',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                languageProvider.currentLanguage == 'am'
                    ? 'ETB ${widget.amount} በተሳካ ሁኔታ ተከፍሏል'
                    : 'ETB ${widget.amount} has been paid successfully',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: YeneFarmColors.textMedium,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: YeneFarmColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    languageProvider.currentLanguage == 'am' ? 'እሺ' : 'OK',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        title: const Text(
          'Error',
          style: TextStyle(
            color: YeneFarmColors.warningRed,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(color: YeneFarmColors.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          languageProvider.currentLanguage == 'am' ? 'ክፍያ' : 'Payment',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: YeneFarmColors.primaryGreen,
      ),
      body: AnimatedBuilder(
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageProvider.currentLanguage == 'am' ? 'የትዕዛዝ ማጠቃለያ' : 'Order Summary',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryItem('Product', widget.productName),
                    _buildSummaryItem('Farmer', widget.farmerName),
                    _buildSummaryItem('Amount', 'ETB ${widget.amount}'),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          languageProvider.currentLanguage == 'am' ? 'ጠቅላላ' : 'Total',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'ETB ${widget.amount}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: YeneFarmColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Payment Methods
              Text(
                languageProvider.currentLanguage == 'am' ? 'የክፍያ ዘዴ' : 'Payment Method',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
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
                  children: paymentProvider.paymentMethods.map((method) {
                    final isSelected = paymentProvider.selectedPaymentMethod == method['id'];
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(method['color']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.payment_rounded,
                          color: Color(method['color']),
                        ),
                      ),
                      title: Text(method['name']),
                      trailing: isSelected
                          ? Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: YeneFarmColors.primaryGreen,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            )
                          : null,
                      onTap: () => paymentProvider.setPaymentMethod(method['id']),
                    );
                  }).toList(),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Phone Number Input
              Text(
                languageProvider.currentLanguage == 'am' ? 'ስልክ ቁጥር' : 'Phone Number',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: YeneFarmColors.primaryGreen.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    hintText: languageProvider.currentLanguage == 'am' ? '+251 ...' : '+251 ...',
                    prefixIcon: Container(
                      margin: const EdgeInsets.only(right: 12),
                      decoration: const BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: YeneFarmColors.border,
                            width: 1,
                          ),
                        ),
                      ),
                      child: const Icon(Icons.phone_rounded, color: YeneFarmColors.primaryGreen),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Pay Now Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: YeneFarmColors.primaryGreen.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: paymentProvider.isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: YeneFarmColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                    ),
                  ),
                  child: paymentProvider.isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          languageProvider.currentLanguage == 'am' 
                              ? 'ETB ${widget.amount} ክፈል' 
                              : 'Pay ETB ${widget.amount}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Security Notice
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: YeneFarmColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.security_rounded, color: YeneFarmColors.primaryGreen),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        languageProvider.currentLanguage == 'am'
                            ? 'ክፍያዎት በደህንነት ይጠበቃል'
                            : 'Your payment is securely processed',
                        style: const TextStyle(
                          color: YeneFarmColors.primaryGreen,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: YeneFarmColors.textMedium,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}