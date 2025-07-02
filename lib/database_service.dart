import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DatabaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // =================== AUTHENTICATION ===================

  // Register User and Store Data in Firestore
  Future<String?> createUser(
      String name, String email, String phone, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        // 🔥 Removed storing password in Firestore for security reasons
      });

      return "User registered successfully!";
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  // Login User
  Future<String?> loginUser(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return "Login Successfully";
    } catch (e) {
      return "Login Failed: ${e.toString()}";
    }
  }

  // =================== CITY MANAGEMENT ===================

  // Fetch City from Firestore
  Future<List<Map<String, dynamic>>> getCity() async {
    QuerySnapshot snapshot = await _firestore.collection('cities').get();
    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  // Add New City
  Future<void> addCity(String title, File imageFile) async {
    try {
      String imageUrl = await _uploadImage(imageFile, "cities_images", title);

      await _firestore.collection('cities').add({
        'title': title,
        'image_url': imageUrl,
      });
    } catch (e) {
      print("Error adding city: $e");
    }
  }

  // Delete City
  Future<void> deleteCity(String cityId) async {
    await _firestore.collection('cities').doc(cityId).delete();
  }

  // =================== CATEGORY MANAGEMENT ===================

  // Fetch Categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    QuerySnapshot snapshot = await _firestore.collection('categories').get();
    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  // Add New Category
  Future<void> addCategory(
      String title, File imageFile, String color1, String color2) async {
    try {
      String imageUrl =
          await _uploadImage(imageFile, "categories_images", title);

      await _firestore.collection('categories').add({
        'title': title,
        'image_url': imageUrl,
        'color1': color1,
        'color2': color2,
      });
    } catch (e) {
      print("Error adding category: $e");
    }
  }

  // =================== ATTRACTION MANAGEMENT ===================

  Future<List<Map<String, dynamic>>> getListings({
    required String category,
    String subCategory = "All",
    bool highestRated = true,
    String searchQuery = "",
  }) async {
    List<String> categories = [
      "Attractions",
      "Hotels",
      "Events",
      "Restaurants"
    ];
    List<Map<String, dynamic>> allListings = [];

    if (category == "All") {
      // Fetch from all collections
      for (String cat in categories) {
        Query query = _firestore.collection(cat);

        if (subCategory != "All") {
          query = query.where("subCategory", isEqualTo: subCategory);
        }

        if (searchQuery.isNotEmpty) {
          query = query
              .orderBy("name") // ✅ Required for search filtering
              .where("name", isGreaterThanOrEqualTo: searchQuery)
              .where("name", isLessThanOrEqualTo: searchQuery + '\uf8ff');
        } else if (highestRated) {
          query = query.orderBy("rating", descending: true);
        }

        QuerySnapshot snapshot = await query.get();
        allListings.addAll(snapshot.docs.map((doc) => {
              'documentId': doc.id, 
              'collection': cat, 
              ...doc.data() as Map<String, dynamic>
            }));
      }
    } else {
      // Fetch from a single category collection
      Query query = _firestore.collection(category);

      if (subCategory != "All") {
        query = query.where("subCategory", isEqualTo: subCategory);
      }

      if (searchQuery.isNotEmpty) {
        query = query
            .orderBy("name")
            .where("name", isGreaterThanOrEqualTo: searchQuery)
            .where("name", isLessThanOrEqualTo: searchQuery + '\uf8ff');
      } else if (highestRated) {
        query = query.orderBy("rating", descending: true);
      }

      QuerySnapshot snapshot = await query.get();
      allListings = snapshot.docs
          .map((doc) => {
                'documentId': doc.id, // ✅ Ensure document ID is correctly named
                'collection': category, // ✅ Store the collection name
                ...doc.data() as Map<String, dynamic>
              })
          .toList();
    }

    return allListings;
  }

  // =================== UTILITY FUNCTIONS ===================

  // Upload Image to Firebase Storage (Reusable)
  Future<String> _uploadImage(
      File imageFile, String folder, String title) async {
    Reference ref = _storage.ref().child('$folder/$title.jpg');
    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

// ==================//
}
