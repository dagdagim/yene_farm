import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yene_farm/providers/auth_provider.dart';
import 'package:yene_farm/providers/language_provider.dart';
import 'package:yene_farm/screens/auth/login_screen.dart';
import 'package:yene_farm/utils/colors.dart';
import 'package:yene_farm/utils/constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          languageProvider.currentLanguage == 'am' ? 'መገለጫ' : 'Profile',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: YeneFarmColors.primaryGreen,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Card
                  Container(
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
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: const Icon(
                            Icons.person_rounded,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user.role.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star_rounded, size: 20, color: Colors.yellow),
                            const SizedBox(width: 8),
                            Text(
                              '${user.rating} ★ (${user.totalTransactions} ${languageProvider.currentLanguage == 'am' ? 'ትራንዛክሽን' : 'transactions'})',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Info Section
                  Container(
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
                          languageProvider.currentLanguage == 'am' ? 'የግል መረጃ' : 'Personal Information',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoItem(Icons.phone_rounded, languageProvider.translate('phone_number'), user.phone),
                        _buildInfoItem(Icons.email_rounded, languageProvider.translate('email'), user.email),
                        _buildInfoItem(Icons.location_on_rounded, languageProvider.translate('region'), user.location),
                        _buildInfoItem(Icons.language_rounded, languageProvider.translate('language'), 
                            user.language == 'am' ? 'አማርኛ' : 'English'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Actions Section
                  Container(
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
                          languageProvider.currentLanguage == 'am' ? 'እርምጃዎች' : 'Actions',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildActionItem(Icons.edit_rounded, languageProvider.currentLanguage == 'am' ? 'መገለጫ አስተካክል' : 'Edit Profile', () {}),
                        _buildActionItem(Icons.settings_rounded, languageProvider.currentLanguage == 'am' ? 'ማስተካከያዎች' : 'Settings', () {}),
                        _buildActionItem(Icons.help_rounded, languageProvider.currentLanguage == 'am' ? 'እርዳታ' : 'Help & Support', () {}),
                        _buildActionItem(Icons.logout_rounded, languageProvider.currentLanguage == 'am' ? 'ውጣ' : 'Logout', () {
                          authProvider.logout();
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (route) => false,
                          );
                        }, isLogout: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: YeneFarmColors.primaryGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: YeneFarmColors.textLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? YeneFarmColors.warningRed : YeneFarmColors.primaryGreen,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? YeneFarmColors.warningRed : null,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      onTap: onTap,
    );
  }
}