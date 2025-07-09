import 'package:city_guide_app/App/Abbotabad.dart';
import 'package:city_guide_app/App/Islamabad.dart';
import 'package:city_guide_app/App/Karachi.dart';
import 'package:city_guide_app/App/explore.dart';
import 'package:city_guide_app/App/lahore.dart';
import 'package:city_guide_app/App/login.dart';
import 'package:city_guide_app/App/multan.dart';
import 'package:city_guide_app/App/profile.dart';
import 'package:city_guide_app/App/signup.dart';
import 'package:city_guide_app/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  String userName = "Guest";
  String userEmail = "guest@example.com";
  final DatabaseService _databaseService = DatabaseService();
  List<Map<String, dynamic>> cities = [];
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _notificationsEnabled = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
    _loadUserData();
    _fetchCities();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<String> getProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('profileImage') ??
        'https://cdn-icons-png.flaticon.com/512/3135/3135715.png';
  }

  _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'Guest';
      userEmail = prefs.getString('userEmail') ?? 'guest@example.com';
    });

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          userName = data['name'] ?? 'Guest';
          userEmail = data['email'] ?? 'guest@example.com';
        });

        await prefs.setString('userName', userName);
        await prefs.setString('userEmail', userEmail);
      }
    }
  }

  void _fetchCities() async {
    List<Map<String, dynamic>> fetchedCity = await _databaseService.getCity();
    List<String> popularCityNames = ['Multan', 'Karachi', 'Abbottabad', 'Islamabad', 'Lahore'];
    List<Map<String, dynamic>> popularCities = fetchedCity
        .where((city) => popularCityNames.contains(city['title']))
        .toList();

    popularCities.sort((a, b) {
      return popularCityNames.indexOf(a['title']).compareTo(popularCityNames.indexOf(b['title']));
    });

    setState(() {
      cities = popularCities;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Explore Pakistan',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Search cities, places...',
                    hintStyle: TextStyle(color: Colors.grey[500], fontFamily: 'Poppins'),
                    prefixIcon: Icon(Icons.search, color: Colors.blueGrey[300]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ).animate().fadeIn(delay: 100.ms),
            ),

            // Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Image.network(
                        'https://cdn-icons-png.flaticon.com/512/1865/1865269.png',
                        width: 120,
                        height: 120,
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Discover Hidden Gems',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Explore the best places in Pakistan',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              'Get Started',
                              style: TextStyle(
                                color: Color(0xFF2575FC),
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms),
            ),

            // Categories
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
              child: Text(
                'Categories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ).animate().fadeIn(delay: 300.ms),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.9,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  List<Map<String, dynamic>> categories = [
                    {
                      'name': 'Attractions', 
                      'icon': Icons.landscape, 
                      'color': Color(0xFF6A11CB),
                      'screen': explore()
                    },
                    {
                      'name': 'Food', 
                      'icon': Icons.restaurant, 
                      'color': Color(0xFFFE5F55),
                      'screen': explore()
                    },
                    {
                      'name': 'Hotels', 
                      'icon': Icons.hotel, 
                      'color': Color(0xFF2575FC),
                      'screen': explore()
                    },
                    {
                      'name': 'Events', 
                      'icon': Icons.event, 
                      'color': Color(0xFFF9A826),
                      'screen': explore()
                    },
                  ];
                  
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => categories[index]['screen']),
                      );
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: categories[index]['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                            gradient: LinearGradient(
                              colors: [
                                categories[index]['color'].withOpacity(0.2),
                                categories[index]['color'].withOpacity(0.4),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Icon(
                            categories[index]['icon'],
                            color: categories[index]['color'],
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          categories[index]['name'],
                          style: TextStyle(
                            fontSize: 12, 
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ).animate().fadeIn(delay: (100 * index + 300).ms),
                  );
                },
              ),
            ),

            // Popular Cities
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Popular Cities',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const explore()),
                      );
                    },
                    child: Text(
                      "See All",
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms),
            ),
            
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: cities.length,
                      itemBuilder: (context, index) {
                        return _buildCityCard(
                          context: context,
                          imageUrl: cities[index]['image_url'] ?? '',
                          title: cities[index]['title'] ?? '',
                          onTap: () {
                            switch (cities[index]['title']) {
                              case 'Karachi':
                                Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => KarachiPage()));
                                break;
                              case 'Lahore':
                                Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => LahorePage()));
                                break;
                              case 'Multan':
                                Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => Multan()));
                                break;
                              case 'Islamabad':
                                Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => IslamabadPage()));
                                break;
                              case 'Abbottabad':
                                Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => Abbotabad()));
                                break;
                              default:
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CategoryPage(
                                        category: cities[index]['title'] ?? ''),
                                  ),
                                );
                                break;
                            }
                          },
                        ).animate().fadeIn(delay: (100 * index + 400).ms);
                      },
                    ),
                  ),
          ],
        ),
      ),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.reactCircle,
        height: 60,
        curveSize: 80,
        items: [
          TabItem(icon: Icons.home_outlined, title: 'Home'),
          TabItem(icon: Icons.explore_outlined, title: 'Explore'),
          TabItem(icon: Icons.person_outline, title: 'Profile'),
        ],
        initialActiveIndex: 2,
        backgroundColor: Colors.white,
        color: Colors.grey,
        activeColor: Colors.deepPurple,
        shadowColor: Colors.deepPurple.withOpacity(0.2),
        elevation: 5,
        onTap: (int index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Home()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => explore()),
            );
          }
        },
      ).animate().slide(delay: 1000.ms),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            FutureBuilder<String>(
              future: getProfileImage(),
              builder: (context, snapshot) {
                String profileImageUrl = snapshot.data ??
                    'https://cdn-icons-png.flaticon.com/512/3135/3135715.png';
                return Container(
                  padding: EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(profileImageUrl),
                      ),
                      SizedBox(height: 15),
                      Text(
                        userName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        userEmail,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.home_outlined,
              title: 'Home',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _buildDrawerItem(
              icon: Icons.explore_outlined,
              title: 'Explore',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const explore()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.person_outline,
              title: 'Profile',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Profile()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () {},
            ),
            Divider(color: Colors.grey[300], indent: 20, endIndent: 20),
            if (userEmail == "guest@example.com") ...[
              _buildDrawerItem(
                icon: Icons.login,
                title: 'Login',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                },
              ),
              _buildDrawerItem(
                icon: Icons.person_add_outlined,
                title: 'Sign Up',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Signup()),
                  );
                },
              ),
            ] else ...[
              _buildDrawerItem(
                icon: Icons.logout,
                title: 'Logout',
                onTap: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.remove('userName');
                  await prefs.remove('userEmail');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey[700]),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Poppins',
          color: Colors.blueGrey[800],
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildCityCard({
    required BuildContext context,
    required String imageUrl,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              Image.network(
                imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: Center(child: Icon(Icons.image, color: Colors.grey)),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 15,
                left: 15,
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
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

class CategoryPage extends StatelessWidget {
  final String category;

  const CategoryPage({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: Center(
        child: Text(
          'Welcome to $category page!',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}