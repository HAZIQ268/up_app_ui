import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String _errorMessage = '';
  bool _isAdminLogin = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Check if user is admin (you'll need to implement this logic)
      final isAdmin = await _checkIfAdmin(credential.user!.uid);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => isAdmin ? AdminHomePage() : UserHomePage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.code);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _checkIfAdmin(String uid) async {
    // Implement your logic to check if user is admin
    // For example, check Firestore for admin role
    return uid == 'your-admin-uid'; // Replace with actual check
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Please enter a valid email';
      default:
        return 'Login failed. Please try again.';
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email to reset password';
      });
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset email sent to $email'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.code);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6A11CB),
              Color(0xFF2575FC),
            ],
          )),
          ),
          // Background Animated Elements
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat())
              .scale(duration: 10.seconds, curve: Curves.easeInOut)
              .fadeOut(duration: 10.seconds),
          
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat())
              .scale(duration: 15.seconds, begin: Offset(0.5, 0.5))
              .fadeOut(duration: 15.seconds),
          
          // Content
          SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 80),
                
                // Animated Title
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'City Explorer',
                      textStyle: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      speed: Duration(milliseconds: 100),
                    ),
                  ],
                  totalRepeatCount: 1,
                ),
                
                SizedBox(height: 8),
                Text(
                  'Discover the best of your city',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 40),
                
                // Login Form Card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Toggle between Admin/User Login
                          ToggleButtons(
                            isSelected: [_isAdminLogin, !_isAdminLogin],
                            onPressed: (index) {
                              setState(() {
                                _isAdminLogin = index == 0;
                              });
                            },
                            borderRadius: BorderRadius.circular(10),
                            selectedColor: Colors.white,
                            fillColor: Color(0xFF2575FC),
                            color: Color(0xFF2575FC),
                            constraints: BoxConstraints.expand(width: 120, height: 40),
                            children: [
                              Text('Admin', style: GoogleFonts.poppins()),
                              Text('User', style: GoogleFonts.poppins()),
                            ],
                          ),
                          
                          SizedBox(height: 30),
                          
                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email, color: Colors.blue),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          
                          SizedBox(height: 20),
                          
                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock, color: Colors.blue),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            obscureText: !_isPasswordVisible,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          
                          SizedBox(height: 10),
                          
                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _resetPassword,
                              child: Text(
                                'Forgot Password?',
                                style: GoogleFonts.poppins(
                                  color: Colors.blue,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 20),
                          
                          // Error Message
                          if (_errorMessage.isNotEmpty)
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error, color: Colors.red),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _errorMessage,
                                      style: GoogleFonts.poppins(
                                        color: Colors.red[800],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          SizedBox(height: 20),
                          
                          // Login Button
                          ElevatedButton(
                            onPressed: _isLoading ? null : _signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF2575FC),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Login',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                          
                          SizedBox(height: 20),
                          
                          // Or Divider
                          Row(
                            children: [
                              Expanded(child: Divider()),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  'OR',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),
                          
                          SizedBox(height: 20),
                          
                          // Social Login
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: SvgPicture.asset(
                                  'assets/icons/google.svg',
                                  height: 24,
                                ),
                              ),
                              SizedBox(width: 20),
                              IconButton(
                                onPressed: () {},
                                icon: SvgPicture.asset(
                                  'assets/icons/facebook.svg',
                                  height: 24,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 30),
                
                // Sign Up Prompt
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to sign up page
                      },
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Animated decoration at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Lottie.asset(
              'assets/animations/wave.json',
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
            ),
          ),
        ],
      ),
    );
  }
}

// Placeholder pages - you'll need to implement these
class AdminHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Dashboard')),
      body: Center(child: Text('Admin Home')),
    );
  }
}

class UserHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Explore Cities')),
      body: Center(child: Text('User Home')),
    );
  }
}