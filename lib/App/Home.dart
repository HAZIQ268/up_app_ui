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
    // Filter only the 5 popular cities
    List<String> popularCityNames = ['Multan', 'Karachi', 'Abbottabad', 'Islamabad', 'Lahore'];
    List<Map<String, dynamic>> popularCities = fetchedCity
        .where((city) => popularCityNames.contains(city['title']))
        .toList();

    // Ensure correct ordering
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'City Guide',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Image with Search Bar
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1519501025264-65ba15a82390?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2000&q=80'),
                  fit: BoxFit.cover,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.5),
                      Colors.black.withOpacity(0.2),
                    ],
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Discover Amazing Places',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Explore the best locations in your city',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
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
                          hintText: 'Search for places...',
                          prefixIcon: const Icon(Icons.search, color: Colors.blue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Category Section
            const Padding(
              padding: EdgeInsets.only(left: 20, top: 30, bottom: 10),
              child: Text(
                'Explore Cities:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            
            // Categories Grid - MODIFIED SECTION
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
                      'color': Colors.red,
                      'screen': explore() // Added screen reference
                    },
                    {
                      'name': 'Restaurants', 
                      'icon': Icons.restaurant, 
                      'color': Colors.green,
                      'screen': explore() // Added screen reference
                    },
                    {
                      'name': 'Hotels', 
                      'icon': Icons.hotel, 
                      'color': Colors.blue,
                      'screen': explore() // Added screen reference
                    },

                    {
                      'name': 'Events', 
                      'icon': Icons.event, 
                      'color': Colors.orange,
                      'screen': explore() // Added screen reference
                    },
                  ];
                  
                  return InkWell( // Wrapped with InkWell
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => categories[index]['screen']),
                      );
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: categories[index]['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: categories[index]['color'].withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            categories[index]['icon'],
                            color: categories[index]['color'],
                            size: 35,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          categories[index]['name'],
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ).animate().fadeIn(delay: (100 * index).ms),
                  );
                },
              ),
            ),
            
            // Popular Cities section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Popular Cities',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const explore()),
                          );
                        },
                        child: const Text(
                          "See All",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildCitiesGrid(),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          FutureBuilder<String>(
            future: getProfileImage(),
            builder: (context, snapshot) {
              String profileImageUrl = snapshot.data ??
                  'https://cdn-icons-png.flaticon.com/512/3135/3135715.png';
              return UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                accountName: Text(
                  userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                accountEmail: Text(userEmail),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(profileImageUrl),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.explore),
            title: const Text('Explore'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const explore()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Profile()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              // Show settings dialog
            },
          ),
          const Divider(),
          if (userEmail == "guest@example.com") ...[
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Sign Up'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Signup()),
                );
              },
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
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
    );
  }

  Widget _buildCitiesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.9,
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
        ).animate().fadeIn(delay: (100 * index).ms);
      },
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
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
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
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return ConvexAppBar(
      style: TabStyle.fixedCircle,
      items: [
        TabItem(icon: Icons.home, title: 'Home'),
        TabItem(icon: Icons.explore, title: 'Explore'),
        TabItem(icon: Icons.person, title: 'Profile'),
      ],
      initialActiveIndex: 0,
      backgroundColor: Colors.white,
      color: Colors.grey,
      activeColor: Colors.blue,
      onTap: (int index) {
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const explore()),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Profile()),
          );
        }
      },
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