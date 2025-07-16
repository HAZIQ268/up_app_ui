import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter/services.dart';

/// ---------------------------------------------------------------------------
/// 🌈  Shared gradient + reusable widgets (same as other city screens)
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: DefaultTextStyle.merge(
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
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
            )
          ],
        ),
        child: const GradientIcon(Icons.add, size: 28),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// 🕌  Multan Attractions Screen with unified theme
/// ---------------------------------------------------------------------------
class MultanScreen extends StatefulWidget {
  const MultanScreen({super.key});
  @override
  State<MultanScreen> createState() => _MultanScreenState();
}

class _MultanScreenState extends State<MultanScreen> {
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  final TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  String _sortCriteria = 'Rating';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  /* ---------------------------  Firestore Ops  --------------------------- */

  Future<void> fetchData() async {
    try {
      final snap = await FirebaseFirestore.instance.collection('multan').get();
      final raw =
          snap.docs.map((d) => d.data()..['id'] = d.id).toList(growable: false);
      setState(() {
        _products = raw;
        _filteredProducts = List.from(raw)..sort(_sortByCriteria);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar('Error fetching data: $e', isError: true);
    }
  }

  int _sortByCriteria(a, b) {
    switch (_sortCriteria) {
      case 'Rating':
        final ra = double.tryParse(a['rating']?.toString() ?? '') ?? 0.0;
        final rb = double.tryParse(b['rating']?.toString() ?? '') ?? 0.0;
        return rb.compareTo(ra);
      case 'Name':
        return a['name'].compareTo(b['name']);
      default:
        return 0;
    }
  }

  Future<void> updateData(String id, Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance.collection('multan').doc(id).update(data);
      _showSnackBar('Attraction updated successfully!');
      fetchData();
    } catch (e) {
      _showSnackBar('Error updating data: $e', isError: true);
    }
  }

  Future<void> deleteData(String id) async {
    try {
      await FirebaseFirestore.instance.collection('multan').doc(id).delete();
      _showSnackBar('Attraction deleted successfully!');
      fetchData();
    } catch (e) {
      _showSnackBar('Error deleting data: $e', isError: true);
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

  Widget _buildFormField(TextEditingController c, String label,
      {bool isNum = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: GradientIcon(Icons.edit),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
      ),
    );
  }

  Widget _buildSortButton(String label, IconData icon) {
    return GradientButton(
      onPressed: () => setState(() {
        _sortCriteria = label;
        _filteredProducts.sort(_sortByCriteria);
      }),
      borderRadius: 8,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GradientIcon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> a) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showEditDialog(a),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              if (a['image_url']?.toString().isNotEmpty ?? false)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    a['image_url'],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey.shade200,
                      child: const GradientIcon(Icons.broken_image, size: 30),
                    ),
                  ),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a['name'] ?? 'No Name',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF283593))),
                      const SizedBox(height: 4),
                      Text(a['subCategory'] ?? 'No Category',
                          style: TextStyle(color: Colors.grey.shade600)),
                      const SizedBox(height: 8),
                      RatingBarIndicator(
                        rating:
                            double.tryParse(a['rating']?.toString() ?? '') ?? 0,
                        itemBuilder: (_, __) =>
                            const Icon(Icons.star, color: Colors.amber),
                        itemCount: 5,
                        itemSize: 20,
                      ),
                    ]),
              ),
            ]),
            const SizedBox(height: 12),
            Text(
              a['description'] ?? 'No description available',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              IconButton(
                icon: const GradientIcon(Icons.edit),
                onPressed: () => _showEditDialog(a),
              ),
              IconButton(
                icon: const GradientIcon(Icons.delete),
                onPressed: () => _deleteDialog(a['id']),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  /* --------------------------  Dialogs / Sheets  ------------------------- */

  void _deleteDialog(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const GradientIcon(Icons.warning, size: 32),
        content: const Text('Are you sure you want to delete this attraction?'),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          GradientButton(
              onPressed: () {
                deleteData(id);
                Navigator.pop(context);
              },
              child: const Text('DELETE')),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> a) => _showAddEditSheet(attraction: a);

  void _showAddEditSheet({Map<String, dynamic>? attraction}) {
    final key = GlobalKey<FormState>();
    final c = {
      'description': TextEditingController(text: attraction?['description'] ?? ''),
      'image_url': TextEditingController(text: attraction?['image_url'] ?? ''),
      'name': TextEditingController(text: attraction?['name'] ?? ''),
      'subCategory': TextEditingController(text: attraction?['subCategory'] ?? ''),
      'rating': TextEditingController(text: attraction?['rating']?.toString() ?? ''),
      'longitude': TextEditingController(text: attraction?['longitude']?.toString() ?? ''),
      'latitude': TextEditingController(text: attraction?['latitude']?.toString() ?? ''),
      'location': TextEditingController(text: attraction?['location'] ?? ''),
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Form(
          key: key,
          child: Column(children: [
            Row(children: [
              Text(attraction == null ? 'Add New Attraction' : 'Edit Attraction',
                  style:
                      const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close))
            ]),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(children: [
                  _buildFormField(c['description']!, 'Description'),
                  _buildFormField(c['image_url']!, 'Image URL'),
                  _buildFormField(c['name']!, 'Attraction Name'),
                  _buildFormField(c['subCategory']!, 'SubCategory'),
                  _buildFormField(c['rating']!, 'Rating', isNum: true),
                  _buildFormField(c['longitude']!, 'Longitude', isNum: true),
                  _buildFormField(c['latitude']!, 'Latitude', isNum: true),
                  _buildFormField(c['location']!, 'Location'),
                ]),
              ),
            ),
            const SizedBox(height: 20),
            GradientButton(
              onPressed: () {
                if (key.currentState!.validate()) {
                  final data = {
                    'description': c['description']!.text,
                    'image_url': c['image_url']!.text,
                    'name': c['name']!.text,
                    'subCategory': c['subCategory']!.text,
                    'rating': double.tryParse(c['rating']!.text) ?? 0.0,
                    'longitude': double.tryParse(c['longitude']!.text) ?? 0.0,
                    'latitude': double.tryParse(c['latitude']!.text) ?? 0.0,
                    'location': c['location']!.text,
                  };
                  if (attraction == null) {
                    FirebaseFirestore.instance
                        .collection('multan')
                        .add(data)
                        .then((_) {
                      fetchData();
                      Navigator.pop(context);
                    });
                  } else {
                    updateData(attraction['id'], data);
                    Navigator.pop(context);
                  }
                }
              },
              child: Text(attraction == null ? 'ADD ATTRACTION' : 'SAVE CHANGES'),
            ),
          ]),
        ),
      ),
    );
  }

  /* ----------------------------------------------------------------------- */
  /*                                 BUILD                                   */
  /* ----------------------------------------------------------------------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        systemOverlayStyle:
            const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
        title: const Text('Multan Attractions',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace:
            Container(decoration: const BoxDecoration(gradient: kGradient)),
        actions: [
          IconButton(icon: const GradientIcon(Icons.refresh), onPressed: fetchData),
          IconButton(icon: const GradientIcon(Icons.add), onPressed: () => _showAddEditSheet()),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
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
                          offset: Offset(0, 4))
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: (q) => setState(() {
                      _filteredProducts = _products.where((p) {
                        final n = p['name'].toString().toLowerCase();
                        final d = p['description'].toString().toLowerCase();
                        return n.contains(q.toLowerCase()) ||
                            d.contains(q.toLowerCase());
                      }).toList();
                    }),
                    decoration: InputDecoration(
                      hintText: 'Search attractions...',
                      prefixIcon: const GradientIcon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                    ),
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
                    ]),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _filteredProducts.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          GradientIcon(Icons.search_off, size: 60),
                          SizedBox(height: 8),
                          Text('No attractions found'),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: _filteredProducts.length,
                        itemBuilder: (_, i) => _buildCard(_filteredProducts[i]),
                      ),
              ),
            ]),
      floatingActionButton:
          GradientActionButton(onPressed: () => _showAddEditSheet()),
    );
  }
}
