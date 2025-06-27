import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Restaurants extends StatefulWidget {
  const Restaurants({super.key});

  @override
  State<Restaurants> createState() => _RestaurantsState();
}

class _RestaurantsState extends State<Restaurants> {
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // Fetch data from Firestore
  void fetchData() async {
    final userdata =
        await FirebaseFirestore.instance.collection('Restaurants').get();
    final rawdata = userdata.docs
        .map((doc) => doc.data()..['id'] = doc.id)
        .toList(); // Add 'id' for each document
    setState(() {
      _products = rawdata;
      _filteredProducts = List.from(rawdata)
        ..sort((a, b) {
          double ratingA = double.tryParse(a["rating"].toString()) ?? 0.0;
          double ratingB = double.tryParse(b["rating"].toString()) ?? 0.0;
          return ratingB.compareTo(ratingA); // Sort descending
        });
      isLoading = false;
    });
  }

  // Update data in Firestore
  void updateData(String docId, Map<String, dynamic> newData) async {
    try {
      final db = FirebaseFirestore.instance.collection('Restaurants');
      await db.doc(docId).update(newData); // Use document ID to update
      print("Restaurants updated successfully!");
      fetchData(); // Refresh the list after updating
    } catch (e) {
      print("Error updating data: $e");
    }
  }

  // Delete data from Firestore
  void deleteData(String docId) async {
    try {
      final db = FirebaseFirestore.instance.collection('Restaurants');
      await db.doc(docId).delete(); // Use document ID to delete
      print("Restaurants deleted successfully!");
      fetchData(); // Refresh the list after deleting
    } catch (e) {
      print("Error deleting data: $e");
    }
  }

