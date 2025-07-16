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
  Widget build(BuildContext context) => ShaderMask(
    shaderCallback: (r) => kGradient.createShader(r),
    blendMode: BlendMode.srcIn,
    child: Icon(icon, size: size, color: Colors.white),
  );
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
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(borderRadius),
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

class GradientActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  const GradientActionButton({Key? key, required this.onPressed})
    : super(key: key);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onPressed,
    child: Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: kGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 6),
        ],
      ),
      child: GradientIcon(Icons.add, size: 28),
    ),
  );
}

/// ---------------------------------------------------------------------------
/// 🏞  Abbottabad Attractions Screen (with bottom‑right FAB added!)
/// ---------------------------------------------------------------------------
class AbbottabadScreen extends StatefulWidget {
  const AbbottabadScreen({super.key});
  @override
  State<AbbottabadScreen> createState() => _AbbottabadScreenState();
}

class _AbbottabadScreenState extends State<AbbottabadScreen> {
  List<Map<String, dynamic>> _data = [];
  List<Map<String, dynamic>> _filtered = [];
  final TextEditingController _search = TextEditingController();
  bool _loading = true;
  String _sort = 'Rating';

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  /* ---------------------------  Firestore Ops  --------------------------- */

  Future<void> _fetch() async {
    try {
      final snap =
          await FirebaseFirestore.instance.collection('abbottabad').get();
      final raw = snap.docs
          .map((d) => d.data()..['id'] = d.id)
          .toList(growable: false);
      setState(() {
        _data = raw;
        _filtered = List.from(raw)..sort(_cmp);
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      _snack('Error fetching data: $e', err: true);
    }
  }

  int _cmp(a, b) {
    switch (_sort) {
      case 'Rating':
        final ra = double.tryParse(a['rating']?.toString() ?? '') ?? 0.0;
        final rb = double.tryParse(b['rating']?.toString() ?? '') ?? 0.0;
        return rb.compareTo(ra);
      case 'Name':
        return a['name'].toString().compareTo(b['name'].toString());
      default:
        return 0;
    }
  }

  Future<void> _update(String id, Map<String, dynamic> d) async {
    try {
      await FirebaseFirestore.instance
          .collection('abbottabad')
          .doc(id)
          .update(d);
      _snack('Attraction updated successfully!');
      _fetch();
    } catch (e) {
      _snack('Error updating data: $e', err: true);
    }
  }

  Future<void> _delete(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('abbottabad')
          .doc(id)
          .delete();
      _snack('Attraction deleted successfully!');
      _fetch();
    } catch (e) {
      _snack('Error deleting data: $e', err: true);
    }
  }

  void _snack(String msg, {bool err = false}) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: err ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );

  /* ----------------------------  UI helpers  ----------------------------- */

  Widget _field(TextEditingController c, String label, {bool num = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: c,
          keyboardType: num ? TextInputType.number : TextInputType.text,
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

  Widget _sortBtn(String label, IconData icon) => GradientButton(
    borderRadius: 8,
    onPressed:
        () => setState(() {
          _sort = label;
          _filtered.sort(_cmp);
        }),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GradientIcon(icon, size: 16),
        const SizedBox(width: 6),
        Text(label),
      ],
    ),
  );

