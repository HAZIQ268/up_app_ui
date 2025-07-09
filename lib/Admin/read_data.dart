import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<Map<String, dynamic>> _users = [];
  TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').get();
      final users = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      _showSnackBar('Failed to load users: $e', isError: true);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update(userData);
      _showSnackBar('User updated successfully!');
      _fetchUsers();
    } catch (e) {
      _showSnackBar('Error updating user: $e', isError: true);
    }
  }

  Future<void> _deleteUser(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      _showSnackBar('User deleted successfully!');
      _fetchUsers();
    } catch (e) {
      _showSnackBar('Error deleting user: $e', isError: true);
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

  void _showDeleteDialog(String userId, String userName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete User', 
               style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete "$userName"?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('CANCEL', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              _deleteUser(userId);
              Navigator.of(context).pop();
            },
            child: Text('DELETE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> user) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: user['name']);
    final _emailController = TextEditingController(text: user['email']);
    final _passwordController = TextEditingController(text: user['password']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                Text('Edit User', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(_nameController, 'Name', Icons.person),
                      SizedBox(height: 20),
                      _buildTextField(_emailController, 'Email', Icons.email),
                      SizedBox(height: 20),
                      _buildTextField(_passwordController, 'Password', Icons.lock),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _updateUser(user['id'], {
                          'name': _nameController.text,
                          'email': _emailController.text,
                          'password': _passwordController.text,
                        });
                        Navigator.of(context).pop();
                      }
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

  void _showAddUserDialog() {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                Text('Add New User', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(_nameController, 'Name', Icons.person),
                      SizedBox(height: 20),
                      _buildTextField(_emailController, 'Email', Icons.email),
                      SizedBox(height: 20),
                      _buildTextField(_passwordController, 'Password', Icons.lock),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          await FirebaseFirestore.instance.collection('users').add({
                            'name': _nameController.text,
                            'email': _emailController.text,
                            'password': _passwordController.text,
                            'images': '',
                          });
                          _showSnackBar('User added successfully!');
                          Navigator.of(context).pop();
                          _fetchUsers();
                        } catch (e) {
                          _showSnackBar('Error adding user: $e', isError: true);
                        }
                      }
                    },
                    child: Text('ADD USER', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.indigo),
        prefixIcon: Icon(icon, color: Colors.indigo),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.indigo),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.indigo, width: 2),
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
          statusBarColor: Colors.indigo,
          statusBarIconBrightness: Brightness.light,
        ),
        title: Text('User Management', style: TextStyle(color: Colors.white)),
        centerTitle: true,
          backgroundColor: Colors.indigo,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchUsers,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
              ),
                ],
              ),
              
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: Icon(Icons.search, color: Colors.indigo),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
                onChanged: (value) {
                  setState(() {
                    _isSearching = value.isNotEmpty;
                    if (value.isEmpty) {
                      _fetchUsers();
                    } else {
                      _users = _users.where((user) {
                        final name = user['name']?.toString().toLowerCase() ?? '';
                        final email = user['email']?.toString().toLowerCase() ?? '';
                        return name.contains(value.toLowerCase()) || 
                               email.contains(value.toLowerCase());
                      }).toList();
                    }
                  });
                },
              ),
            ),
          ),
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _isSearching = false;
                        _fetchUsers();
                      });
                    },
                    child: Text('Clear search', style: TextStyle(color: Colors.indigo)),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.indigo))
                : _users.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 60, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              _isSearching ? 'No matching users found' : 'No users available',
                              style: TextStyle(color: Colors.grey),
                            ),
                            if (!_isSearching)
                              TextButton(
                                onPressed: _showAddUserDialog,
                                child: Text('Add First User', style: TextStyle(color: Colors.indigo)),
                              ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.only(bottom: 16),
                        itemCount: _users.length,
                        itemBuilder: (context, index) {
                          final user = _users[index];
                          return _buildUserCard(user);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUserDialog,
        backgroundColor: Colors.indigo,
        child: Icon(Icons.add, color: Colors.white),
        elevation: 4,
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => _showEditDialog(user),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Icon(Icons.person, color: Colors.indigo),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['name'] ?? 'No Name',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            user['email'] ?? 'No Email',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton(
                      icon: Icon(Icons.more_vert, color: Colors.grey),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: ListTile(
                            leading: Icon(Icons.edit, color: Colors.indigo),
                            title: Text('Edit'),
                            onTap: () {
                              Navigator.pop(context);
                              _showEditDialog(user);
                            },
                          ),
                        ),
                        PopupMenuItem(
                          child: ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text('Delete'),
                            onTap: () {
                              Navigator.pop(context);
                              _showDeleteDialog(user['id'], user['name'] ?? 'this user');
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  'Password: ${user['password'] ?? 'Not set'}',
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}