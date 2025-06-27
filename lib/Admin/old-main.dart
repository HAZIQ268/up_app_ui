import 'package:city_guide_app/Admin/Islamabad.dart';
import 'package:city_guide_app/Admin/abbottabad.dart';
import 'package:city_guide_app/Admin/cities.dart';
import 'package:city_guide_app/Admin/hotels.dart';
import 'package:city_guide_app/Admin/karachi.dart';
import 'package:city_guide_app/Admin/lahore.dart';
import 'package:city_guide_app/Admin/multan.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// Firebase packages (commented if not using now)
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:city_guide_app/firebase_options.dart';

import 'package:city_guide_app/Admin/product.dart';
import 'package:city_guide_app/Admin/read_data.dart';
import 'package:city_guide_app/Admin/restaurants.dart';

void main() {
  // Agar Firebase future mein use karni ho to ye version use karein:
  /*
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  */
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color(0xFFF8FAFC),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          centerTitle: true,
        ),
      ),
      home: AdminScreen(),
    );
  }
}

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int userCount = 0;
  int attractionCount = 0;
  int cityCount = 0;
  Map<String, int> cityAttractionCount = {};

  @override
  void initState() {
    super.initState();
    fetchCounts();
  }

  Future<void> fetchCounts() async {
    try {
      final userSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      final attractionSnapshot =
          await FirebaseFirestore.instance.collection('Attractions').get();
      final citySnapshot =
          await FirebaseFirestore.instance.collection('cities').get();

      setState(() {
        userCount = userSnapshot.docs.length;
        attractionCount = attractionSnapshot.docs.length;
        cityCount = citySnapshot.docs.length;
      });

      fetchCityAttractionCounts();
    } catch (e) {
      print('Firestore error: $e');
    }
  }

  Future<void> fetchCityAttractionCounts() async {
    try {
      final attractionSnapshot =
          await FirebaseFirestore.instance.collection('Attractions').get();
      Map<String, int> counts = {};

      for (var doc in attractionSnapshot.docs) {
        final cityId = doc['cat_id'];
        counts[cityId] = (counts[cityId] ?? 0) + 1;
      }

      setState(() {
        cityAttractionCount = counts;
      });
    } catch (e) {
      print('Error fetching city counts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('City Guide Admin', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: fetchCounts,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            _buildHeaderCard(),
            SizedBox(height: 24),

            // Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildStatCard(
                  icon: FontAwesomeIcons.users,
                  title: 'Total Users',
                  value: userCount,
                  color: Color(0xFF3B82F6),
                ),
                _buildStatCard(
                  icon: FontAwesomeIcons.locationDot,
                  title: 'Attractions',
                  value: attractionCount,
                  color: Color(0xFF10B981),
                ),
                _buildStatCard(
                  icon: FontAwesomeIcons.city,
                  title: 'Cities',
                  value: cityCount,
                  color: Color(0xFFF59E0B),
                ),
                _buildStatCard(
                  icon: FontAwesomeIcons.chartPie,
                  title: 'Categories',
                  value: cityAttractionCount.length,
                  color: Color(0xFF8B5CF6),
                ),
              ],
            ),
            SizedBox(height: 24),

            // City Attractions Section
            Text(
              'Attractions by City',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 12),
            ...cityAttractionCount.entries
                .map((entry) => _buildCityCard(entry.key, entry.value))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Manage your city guide content and analytics',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            FontAwesomeIcons.compass,
            size: 48,
            color: Colors.white.withOpacity(0.8),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required int value,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FaIcon(icon, size: 20, color: color),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 4),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityCard(String city, int count) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            FontAwesomeIcons.city,
            size: 16,
            color: Color(0xFF3B82F6),
          ),
        ),
        title: Text(
          city,
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: Color(0xFF10B981),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Drawer Header
            Container(
              height: 180,
              padding: EdgeInsets.only(top: 40, bottom: 20),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Icon(
                      FontAwesomeIcons.userShield,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Admin Panel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    'Manage your app',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // Drawer Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    context,
                    icon: FontAwesomeIcons.users,
                    title: 'User Management',
                    destination: FetchData(),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: FontAwesomeIcons.locationDot,
                    title: 'Attractions',
                    destination: Attractions(),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: FontAwesomeIcons.city,
                    title: 'Cities',
                    destination: CitiesScreen(),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: FontAwesomeIcons.utensils,
                    title: 'Restaurants',
                    destination: Restaurants(),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: FontAwesomeIcons.hotel,
                    title: 'Hotels',
                    destination: HotelsScreen(),
                  ),
                  Divider(height: 24, color: Colors.grey[300]),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Text(
                      'CITY ATTRACTIONS',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Individual city links
                  _buildDrawerItem(
                    context,
                    icon: FontAwesomeIcons.mapPin,
                    title: 'Lahore',
                    destination: LahoreAttractions(),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: FontAwesomeIcons.mapPin,
                    title: 'Karachi',
                    destination: KarachiAttractions(),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: FontAwesomeIcons.mapPin,
                    title: 'Islamabad',
                    destination: IslamabadAttractions(),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: FontAwesomeIcons.mapPin,
                    title: 'Multan',
                    destination: MultanAttractions(),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: FontAwesomeIcons.mapPin,
                    title: 'Abbottabad',
                    destination: AbbottabadAttractions(),
                  ),

                  Divider(height: 24, color: Colors.grey[300]),
                  _buildDrawerItem(
                    context,
                    icon: FontAwesomeIcons.rightFromBracket,
                    title: 'Logout',
                    isLogout: true,
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
    Widget? destination,
    bool isLogout = false,
  }) {
    return ListTile(
      leading: FaIcon(icon, size: 18, color: Colors.deepPurple),
      title: Text(title, style: TextStyle(fontSize: 15, color: Colors.black87)),
      trailing: Icon(Icons.chevron_right, size: 18, color: Colors.grey[500]),
      onTap: () {
        Navigator.pop(context); // Close drawer first
        if (isLogout) {
          // Show confirmation
          showDialog(
            context: context,
            builder:
                (ctx) => AlertDialog(
                  title: Text("Logout"),
                  content: Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        // Add actual logout logic
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Logout successful")),
                        );
                      },
                      child: Text("Logout"),
                    ),
                  ],
                ),
          );
        } else if (destination != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        }
      },
    );
  }
}
