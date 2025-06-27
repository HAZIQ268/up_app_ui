import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FetchData extends StatefulWidget {
  const FetchData({super.key});

  @override
  State<FetchData> createState() => _FetchDataState();
}

class _FetchDataState extends State<FetchData> {
  List<Map<String, dynamic>> _users = [];
  TextEditingController searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      setState(() => _isLoading = true);
      final snapshot = await FirebaseFirestore.instance.collection('Users').get();
      final data = snapshot.docs.map((doc) {
        final userData = doc.data();
        userData['id'] = doc.id;
        return userData;
      }).toList();

      setState(() {
        _users = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching users: $e');
      setState(() => _isLoading = false);
    }
  }

  void showAddUserDialog() {
    // Implement your Add User logic
  }

  void showEditDialog(Map<String, dynamic> user) {
    // Implement your Edit logic
  }

  void deleteDialog(String id) {
    // Implement your delete confirmation logic
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text('User Management', style: TextStyle(
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimary,
        )),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: FaIcon(FontAwesomeIcons.userPlus, size: 20),
            onPressed: showAddUserDialog,
            tooltip: 'Add User',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: Icon(Icons.search, color: colorScheme.onSurface.withOpacity(0.6)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
                style: TextStyle(color: colorScheme.onSurface),
                onChanged: (value) {
                  setState(() {
                    if (value.isEmpty) {
                      fetchData();
                    } else {
                      _users = _users.where((user) {
                        final name = (user["name"] ?? "").toString().toLowerCase();
                        final email = (user["email"] ?? "").toString().toLowerCase();
                        return name.contains(value.toLowerCase()) || email.contains(value.toLowerCase());
                      }).toList();
                    }
                  });
                },
              ),
            ),
          ),

          // User Count
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${_users.length} Users Found',
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ),
          ),

          SizedBox(height: 8),

          // Users List
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    ),
                  )
                : _users.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FaIcon(FontAwesomeIcons.usersSlash, size: 48, color: colorScheme.onSurface.withOpacity(0.3)),
                            SizedBox(height: 16),
                            Text('No users found', style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.5),
                              fontSize: 18,
                            )),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.only(bottom: 16),
                        itemCount: _users.length,
                        itemBuilder: (context, index) {
                          final user = _users[index];
                          return _buildUserCard(user, colorScheme);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, ColorScheme colorScheme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: FaIcon(FontAwesomeIcons.user, color: colorScheme.primary),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (user["name"] ?? 'No Name').toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          (user["email"] ?? 'No Email').toString(),
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.7),
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

              // User Details
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    FaIcon(FontAwesomeIcons.lock, size: 14, color: colorScheme.onSurface.withOpacity(0.6)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        (user["password"] ?? 'No Password').toString(),
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    icon: FaIcon(FontAwesomeIcons.pen, size: 14),
                    label: Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      side: BorderSide(color: colorScheme.primary),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onPressed: () => showEditDialog(user),
                  ),
                  SizedBox(width: 8),
                  OutlinedButton.icon(
                    icon: FaIcon(FontAwesomeIcons.trash, size: 14),
                    label: Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.error,
                      side: BorderSide(color: colorScheme.error),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onPressed: () => deleteDialog(user["id"]),
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
