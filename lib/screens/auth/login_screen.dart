import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yene_farm/providers/auth_provider.dart';
import 'package:yene_farm/providers/language_provider.dart';
import 'package:yene_farm/screens/auth/register_screen.dart';
import 'package:yene_farm/screens/home_screen.dart';
import 'package:yene_farm/utils/colors.dart';
import 'package:yene_farm/utils/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
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

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _phoneController.text,
        _passwordController.text,
      );
      
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
        _showErrorDialog();
      }
    }
  }

  void _showErrorDialog() {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        title: Text(
          languageProvider.currentLanguage == 'am' ? 'ስህተት' : 'Error',
          style: const TextStyle(
            color: YeneFarmColors.warningRed,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          languageProvider.currentLanguage == 'am' 
              ? 'ያስገቡት ስልክ ቁጥር ወይም የይለፍ ቃል ትክክል አይደለም።'
              : 'The phone number or password you entered is incorrect.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              languageProvider.currentLanguage == 'am' ? 'እሺ' : 'OK',
              style: const TextStyle(color: YeneFarmColors.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const RegisterScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = const Offset(1.0, 0.0);
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
    _phoneController.dispose();
    _passwordController.dispose();
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
            height: MediaQuery.of(context).size.height,
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
                  // Back Button with Animated Container
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
                  
                  const SizedBox(height: 40),
                  
                  // Welcome Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        languageProvider.translate('welcome_back'),
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 36,
                          foreground: Paint()
                            ..shader = YeneFarmColors.primaryGradient.createShader(
                              const Rect.fromLTWH(0, 0, 200, 70),
                            ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        languageProvider.translate('sign_in_to_continue'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: YeneFarmColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Login Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Phone Number Field
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
                          child: TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: languageProvider.translate('phone_number'),
                              prefixText: '+251 ',
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
                                child: const Icon(
                                  Icons.phone_rounded,
                                  color: YeneFarmColors.primaryGreen,
                                ),
                              ),
                            ),
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
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Password Field
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
                          child: TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: languageProvider.translate('password'),
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
                                child: const Icon(
                                  Icons.lock_rounded,
                                  color: YeneFarmColors.primaryGreen,
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                  color: YeneFarmColors.textLight,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            obscureText: _obscurePassword,
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
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // Handle forgot password
                            },
                            child: Text(
                              languageProvider.translate('forgot_password'),
                              style: const TextStyle(
                                color: YeneFarmColors.primaryGreen,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Login Button
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
                            onPressed: _isLoading ? null : _login,
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
                                    languageProvider.translate('login'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Divider with Text
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(
                                color: YeneFarmColors.divider,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                languageProvider.currentLanguage == 'am' ? 'ወይም' : 'OR',
                                style: const TextStyle(
                                  color: YeneFarmColors.textLight,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(
                                color: YeneFarmColors.divider,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Register Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              languageProvider.translate('dont_have_account'),
                              style: const TextStyle(
                                color: YeneFarmColors.textMedium,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: _navigateToRegister,
                              child: Text(
                                languageProvider.translate('create_account'),
                                style: const TextStyle(
                                  color: YeneFarmColors.primaryGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
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
}