import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CitiesAdminPanel extends StatefulWidget {
  const CitiesAdminPanel({super.key});

  @override
  State<CitiesAdminPanel> createState() => _CitiesAdminPanelState();
}

class _CitiesAdminPanelState extends State<CitiesAdminPanel> {
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  String _sortCriterion = 'Name';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final userdata =
          await FirebaseFirestore.instance.collection('cities').get();
      final rawdata =
          userdata.docs.map((doc) => doc.data()..['id'] = doc.id).toList();
      setState(() {
        _products = rawdata;
        _filteredProducts = rawdata;
        isLoading = false;
        _sortProducts(_sortCriterion);
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar('Error fetching cities: $e', isError: true);
    }
  }

  Future<void> updateData(String docId, Map<String, dynamic> newData) async {
    try {
      await FirebaseFirestore.instance
          .collection('cities')
          .doc(docId)
          .update(newData);
      _showSnackBar('City updated successfully!');
      fetchData();
    } catch (e) {
      _showSnackBar('Error updating city: $e', isError: true);
    }
  }

  Future<void> deleteData(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('cities').doc(docId).delete();
      _showSnackBar('City deleted successfully!');
      fetchData();
    } catch (e) {
      _showSnackBar('Error deleting city: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _deleteDialog(String docId, String cityName) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Delete City',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text('Are you sure you want to delete "$cityName"?'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
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

  void _showEditDialog(Map<String, dynamic> city) {
    final formKey = GlobalKey<FormState>();
    final controllers = {
      "description": TextEditingController(text: city["description"]),
      "image_url": TextEditingController(text: city["image_url"]),
      "title": TextEditingController(text: city["title"]),
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit City',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          _buildFormField(
                            controllers["title"]!,
                            'City Name',
                            Icons.location_city,
                          ),
                          SizedBox(height: 20),
                          _buildFormField(
                            controllers["description"]!,
                            'Description',
                            Icons.description,
                            maxLines: 4,
                          ),
                          SizedBox(height: 20),
                          _buildFormField(
                            controllers["image_url"]!,
                            'Image URL',
                            Icons.image,
                          ),
                          SizedBox(height: 20),
                          if (controllers["image_url"]!.text.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                controllers["image_url"]!.text,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      height: 150,
                                      color: Colors.grey.shade200,
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 50,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final updatedData = {
                        "description": controllers["description"]!.text,
                        "image_url": controllers["image_url"]!.text,
                        "title": controllers["title"]!.text,
                      };
                      updateData(city["id"], updatedData);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(
                    'Save Changes',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildFormField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.indigo),
        prefixIcon: Icon(icon, color: Colors.indigo),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.indigo, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (value) => value!.isEmpty ? 'Required' : null,
    );
  }

  void _showAddCityDialog() {
    final formKey = GlobalKey<FormState>();
    final controllers = {
      "description": TextEditingController(),
      "image_url": TextEditingController(),
      "title": TextEditingController(),
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add New City',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          _buildFormField(
                            controllers["title"]!,
                            'City Name',
                            Icons.location_city,
                          ),
                          SizedBox(height: 20),
                          _buildFormField(
                            controllers["description"]!,
                            'Description',
                            Icons.description,
                            maxLines: 4,
                          ),
                          SizedBox(height: 20),
                          _buildFormField(
                            controllers["image_url"]!,
                            'Image URL',
                            Icons.image,
                          ),
                          SizedBox(height: 20),
                          if (controllers["image_url"]!.text.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                controllers["image_url"]!.text,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      height: 150,
                                      color: Colors.grey.shade200,
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 50,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final newCity = {
                        "description": controllers["description"]!.text,
                        "image_url": controllers["image_url"]!.text,
                        "title": controllers["title"]!.text,
                      };
                      FirebaseFirestore.instance
                          .collection('cities')
                          .add(newCity)
                          .then((_) {
                            fetchData();
                            Navigator.of(context).pop();
                          });
                    }
                  },
                  child: Text(
                    'Add City',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _sortProducts(String criterion) {
    setState(() {
      _sortCriterion = criterion;
      _filteredProducts.sort((a, b) => a['title'].compareTo(b['title']));
    });
  }

  void _searchProducts(String query) {
    setState(() {
      _filteredProducts =
          _products.where((city) {
            final name = city['title'].toLowerCase();
            return name.contains(query.toLowerCase());
          }).toList();
      _sortProducts(_sortCriterion);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
  appBar: AppBar(
  systemOverlayStyle: const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ),
  title: const Text(
    'Cities Management',
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
  centerTitle: true,
  backgroundColor: Colors.transparent,
  elevation: 0,
  iconTheme: const IconThemeData(color: Colors.white),
  actionsIconTheme: const IconThemeData(color: Colors.white),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
  ),
  flexibleSpace: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.indigo.shade700,
          Colors.blue.shade500,
        ],
      ),
    ),
  ),
  actions: [
    IconButton(
      icon: const Icon(Icons.add),
      onPressed: _showAddCityDialog,
    ),
  ],
),

      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
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
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search cities...',
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          prefixIcon: Icon(Icons.search, color: Colors.indigo),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 20,
                          ),
                          suffixIcon:
                              searchController.text.isNotEmpty
                                  ? IconButton(
                                    icon: Icon(Icons.clear, color: Colors.grey),
                                    onPressed: () {
                                      searchController.clear();
                                      _searchProducts('');
                                    },
                                  )
                                  : null,
                        ),
                        onChanged: _searchProducts,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Text(
                          'Sort by:',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        SizedBox(width: 10),
                        ChoiceChip(
                          label: Text('Name'),
                          selected: _sortCriterion == 'Name',
                          onSelected: (selected) => _sortProducts('Name'),
                          selectedColor: Colors.indigo,
                          labelStyle: TextStyle(
                            color:
                                _sortCriterion == 'Name'
                                    ? Colors.white
                                    : Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child:
                        _filteredProducts.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 60,
                                    color: Colors.grey.shade400,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'No cities found',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  if (searchController.text.isNotEmpty)
                                    TextButton(
                                      onPressed: () {
                                        searchController.clear();
                                        _searchProducts('');
                                      },
                                      child: Text(
                                        'Clear search',
                                        style: TextStyle(color: Colors.indigo),
                                      ),
                                    ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              padding: EdgeInsets.only(bottom: 16),
                              itemCount: _filteredProducts.length,
                              itemBuilder: (context, index) {
                                final city = _filteredProducts[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                  child: Card(
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () => _showEditDialog(city),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (city["image_url"] != null &&
                                                city["image_url"].isNotEmpty)
                                              Container(
                                                width: 80,
                                                height: 80,
                                                margin: EdgeInsets.only(
                                                  right: 12,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                      city["image_url"],
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    city["title"],
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.indigo,
                                                    ),
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text(
                                                    city["description"]
                                                                ?.length >
                                                            50
                                                        ? '${city["description"].substring(0, 50)}...'
                                                        : city["description"] ??
                                                            '',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            PopupMenuButton(
                                              icon: Icon(
                                                Icons.more_vert,
                                                color: Colors.grey.shade600,
                                              ),
                                              itemBuilder:
                                                  (context) => [
                                                    PopupMenuItem(
                                                      child: ListTile(
                                                        leading: Icon(
                                                          Icons.edit,
                                                          color: Colors.indigo,
                                                        ),
                                                        title: Text('Edit'),
                                                        onTap: () {
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                          _showEditDialog(city);
                                                        },
                                                      ),
                                                    ),
                                                    PopupMenuItem(
                                                      child: ListTile(
                                                        leading: Icon(
                                                          Icons.delete,
                                                          color: Colors.red,
                                                        ),
                                                        title: Text('Delete'),
                                                        onTap: () {
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                          _deleteDialog(
                                                            city["id"],
                                                            city["title"],
                                                          );
                                                        },
                                                      ),
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
                            ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCityDialog,
        backgroundColor: Colors.indigo,
        child: Icon(Icons.add, color: Colors.white, size: 28),
        elevation: 4,
      ),
    );
  }
}
