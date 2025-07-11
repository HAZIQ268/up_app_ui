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
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Color(0xFFF8FAFC),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
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
            adminName = userDoc['name'] ?? _currentUser!.displayName ?? "Admin";
            adminEmail = _currentUser!.email ?? "admin@gmail.com";
            adminAvatar =
                userDoc['profileImage'] ??
                _currentUser!.photoURL ??
                "https://cdn-icons-png.flaticon.com/512/149/149071.png";
          });
        }
      }
    } catch (e) {
      setState(() {
        adminName = "Admin";
        adminEmail = "admin@gmail.com";
      });
    }
  }

  void _showAdminProfile(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            child: Container(
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: CachedNetworkImageProvider(
                          adminAvatar,
                        ),
                        backgroundColor: Colors.grey[200],
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.indigo,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    adminName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    adminEmail,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 25),
                  Divider(height: 1, color: Colors.grey[300]),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => Login()),
                        );
                      },
                      icon: Icon(Icons.logout, size: 20),
                      label: Text(
                        "Logout",
                        style: TextStyle(fontFamily: 'Poppins'),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 15,
                        ),
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
        title: Text('Admin Dashboard', style: TextStyle(fontFamily: 'Poppins')),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Badge(
              smallSize: 8,
              backgroundColor: Colors.red,
              child: Icon(Icons.notifications, color: Colors.indigo, size: 26),
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: CircleAvatar(
              radius: 18,
              backgroundImage: CachedNetworkImageProvider(adminAvatar),
              child:
                  adminAvatar.isEmpty
                      ? Icon(Icons.person, size: 18, color: Colors.indigo)
                      : null,
            ),
            onPressed: () => _showAdminProfile(context),
          ),
          SizedBox(width: 10),
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
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red, fontFamily: 'Poppins'),
                ),
              )
              : SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.indigo.shade700,
                            Colors.blue.shade500,
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
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome Back,',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 18,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      adminName,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.waving_hand,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Today\'s Date',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                Text(
                                  '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 25),

                    // Stats Overview
                    Text(
                      'Dashboard Overview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.indigo.shade800,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(height: 15),

                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 1,
                      children: [
                        _buildStatCard(
                          icon: Icons.people_alt_rounded,
                          title: 'Total Users',
                          value: userCount.toString(),
                          color: Colors.purpleAccent,
                          percent: 0.75,
                        ),
                        _buildStatCard(
                          icon: Icons.place_rounded,
                          title: 'Attractions',
                          value: bookCount.toString(),
                          color: Colors.orangeAccent,
                          percent: 0.65,
                        ),
                        _buildStatCard(
                          icon: Icons.location_city_rounded,
                          title: 'Cities',
                          value: categoryCount.toString(),
                          color: Colors.greenAccent,
                          percent: 0.45,
                        ),
                        _buildStatCard(
                          icon: Icons.category_rounded,
                          title: 'Categories',
                          value: categoryBookCount.length.toString(),
                          color: Colors.blueAccent,
                          percent: 0.85,
                        ),
                      ],
                    ),
                    SizedBox(height: 25),
                  ],
                ),
              ),
    );
  }
  

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required double percent,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 15,
              spreadRadius: 1,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '+${(percent * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.indigo.shade800,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.trending_up_rounded, color: color, size: 24),
                ],
              ),
              SizedBox(height: 15),
              LinearProgressIndicator(
                value: percent,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCityCard({required String cityId, required int count}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 15,
              spreadRadius: 1,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
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
                            fontFamily: 'Poppins',
                          ),
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Attractions',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          count.toString(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.indigo,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              value: count / 50,
                              backgroundColor: Colors.indigo.withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.indigo,
                              ),
                              strokeWidth: 6,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            '${((count / 50) * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
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
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                left: 25,
                right: 25,
                bottom: 25,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.indigo.shade700, Colors.blue.shade500],
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: CachedNetworkImageProvider(adminAvatar),
                    backgroundColor: Colors.grey[200],
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          adminName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          adminEmail,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(top: 10),
                children: [
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
                    height: 30,
                    color: Colors.grey.shade300,
                    indent: 25,
                    endIndent: 25,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                    child: Text(
                      'CITY ATTRACTIONS',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        letterSpacing: 1,
                        fontFamily: 'Poppins',
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
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
            color: isSelected ? Colors.indigo : Colors.grey.withOpacity(0.1),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.indigo : Colors.grey.shade700,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.indigo : Colors.grey.shade800,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            fontFamily: 'Poppins',
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