  // Delete confirmation dialog
  void deleteDialog(String docId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Confirmation',
              style: TextStyle(color: Colors.black)),
          content: const Text('Are you sure you want to delete this product?',
              style: TextStyle(color: Colors.black)),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () {
                deleteData(docId);
                Navigator.of(context).pop();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  void showEditDialog(Map<String, dynamic> attraction) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController description =
        TextEditingController(text: attraction["description"]);
    final TextEditingController imageurl =
        TextEditingController(text: attraction["image_url"]);
    final TextEditingController name =
        TextEditingController(text: attraction["name"]);
    final TextEditingController subcategoryController =
        TextEditingController(text: attraction["subCategory"]);
    final TextEditingController ratingController =
        TextEditingController(text: attraction["rating"].toString());
    final TextEditingController longitudeController =
        TextEditingController(text: attraction["longitude"].toString());
    final TextEditingController latitudeController =
        TextEditingController(text: attraction["latitude"].toString());
    final TextEditingController location =
        TextEditingController(text: attraction["location"]);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: description,
                      decoration: const InputDecoration(labelText: 'Description'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: imageurl,
                      decoration: const InputDecoration(labelText: 'Image URL'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: name,
                      decoration: const InputDecoration(labelText: 'Attraction Name'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: subcategoryController,
                      decoration: const InputDecoration(labelText: 'SubCategory'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: ratingController,
                      decoration: const InputDecoration(labelText: 'Rating'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: longitudeController,
                      decoration: const InputDecoration(labelText: 'Longitude'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: latitudeController,
                      decoration: const InputDecoration(labelText: 'Latitude'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: location,
                      decoration: const InputDecoration(labelText: 'Location'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              final updatedData = {
                                "description": description.text,
                                "image_url": imageurl.text,
                                "name": name.text,
                                "subCategory": subcategoryController.text,
                                "rating":
                                    double.tryParse(ratingController.text) ??
                                        0.0,
                                "longitude":
                                    double.tryParse(longitudeController.text) ??
                                        0.0,
                                "latitude":
                                    double.tryParse(latitudeController.text) ??
                                        0.0,
                                "location": location.text,
                              };
                              updateData(attraction["id"], updatedData);
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text('Update'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Show add product dialog
  void showAddProductDialog() {
    final formKey = GlobalKey<FormState>();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController imageurlController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController subcategoryController = TextEditingController();
    final TextEditingController ratingController = TextEditingController();
    final TextEditingController longitudeController = TextEditingController();
    final TextEditingController latitudeController = TextEditingController();
    final TextEditingController locationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom +
                    20, // Adjust for keyboard
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: 'Description'),
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null),
                    TextFormField(
                        controller: imageurlController,
                        decoration: const InputDecoration(labelText: 'Image URL'),
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null),
                    TextFormField(
                        controller: nameController,
                        decoration:
                            const InputDecoration(labelText: 'Attraction Name'),
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null),
                    TextFormField(
                        controller: subcategoryController,
                        decoration: const InputDecoration(labelText: 'SubCategory'),
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null),
                    TextFormField(
                        controller: ratingController,
                        decoration: const InputDecoration(labelText: 'Rating'),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null),
                    TextFormField(
                        controller: longitudeController,
                        decoration: const InputDecoration(labelText: 'Longitude'),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null),
                    TextFormField(
                        controller: latitudeController,
                        decoration: const InputDecoration(labelText: 'Latitude'),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null),
                    TextFormField(
                        controller: locationController,
                        decoration: const InputDecoration(labelText: 'Location'),
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              final newProduct = {
                                "description": descriptionController.text,
                                "image_url": imageurlController.text,
                                "name": nameController.text,
                                "subCategory": subcategoryController.text,
                                "rating":
                                    double.tryParse(ratingController.text) ??
                                        0.0,
                                "longitude":
                                    double.tryParse(longitudeController.text) ??
                                        0.0,
                                "latitude":
                                    double.tryParse(latitudeController.text) ??
                                        0.0,
                                "location": locationController.text
                              };
                              FirebaseFirestore.instance
                                  .collection('Restaurants')
                                  .add(newProduct)
                                  .then((_) {
                                fetchData(); // Refresh the list after adding the new product
                                Navigator.of(context).pop();
                              });
                            }
                          },
                          child: const Text('Add Attraction'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Search products
  void searchProducts(String query) {
    final results = _products.where((product) {
      final name = product['name'].toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredProducts = results;
    });
  }

  // Sort products by price or name
  void sortProducts(String criterion) {
    setState(() {
      if (criterion == 'Rating') {
        _filteredProducts.sort((a, b) {
          double ratingA = double.tryParse(a['rating'].toString()) ?? 0.0;
          double ratingB = double.tryParse(b['rating'].toString()) ?? 0.0;
          return ratingB.compareTo(ratingA); // Sort descending
        });
      } else if (criterion == 'Name') {
        _filteredProducts.sort((a, b) => a['name'].compareTo(b['name']));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants Data',
            style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: showAddProductDialog, // Show the Add Product Dialog
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search Restaurants',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.search, color: Colors.black),
                    ),
                    style: const TextStyle(color: Colors.black),
                    onChanged: (value) {
                      setState(() {
                        if (value.isEmpty) {
                          _filteredProducts =
                              _products; // Reset to all products when search query is empty
                        } else {
                          searchProducts(
                              value); // Filter the list based on the search query
                        }
                      });
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => sortProducts('Rating'),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                        foregroundColor:
                            Colors.white, // Set text color to white
                        padding:
                            const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Sort by Rating'),
                    ),
                    const SizedBox(width: 10), // Space between buttons
                    TextButton(
                      onPressed: () => sortProducts('Name'),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                        foregroundColor:
                            Colors.white, // Set text color to white
                        padding:
                            const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Sort by Name'),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return Card(
                        margin: const EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Name: ${product["name"]}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text("Description: ${product["description"]}",
                                  style: const TextStyle(color: Colors.black)),
                              Text("SubCategory: ${product["subCategory"]}",
                                  style: const TextStyle(color: Colors.black)),
                              Text("Rating: ${product["rating"]}",
                                  style: const TextStyle(color: Colors.black)),
                              product["image_url"] != null
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: CircleAvatar(
                                        radius: 40,
                                        backgroundImage: NetworkImage(
                                            product["image_url"] ?? ""),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => showEditDialog(product),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () =>
                                        deleteDialog(product["id"]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}