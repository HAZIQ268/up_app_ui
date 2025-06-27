import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CitiesScreen extends StatefulWidget {
  const CitiesScreen({super.key});

  @override
  State<CitiesScreen> createState() => _CitiesScreenState();
}

class _CitiesScreenState extends State<CitiesScreen> {
  List<Map<String, dynamic>> _cities = [];
  List<Map<String, dynamic>> _filteredCities = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCities();
  }

  Future<void> _fetchCities() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('cities').get();
      final cities =
          snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

      setState(() {
        _cities = cities;
        _filteredCities = cities;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching cities: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateCity(String docId, Map<String, dynamic> newData) async {
    try {
      await FirebaseFirestore.instance
          .collection('cities')
          .doc(docId)
          .update(newData);
      _fetchCities();
    } catch (e) {
      print("Error updating city: $e");
    }
  }

  Future<void> _deleteCity(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('cities').doc(docId).delete();
      _fetchCities();
    } catch (e) {
      print("Error deleting city: $e");
    }
  }

  void _showDeleteDialog(String docId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirm Delete'),
            content: Text('Are you sure you want to delete this city?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  _deleteCity(docId);
                  Navigator.pop(context);
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _showEditDialog(Map<String, dynamic> city) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: city['title'] ?? '');
    final descriptionController = TextEditingController(
      text: city['description'] ?? '',
    );
    final imageController = TextEditingController(
      text: city['image_url'] ?? '',
    );

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Edit City',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'City Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 3,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: imageController,
                      decoration: InputDecoration(
                        labelText: 'Image URL',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              _updateCity(city['id'], {
                                'title': titleController.text,
                                'description': descriptionController.text,
                                'image_url': imageController.text,
                              });
                              Navigator.pop(context);
                            }
                          },
                          child: Text('Update'),
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

  void _showAddDialog() {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final imageController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Add New City',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'City Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 3,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: imageController,
                      decoration: InputDecoration(
                        labelText: 'Image URL',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              FirebaseFirestore.instance
                                  .collection('cities')
                                  .add({
                                    'title': titleController.text,
                                    'description': descriptionController.text,
                                    'image_url': imageController.text,
                                  })
                                  .then((_) {
                                    _fetchCities();
                                    Navigator.pop(context);
                                  });
                            }
                          },
                          child: Text('Add'),
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

  void _searchCities(String query) {
    setState(() {
      _filteredCities =
          query.isEmpty
              ? List.from(_cities)
              : _cities.where((city) {
                final name = city['title']?.toLowerCase() ?? '';
                return name.contains(query.toLowerCase());
              }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cities Management', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: _showAddDialog,
            tooltip: 'Add City',
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search cities...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      onChanged: _searchCities,
                    ),
                  ),
                  Expanded(
                    child:
                        _filteredCities.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    FontAwesomeIcons.city,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No cities found',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  TextButton(
                                    onPressed: _showAddDialog,
                                    child: Text('Add your first city'),
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _filteredCities.length,
                              itemBuilder: (context, index) {
                                final city = _filteredCities[index];
                                return Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin: EdgeInsets.only(bottom: 16),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => _showEditDialog(city),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (city["image_url"] != null &&
                                            city["image_url"].isNotEmpty)
                                          ClipRRect(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(12),
                                            ),
                                            child: Image.network(
                                              city["image_url"],
                                              height: 180,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Container(
                                                    height: 180,
                                                    color: Colors.grey[200],
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.broken_image,
                                                      ),
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        Padding(
                                          padding: EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                city["title"] ?? '',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                city["description"] ?? '',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                              SizedBox(height: 12),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.edit,
                                                      color: Colors.blue,
                                                    ),
                                                    onPressed:
                                                        () => _showEditDialog(
                                                          city,
                                                        ),
                                                  ),
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                    ),
                                                    onPressed:
                                                        () => _showDeleteDialog(
                                                          city["id"],
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
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
