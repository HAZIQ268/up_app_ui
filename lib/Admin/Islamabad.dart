import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IslamabadAttractions extends StatefulWidget {
  const IslamabadAttractions({super.key});

  @override
  State<IslamabadAttractions> createState() => _IslamabadAttractionsState();
}

class _IslamabadAttractionsState extends State<IslamabadAttractions> {
  List<Map<String, dynamic>> _attractions = [];
  List<Map<String, dynamic>> _filteredAttractions = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _sortCriteria = 'Rating';

  @override
  void initState() {
    super.initState();
    _fetchAttractions();
  }

  Future<void> _fetchAttractions() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('Islamabad').get();
      final attractions = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      
      setState(() {
        _attractions = attractions;
        _filteredAttractions = List.from(attractions);
        _sortAttractions();
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching attractions: $e");
      setState(() => _isLoading = false);
    }
  }

  void _sortAttractions() {
    setState(() {
      if (_sortCriteria == 'Rating') {
        _filteredAttractions.sort((a, b) {
          double ratingA = double.tryParse(a["rating"].toString()) ?? 0.0;
          double ratingB = double.tryParse(b["rating"].toString()) ?? 0.0;
          return ratingB.compareTo(ratingA);
        });
      } else {
        _filteredAttractions.sort((a, b) => a['name'].compareTo(b['name']));
      }
    });
  }

  Future<void> _updateAttraction(String docId, Map<String, dynamic> newData) async {
    try {
      await FirebaseFirestore.instance.collection('Islamabad').doc(docId).update(newData);
      _fetchAttractions();
    } catch (e) {
      print("Error updating attraction: $e");
    }
  }

