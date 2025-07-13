import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:city_guide_app/App/forgetpassword.dart';
import 'package:city_guide_app/App/signup.dart';
import 'package:city_guide_app/database_service.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Modern color scheme
  final Color primaryColor = const Color(0xFF6C5CE7);
  final Color secondaryColor = const Color(0xFF00CEFF);
  final Color accentColor = const Color(0xFFFD79A8);
  final Color darkColor = const Color(0xFF2D3436);
  final Color lightColor = const Color(0xFFDFE6E9);

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
    _emailController.dispose();
    _passwordController.dispose();
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
                        'Login Failed',
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
                        'Welcome Back!',
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
                          'Continue',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ).animate().scale(),
            ),
          ),
    );
  }

  Future<void> handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final result = await DatabaseService().loginUser(email, password);
      setState(() => isLoading = false);

      if (result == 'Login Successfully') {
        _showSuccessDialog('You have logged in successfully.');
        await Future.delayed(const Duration(seconds: 1));
        final user = FirebaseAuth.instance.currentUser;
        if (user == null)
          return _showErrorDialog('User not found after login.');

        try {
          final snap =
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get();
          final data = snap.data();
          if (data == null)
            return _showErrorDialog('User data not found in database.');

          final role = data['role'] ?? 'user';
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userName', data['name'] ?? 'Unknown');
          await prefs.setString('userEmail', user.email ?? 'Unknown');
          await prefs.setString('userRole', role);

          if (!mounted) return;
          Navigator.pushReplacementNamed(
            context,
            role == 'admin' ? '/admin' : '/app_home',
          );
        } catch (e) {
          _showErrorDialog('Something went wrong: $e');
        }
      } else {
        _showErrorDialog('Incorrect credentials. Please try again.');
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
      _showSuccessDialog('Signed in with Google successfully!');
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
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Login to continue your journey',
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
                              controller: _emailController,
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
                            ).animate().slideX(delay: 200.ms),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _passwordController,
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
                            ).animate().slideX(delay: 300.ms),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Forget(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ).animate().fadeIn(delay: 400.ms),
                            const SizedBox(height: 25),
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
                                  onTap: isLoading ? null : handleLogin,
                                  child: Center(
                                    child:
                                        isLoading
                                            ? const CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 3,
                                            )
                                            : const Text(
                                              'Login',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                  ),
                                ),
                              ),
                            ).animate().scale(delay: 500.ms),
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
                            ).animate().fadeIn(delay: 600.ms),
                            const SizedBox(height: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildSocialButton(
                                  icon: Icons.g_mobiledata,
                                  color: const Color(0xFFDB4437),
                                  onPressed: handleGoogleSignIn,
                                ).animate().scale(delay: 700.ms),
                              ],
                            ),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account?",
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const Signup(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Sign Up',
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