  Widget _card(Map<String, dynamic> a) => Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _sheet(attraction: a),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (a['image_url']?.toString().isNotEmpty ?? false)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      a['image_url'],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey.shade200,
                            child: const GradientIcon(Icons.broken_image),
                          ),
                    ),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a['name'] ?? 'No Name',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF283593),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        a['subCategory'] ?? 'No Category',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      RatingBarIndicator(
                        rating:
                            double.tryParse(a['rating']?.toString() ?? '') ?? 0,
                        itemBuilder:
                            (_, __) =>
                                const Icon(Icons.star, color: Colors.amber),
                        itemSize: 20,
                        itemCount: 5,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              a['description'] ?? 'No description available',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const GradientIcon(Icons.edit),
                  onPressed: () => _sheet(attraction: a),
                ),
                IconButton(
                  icon: const GradientIcon(Icons.delete),
                  onPressed: () => _confirmDelete(a['id']),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  /* -------------------------  Sheets & dialogs  -------------------------- */

  void _confirmDelete(String id) => showDialog(
    context: context,
    builder:
        (_) => AlertDialog(
          title: const GradientIcon(Icons.warning, size: 32),
          content: const Text(
            'Are you sure you want to delete this attraction?',
          ),
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
                _delete(id);
                Navigator.pop(context);
              },
              child: const Text('DELETE'),
            ),
          ],
        ),
  );

  void _sheet({Map<String, dynamic>? attraction}) {
    final key = GlobalKey<FormState>();
    final c = {
      'description': TextEditingController(
        text: attraction?['description'] ?? '',
      ),
      'image_url': TextEditingController(text: attraction?['image_url'] ?? ''),
      'name': TextEditingController(text: attraction?['name'] ?? ''),
      'subCategory': TextEditingController(
        text: attraction?['subCategory'] ?? '',
      ),
      'rating': TextEditingController(
        text: attraction?['rating']?.toString() ?? '',
      ),
      'longitude': TextEditingController(
        text: attraction?['longitude']?.toString() ?? '',
      ),
      'latitude': TextEditingController(
        text: attraction?['latitude']?.toString() ?? '',
      ),
      'location': TextEditingController(text: attraction?['location'] ?? ''),
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
                        attraction == null
                            ? 'Add New Attraction'
                            : 'Edit Attraction',
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
                          _field(c['description']!, 'Description'),
                          _field(c['image_url']!, 'Image URL'),
                          _field(c['name']!, 'Attraction Name'),
                          _field(c['subCategory']!, 'SubCategory'),
                          _field(c['rating']!, 'Rating', num: true),
                          _field(c['longitude']!, 'Longitude', num: true),
                          _field(c['latitude']!, 'Latitude', num: true),
                          _field(c['location']!, 'Location'),
                        ],
                      ),
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
                          'longitude':
                              double.tryParse(c['longitude']!.text) ?? 0.0,
                          'latitude':
                              double.tryParse(c['latitude']!.text) ?? 0.0,
                          'location': c['location']!.text,
                        };
                        if (attraction == null) {
                          FirebaseFirestore.instance
                              .collection('abbottabad')
                              .add(data)
                              .then((_) {
                                _fetch();
                                Navigator.pop(context);
                              });
                        } else {
                          _update(attraction['id'], data);
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: Text(
                      attraction == null ? 'ADD ATTRACTION' : 'SAVE CHANGES',
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  /* ----------------------------------------------------------------------- */
  /*                                 BUILD                                   */
  /* ----------------------------------------------------------------------- */

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F7FA),
    appBar: AppBar(
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
      title: const Text(
        'Abbottabad Attractions',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: kGradient),
      ),
      actions: [
        IconButton(icon: const GradientIcon(Icons.refresh), onPressed: _fetch),
        IconButton(
          icon: const GradientIcon(Icons.add),
          onPressed: () => _sheet(),
        ),
      ],
    ),
    body:
        _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _search,
                    onChanged:
                        (q) => setState(() {
                          _filtered =
                              _data.where((p) {
                                final n = p['name'].toString().toLowerCase();
                                final d =
                                    p['description'].toString().toLowerCase();
                                return n.contains(q.toLowerCase()) ||
                                    d.contains(q.toLowerCase());
                              }).toList();
                        }),
                    decoration: InputDecoration(
                      hintText: 'Search attractions...',
                      prefixIcon: const GradientIcon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _sortBtn('Rating', Icons.star),
                      _sortBtn('Name', Icons.sort_by_alpha),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child:
                      _filtered.isEmpty
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
                            itemCount: _filtered.length,
                            itemBuilder: (_, i) => _card(_filtered[i]),
                          ),
                ),
              ],
            ),
    /* ----------------------------------------------------------------- */
    /* 🎉  Bottom‑right FAB (requested)                                   */
    /* ----------------------------------------------------------------- */
    floatingActionButton: GradientActionButton(onPressed: () => _sheet()),
  );
}
