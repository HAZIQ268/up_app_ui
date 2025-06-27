import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('categories').get();
      final categories = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Store document ID
        return data;
      }).toList();

      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching categories: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateCategory(String docId, Map<String, dynamic> newData) async {
    try {
      await FirebaseFirestore.instance.collection('categories').doc(docId).update(newData);
      _fetchCategories();
    } catch (e) {
      print("Error updating category: $e");
    }
  }

  Future<void> _deleteCategory(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('categories').doc(docId).delete();
      _fetchCategories();
    } catch (e) {
      print("Error deleting category: $e");
    }
  }

  void _showDeleteDialog(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this category?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteCategory(docId);
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> category) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: category['category'] ?? '');
    final imageController = TextEditingController(text: category['cat_img'] ?? '');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Edit Category', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Category Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: imageController,
                  decoration: InputDecoration(
                    labelText: 'Image URL',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                          _updateCategory(category['id'], {
                            'category': nameController.text,
                            'cat_img': imageController.text,
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
    final nameController = TextEditingController();
    final imageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Add New Category', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Category Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: imageController,
                  decoration: InputDecoration(
                    labelText: 'Image URL',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                          FirebaseFirestore.instance.collection('categories').add({
                            'category': nameController.text,
                            'cat_img': imageController.text,
                          }).then((_) {
                            _fetchCategories();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: _showAddDialog,
            tooltip: 'Add Category',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _categories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(FontAwesomeIcons.folderOpen, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No categories found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      SizedBox(height: 8),
                      TextButton(
                        onPressed: _showAddDialog,
                        child: Text('Add your first category'),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                  child: (category['cat_img'] != null && (category['cat_img'] as String).isNotEmpty)
                                      ? Image.network(
                                          category['cat_img'],
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              Container(
                                                color: Colors.grey[200],
                                                child: Center(child: Icon(Icons.broken_image)),
                                              ),
                                        )
                                      : Container(
                                          color: Colors.grey[200],
                                          child: Center(child: Icon(Icons.image, size: 48, color: Colors.grey)),
                                        ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(12),
                                child: Text(
                                  category['category'] ?? 'Unnamed Category',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, size: 20),
                                    onPressed: () => _showEditDialog(category),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, size: 20, color: Colors.red),
                                    onPressed: () => _showDeleteDialog(category['id']),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}