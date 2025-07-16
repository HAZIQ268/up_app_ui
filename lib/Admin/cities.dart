import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ---------------------------------------------------------------------------
/// 🌈  Shared gradient + reusable widgets (same as other screens)
/// ---------------------------------------------------------------------------
const LinearGradient kGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF283593), // indigo
    Color(0xFF42A5F5), // blue
  ],
);

class GradientIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  const GradientIcon(this.icon, {Key? key, this.size = 24}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) => kGradient.createShader(rect),
      blendMode: BlendMode.srcIn,
      child: Icon(icon, size: size, color: Colors.white),
    );
  }
}

class GradientButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final double borderRadius;
  const GradientButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.borderRadius = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(borderRadius),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            gradient: kGradient,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: DefaultTextStyle.merge(
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GradientActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  const GradientActionButton({Key? key, required this.onPressed})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: kGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 4),
              blurRadius: 6,
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.add,
            size: 28,
            color: Colors.white, // ✅ White color icon
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// 🏙  Cities Admin Panel with unified theme
/// ---------------------------------------------------------------------------
class CitiesAdminPanel extends StatefulWidget {
  const CitiesAdminPanel({super.key});
  @override
  State<CitiesAdminPanel> createState() => _CitiesAdminPanelState();
}

class _CitiesAdminPanelState extends State<CitiesAdminPanel> {
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  final TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  String _sortCriterion = 'Name';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final snap = await FirebaseFirestore.instance.collection('cities').get();
      final raw = snap.docs
          .map((d) => d.data()..['id'] = d.id)
          .toList(growable: false);
      setState(() {
        _products = raw;
        _filteredProducts = raw;
        _sortProducts(_sortCriterion);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar('Error fetching cities: $e', isError: true);
    }
  }

