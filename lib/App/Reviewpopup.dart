import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewsPopup extends StatefulWidget {
  final String collection;
  final String documentId;
  final String listingName;

  const ReviewsPopup({
    Key? key,
    required this.collection,
    required this.documentId,
    required this.listingName,
  }) : super(key: key);

  @override
  _ReviewsPopupState createState() => _ReviewsPopupState();
}

class _ReviewsPopupState extends State<ReviewsPopup> {
  List<Map<String, dynamic>> reviews = [];
  final TextEditingController reviewController = TextEditingController();
  double userRating = 5.0; // Default rating

  @override
  void initState() {
    super.initState();
    getReviews();
  }

  void getReviews() async {
    FirebaseFirestore.instance
        .collection(widget.collection)
        .doc(widget.documentId)
        .collection('reviews')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        reviews = snapshot.docs.map((doc) {
          var data = doc.data();
          return {
            'username': data['username'] ?? "Anonymous",
            'text': data['text'] ?? "No review available",
            'rating': data['rating'] ?? 0,
            'profileImage': data['profileImage'] ?? "", // ✅ Fetching image URL
          };
        }).toList();
      });
    });
  }

  // Add a new review to Firestore
  Future<void> addReview() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to leave a review!")),
      );
      return;
    }

    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection("users").doc(userId).get();

    String username = userSnapshot.exists ? userSnapshot['name'] : "Guest";
    String userImage =
        userSnapshot.exists ? userSnapshot['profileImage'] ?? "" : "";

    String reviewText = reviewController.text.trim();

    if (reviewText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Review cannot be empty!")),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection(widget.collection)
        .doc(widget.documentId)
        .collection("reviews")
        .add({
      'rating': userRating,
      'text': reviewText,
      'timestamp': FieldValue.serverTimestamp(),
      'username': username,
      'profileImage': userImage, // ✅ Storing the image URL
    });

    reviewController.clear();
    setState(() {
      userRating = 5.0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Review added successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context)
            .viewInsets
            .bottom, // Prevents keyboard overlap
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Text(
                "Reviews for ${widget.listingName}",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Reviews List
              SizedBox(
                height: 300, // Set a fixed height for scrolling
                child: reviews.isEmpty
                    ? const Center(child: Text("No reviews yet"))
                    : ListView.builder(
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          var data = reviews[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              leading: data['profileImage'] != null &&
                                      data['profileImage'].isNotEmpty
                                  ? CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(data['profileImage']),
                                    )
                                  : const CircleAvatar(
                                      backgroundColor: Colors.blueAccent,
                                      child: Icon(Icons.person,
                                          color: Colors.white),
                                    ),
                              title: Text(data['username'] ?? "Anonymous"),
                              subtitle:
                                  Text(data['text'] ?? "No review available"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("${data['rating']}"),
                                  const Icon(Icons.star,
                                      color: Colors.amber, size: 18),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              const Divider(),

              // Add Review Section
              const Text(
                "Add a Review",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),

              // Rating Bar
              RatingBar.builder(
                initialRating: userRating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    userRating = rating;
                  });
                },
              ),

              const SizedBox(height: 10),

              // Text Field and Submit Button
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: reviewController,
                      decoration: InputDecoration(
                        hintText: "Write a review...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.deepPurple),
                    onPressed: addReview,
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
