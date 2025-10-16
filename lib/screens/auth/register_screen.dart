import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yene_farm/models/user_model.dart';
import 'package:yene_farm/providers/auth_provider.dart';
import 'package:yene_farm/providers/language_provider.dart';
import 'package:yene_farm/screens/auth/login_screen.dart';
import 'package:yene_farm/screens/home_screen.dart';
import 'package:yene_farm/utils/colors.dart';
import 'package:yene_farm/utils/constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String _selectedRole = 'farmer';
  String _selectedRegion = 'Addis Ababa';
  String _selectedLanguage = 'am';
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        _showErrorDialog(
          Provider.of<LanguageProvider>(context, listen: false).currentLanguage == 'am' 
              ? 'የይለፍ ቃላት አይዛመዱም'
              : 'Passwords do not match'
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      
      final newUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        role: _selectedRole,
        location: _selectedRegion,
        language: _selectedLanguage,
        isVerified: false,
        rating: 0.0,
        totalTransactions: 0,
        createdAt: DateTime.now(),
      );
      
      final success = await authProvider.register(newUser, _passwordController.text);
      
      setState(() {
        _isLoading = false;
      });

      if (success) {
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
        _showErrorDialog(
          languageProvider.currentLanguage == 'am' 
              ? 'ምዝገባው አልተሳካም። እባክዎ እንደገና ይሞክሩ።'
              : 'Registration failed. Please try again.'
        );
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        title: Text(
          Provider.of<LanguageProvider>(context, listen: false).currentLanguage == 'am' ? 'ስህተት' : 'Error',
          style: const TextStyle(
            color: YeneFarmColors.warningRed,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              Provider.of<LanguageProvider>(context, listen: false).currentLanguage == 'am' ? 'እሺ' : 'OK',
              style: const TextStyle(color: YeneFarmColors.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = const Offset(-1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration: AppConstants.pageTransitionDuration,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: YeneFarmColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: AnimatedBuilder(
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
              child: Column(
                children: [
                  // Back Button
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: YeneFarmColors.primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_rounded,
                              size: 20,
                              color: YeneFarmColors.primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Header Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        languageProvider.translate('create_account'),
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 32,
                          foreground: Paint()
                            ..shader = YeneFarmColors.primaryGradient.createShader(
                              const Rect.fromLTWH(0, 0, 200, 70),
                            ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        languageProvider.currentLanguage == 'am' 
                            ? 'የYeneFarm መለያ ይፍጠሩ'
                            : 'Create your YeneFarm account',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: YeneFarmColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Registration Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Name Field
                        _buildFormField(
                          controller: _nameController,
                          label: languageProvider.translate('full_name'),
                          icon: Icons.person_rounded,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return languageProvider.currentLanguage == 'am' 
                                  ? 'ስም ያስፈልጋል'
                                  : 'Name is required';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Phone Field
                        _buildFormField(
                          controller: _phoneController,
                          label: languageProvider.translate('phone_number'),
                          icon: Icons.phone_rounded,
                          prefixText: '+251 ',
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return languageProvider.currentLanguage == 'am' 
                                  ? 'ስልክ ቁጥር ያስፈልጋል'
                                  : 'Phone number is required';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Email Field
                        _buildFormField(
                          controller: _emailController,
                          label: languageProvider.translate('email'),
                          icon: Icons.email_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return languageProvider.currentLanguage == 'am' 
                                  ? 'ኢሜይል ያስፈልጋል'
                                  : 'Email is required';
                            }
                            if (!value.contains('@')) {
                              return languageProvider.currentLanguage == 'am' 
                                  ? 'ትክክለኛ ኢሜይል ያስገቡ'
                                  : 'Enter valid email';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Role and Region Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdown(
                                value: _selectedRole,
                                label: languageProvider.translate('role'),
                                items: [
                                  _buildDropdownItem('farmer', languageProvider.translate('farmer'), Icons.agriculture),
                                  _buildDropdownItem('buyer', languageProvider.translate('buyer'), Icons.shopping_cart),
                                  _buildDropdownItem('driver', languageProvider.translate('driver'), Icons.directions_car),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedRole = value!;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDropdown(
                                value: _selectedRegion,
                                label: languageProvider.translate('region'),
                                items: AppConstants.ethiopianRegions
                                    .map((region) => _buildDropdownItem(region, region, Icons.location_on))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedRegion = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Language Dropdown
                        _buildDropdown(
                          value: _selectedLanguage,
                          label: languageProvider.translate('language'),
                          items: [
                            _buildDropdownItem('am', 'አማርኛ', Icons.language),
                            _buildDropdownItem('en', 'English', Icons.language),
                            _buildDropdownItem('om', 'Afan Oromo', Icons.language),
                            _buildDropdownItem('ti', 'ትግርኛ', Icons.language),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedLanguage = value!;
                            });
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Password Field
                        _buildPasswordField(
                          controller: _passwordController,
                          label: languageProvider.translate('password'),
                          obscureText: _obscurePassword,
                          onToggle: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return languageProvider.currentLanguage == 'am' 
                                  ? 'የይለፍ ቃል ያስፈልጋል'
                                  : 'Password is required';
                            }
                            if (value.length < 6) {
                              return languageProvider.currentLanguage == 'am' 
                                  ? 'የይለፍ ቃል ቢያንስ 6 ቁምፊ ሊኖረው ይገባል'
                                  : 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Confirm Password Field
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          label: languageProvider.translate('confirm_password'),
                          obscureText: _obscureConfirmPassword,
                          onToggle: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return languageProvider.currentLanguage == 'am' 
                                  ? 'የይለፍ ቃል አረጋግጥ ያስፈልጋል'
                                  : 'Please confirm your password';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Register Button
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
                            onPressed: _isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: YeneFarmColors.primaryGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    languageProvider.translate('register'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Login Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              languageProvider.translate('already_have_account'),
                              style: const TextStyle(
                                color: YeneFarmColors.textMedium,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: _navigateToLogin,
                              child: Text(
                                languageProvider.translate('login'),
                                style: const TextStyle(
                                  color: YeneFarmColors.primaryGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? prefixText,
    TextInputType? keyboardType,
    required String? Function(String?) validator,
  }) {
    return Container(
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
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixText: prefixText,
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
            child: Icon(icon, color: YeneFarmColors.primaryGreen),
          ),
        ),
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return Container(
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
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
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
            child: const Icon(Icons.lock_rounded, color: YeneFarmColors.primaryGreen),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: YeneFarmColors.textLight,
            ),
            onPressed: onToggle,
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Container(
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
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
        ),
        items: items,
        onChanged: onChanged,
        icon: const Icon(Icons.arrow_drop_down_rounded, color: YeneFarmColors.primaryGreen),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
    );
  }

  DropdownMenuItem<String> _buildDropdownItem(String value, String text, IconData icon) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: YeneFarmColors.primaryGreen),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }
}