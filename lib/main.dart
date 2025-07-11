import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:city_guide_app/Admin/Islamabad.dart';
import 'package:city_guide_app/Admin/abbottabad.dart';
import 'package:city_guide_app/Admin/karachi.dart';
import 'package:city_guide_app/Admin/lahore.dart';
import 'package:city_guide_app/Admin/multan.dart';
import 'package:city_guide_app/Admin/product.dart';
import 'package:city_guide_app/App/Home.dart';
import 'package:city_guide_app/App/login.dart';
import 'package:city_guide_app/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:city_guide_app/Admin/cities.dart';
import 'package:city_guide_app/Admin/hotels.dart';
import 'package:city_guide_app/Admin/user_manage.dart';
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
        '/app_home': (context) => Home(),
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
                            onTap:
                                () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Login(),
                                  ),
                                ),
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
  late User? _currentUser;
  String adminName = "Loading...";
  String adminEmail = "Loading...";
  String adminAvatar = "https://cdn-icons-png.flaticon.com/512/149/149071.png";

  int userCount = 0;
  int bookCount = 0;
  int categoryCount = 0;
  Map<String, int> categoryBookCount = {};
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _loadAdminData();
    fetchCounts();
  }

  Future<void> _loadAdminData() async {
    try {
      if (_currentUser != null) {
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(_currentUser!.uid)
                .get();

        if (userDoc.exists) {
          setState(() {
            adminName =
                userDoc['name'] ?? _currentUser!.displayName ?? "Admin User";
            adminEmail = _currentUser!.email ?? "admin@cityguide.com";
            adminAvatar =
                userDoc['profileImage'] ??
                _currentUser!.photoURL ??
                "https://cdn-icons-png.flaticon.com/512/149/149071.png";
          });
        }
      }
    } catch (e) {
      setState(() {
        adminName = "Admin User";
        adminEmail = "admin@cityguide.com";
      });
    }
  }

  void _showAdminProfile(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
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
                    backgroundImage: CachedNetworkImageProvider(adminAvatar),
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
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                      );
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

  void fetchCounts() async {
    try {
      final userSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      final bookSnapshot =
          await FirebaseFirestore.instance.collection('Attractions').get();
      final categorySnapshot =
          await FirebaseFirestore.instance.collection('cities').get();

      setState(() {
        userCount = userSnapshot.docs.length;
        bookCount = bookSnapshot.docs.length;
        categoryCount = categorySnapshot.docs.length;
      });

      await fetchCategoryCounts();
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching data: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchCategoryCounts() async {
    try {
      final bookSnapshot =
          await FirebaseFirestore.instance.collection('Attractions').get();
      Map<String, int> categoryCounts = {};

      for (var doc in bookSnapshot.docs) {
        final data = doc.data();
        final categoryId = data['cat_id']?.toString() ?? 'unknown';
        categoryCounts[categoryId] = (categoryCounts[categoryId] ?? 0) + 1;
      }

      setState(() {
        categoryBookCount = categoryCounts;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching category counts: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.indigo),
            onPressed: () {},
          ),
          IconButton(
            icon: CircleAvatar(
              radius: 16,
              backgroundImage: CachedNetworkImageProvider(adminAvatar),
              child:
                  adminAvatar.isEmpty
                      ? Icon(Icons.person, size: 18, color: Colors.indigo)
                      : null,
            ),
            onPressed: () => _showAdminProfile(context),
          ),
          SizedBox(width: 16),
        ],
      ),
      drawer: DashboardDrawer(
        adminName: adminName,
        adminEmail: adminEmail,
        adminAvatar: adminAvatar,
      ),
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
                ),
              )
              : errorMessage.isNotEmpty
              ? Center(
                child: Text(errorMessage, style: TextStyle(color: Colors.red)),
              )
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Card with Glass Morphism Effect
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.indigo.shade600,
                            Colors.blue.shade400,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Back, $adminName!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Manage your city guide app with powerful insights',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 16),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Stats Overview
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'Dashboard Overview',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.indigo,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                      children: [
                        _buildStatCard(
                          icon: Icons.people_alt_rounded,
                          title: 'Total Users',
                          value: userCount.toString(),
                          color: Colors.purpleAccent,
                        ),
                        _buildStatCard(
                          icon: Icons.place_rounded,
                          title: 'Attractions',
                          value: bookCount.toString(),
                          color: Colors.orangeAccent,
                        ),
                        _buildStatCard(
                          icon: Icons.location_city_rounded,
                          title: 'Cities',
                          value: categoryCount.toString(),
                          color: Colors.greenAccent,
                        ),
                        _buildStatCard(
                          icon: Icons.category_rounded,
                          title: 'Categories',
                          value: categoryBookCount.length.toString(),
                          color: Colors.blueAccent,
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Attractions by City
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Attractions by City',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.indigo,
                              letterSpacing: 0.5,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.refresh, color: Colors.indigo),
                            onPressed: fetchCounts,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),

                    if (categoryBookCount.isNotEmpty)
                      GridView.count(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.5,
                        children:
                            categoryBookCount.entries.map((entry) {
                              return _buildCityCard(
                                cityId: entry.key,
                                count: entry.value,
                              );
                            }).toList(),
                      )
                    else
                      Container(
                        height: 100,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.indigo,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add action
        },
        backgroundColor: Colors.indigo,
        child: Icon(Icons.add, color: Colors.white),
        elevation: 4,
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), color.withOpacity(0.2)],
          ),
        ),
        child: Padding(
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
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  Spacer(),
                  Icon(Icons.more_vert, color: Colors.grey.shade400, size: 20),
                ],
              ),
              SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.indigo.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCityCard({required String cityId, required int count}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.location_city_rounded,
                    color: Colors.indigo,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: FutureBuilder<DocumentSnapshot>(
                    future:
                        FirebaseFirestore.instance
                            .collection('cities')
                            .doc(cityId)
                            .get(),
                    builder: (context, snapshot) {
                      String cityName = "City $cityId";
                      if (snapshot.hasData && snapshot.data!.exists) {
                        cityName = snapshot.data!['name'] ?? cityName;
                      }
                      return Text(
                        cityName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.indigo.shade800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            LinearProgressIndicator(
              value: count / 50,
              backgroundColor: Colors.indigo.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Attractions:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardDrawer extends StatelessWidget {
  final String adminName;
  final String adminEmail;
  final String adminAvatar;

  const DashboardDrawer({
    Key? key,
    required this.adminName,
    required this.adminEmail,
    required this.adminAvatar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFF5F9FF)],
          ),
        ),
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                adminName,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(adminEmail),
              currentAccountPicture: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(adminAvatar),
                backgroundColor: Colors.grey[200],
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.indigo.shade600, Colors.blue.shade400],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  SizedBox(height: 8),
                  _buildDrawerItem(
                    context,
                    icon: Icons.dashboard_rounded,
                    title: 'Dashboard',
                    isSelected: true,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.people_alt_rounded,
                    title: 'User Management',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserManagementScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.place_rounded,
                    title: 'Attractions',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Attractions()),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.location_city_rounded,
                    title: 'Cities',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CitiesAdminPanel(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.restaurant_rounded,
                    title: 'Restaurants',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Restaurants()),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.hotel_rounded,
                    title: 'Hotels',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HotelsScreen()),
                      );
                    },
                  ),
                  Divider(
                    height: 24,
                    color: Colors.grey.shade300,
                    indent: 16,
                    endIndent: 16,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Text(
                      'CITY ATTRACTIONS',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.place_rounded,
                    title: 'Lahore',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Lahore()),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.place_rounded,
                    title: 'Karachi',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => karachi()),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.place_rounded,
                    title: 'Islamabad',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Islamabad()),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.place_rounded,
                    title: 'Multan',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => multan()),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.place_rounded,
                    title: 'Abbottabad',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => abbottabad()),
                      );
                    },
                  ),
                  Spacer(),
                  Divider(height: 1, color: Colors.grey.shade300),
                  _buildDrawerItem(
                    context,
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.indigo.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? Colors.indigo : Colors.grey.withOpacity(0.2),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.indigo,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.indigo : Colors.grey.shade800,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
        trailing:
            isSelected
                ? Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.indigo,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    size: 14,
                    color: Colors.white,
                  ),
                )
                : null,
        onTap: onTap,
      ),
    );
  }
}
