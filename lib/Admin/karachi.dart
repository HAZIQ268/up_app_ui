import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class karachi extends StatefulWidget {
  const karachi({super.key});

  @override
  State<karachi> createState() => _karachiState();
}

class _karachiState extends State<karachi> {
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  String _sortCriteria = 'Rating';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final userdata = await FirebaseFirestore.instance.collection('karachi').get();
      final rawdata = userdata.docs.map((doc) => doc.data()..['id'] = doc.id).toList();
      
      setState(() {
        _products = rawdata;
        _filteredProducts = List.from(rawdata)..sort(_sortByCriteria);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showSnackBar('Error fetching data: $e', isError: true);
    }
  }

  int _sortByCriteria(a, b) {
    switch (_sortCriteria) {
      case 'Rating':
        double ratingA = double.tryParse(a["rating"].toString()) ?? 0.0;
        double ratingB = double.tryParse(b["rating"].toString()) ?? 0.0;
        return ratingB.compareTo(ratingA);
      case 'Name':
        return a['name'].compareTo(b['name']);
      default:
        return 0;
    }
  }

  Future<void> updateData(String docId, Map<String, dynamic> newData) async {
    try {
      await FirebaseFirestore.instance.collection('karachi').doc(docId).update(newData);
      _showSnackBar('Attraction updated successfully!');
      fetchData();
    } catch (e) {
      _showSnackBar('Error updating data: $e', isError: true);
    }
  }

  Future<void> deleteData(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('karachi').doc(docId).delete();
      _showSnackBar('Attraction deleted successfully!');
      fetchData();
    } catch (e) {
      _showSnackBar('Error deleting data: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void deleteDialog(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Attraction', 
               style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete this attraction?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              deleteData(docId);
              Navigator.of(context).pop();
            },
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void showEditDialog(Map<String, dynamic> attraction) {
    final formKey = GlobalKey<FormState>();
    final controllers = {
      "description": TextEditingController(text: attraction["description"]),
      "image_url": TextEditingController(text: attraction["image_url"]),
      "name": TextEditingController(text: attraction["name"]),
      "subCategory": TextEditingController(text: attraction["subCategory"]),
      "rating": TextEditingController(text: attraction["rating"].toString()),
      "longitude": TextEditingController(text: attraction["longitude"].toString()),
      "latitude": TextEditingController(text: attraction["latitude"].toString()),
      "location": TextEditingController(text: attraction["location"]),
    };

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Edit Attraction',
                     style: TextStyle(
                       fontSize: 22,
                       fontWeight: FontWeight.bold,
                       color: Colors.teal.shade800,
                     )),
                SizedBox(height: 20),
                _buildFormField(controllers["description"]!, 'Description'),
                _buildFormField(controllers["image_url"]!, 'Image URL'),
                _buildFormField(controllers["name"]!, 'Attraction Name'),
                _buildFormField(controllers["subCategory"]!, 'SubCategory'),
                _buildFormField(controllers["rating"]!, 'Rating', isNumber: true),
                _buildFormField(controllers["longitude"]!, 'Longitude', isNumber: true),
                _buildFormField(controllers["latitude"]!, 'Latitude', isNumber: true),
                _buildFormField(controllers["location"]!, 'Location'),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade800,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          final updatedData = {
                            "description": controllers["description"]!.text,
                            "image_url": controllers["image_url"]!.text,
                            "name": controllers["name"]!.text,
                            "subCategory": controllers["subCategory"]!.text,
                            "rating": double.tryParse(controllers["rating"]!.text) ?? 0.0,
                            "longitude": double.tryParse(controllers["longitude"]!.text) ?? 0.0,
                            "latitude": double.tryParse(controllers["latitude"]!.text) ?? 0.0,
                            "location": controllers["location"]!.text,
                          };
                          updateData(attraction["id"], updatedData);
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text('Update', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(TextEditingController controller, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (value) => value!.isEmpty ? 'Required' : null,
      ),
    );
  }

