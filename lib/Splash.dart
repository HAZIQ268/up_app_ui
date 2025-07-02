import 'package:flutter/material.dart';
import 'package:city_guide_app/App/Lp.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  bool _isLoading = true;
  bool _errorOccurred = false;

  @override
  void initState() {
    super.initState();
    _loadDataAndNavigate();
  }

  Future<void> _loadDataAndNavigate() async {
    try {
      await fetchData();
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Lp()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorOccurred = true;
          _isLoading = false;
        });
      }
      // Optionally show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> fetchData() async {
    // Simulate data loading
    await Future.delayed(const Duration(seconds: 6));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/city_guide_logo_black.png", // Corrected asset path
              width: 250, // More reasonable size
              height: 250,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.error_outline,
                size: 100,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 30),
            if (_isLoading)
              CircularProgressIndicator(
                strokeWidth: 6,
                valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFFE74919)),
              ),
            if (_errorOccurred)
              Column(
                children: [
                  const Text(
                    'Failed to load data',
                    style: TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _loadDataAndNavigate,
                    child: const Text('Retry'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}



