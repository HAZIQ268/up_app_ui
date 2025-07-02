import 'package:flutter/material.dart';
import 'package:city_guide_app/App/Lp.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  bool _isLoading = true; // Track loading state

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
        MaterialPageRoute(builder: (context) => Lp()), // Navigate when data is ready
      );
    }
  }

  Future<void> fetchData() async {
    // Simulating actual data fetching (e.g., API call, database query)
    await Future.delayed(Duration(seconds: 6)); // Example: Data takes 6 sec to load
    setState(() {
      _isLoading = false; // Mark data as loaded
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Column(
              children: [
                Image.asset(
                  "../assets/images/city_guide_logo_black.png",
                  width: 500,
                  height: 500,
                ),
                const SizedBox(height: 20),
                if (_isLoading) // Show progress indicator only while loading
                  CircularProgressIndicator(
                    strokeWidth: 6,
                    valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFFE74919),
),
                  ),
              ],
            ),
          ),
        ],
    
      ),
    
    );
    
  }
}