  Future<void> _deleteAttraction(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('Islamabad').doc(docId).delete();
      _fetchAttractions();
    } catch (e) {
      print("Error deleting attraction: $e");
    }
  }

  void _showDeleteDialog(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this attraction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteAttraction(docId);
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> attraction) {
    final formKey = GlobalKey<FormState>();
    final controllers = {
      'description': TextEditingController(text: attraction["description"]),
      'image_url': TextEditingController(text: attraction["image_url"]),
      'name': TextEditingController(text: attraction["name"]),
      'subCategory': TextEditingController(text: attraction["subCategory"]),
      'rating': TextEditingController(text: attraction["rating"].toString()),
      'longitude': TextEditingController(text: attraction["longitude"].toString()),
      'latitude': TextEditingController(text: attraction["latitude"].toString()),
      'location': TextEditingController(text: attraction["location"]),
    };

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Edit Attraction', 
                      style: TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      )),
                  SizedBox(height: 20),
                  _buildFormField(controllers['name']!, 'Attraction Name'),
                  _buildFormField(controllers['description']!, 'Description', maxLines: 3),
                  _buildFormField(controllers['subCategory']!, 'Category'),
                  _buildFormField(controllers['rating']!, 'Rating (0-5)', isNumber: true),
                  _buildFormField(controllers['location']!, 'Location'),
                  _buildFormField(controllers['image_url']!, 'Image URL'),
                  _buildFormField(controllers['longitude']!, 'Longitude', isNumber: true),
                  _buildFormField(controllers['latitude']!, 'Latitude', isNumber: true),
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
                          backgroundColor: Colors.green[800],
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final updatedData = {
                              "description": controllers['description']!.text,
                              "image_url": controllers['image_url']!.text,
                              "name": controllers['name']!.text,
                              "subCategory": controllers['subCategory']!.text,
                              "rating": double.tryParse(controllers['rating']!.text) ?? 0.0,
                              "longitude": double.tryParse(controllers['longitude']!.text) ?? 0.0,
                              "latitude": double.tryParse(controllers['latitude']!.text) ?? 0.0,
                              "location": controllers['location']!.text,
                            };
                            _updateAttraction(attraction["id"], updatedData);
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
      ),
    );
  }

  Widget _buildFormField(TextEditingController controller, String label, 
      {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.green[800]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.green[800]!, width: 2),
          ),
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        validator: (value) => value!.isEmpty ? 'Required' : null,
      ),
    );
  }

  void _showAddDialog() {
    final formKey = GlobalKey<FormState>();
    final controllers = {
      'description': TextEditingController(),
      'image_url': TextEditingController(),
      'name': TextEditingController(),
      'subCategory': TextEditingController(),
      'rating': TextEditingController(),
      'longitude': TextEditingController(),
      'latitude': TextEditingController(),
      'location': TextEditingController(),
    };

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Add New Attraction', 
                      style: TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      )),
                  SizedBox(height: 20),
                  _buildFormField(controllers['name']!, 'Attraction Name'),
                  _buildFormField(controllers['description']!, 'Description', maxLines: 3),
                  _buildFormField(controllers['subCategory']!, 'Category'),
                  _buildFormField(controllers['rating']!, 'Rating (0-5)', isNumber: true),
                  _buildFormField(controllers['location']!, 'Location'),
                  _buildFormField(controllers['image_url']!, 'Image URL'),
                  _buildFormField(controllers['longitude']!, 'Longitude', isNumber: true),
                  _buildFormField(controllers['latitude']!, 'Latitude', isNumber: true),
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
                          backgroundColor: Colors.green[800],
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final newAttraction = {
                              "description": controllers['description']!.text,
                              "image_url": controllers['image_url']!.text,
                              "name": controllers['name']!.text,
                              "subCategory": controllers['subCategory']!.text,
                              "rating": double.tryParse(controllers['rating']!.text) ?? 0.0,
                              "longitude": double.tryParse(controllers['longitude']!.text) ?? 0.0,
                              "latitude": double.tryParse(controllers['latitude']!.text) ?? 0.0,
                              "location": controllers['location']!.text,
                            };
                            FirebaseFirestore.instance.collection('Islamabad').add(newAttraction)
                              .then((_) {
                                _fetchAttractions();
                                Navigator.pop(context);
                              });
                          }
                        },
                        child: Text('Add Attraction'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _searchAttractions(String query) {
    setState(() {
      _filteredAttractions = query.isEmpty
          ? List.from(_attractions)
          : _attractions.where((attraction) {
              final name = attraction['name'].toLowerCase();
              return name.contains(query.toLowerCase());
            }).toList();
      _sortAttractions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Islamabad Attractions', 
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
        centerTitle: true,
        backgroundColor: Colors.green[800],
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: _showAddDialog,
            tooltip: 'Add Attraction',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.green[800]))
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search attractions...',
                      prefixIcon: Icon(Icons.search, color: Colors.green[800]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    onChanged: _searchAttractions,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text('Sort by:', 
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          )),
                      SizedBox(width: 10),
                      ChoiceChip(
                        label: Text('Rating'),
                        selected: _sortCriteria == 'Rating',
                        selectedColor: Colors.green[800],
                        onSelected: (selected) {
                          setState(() {
                            _sortCriteria = 'Rating';
                            _sortAttractions();
                          });
                        },
                      ),
                      SizedBox(width: 10),
                      ChoiceChip(
                        label: Text('Name'),
                        selected: _sortCriteria == 'Name',
                        selectedColor: Colors.green[800],
                        onSelected: (selected) {
                          setState(() {
                            _sortCriteria = 'Name';
                            _sortAttractions();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _filteredAttractions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FontAwesomeIcons.mountainCity, 
                                  size: 48, 
                                  color: Colors.grey),
                              SizedBox(height: 16),
                              Text('No attractions found', 
                                  style: TextStyle(
                                    fontSize: 18, 
                                    color: Colors.grey)),
                              SizedBox(height: 8),
                              TextButton(
                                onPressed: _showAddDialog,
                                child: Text('Add your first attraction',
                                    style: TextStyle(color: Colors.green[800])),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: _filteredAttractions.length,
                          itemBuilder: (context, index) {
                            final attraction = _filteredAttractions[index];
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: EdgeInsets.only(bottom: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (attraction["image_url"] != null && attraction["image_url"].isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                      child: Image.network(
                                        attraction["image_url"],
                                        height: 180,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => 
                                          Container(
                                            height: 180,
                                            color: Colors.grey[200],
                                            child: Center(
                                              child: Icon(Icons.broken_image, color: Colors.grey)),
                                          ),
                                      ),
                                    ),
                                  Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                attraction["name"],
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Icon(Icons.star, color: Colors.amber, size: 20),
                                                SizedBox(width: 4),
                                                Text(
                                                  attraction["rating"].toString(),
                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          attraction["description"],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(color: Colors.grey[700]),
                                        ),
                                        SizedBox(height: 8),
                                        Wrap(
                                          spacing: 8,
                                          children: [
                                            Chip(
                                              label: Text(attraction["subCategory"]),
                                              backgroundColor: Colors.green[50],
                                              labelStyle: TextStyle(color: Colors.green[800]),
                                            ),
                                            Chip(
                                              label: Text(attraction["location"]),
                                              backgroundColor: Colors.blue[50],
                                              labelStyle: TextStyle(color: Colors.blue[800]),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.edit, color: Colors.green[800]),
                                              onPressed: () => _showEditDialog(attraction),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete, color: Colors.red),
                                              onPressed: () => _showDeleteDialog(attraction["id"]),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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