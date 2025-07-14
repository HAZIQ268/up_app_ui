import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:city_guide_app/App/Abbotabad.dart';
import 'package:city_guide_app/App/Islamabad.dart';
import 'package:city_guide_app/App/Karachi.dart';
import 'package:city_guide_app/App/Explore.dart';
import 'package:city_guide_app/App/lahore.dart';
import 'package:city_guide_app/App/login.dart';
import 'package:city_guide_app/App/multan.dart';
import 'package:city_guide_app/App/profile.dart';
import 'package:city_guide_app/App/signup.dart';
import 'package:city_guide_app/database_service.dart';

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
  List<Map<String, dynamic>> filteredCities = [];
  bool isLoading = true;
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();

  // Color Scheme
  final Color primaryColor = const Color(0xFF6A11CB);
  final Color secondaryColor = const Color(0xFF2575FC);
  final Color accentColor = const Color(0xFF7C4FDC);
  final Color backgroundColor = const Color(0xFFF8F9FA);
  final Color textColor = const Color(0xFF333333);
  final Color lightTextColor = const Color(0xFF666666);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadUserData();
    _fetchCities();
    _searchController.addListener(_filterCities);
  }

  void _filterCities() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredCities =
          cities.where((city) {
            final title = city['title']?.toString().toLowerCase() ?? '';
            return title.contains(query);
          }).toList();
    });
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
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
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
    List<String> popularCityNames = [
      'Multan',
      'Karachi',
      'Abbottabad',
      'Islamabad',
      'Lahore',
    ];
    List<Map<String, dynamic>> popularCities =
        fetchedCity
            .where((city) => popularCityNames.contains(city['title']))
            .toList();

    popularCities.sort((a, b) {
      return popularCityNames
          .indexOf(a['title'])
          .compareTo(popularCityNames.indexOf(b['title']));
    });

    setState(() {
      cities = popularCities;
      filteredCities = popularCities;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor.withOpacity(0.8),
                secondaryColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $userName',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                fontFamily: 'Poppins',
              ),
            ),
            const Text(
              'Explore Pakistan',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search cities...',
                    hintStyle: TextStyle(color: lightTextColor),
                    prefixIcon: Icon(Icons.search, color: lightTextColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: Icon(Icons.close, color: lightTextColor),
                              onPressed: () {
                                _searchController.clear();
                                _filterCities();
                              },
                            )
                            : null,
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
                    colors: [primaryColor, secondaryColor],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: secondaryColor.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Image.asset(
                        '../assets/images/banner_img_icon.png',
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
                          const SizedBox(height: 5),
                          Text(
                            'Explore the best places in Pakistan',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              'Get Started',
                              style: TextStyle(
                                color: secondaryColor,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms),
            ),

            // Categories Section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: textColor,
                    ),
                  ),
                  TextButton(
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => Explore()),
                        ),
                    child: Text(
                      'See All',
                      style: TextStyle(
                        color: secondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                children: [
                  _buildCategoryCard(
                    icon: Icons.landscape,
                    title: 'Attractions',
                    color: primaryColor,
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => Explore()),
                        ),
                  ),
                  _buildCategoryCard(
                    icon: Icons.restaurant,
                    title: 'Food',
                    color: const Color(0xFFFE5F55),
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => Explore()),
                        ),
                  ),
                  _buildCategoryCard(
                    icon: Icons.hotel,
                    title: 'Hotels',
                    color: secondaryColor,
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => Explore()),
                        ),
                  ),
                  _buildCategoryCard(
                    icon: Icons.event,
                    title: 'Events',
                    color: const Color(0xFFF9A826),
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => Explore()),
                        ),
                  ),
                ].animate(interval: 100.ms).slideX(begin: 0.5),
              ),
            ),

            // Popular Cities Section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Popular Cities',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: textColor,
                    ),
                  ),
                  TextButton(
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const Explore()),
                        ),
                    child: Text(
                      'See All',
                      style: TextStyle(
                        color: secondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            isLoading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 0.85,
                        ),
                    itemCount:
                        _searchController.text.isEmpty
                            ? cities.length
                            : filteredCities.length,
                    itemBuilder: (context, index) {
                      final city =
                          _searchController.text.isEmpty
                              ? cities[index]
                              : filteredCities[index];
                      return _buildCityCard(
                        context: context,
                        imageUrl: city['image_url'] ?? '',
                        title: city['title'] ?? '',
                        onTap: () {
                          switch (city['title']) {
                            case 'Karachi':
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => KarachiPage(),
                                ),
                              );
                              break;
                            case 'Lahore':
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LahorePage(),
                                ),
                              );
                              break;
                            case 'Multan':
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Multan(),
                                ),
                              );
                              break;
                            case 'Islamabad':
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => IslamabadPage(),
                                ),
                              );
                              break;
                            case 'Abbottabad':
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Abbotabad(),
                                ),
                              );
                              break;
                            default:
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => CategoryPage(
                                        category: city['title'] ?? '',
                                      ),
                                ),
                              );
                              break;
                          }
                        },
                      ).animate().fadeIn(delay: (100 * index).ms);
                    },
                  ),
                ),
          ],
        ),
      ),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.reactCircle,
        height: 60,
        items: const [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.explore, title: 'Explore'),
          TabItem(icon: Icons.person, title: 'Profile'),
        ],
        initialActiveIndex: 0,
        backgroundColor: Colors.white,
        color: lightTextColor,
        activeColor: accentColor,
        elevation: 10,
        onTap: (int i) {
          if (i == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Home()),
            );
          } else if (i == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Explore()),
            );
          } else if (i == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Profile()),
            );
          }
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: Container(
        decoration: BoxDecoration(color: backgroundColor),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            FutureBuilder<String>(
              future: getProfileImage(),
              builder: (context, snapshot) {
                String profileImageUrl =
                    snapshot.data ??
                    'https://cdn-icons-png.flaticon.com/512/3135/3135715.png';
                return Container(
                  padding: const EdgeInsets.only(
                    top: 60,
                    bottom: 30,
                    left: 25,
                    right: 25,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primaryColor, secondaryColor],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.network(
                              profileImageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder:
                                  (context, error, stackTrace) => const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        userEmail,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
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
                  MaterialPageRoute(builder: (context) => const Explore()),
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
            Divider(
              color: Colors.grey[300],
              indent: 25,
              endIndent: 25,
              thickness: 1,
              height: 30,
            ),
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
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
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
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: primaryColor),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
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
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Image.network(
                imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value:
                          progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!
                              : null,
                      color: primaryColor,
                    ),
                  );
                },
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(Icons.image, color: Colors.grey),
                      ),
                    ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.favorite_border,
                    color: Colors.white,
                    size: 20,
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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF6A11CB).withOpacity(0.8),
                const Color(0xFF2575FC).withOpacity(0.8),
              ],
            ),
          ),
        ),
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
