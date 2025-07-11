import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:city_guide_app/App/explore.dart';
import 'package:city_guide_app/App/home.dart';

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

  String _profileImageUrl = '';
  File? _imageFile;
  bool _isLoading = false;
  late AnimationController _animationController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
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
          _profileImageUrl = data['profileImage'] ?? '';
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', data['name'] ?? '');
        await prefs.setString('userEmail', data['email'] ?? '');
        if (data['profileImage'] != null) {
          await prefs.setString('profileImage', data['profileImage']);
        }
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

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'profileImage': downloadUrl});

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('profileImage', downloadUrl);

        setState(() {
          _profileImageUrl = downloadUrl;
          _isLoading = false;
        });

        _showSuccessSnackbar("Profile image updated successfully!");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar("Error: ${e.toString()}");
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

        _showSuccessSnackbar("Profile updated successfully!");
      } catch (e) {
        _showErrorSnackbar("Error updating profile: ${e.toString()}");
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 5,
        margin: const EdgeInsets.all(15),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFF44336),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Container(
      width: 120,
      height: 120,
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
        child:
            _imageFile != null
                ? Image.file(_imageFile!, fit: BoxFit.cover)
                : _profileImageUrl.isNotEmpty
                ? CachedNetworkImage(
                  imageUrl: _profileImageUrl,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Color(0xFF6A11CB)),
                        ),
                      ),
                  errorWidget: (context, url, error) => _buildDefaultAvatar(),
                )
                : _buildDefaultAvatar(),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: const Color(0xFFF3E5F5),
      child: const Center(
        child: Icon(Icons.person, size: 50, color: Color(0xFF6A11CB)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF6A11CB)),
                ),
              )
              : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    expandedHeight: 200,
                    floating: false,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                    leading: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Transform.translate(
                      offset: const Offset(0, -60),
                      child: Center(
                        child: GestureDetector(
                          onTap: _uploadProfileImage,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              _buildProfileImage().animate().scale(
                                delay: 200.ms,
                              ),
                              Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6A11CB),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ).animate().shake(delay: 500.ms),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 20,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildProfileField(
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
                                )
                                .animate()
                                .fadeIn(delay: 300.ms)
                                .slideX(begin: 0.2),
                            const SizedBox(height: 20),
                            _buildProfileField(
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
                                )
                                .animate()
                                .fadeIn(delay: 400.ms)
                                .slideX(begin: 0.2),
                            const SizedBox(height: 20),
                            _buildProfileField(
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
                            ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.2),
                            const SizedBox(height: 20),
                            _buildProfileField(
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
                                )
                                .animate()
                                .fadeIn(delay: 600.ms)
                                .slideX(begin: 0.2),
                            const SizedBox(height: 40),
                            ElevatedButton(
                                  onPressed: saveProfileData,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6A11CB),
                                    foregroundColor: Colors.white,
                                    elevation: 5,
                                    shadowColor: const Color(
                                      0xFF6A11CB,
                                    ).withOpacity(0.3),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 40,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    "UPDATE PROFILE",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: 700.ms)
                                .slideY(begin: 0.5),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.reactCircle,
        height: 60,
        items: const [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.explore, title: 'Explore'),
          TabItem(icon: Icons.person, title: 'Profile'),
        ],
        initialActiveIndex: 2,
        backgroundColor: Colors.white,
        color: Colors.grey,
        activeColor: const Color(0xFF6A11CB),
        elevation: 10,
        shadowColor: const Color(0xFF6A11CB).withOpacity(0.2),
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
              color: const Color(0xFF6A11CB).withOpacity(0.8),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
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
            style: TextStyle(color: Colors.grey[800]),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(icon, color: const Color(0xFF6A11CB)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
