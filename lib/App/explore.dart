import 'package:city_guide_app/App/Home.dart';
import 'package:city_guide_app/App/detail.dart';
import 'package:city_guide_app/App/profile.dart';
import 'package:city_guide_app/database_service.dart';
import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

class explore extends StatefulWidget {
  const explore({super.key});

  @override
  State<explore> createState() => _exploreState();
}

class _exploreState extends State<explore> {
  final DatabaseService _dbService = DatabaseService();
  String selectedCategory = "All";
  bool highestRated = true;
  TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  List<String> categories = ["All", "Attractions", "Hotels", "Restaurants"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 60),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Search...",
                prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Category Dropdown
                DropdownButton<String>(
                  value: selectedCategory,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCategory = newValue!;
                    });
                  },
                  items: categories.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),

                // Sort by Rating
                Row(
                  children: [
                    const Text("Lowest"),
                    Switch(
                      value: highestRated,
                      onChanged: (bool value) {
                        setState(() {
                          highestRated = value;
                        });
                      },
                    ),
                    const Text("Highest"),
                  ],
                ),
              ],
            ),
          ),

          // Fetch & Display Listings
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _dbService.getListings(
                category: selectedCategory,
                highestRated: highestRated,
                searchQuery: searchQuery, // Pass search query to DB
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No listings available"));
                }

                List<Map<String, dynamic>> listings = snapshot.data!;

                return ListView.builder(
                  itemCount: listings.length,
                  itemBuilder: (context, index) {
                    return listingCard(listings[index], context);
                  },
                );
              },
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.reactCircle,
        height: 50,
        items: [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.explore, title: 'Explore'),
          TabItem(icon: Icons.person, title: 'Profile'),
        ],
        initialActiveIndex: 1,
        backgroundColor: Colors.grey[50],
        color: Colors.deepPurple,
        activeColor: Colors.deepPurpleAccent,
        onTap: (int index) {
          setState(() {
            // ✅ Forces the UI to refresh properly
            if (index == 0) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Home()));
            } else if (index == 1) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const explore()));
            } else if (index == 2) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Profile()));
            }
          });
        },
      ),
    );
  }

  // UI for Listing Card
  Widget listingCard(Map<String, dynamic> listing, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        shadowColor: Colors.black26,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Detail(
                  listing: listing,
                  collection: listing['collection'] ??
                      'unknown_collection', // Fix: Pass collection
                  documentId: listing['documentId'] ??
                      'unknown_document', // Fix: Pass document ID
                ),
              ),
            );
          },
          child: Row(
            children: [
              // Listing Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
                child: Image.network(
                  listing['image_url'] ?? "",
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.image_not_supported,
                      size: 100,
                      color: Colors.grey),
                ),
              ),

              // Listing Info
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        listing['name'] ?? "Unnamed Listing",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Description
                      Text(
                        listing['description'] ?? "No description available",
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black54),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 6),

                      // Rating Row
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            "${listing['rating'] ?? 'N/A'} ⭐",
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Arrow Icon
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child:
                    Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
