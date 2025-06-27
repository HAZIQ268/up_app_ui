import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:city_guide_app/App/Home.dart';
import 'package:city_guide_app/App/login.dart';
import 'package:city_guide_app/App/signup.dart';

class Lp extends StatefulWidget {
  const Lp({super.key});

  @override
  State<Lp> createState() => _LpState();
}

class _LpState extends State<Lp> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutQuart,
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.deepPurple.shade800,
                    Colors.purple.shade600,
                    Colors.purple.shade400,
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 800.ms),
          ),

          // City Skyline Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.45,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage(
                      "../assets/images/pngtree-lahore-skyline-with-color-landmarks-blue-sky-and-copy-space-png-image_15532952.png"),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.deepPurple.withOpacity(0.7),
                    BlendMode.darken,
                  ),
                ),
              ),
            ).animate().slideY(
              begin: -0.5,
              end: 0,
              duration: 1000.ms,
              curve: Curves.easeOutBack,
            ),
          ),

          // Content Card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.6,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title with animation
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          "Explore the City's Best Spots",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple.shade800,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Subtitle with animation
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          "Discover top attractions, restaurants, hotels and events with our comprehensive city guide",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Buttons with staggered animations
                    Column(
                      children: [
                        // Sign Up Button
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) =>
                                          const Signup(),
                                      transitionsBuilder:
                                          (context, animation, secondaryAnimation, child) {
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
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  elevation: 8,
                                  shadowColor: Colors.deepPurple.withOpacity(0.5),
                                ),
                                child: const Text(
                                  "Create Account",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Login Button
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) =>
                                          const Login(),
                                      transitionsBuilder:
                                          (context, animation, secondaryAnimation, child) {
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
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    side: BorderSide(
                                      color: Colors.deepPurple,
                                      width: 2,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  "Sign In",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Guest Option with animation
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                    const Home(),
                                transitionsBuilder:
                                    (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                          child: Text(
                            "Continue as Guest",
                            style: TextStyle(
                              color: Colors.deepPurple.shade600,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().slide(
                begin: const Offset(0, 0.5),
              duration: 1000.ms,
              curve: Curves.easeOutQuart,
            ),
          ),

          // App Logo/Name at top
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "City Guide",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(
                begin: -0.5,
                duration: 800.ms,
              ),
            ),
          ),
        ],
      ),
    );
  }
}