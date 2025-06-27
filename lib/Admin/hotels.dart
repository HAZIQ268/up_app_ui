import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HotelsScreen extends StatefulWidget {
  const HotelsScreen({super.key});

  @override
  State<HotelsScreen> createState() => _HotelsScreenState();
}

class _HotelsScreenState extends State<HotelsScreen> {
  List<Map<String, dynamic>> _hotels = [];
  List<Map<String, dynamic>> _filteredHotels = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _sortCriteria = 'Rating';

  @override
  void initState() {
    super.initState();
    _fetchHotels();
  }

  Future<void> _fetchHotels() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('Hotels').get();
      final hotels = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      setState(() {
        _hotels = hotels;
        _filteredHotels = List.from(hotels);
        _sortHotels();
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching hotels: $e");
      setState(() => _isLoading = false);
    }
  }

  void _sortHotels() {
    setState(() {
      if (_sortCriteria == 'Rating') {
        _filteredHotels.sort((a, b) {
          double ratingA = double.tryParse(a["rating"].toString()) ?? 0.0;
          double ratingB = double.tryParse(b["rating"].toString()) ?? 0.0;
          return ratingB.compareTo(ratingA);
        });
      } else {
        _filteredHotels.sort((a, b) => a['name'].compareTo(b['name']));
      }
    });
  }

  Future<void> _updateHotel(String docId, Map<String, dynamic> newData) async {
    try {
      await FirebaseFirestore.instance.collection('Hotels').doc(docId).update(newData);
      _fetchHotels();
    } catch (e) {
      print("Error updating hotel: $e");
    }
  }

  Future<void> _deleteHotel(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('Hotels').doc(docId).delete();
      _fetchHotels();
    } catch (e) {
      print("Error deleting hotel: $e");
    }
  }

  void _showDeleteDialog(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this hotel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteHotel(docId);
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> hotel) {
    final formKey = GlobalKey<FormState>();
    final controllers = {
      'description': TextEditingController(text: hotel["description"]),
      'image_url': TextEditingController(text: hotel["image_url"]),
      'name': TextEditingController(text: hotel["name"]),
      'subCategory': TextEditingController(text: hotel["subCategory"]),
      'rating': TextEditingController(text: hotel["rating"].toString()),
      'longitude': TextEditingController(text: hotel["longitude"].toString()),
      'latitude': TextEditingController(text: hotel["latitude"].toString()),
      'location': TextEditingController(text: hotel["location"]),
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
                  Text('Edit Hotel', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  _buildFormField(controllers['name']!, 'Hotel Name'),
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
                          backgroundColor: Colors.blue[800],
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
                            _updateHotel(hotel["id"], updatedData);
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
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
                  Text('Add New Hotel', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  _buildFormField(controllers['name']!, 'Hotel Name'),
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
                          backgroundColor: Colors.blue[800],
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final newHotel = {
                              "description": controllers['description']!.text,
                              "image_url": controllers['image_url']!.text,
                              "name": controllers['name']!.text,
                              "subCategory": controllers['subCategory']!.text,
                              "rating": double.tryParse(controllers['rating']!.text) ?? 0.0,
                              "longitude": double.tryParse(controllers['longitude']!.text) ?? 0.0,
                              "latitude": double.tryParse(controllers['latitude']!.text) ?? 0.0,
                              "location": controllers['location']!.text,
                            };
                            FirebaseFirestore.instance.collection('Hotels').add(newHotel).then((_) {
                              _fetchHotels();
                              Navigator.pop(context);
                            });
                          }
                        },
                        child: Text('Add Hotel'),
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

  void _searchHotels(String query) {
    setState(() {
      _filteredHotels = query.isEmpty
          ? List.from(_hotels)
          : _hotels.where((hotel) {
              final name = hotel['name'].toLowerCase();
              return name.contains(query.toLowerCase());
            }).toList();
      _sortHotels();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hotels Management', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: _showAddDialog,
            tooltip: 'Add Hotel',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search hotels...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    onChanged: _searchHotels,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text('Sort by:', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      ChoiceChip(
                        label: Text('Rating'),
                        selected: _sortCriteria == 'Rating',
                        onSelected: (selected) {
                          setState(() {
                            _sortCriteria = 'Rating';
                            _sortHotels();
                          });
                        },
                      ),
                      SizedBox(width: 10),
                      ChoiceChip(
                        label: Text('Name'),
                        selected: _sortCriteria == 'Name',
                        onSelected: (selected) {
                          setState(() {
                            _sortCriteria = 'Name';
                            _sortHotels();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _filteredHotels.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FontAwesomeIcons.hotel, size: 48, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('No hotels found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                              SizedBox(height: 8),
                              TextButton(
                                onPressed: _showAddDialog,
                                child: Text('Add your first hotel'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: _filteredHotels.length,
                          itemBuilder: (context, index) {
                            final hotel = _filteredHotels[index];
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: EdgeInsets.only(bottom: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (hotel["image_url"] != null && hotel["image_url"].isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                      child: Image.network(
                                        hotel["image_url"],
                                        height: 180,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          height: 180,
                                          color: Colors.grey[200],
                                          child: Center(child: Icon(Icons.broken_image)),
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
                                                hotel["name"],
                                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Icon(Icons.star, color: Colors.amber, size: 20),
                                                SizedBox(width: 4),
                                                Text(
                                                  hotel["rating"].toString(),
                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          hotel["description"],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(color: Colors.grey[700]),
                                        ),
                                        SizedBox(height: 8),
                                        Wrap(
                                          spacing: 8,
                                          children: [
                                            Chip(
                                              label: Text(hotel["subCategory"]),
                                              backgroundColor: Colors.blue[50],
                                              labelStyle: TextStyle(color: Colors.blue[800]),
                                            ),
                                            Chip(
                                              label: Text(hotel["location"]),
                                              backgroundColor: Colors.green[50],
                                              labelStyle: TextStyle(color: Colors.green[800]),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.edit, color: Colors.blue),
                                              onPressed: () => _showEditDialog(hotel),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete, color: Colors.red),
                                              onPressed: () => _showDeleteDialog(hotel["id"]),
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
