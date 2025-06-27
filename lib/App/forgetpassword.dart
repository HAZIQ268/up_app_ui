import 'package:city_guide_app/App/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_animate/flutter_animate.dart';

class Forget extends StatefulWidget {
  const Forget({super.key});

  @override
  State<Forget> createState() => _ForgetState();
}

class _ForgetState extends State<Forget> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, 
                  color: Colors.red, 
                  size: 60),
                const SizedBox(height: 20),
                Text('Password Reset Failed',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(message,
                  style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 12),
                  ),
                  child: const Text('Try Again',
                    style: TextStyle(color: Colors.white)),
                ),
              ],
            ).animate().shakeX(),
          ),
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, 
                  color: Colors.green, 
                  size: 60),
                const SizedBox(height: 20),
                Text('Email Sent!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(message,
                  style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 12),
                  ),
                  child: const Text('Back to Login',
                    style: TextStyle(color: Colors.white)),
                ),
              ],
            ).animate().scale(),
          ),
        );
      },
    );
  }

  Future<void> resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _emailController.text.trim(),
        );
        _showSuccessDialog("Password reset link has been sent to your email.");
      } catch (error) {
        _showErrorDialog(error.toString());
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary,
              colorScheme.primary.withOpacity(0.8),
              colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ).animate().slideX(delay: 100.ms),
                        Image.asset(
                          '../assets/images/city_guide_logo.png', 
                          height: 100,
                          width: 100,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Forgot Password?",
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "Enter your email to receive a password reset link",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(25),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _emailController,
                              hintText: "Email",
                              icon: Icons.email_outlined,
                              theme: theme,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter your email";
                                }
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                  return "Enter a valid email";
                                }
                                return null;
                              },
                            ).animate().slideX(delay: 200.ms),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : resetPassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 40),
                                  elevation: 5,
                                  shadowColor: colorScheme.primary.withOpacity(0.4),
                                ),
                                child: isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      )
                                    : Text(
                                        "Send Reset Link",
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ).animate().scale(delay: 300.ms),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Remember your password?",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation, secondaryAnimation) => const Login(),
                                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                          return SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(1, 0),
                                              end: Offset.zero,
                                            ).animate(animation),
                                            child: child,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Login",
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ).animate().fadeIn(delay: 400.ms),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required ThemeData theme,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16, horizontal: 20),
      ),
    );
  }
}