  Future<void> updateData(String id, Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance
          .collection('cities')
          .doc(id)
          .update(data);
      _showSnackBar('City updated successfully!');
      fetchData();
    } catch (e) {
      _showSnackBar('Error updating city: $e', isError: true);
    }
  }

  Future<void> deleteData(String id) async {
    try {
      await FirebaseFirestore.instance.collection('cities').doc(id).delete();
      _showSnackBar('City deleted successfully!');
      fetchData();
    } catch (e) {
      _showSnackBar('Error deleting city: $e', isError: true);
    }
  }

  /* ----------------------------------------------------------------------- */
  /*                                UI helpers                               */
  /* ----------------------------------------------------------------------- */

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildFormField(
    TextEditingController c,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: GradientIcon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }

  void _deleteDialog(String id, String name) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const GradientIcon(Icons.warning, size: 32),
            content: Text('Are you sure you want to delete "$name"?'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
              GradientButton(
                onPressed: () {
                  deleteData(id);
                  Navigator.pop(context);
                },
                child: const Text('DELETE'),
              ),
            ],
          ),
    );
  }

  /* ------------------------  Add / Edit BottomSheet  --------------------- */

  void _showCitySheet({Map<String, dynamic>? city}) {
    final key = GlobalKey<FormState>();
    final c = {
      'title': TextEditingController(text: city?['title'] ?? ''),
      'description': TextEditingController(text: city?['description'] ?? ''),
      'image_url': TextEditingController(text: city?['image_url'] ?? ''),
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => Container(
            height: MediaQuery.of(context).size.height * 0.9,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Form(
              key: key,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        city == null ? 'Add New City' : 'Edit City',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildFormField(
                            c['title']!,
                            'City Name',
                            Icons.location_city,
                          ),
                          const SizedBox(height: 20),
                          _buildFormField(
                            c['description']!,
                            'Description',
                            Icons.description,
                            maxLines: 4,
                          ),
                          const SizedBox(height: 20),
                          _buildFormField(
                            c['image_url']!,
                            'Image URL',
                            Icons.image,
                          ),
                          const SizedBox(height: 20),
                          if (c['image_url']!.text.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                c['image_url']!.text,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => Container(
                                      height: 150,
                                      color: Colors.grey.shade200,
                                      child: const GradientIcon(
                                        Icons.broken_image,
                                        size: 50,
                                      ),
                                    ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GradientButton(
                    onPressed: () {
                      if (key.currentState!.validate()) {
                        final data = {
                          'title': c['title']!.text,
                          'description': c['description']!.text,
                          'image_url': c['image_url']!.text,
                        };
                        if (city == null) {
                          FirebaseFirestore.instance
                              .collection('cities')
                              .add(data)
                              .then((_) {
                                fetchData();
                                Navigator.pop(context);
                              });
                        } else {
                          updateData(city['id'], data);
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: Text(city == null ? 'ADD CITY' : 'SAVE CHANGES'),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  /* --------------------------  Sorting & Search  ------------------------- */

  void _sortProducts(String criterion) {
    setState(() {
      _sortCriterion = criterion;
      _filteredProducts.sort(
        (a, b) => a['title'].toLowerCase().compareTo(b['title'].toLowerCase()),
      );
    });
  }

  void _searchProducts(String q) {
    setState(() {
      _filteredProducts =
          _products
              .where((c) => c['title'].toLowerCase().contains(q.toLowerCase()))
              .toList();
      _sortProducts(_sortCriterion);
    });
  }

  /* ----------------------------------------------------------------------- */
  /*                                 BUILD                                   */
  /* ----------------------------------------------------------------------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: kGradient),
        ),
        title: const Text(
          'Cities Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const GradientIcon(Icons.refresh),
            onPressed: fetchData,
          ),
          IconButton(
            icon: const GradientIcon(Icons.add),
            onPressed: () => _showCitySheet(),
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: _searchProducts,
                        decoration: InputDecoration(
                          hintText: 'Search cities...',
                          prefixIcon: const GradientIcon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 20,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  Expanded(
                    child:
                        _filteredProducts.isEmpty
                            ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                GradientIcon(Icons.search_off, size: 60),
                                SizedBox(height: 8),
                                Text('No cities found'),
                              ],
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 16),
                              itemCount: _filteredProducts.length,
                              itemBuilder: (_, i) {
                                final city = _filteredProducts[i];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: Card(
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () => _showCitySheet(city: city),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Row(
                                          children: [
                                            if (city['image_url']
                                                    ?.toString()
                                                    .isNotEmpty ??
                                                false)
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Image.network(
                                                  city['image_url'],
                                                  width: 80,
                                                  height: 80,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (_, __, ___) => Container(
                                                        width: 80,
                                                        height: 80,
                                                        color:
                                                            Colors
                                                                .grey
                                                                .shade200,
                                                        child:
                                                            const GradientIcon(
                                                              Icons
                                                                  .broken_image,
                                                              size: 30,
                                                            ),
                                                      ),
                                                ),
                                              ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    city['title'],
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF283593),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    city['description'].length >
                                                            60
                                                        ? '${city['description'].substring(0, 60)}...'
                                                        : city['description'],
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            PopupMenuButton(
                                              icon: const Icon(Icons.more_vert),
                                              itemBuilder:
                                                  (_) => [
                                                    PopupMenuItem(
                                                      child: ListTile(
                                                        leading:
                                                            const GradientIcon(
                                                              Icons.edit,
                                                            ),
                                                        title: const Text(
                                                          'Edit',
                                                        ),
                                                        onTap: () {
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                          _showCitySheet(
                                                            city: city,
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    PopupMenuItem(
                                                      child: ListTile(
                                                        leading:
                                                            const GradientIcon(
                                                              Icons.delete,
                                                            ),
                                                        title: const Text(
                                                          'Delete',
                                                        ),
                                                        onTap: () {
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                          _deleteDialog(
                                                            city['id'],
                                                            city['title'],
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
      floatingActionButton: GradientActionButton(
        onPressed: () => _showCitySheet(),
      ),
    );
  }
}
