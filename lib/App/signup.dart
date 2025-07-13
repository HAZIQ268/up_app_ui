import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:city_guide_app/database_service.dart';
import 'package:city_guide_app/App/login.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> with SingleTickerProviderStateMixin {
  final _dbService = DatabaseService();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Modern color scheme
  final Color primaryColor = const Color(0xFF6C5CE7); // Vibrant purple
  final Color secondaryColor = const Color(0xFF00CEFF); // Bright cyan
  final Color accentColor = const Color(0xFFFD79A8); // Pink accent
  final Color darkColor = const Color(0xFF2D3436); // Dark gray
  final Color lightColor = const Color(0xFFDFE6E9); // Light gray

  // Initialize GoogleSignIn with platform detection
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Client ID is required for web, optional for Android/iOS
    clientId:
        '804538823277-9485hp4lb377rhhe1chbvkj418o5qn2j.apps.googleusercontent.com',
    scopes: ['email'],
  );

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child:
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.redAccent,
                        size: 60,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Signup Failed',
                        style: TextStyle(
                          fontSize: 22,
                          color: darkColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: darkColor.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 25),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 14,
                          ),
                        ),
                        child: const Text(
                          'Try Again',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ).animate().shakeX(),
            ),
          ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child:
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 60,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Account Created!',
                        style: TextStyle(
                          fontSize: 22,
                          color: darkColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: darkColor.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 25),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Login(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 14,
                          ),
                        ),
                        child: const Text(
                          'Continue to Login',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ).animate().scale(),
            ),
          ),
    );
  }

  Future<void> handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      String name = _name.text.trim();
      String email = _email.text.trim();
      String phone = _phone.text.trim();
      String password = _password.text.trim();

      String? result = await _dbService.createUser(
        name,
        email,
        phone,
        password,
      );

      setState(() => isLoading = false);

      if (result == "User registered successfully!") {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', name);
        await prefs.setString('userEmail', email);

        _showSuccessDialog("Welcome to City Guide, $name!");
      } else {
        _showErrorDialog(result ?? 'An error occurred, please try again.');
      }
    }
  }

  Future<void> handleGoogleSignIn() async {
    setState(() => isLoading = true);
    try {
      // Step 1: Trigger Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => isLoading = false);
        return;
      }

      // Step 2: Obtain auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Step 3: Create Firebase credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Step 4: Sign in to Firebase
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        throw Exception('Google sign-in failed - no user returned');
      }

      // Step 5: Check/create user document in Firestore
      final DocumentReference userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);

      final DocumentSnapshot snap = await userRef.get();

      if (!snap.exists) {
        await userRef.set({
          'name': user.displayName ?? 'Google User',
          'email': user.email,
          'phone': '',
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
          'photoUrl': user.photoURL,
        });
      }

      // Step 6: Get user data
      final Map<String, dynamic> userData =
          (await userRef.get()).data() as Map<String, dynamic>;
      final String role = userData['role'] ?? 'user';

      // Step 7: Save to local storage
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', userData['name'] ?? 'Google User');
      await prefs.setString('userEmail', user.email ?? '');
      await prefs.setString('userRole', role);

      // Step 8: Show success and navigate
      _showSuccessDialog('Account created with Google successfully!');
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        role == 'admin' ? '/admin' : '/app_home',
      );
    } catch (e) {
      _showErrorDialog('Google Sign-In failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor.withOpacity(0.9),
              secondaryColor.withOpacity(0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        const Text(
                          'Join City Guide',
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your account to explore the city',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 25),
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _name,
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: primaryColor,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: lightColor.withOpacity(0.3),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 20,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ).animate().slideX(delay: 200.ms),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(
                                  Icons.email,
                                  color: primaryColor,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: lightColor.withOpacity(0.3),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 20,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(
                                  r'^[^@]+@[^@]+\.[^@]+',
                                ).hasMatch(value)) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ).animate().slideX(delay: 300.ms),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _phone,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                prefixIcon: Icon(
                                  Icons.phone,
                                  color: primaryColor,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: lightColor.withOpacity(0.3),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 20,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your phone number';
                                }
                                if (value.length < 10) {
                                  return 'Phone number must be at least 10 digits';
                                }
                                return null;
                              },
                            ).animate().slideX(delay: 400.ms),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _password,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: primaryColor,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: primaryColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: lightColor.withOpacity(0.3),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 20,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ).animate().slideX(delay: 500.ms),
                            const SizedBox(height: 30),
                            Container(
                              width: double.infinity,
                              height: 55,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: LinearGradient(
                                  colors: [primaryColor, accentColor],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(15),
                                  onTap: isLoading ? null : handleSignUp,
                                  child: Center(
                                    child:
                                        isLoading
                                            ? const CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 3,
                                            )
                                            : const Text(
                                              'Sign Up',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                  ),
                                ),
                              ),
                            ).animate().scale(delay: 600.ms),
                            const SizedBox(height: 30),
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey[300],
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey[300],
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ).animate().fadeIn(delay: 700.ms),
                            const SizedBox(height: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildSocialButton(
                                  icon: Icons.g_mobiledata,
                                  color: const Color(0xFFDB4437),
                                  onPressed: handleGoogleSignIn,
                                ).animate().scale(delay: 800.ms),
                              ],
                            ),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Already have an account?",
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const Login(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ).animate().fadeIn(delay: 1000.ms),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 30, color: color),
        onPressed: onPressed,
      ),
    );
  }
}
