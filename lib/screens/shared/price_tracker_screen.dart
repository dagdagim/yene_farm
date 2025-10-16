import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yene_farm/providers/language_provider.dart';
import 'package:yene_farm/utils/colors.dart';

class PriceTrackerScreen extends StatelessWidget {
  const PriceTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          languageProvider.currentLanguage == 'am' ? 'የዕህል ዋጋዎች' : 'Crop Prices',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: YeneFarmColors.primaryGreen,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_rounded,
              size: 80,
              color: YeneFarmColors.primaryGreen.withOpacity(0.3),
            ),
            const SizedBox(height: 20),
            Text(
              languageProvider.currentLanguage == 'am' 
                  ? 'የዋጋ ትንታኔ በቅርብ ጊዜ ይመጣል!'
                  : 'Price Analytics Coming Soon!',
              style: const TextStyle(
                fontSize: 18,
                color: YeneFarmColors.textMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}