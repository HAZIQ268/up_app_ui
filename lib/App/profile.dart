import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:city_guide_app/App/Explore.dart';
import 'package:city_guide_app/App/home.dart';
import 'package:liquid_swipe/liquid_swipe.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();

  String _profileImageUrl =
      'https://cdn-icons-png.flaticon.com/512/3135/3135715.png';
  File? _imageFile;
  Uint8List? _webImageBytes;
  bool _isLoading = false;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;
  final _formKey = GlobalKey<FormState>();

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
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
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
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          _nameController.text = data['name'] ?? '';
          _emailController.text = data['email'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _cityController.text = data['city'] ?? '';
          _profileImageUrl = data['profileImage'] ?? _profileImageUrl;

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userName', _nameController.text);
          await prefs.setString('userEmail', _emailController.text);
          await prefs.setString('profileImage', _profileImageUrl);
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadProfileImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    if (kIsWeb) {
      _webImageBytes = await picked.readAsBytes();
    } else {
      _imageFile = File(picked.path);
    }
    setState(() {});

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final ref = FirebaseStorage.instance.ref(
        'profile_images/${user.uid}.jpg',
      );

      if (kIsWeb) {
        await ref.putData(
          _webImageBytes!,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        await ref.putFile(_imageFile!);
      }

      final downloadUrl = await ref.getDownloadURL();
      _profileImageUrl = downloadUrl;
      _imageFile = null;
      _webImageBytes = null;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'profileImage': downloadUrl},
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImage', downloadUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile image updated successfully!'),
            backgroundColor: primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: const EdgeInsets.all(20),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> saveProfileData() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
            'name': _nameController.text,
            'email': _emailController.text,
            'phone': _phoneController.text,
            'city': _cityController.text,
          });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _nameController.text);
      await prefs.setString('userEmail', _emailController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully!'),
            backgroundColor: primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: const EdgeInsets.all(20),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: LiquidSwipe(
        pages: [
          _isLoading
              ? Center(child: CircularProgressIndicator(color: primaryColor))
              : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildHeader(size, theme),
                      _buildAvatar(),
                      _buildFormFields(theme),
                    ],
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
        color: lightTextColor,
        activeColor: accentColor,
        elevation: 10,
        onTap: (int i) {
          if (i == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Home()),
            );
          } else if (i == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => Explore()),
            );
          }
        },
      ),
    );
  }

  Widget _buildHeader(Size size, ThemeData theme) {
    return Container(
      height: size.height * 0.25,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, secondaryColor],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
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
            child:
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed:
                      () => Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const Home(),
                          transitionsBuilder:
                              (_, anim, __, child) => SlideTransition(
                                position: Tween(
                                  begin: const Offset(-1, 0),
                                  end: Offset.zero,
                                ).animate(anim),
                                child: child,
                              ),
                        ),
                      ),
                ).animate().fadeIn(delay: 200.ms).slideX(),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'My Profile',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black.withOpacity(0.2),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 8),
                Text(
                  'Manage your personal information',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ).animate().fadeIn(delay: 400.ms),
              ],
            ),
          ),
        ],
      ),
    ).animate().scale(delay: 100.ms);
  }

  Widget _buildAvatar() {
    return Transform.translate(
      offset: const Offset(0, -60),
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
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryColor, secondaryColor],
                  ),
                ),
              ),
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 5),
                ),
                child: ClipOval(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child:
                        kIsWeb
                            ? (_webImageBytes != null
                                ? Image.memory(
                                  _webImageBytes!,
                                  fit: BoxFit.cover,
                                  key: ValueKey(_webImageBytes!.length),
                                )
                                : Image.network(
                                  _profileImageUrl,
                                  fit: BoxFit.cover,
                                  key: ValueKey(_profileImageUrl),
                                ))
                            : (_imageFile != null
                                ? Image.file(
                                  _imageFile!,
                                  fit: BoxFit.cover,
                                  key: ValueKey(_imageFile),
                                )
                                : Image.network(
                                  _profileImageUrl,
                                  fit: BoxFit.cover,
                                  key: ValueKey(_profileImageUrl),
                                )),
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
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primaryColor, secondaryColor],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                ).animate().shake(delay: 500.ms),
              ),
            ],
          ).animate().scale(delay: 200.ms),
        ),
      ),
    );
  }

  Widget _buildFormFields(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _animatedField(
            child: _buildProfileField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person_outline,
              hint: 'Enter your full name',
              validator:
                  (v) =>
                      (v == null || v.isEmpty)
                          ? 'Please enter your name'
                          : null,
            ),
          ),
          const SizedBox(height: 20),
          _animatedField(
            child: _buildProfileField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              hint: 'Enter your email',
              readOnly: true,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please enter your email';
                if (!v.contains('@')) return 'Please enter a valid email';
                return null;
              },
            ),
          ),
          const SizedBox(height: 20),
          _animatedField(
            child: _buildProfileField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone_android_outlined,
              hint: 'Enter your phone number',
              validator: (v) {
                if (v == null || v.isEmpty)
                  return 'Please enter your phone number';
                if (v.length < 10) return 'Please enter a valid phone number';
                return null;
              },
            ),
          ),
          const SizedBox(height: 20),
          _animatedField(
            child: _buildProfileField(
              controller: _cityController,
              label: 'City',
              icon: Icons.location_city_outlined,
              hint: 'Enter your city',
              validator:
                  (v) =>
                      (v == null || v.isEmpty)
                          ? 'Please enter your city'
                          : null,
            ),
          ),
          const SizedBox(height: 40),
          _animatedField(
            delay: 800,
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.zero,
                ),
                onPressed: saveProfileData,
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primaryColor, secondaryColor],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Update Profile',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _animatedField({required Widget child, int delay = 400}) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(opacity: _fadeAnimation, child: child),
    ).animate().fadeIn(delay: delay.ms);
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
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
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
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Container(
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                ),
                child: Icon(icon, color: primaryColor),
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 16,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: primaryColor),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.redAccent),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.redAccent),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