  void showAddProductDialog() {
    final formKey = GlobalKey<FormState>();
    final controllers = {
      "description": TextEditingController(),
      "image_url": TextEditingController(),
      "name": TextEditingController(),
      "subCategory": TextEditingController(),
      "rating": TextEditingController(),
      "longitude": TextEditingController(),
      "latitude": TextEditingController(),
      "location": TextEditingController(),
    };

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Add New Attraction',
                     style: TextStyle(
                       fontSize: 22,
                       fontWeight: FontWeight.bold,
                       color: Colors.teal.shade800,
                     )),
                SizedBox(height: 20),
                _buildFormField(controllers["description"]!, 'Description'),
                _buildFormField(controllers["image_url"]!, 'Image URL'),
                _buildFormField(controllers["name"]!, 'Attraction Name'),
                _buildFormField(controllers["subCategory"]!, 'SubCategory'),
                _buildFormField(controllers["rating"]!, 'Rating', isNumber: true),
                _buildFormField(controllers["longitude"]!, 'Longitude', isNumber: true),
                _buildFormField(controllers["latitude"]!, 'Latitude', isNumber: true),
                _buildFormField(controllers["location"]!, 'Location'),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade800,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          final newProduct = {
                            "description": controllers["description"]!.text,
                            "image_url": controllers["image_url"]!.text,
                            "name": controllers["name"]!.text,
                            "subCategory": controllers["subCategory"]!.text,
                            "rating": double.tryParse(controllers["rating"]!.text) ?? 0.0,
                            "longitude": double.tryParse(controllers["longitude"]!.text) ?? 0.0,
                            "latitude": double.tryParse(controllers["latitude"]!.text) ?? 0.0,
                            "location": controllers["location"]!.text,
                          };
                          FirebaseFirestore.instance.collection('karachi').add(newProduct).then((_) {
                            fetchData();
                            Navigator.of(context).pop();
                          });
                        }
                      },
                      child: Text('Add Attraction', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void searchProducts(String query) {
    setState(() {
      _filteredProducts = _products.where((product) {
        final name = product['name'].toString().toLowerCase();
        final description = product['description'].toString().toLowerCase();
        return name.contains(query.toLowerCase()) || 
               description.contains(query.toLowerCase());
      }).toList();
    });
  }

  void sortProducts(String criterion) {
    setState(() {
      _sortCriteria = criterion;
      _filteredProducts.sort(_sortByCriteria);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Karachi Attractions',
               style: TextStyle(
                 color: Colors.white,
                 fontWeight: FontWeight.bold,
                 fontSize: 20,
               )),
           backgroundColor: Colors.indigo,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.add, size: 28),
            onPressed: showAddProductDialog,
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.teal.shade800,
                strokeWidth: 3,
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search attractions...',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        prefixIcon: Icon(Icons.search, color: Colors.teal.shade800),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      ),
                      onChanged: searchProducts,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSortButton('Rating', Icons.star),
                      _buildSortButton('Name', Icons.sort_by_alpha),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Expanded(
                  child: _filteredProducts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 60, color: Colors.grey.shade400),
                              Text('No attractions found',
                                   style: TextStyle(
                                     color: Colors.grey.shade600,
                                     fontSize: 16,
                                   )),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.only(bottom: 16),
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            final attraction = _filteredProducts[index];
                            return _buildAttractionCard(attraction);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddProductDialog,
        backgroundColor: Colors.teal.shade800,
        child: Icon(Icons.add, color: Colors.white),
        elevation: 4,
      ),
    );
  }

  Widget _buildSortButton(String label, IconData icon) {
    return OutlinedButton.icon(
      icon: Icon(icon, size: 16, color: _sortCriteria == label ? Colors.teal.shade800 : Colors.grey),
      label: Text(label, style: TextStyle(color: _sortCriteria == label ? Colors.teal.shade800 : Colors.grey)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: _sortCriteria == label ? Colors.teal.shade800 : Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      onPressed: () => sortProducts(label),
    );
  }

  Widget _buildAttractionCard(Map<String, dynamic> attraction) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => showEditDialog(attraction),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (attraction["image_url"] != null && attraction["image_url"].toString().isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        attraction["image_url"],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey.shade200,
                          child: Icon(Icons.broken_image, color: Colors.grey.shade400),
                        ),
                      ),
                    ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          attraction["name"] ?? 'No Name',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          attraction["subCategory"] ?? 'No Category',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 8),
                        RatingBarIndicator(
                          rating: double.tryParse(attraction["rating"].toString()) ?? 0.0,
                          itemBuilder: (context, index) => Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 20,
                          direction: Axis.horizontal,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                attraction["description"] ?? 'No description available',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.teal.shade800),
                    onPressed: () => showEditDialog(attraction),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteDialog(attraction["id"]),
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