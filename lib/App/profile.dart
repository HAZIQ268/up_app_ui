import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:city_guide_app/App/explore.dart';
import 'package:city_guide_app/App/home.dart';
import 'package:liquid_swipe/liquid_swipe.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  String _profileImageUrl = 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png';
  File? _imageFile;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutQuint,
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _animationController.forward();
    fetchUserData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> fetchUserData() async {
    setState(() => _isLoading = true);
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = data['name'] ?? '';
          _emailController.text = data['email'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _cityController.text = data['city'] ?? '';
          _profileImageUrl = data['profileImage'] ?? _profileImageUrl;
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', data['name'] ?? '');
        await prefs.setString('userEmail', data['email'] ?? '');
        await prefs.setString('profileImage', _profileImageUrl);
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _uploadProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      _imageFile = File(pickedFile.path);
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('${user.uid}.jpg');
        
        await ref.putFile(_imageFile!);
        String downloadUrl = await ref.getDownloadURL();

        setState(() => _profileImageUrl = downloadUrl);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'profileImage': downloadUrl});

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('profileImage', downloadUrl);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Profile image updated successfully!"),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            backgroundColor: Colors.deepPurple,
            elevation: 10,
            margin: EdgeInsets.all(20),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> saveProfileData() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'city': _cityController.text,
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', _nameController.text);
        await prefs.setString('userEmail', _emailController.text);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Profile updated successfully!"),
            backgroundColor: Colors.deepPurple,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 10,
            margin: EdgeInsets.all(20),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error updating profile: $e"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: LiquidSwipe(
        pages: [
          _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
                  ),
                )
              : SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Animated Gradient Header
                        Container(
                          height: size.height * 0.25,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.deepPurple.shade700,
                                Colors.deepPurple.shade400,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(40),
                              bottomRight: Radius.circular(40),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 40,
                                left: 20,
                                child: IconButton(
                                  icon: Icon(Icons.arrow_back_ios_new, 
                                    color: Colors.white, size: 28),
                                  onPressed: () => Navigator.pushReplacement(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) => Home(),
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                        return SlideTransition(
                                          position: Tween<Offset>(
                                            begin: Offset(-1, 0),
                                            end: Offset.zero,
                                          ).animate(animation),
                                          child: child,
                                        );
                                      },
                                    ),
                                  ),
                                ).animate().fadeIn(delay: 200.ms).slideX(),
                              ),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "My Profile",
                                      style: theme.textTheme.headlineMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 10,
                                            color: Colors.black.withOpacity(0.2),
                                          )
                                        ],
                                      ),
                                    ).animate().fadeIn(delay: 300.ms),
                                    SizedBox(height: 8),
                                    Text(
                                      "Manage your personal information",
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ).animate().fadeIn(delay: 400.ms),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ).animate().scale(delay: 100.ms),

                        // Profile Picture Section
                        Transform.translate(
                          offset: Offset(0, -60),
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: GestureDetector(
                              onTap: _uploadProfileImage,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 140,
                                    height: 140,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.deepPurple.shade100,
                                          Colors.deepPurple.shade50,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 130,
                                    height: 130,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 5,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: AnimatedSwitcher(
                                        duration: Duration(milliseconds: 500),
                                        child: _imageFile != null
                                            ? Image.file(
                                                _imageFile!,
                                                fit: BoxFit.cover,
                                                key: ValueKey(_imageFile),
                                              )
                                            : Image.network(
                                                _profileImageUrl,
                                                fit: BoxFit.cover,
                                                loadingBuilder: (context, child, loadingProgress) {
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
                                                errorBuilder: (context, error, stackTrace) =>
                                                    Icon(Icons.person, size: 60, color: Colors.deepPurple),
                                                key: ValueKey(_profileImageUrl),
                                              ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 5,
                                    right: 5,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.deepPurple,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 3,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ).animate().shake(delay: 500.ms),
                                  ),
                                ],
                              ).animate().scale(delay: 200.ms),
                            ),
                          ),
                        ),

                        // Form Fields
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 25),
                          child: Column(
                            children: [
                              SizedBox(height: 20),
                              SlideTransition(
                                position: _slideAnimation,
                                child: FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: _buildProfileField(
                                    controller: _nameController,
                                    label: "Full Name",
                                    icon: Icons.person_outline,
                                    hint: "Enter your full name",
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your name';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              SlideTransition(
                                position: _slideAnimation,
                                child: FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: _buildProfileField(
                                    controller: _emailController,
                                    label: "Email",
                                    icon: Icons.email_outlined,
                                    hint: "Enter your email",
                                    readOnly: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      if (!value.contains('@')) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              SlideTransition(
                                position: _slideAnimation,
                                child: FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: _buildProfileField(
                                    controller: _phoneController,
                                    label: "Phone Number",
                                    icon: Icons.phone_android_outlined,
                                    hint: "Enter your phone number",
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your phone number';
                                      }
                                      if (value.length < 10) {
                                        return 'Please enter a valid phone number';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              SlideTransition(
                                position: _slideAnimation,
                                child: FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: _buildProfileField(
                                    controller: _cityController,
                                    label: "City",
                                    icon: Icons.location_city_outlined,
                                    hint: "Enter your city",
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your city';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 40),

                              // Save Button with Ripple Effect
                              SlideTransition(
                                position: _slideAnimation,
                                child: FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: Container(
                                    width: double.infinity,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.deepPurple.shade600,
                                          Colors.deepPurple.shade400,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.deepPurple.withOpacity(0.3),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                          offset: Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(15),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(15),
                                        onTap: saveProfileData,
                                        splashColor: Colors.white.withOpacity(0.3),
                                        highlightColor: Colors.transparent,
                                        child: Center(
                                          child: Text(
                                            "UPDATE PROFILE",
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ).animate().scale(delay: 800.ms),
                                ),
                              ),
                              SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.reactCircle,
        height: 70,
        curveSize: 100,
        items: [
          TabItem(icon: Icons.home_outlined, title: 'Home'),
          TabItem(icon: Icons.explore_outlined, title: 'Explore'),
          TabItem(icon: Icons.person_outline, title: 'Profile'),
        ],
        initialActiveIndex: 2,
        backgroundColor: Colors.white,
        color: Colors.grey,
        activeColor: Colors.deepPurple,
        shadowColor: Colors.deepPurple.withOpacity(0.3),
        elevation: 10,
        onTap: (int index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const Home(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  var curve = Curves.easeInOutBack;
                  var tween = Tween(begin: Offset(-1, 0), end: Offset.zero)
                      .chain(CurveTween(curve: curve));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
              ),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => explore(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  var curve = Curves.easeInOutBack;
                  var tween = Tween(begin: Offset(1, 0), end: Offset.zero)
                      .chain(CurveTween(curve: curve));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
              ),
            );
          }
        },
      ).animate().slide(delay: 1000.ms),
    );
  }

  Widget _buildProfileField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.deepPurple.shade600,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            validator: validator,
            style: TextStyle(color: Colors.deepPurple.shade800,),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Container(
                margin: EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1),
                  ),
                ),
                child: Icon(icon, color: Colors.deepPurple),
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.deepPurple),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.redAccent),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.redAccent),
              ),
            ),
          ),
        ),
      ],
    );
  }
}