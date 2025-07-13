import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:city_guide_app/App/landing_page.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  bool _isLoading = true; // Track loading state

  final List<Color> colors = [
    Colors.deepPurple.shade800,
    Colors.purple.shade600,
  ];

  @override
  void initState() {
    super.initState();
    _loadDataAndNavigate();
  }

  Future<void> _loadDataAndNavigate() async {
    await fetchData(); // Load data first

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Lp(),
        ), // Navigate when data is ready
      );
    }
  }

  Future<void> fetchData() async {
    // Simulating actual data fetching (e.g., API call, database query)
    await Future.delayed(
      Duration(seconds: 6),
    ); // Example: Data takes 6 sec to load
    setState(() {
      _isLoading = false; // Mark data as loaded
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Animated background elements
              Positioned(
                top: -50,
                left: -50,
                child:
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ).animate().scale(duration: 1500.ms).fadeIn(),
              ),

              Positioned(
                bottom: -100,
                right: -50,
                child:
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ).animate().scale(duration: 1500.ms).fadeIn(),
              ),

              Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Logo
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ).animate().scale(duration: 800.ms),

                          Image.asset(
                                "../assets/images/city_guide_logo_black.png",
                                width: 120,
                                height: 120,
                                color:
                                    Colors
                                        .white, // Make logo white to match theme
                              )
                              .animate()
                              .fadeIn(duration: 500.ms)
                              .scale(delay: 200.ms)
                              .shake(delay: 800.ms),
                        ],
                      ),
                      const SizedBox(height: 40),
                      if (_isLoading)
                        CircularProgressIndicator(
                          strokeWidth: 6,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white, // Changed to white to match theme
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
