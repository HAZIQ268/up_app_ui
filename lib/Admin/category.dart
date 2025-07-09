import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CategoryAdminPanel extends StatefulWidget {
  const CategoryAdminPanel({super.key});

  @override
  State<CategoryAdminPanel> createState() => _CategoryAdminPanelState();
}

class _CategoryAdminPanelState extends State<CategoryAdminPanel> {
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
        data['id'] = doc.id;
        return data;
      }).toList();

      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      _showErrorSnackbar('Failed to load categories: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateCategory(String docId, Map<String, dynamic> newData) async {
    try {
      await FirebaseFirestore.instance.collection('categories').doc(docId).update(newData);
      _showSuccessSnackbar('Category updated successfully');
      _fetchCategories();
    } catch (e) {
      _showErrorSnackbar('Error updating category: $e');
    }
  }

  Future<void> _deleteCategory(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('categories').doc(docId).delete();
      _showSuccessSnackbar('Category deleted successfully');
      _fetchCategories();
    } catch (e) {
      _showErrorSnackbar('Error deleting category: $e');
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showDeleteConfirmation(String docId, String categoryName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Category', style: TextStyle(color: Colors.red)),
        content: Text('Are you sure you want to delete "$categoryName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('CANCEL', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              _deleteCategory(docId);
              Navigator.of(context).pop();
            },
            child: Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> category) {
    final TextEditingController nameController = TextEditingController(text: category["category"]);
    final TextEditingController imageController = TextEditingController(text: category["cat_img"]);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
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
                Text('Edit Category', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTextField(
                      controller: nameController,
                      label: 'Category Name',
                      icon: Icons.category,
                    ),
                    SizedBox(height: 20),
                    _buildTextField(
                      controller: imageController,
                      label: 'Image URL',
                      icon: Icons.image,
                    ),
                    SizedBox(height: 30),
                    if (imageController.text.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          imageController.text,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 180,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 180,
                            color: Colors.grey[200],
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                  Text('Invalid Image URL', style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (nameController.text.isEmpty) {
                        _showErrorSnackbar('Category name is required');
                        return;
                      }

                      _updateCategory(category['id'], {
                        "cat_img": imageController.text,
                        "category": nameController.text,
                      });
                      Navigator.of(context).pop();
                    },
                    child: Text('SAVE CHANGES', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController imageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
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
                Text('Add New Category', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTextField(
                      controller: nameController,
                      label: 'Category Name',
                      icon: Icons.category,
                    ),
                    SizedBox(height: 20),
                    _buildTextField(
                      controller: imageController,
                      label: 'Image URL',
                      icon: Icons.image,
                    ),
                    SizedBox(height: 30),
                    if (imageController.text.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          imageController.text,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 180,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 180,
                            color: Colors.grey[200],
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                  Text('Invalid Image URL', style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (nameController.text.isEmpty) {
                        _showErrorSnackbar('Category name is required');
                        return;
                      }

                      FirebaseFirestore.instance.collection('categories').add({
                        "cat_img": imageController.text,
                        "category": nameController.text,
                      });
                      Navigator.of(context).pop();
                      _fetchCategories();
                    },
                    child: Text('ADD CATEGORY', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.deepOrange),
        prefixIcon: Icon(icon, color: Colors.deepOrange),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.deepOrange),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.deepOrange, width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.deepOrange,
          statusBarIconBrightness: Brightness.light,
        ),
        title: Text('Categories', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: _showAddCategoryDialog,
            tooltip: 'Add Category',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.deepOrange))
          : _categories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.category, size: 60, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No categories found', style: TextStyle(color: Colors.grey)),
                      SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                        ),
                        onPressed: _showAddCategoryDialog,
                        child: Text('Add First Category', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () => _showEditDialog(category),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              if (category["cat_img"] != null && category["cat_img"].isNotEmpty)
                                Container(
                                  width: 70,
                                  height: 70,
                                  margin: EdgeInsets.only(right: 16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: NetworkImage(category["cat_img"]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category["category"],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    if (category["cat_img"] != null && category["cat_img"].isNotEmpty)
                                      Text(
                                        'Image URL: ${category["cat_img"].length > 30 ? '${category["cat_img"].substring(0, 30)}...' : category["cat_img"]}',
                                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                      ),
                                  ],
                                ),
                              ),
                              PopupMenuButton(
                                icon: Icon(Icons.more_vert),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: ListTile(
                                      leading: Icon(Icons.edit, color: Colors.deepOrange),
                                      title: Text('Edit'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _showEditDialog(category);
                                      },
                                    ),
                                  ),
                                  PopupMenuItem(
                                    child: ListTile(
                                      leading: Icon(Icons.delete, color: Colors.red),
                                      title: Text('Delete'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _showDeleteConfirmation(category['id'], category['category']);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
