import 'dart:ui';

import 'package:city_guide_app/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:city_guide_app/Admin/cities.dart';
import 'package:city_guide_app/Admin/hotels.dart';
import 'package:city_guide_app/Admin/read_data.dart';
import 'package:city_guide_app/Admin/restaurants.dart';
import 'package:city_guide_app/Splash.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyUnifiedApp());
}

class MyUnifiedApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'City Guide',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: Color(0xFFF8FAFC),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 2,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          centerTitle: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => RoleSelectorScreen(),
        '/admin': (context) => AdminScreen(),
        '/app': (context) => Splash(),
      },
    );
  }
}

class RoleSelectorScreen extends StatelessWidget {
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
                child: Container(
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
                child: Container(
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

                          Icon(
                            Icons.travel_explore,
                            size: 80,
                            color: Colors.white,
                          )
                              .animate()
                              .fadeIn(duration: 500.ms)
                              .scale(delay: 200.ms)
                              .shake(delay: 800.ms),
                        ],
                      ),

                      SizedBox(height: 30),

                      // Title with animation
                      Column(
                        children: [
                          Text(
                            'Explore Your',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                            ),
                          ).animate().fadeIn().slideY(begin: -10),

                          Text(
                            'City Guide',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 200.ms)
                              .scaleXY(begin: 0.8)
                              .slideY(begin: 10),
                        ],
                      ),

                      SizedBox(height: 50),

                      // Role selection cards
                      Column(
                        children: [
                          // Admin Card
                          _buildRoleCard(
                            context,
                            icon: Icons.admin_panel_settings,
                            title: "Admin Access",
                            subtitle: "Manage city content and users",
                            color: Color(0xFFFF416C),
                            onTap: () => Navigator.pushNamed(context, '/admin'),
                            // correct code navigator 
                  //           Navigator.pushReplacement(
                  // context,
                  // MaterialPageRoute(builder: (context) => Login()),
                          ).animate().fadeIn(delay: 400.ms).slideX(begin: -50),

                          SizedBox(height: 20),

                          // User Card
                          _buildRoleCard(
                            context,
                            icon: Icons.explore,
                            title: "Explore City",
                            subtitle: "Discover places and events",
                            color: Color(0xFF4BC0C8),
                            onTap: () => Navigator.pushNamed(context, '/app'),
                          ).animate().fadeIn(delay: 600.ms).slideX(begin: 50),
                        ],
                      ),

                      SizedBox(height: 30),

                      // Footer text
                      Text(
                        'Select your role to continue',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ).animate().fadeIn(delay: 800.ms),
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

  Widget _buildRoleCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 24),
            ),

            SizedBox(width: 20),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.6),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0;
  String adminName = "Admin User";
  String adminEmail = "admin@cityguide.com";
  String adminAvatar = "https://st3.depositphotos.com/3431221/13621/v/450/depositphotos_136216036-stock-illustration-man-avatar-icon-hipster-character.jpg";

  static List<Widget> _widgetOptions = <Widget>[
    DashboardContent(),
    CitiesScreen(),
    Restaurants(),
    HotelsScreen(),
    FetchData(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAdminProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(adminAvatar),
                backgroundColor: Colors.grey[200],
              ),
              SizedBox(height: 16),
              Text(
                adminName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                adminEmail,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 20),
              Divider(height: 1, color: Colors.grey[300]),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pushReplacementNamed(context, '/'); // Go to login
                },
                icon: Icon(Icons.logout, size: 20),
                label: Text("Logout"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: _selectedIndex == 0
          ? AppBar(
              title: Text(
                'City Guide Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(2, 2),
                    )
                  ],
                ),
              ),
              centerTitle: true,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    onTap: () => _showAdminProfile(context),
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.indigo, Colors.purple],
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(adminAvatar),
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                  ),
                ),
              ],
            )
          : null,
      body: Container(
        height: 650,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("../assets/images/admin_bg_img.jpeg"),
            fit: BoxFit.cover,
          ),
        ),
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: ConvexAppBar(
        items: [
          TabItem(icon: Icons.dashboard_rounded, title: 'Dashboard'),
          TabItem(icon: Icons.location_city_rounded, title: 'Cities'),
          TabItem(icon: Icons.restaurant_rounded, title: 'Restaurants'),
          TabItem(icon: Icons.hotel_rounded, title: 'Hotels'),
          TabItem(icon: Icons.people_rounded, title: 'Users'),
        ],
        initialActiveIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        color: Colors.grey[600],
        activeColor: Colors.deepPurple,
        curveSize: 80,
        height: 56,
        style: TabStyle.reactCircle,
        elevation: 5,
        top: -20,
      ),
    );
  }
}

class DashboardContent extends StatefulWidget {
  @override
  _DashboardContentState createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  bool isLoading = true;
  int userCount = 0;
  int attractionCount = 0;
  int cityCount = 0;
  int categoryCount = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final userSnapshot = await FirebaseFirestore.instance.collection('users').get();
      final attractionSnapshot = await FirebaseFirestore.instance.collection('Attractions').get();
      final citySnapshot = await FirebaseFirestore.instance.collection('cities').get();
      
      // Get unique categories
      final categories = attractionSnapshot.docs.map((doc) => doc['cat_id']).toSet();

      setState(() {
        userCount = userSnapshot.docs.length;
        attractionCount = attractionSnapshot.docs.length;
        cityCount = citySnapshot.docs.length;
        categoryCount = categories.length;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: fetchData,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card with Glass Effect
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF6A11CB).withOpacity(0.5),
                        Color(0xFF2575FC).withOpacity(0.5),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Admin!',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Manage your city guide content and analytics dashboard',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(
                        Icons.analytics_rounded,
                        size: 50,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),

            // Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildGlassStatCard(
                  icon: FontAwesomeIcons.users,
                  title: 'Total Users',
                  value: userCount,
                  baseColor: Color(0xFF3B82F6),
                ),
                _buildGlassStatCard(
                  icon: FontAwesomeIcons.locationDot,
                  title: 'Attractions',
                  value: attractionCount,
                  baseColor: Color(0xFF10B981),
                ),
                _buildGlassStatCard(
                  icon: FontAwesomeIcons.city,
                  title: 'Cities',
                  value: cityCount,
                  baseColor: Color(0xFFF59E0B),
                ),
                _buildGlassStatCard(
                  icon: FontAwesomeIcons.chartPie,
                  title: 'Categories',
                  value: categoryCount,
                  baseColor: Color(0xFF8B5CF6),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassStatCard({
    required IconData icon,
    required String title,
    required int value,
    required Color baseColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: baseColor.withOpacity(0.2),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [baseColor.withOpacity(0.3), baseColor.withOpacity(0.1)],
            ),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: baseColor.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: FaIcon(icon, size: 30, color: Colors.white),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: baseColor.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      value.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}