import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

/// ────────────────────────────────────────────────────────────
/// 1)  Global gradient + small helpers
/// ────────────────────────────────────────────────────────────
const LinearGradient kGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF283593), Color(0xFF42A5F5)], // indigo‑700  →  blue‑400
);

class GradientIcon extends StatelessWidget {
  const GradientIcon(this.icon, {super.key, this.size = 24});
  final IconData icon;
  final double size;
  @override
  Widget build(BuildContext context) => ShaderMask(
    shaderCallback:
        (_) => kGradient.createShader(Rect.fromLTWH(0, 0, size, size)),
    blendMode: BlendMode.srcIn,
    child: Icon(icon, size: size, color: Colors.white),
  );
}

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.child,
    required this.onTap,
    this.radius = 12,
  });
  final Widget child;
  final VoidCallback onTap;
  final double radius;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(radius),
    child: InkWell(
      borderRadius: BorderRadius.circular(radius),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          gradient: kGradient,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Center(child: child),
        ),
      ),
    ),
  );
}

class GradientFAB extends StatelessWidget {
  const GradientFAB({super.key, required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: kGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 4)),
        ],
      ),
      child: Icon(icon, size: 28, color: Colors.white),
    ),
  );
}

/// ────────────────────────────────────────────────────────────
/// 2)  Karachi Attractions screen
/// ────────────────────────────────────────────────────────────
class karachi extends StatefulWidget {
  const karachi({super.key});
  @override
  State<karachi> createState() => _karachiState();
}

class _karachiState extends State<karachi> {
  List<Map<String, dynamic>> _all = [], _filtered = [];
  bool _loading = true;
  String _sort = 'Rating';
  final TextEditingController _searchC = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  /* ───────────── Firebase helpers ───────────── */
  Future<void> _fetch() async {
    try {
      final snap = await FirebaseFirestore.instance.collection('karachi').get();
      final list = snap.docs.map((d) => d.data()..['id'] = d.id).toList();
      setState(() {
        _all = list;
        _filtered = List.from(list)..sort(_cmp);
        _loading = false;
      });
    } catch (e) {
      _loading = false;
      _snack('Error fetching data: $e', true);
    }
  }

  Future<void> _update(String id, Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance
          .collection('karachi')
          .doc(id)
          .update(data);
      _snack('Updated successfully!');
      _fetch();
    } catch (e) {
      _snack('Update error: $e', true);
    }
  }

  Future<void> _delete(String id) async {
    try {
      await FirebaseFirestore.instance.collection('karachi').doc(id).delete();
      _snack('Deleted!');
      _fetch();
    } catch (e) {
      _snack('Delete error: $e', true);
    }
  }

  /* ───────────── UI helpers ───────────── */
  int _cmp(a, b) =>
      _sort == 'Rating'
          ? (double.tryParse(b['rating'].toString()) ?? 0).compareTo(
            double.tryParse(a['rating'].toString()) ?? 0,
          )
          : a['name'].toString().compareTo(b['name'].toString());

  void _setSort(String s) {
    setState(() {
      _sort = s;
      _filtered.sort(_cmp);
    });
  }

  void _search(String q) => setState(() {
    _filtered =
        _all
            .where(
              (e) =>
                  e['name'].toString().toLowerCase().contains(
                    q.toLowerCase(),
                  ) ||
                  e['description'].toString().toLowerCase().contains(
                    q.toLowerCase(),
                  ),
            )
            .toList()
          ..sort(_cmp);
  });

  void _snack(String m, [bool err = false]) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(
    SnackBar(
      content: Text(m),
      backgroundColor: err ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );

  /* ───────────── Build ───────────── */
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: _appBar(),
    floatingActionButton: GradientFAB(icon: Icons.add, onTap: _addDialog),
    body:
        _loading
            ? Center(child: CircularProgressIndicator(color: Colors.indigo))
            : Column(
              children: [
                _searchBox(),
                _sortRow(),
                const SizedBox(height: 8),
                Expanded(child: _body()),
              ],
            ),
  );

  AppBar _appBar() => AppBar(
    title: Text(
      'Karachi Attractions',

      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    centerTitle: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
    actionsIconTheme: IconThemeData(color: Colors.white),
    flexibleSpace: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.indigo.shade700, Colors.blue.shade500],
        ),
      ),
    ),
    actions: [
      IconButton(icon: const Icon(Icons.add, size: 28), onPressed: _addDialog),
    ],
  );
  

  Widget _searchBox() => Padding(
    padding: const EdgeInsets.all(16),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: _searchC,
        decoration: InputDecoration(
          hintText: 'Search attractions...',
          prefixIcon: Padding(
            padding: const EdgeInsets.all(4),
            child: GradientIcon(Icons.search),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
        onChanged: _search,
      ),
    ),
  );

  Widget _sortRow() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _sortChip('Rating', Icons.star),
        _sortChip('Name', Icons.sort_by_alpha),
      ],
    ),
  );

  Widget _sortChip(String label, IconData icon) {
    final sel = _sort == label;
    return OutlinedButton.icon(
      onPressed: () => _setSort(label),
      icon: GradientIcon(icon, size: 18),
      label: Text(
        label,
        style: TextStyle(color: sel ? Colors.indigo : Colors.grey.shade600),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: sel ? Colors.indigo : Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _body() =>
      _filtered.isEmpty
          ? _empty()
          : ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: _filtered.length,
            itemBuilder: (_, i) => _card(_filtered[i]),
          );

  Widget _empty() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GradientIcon(Icons.search_off, size: 60),
        const SizedBox(height: 10),
        Text(
          'No attractions found',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    ),
  );

  Widget _card(Map<String, dynamic> a) => Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _editDialog(a),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((a['image_url'] ?? '').toString().isNotEmpty)
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
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                            ),
                          ),
                    ),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a['name'] ?? '',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        a['subCategory'] ?? '',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      RatingBarIndicator(
                        rating: double.tryParse(a['rating'].toString()) ?? 0,
                        itemBuilder:
                            (_, __) =>
                                const Icon(Icons.star, color: Colors.amber),
                        itemCount: 5,
                        itemSize: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              a['description'] ?? '',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: GradientIcon(Icons.edit),
                  onPressed: () => _editDialog(a),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _delDialog(a['id']),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  /* ───────────── Dialogs ───────────── */
  void _delDialog(String id) => showDialog(
    context: context,
    builder:
        (_) => AlertDialog(
          title: GradientIcon(Icons.warning, size: 32),
          content: const Text('Delete this attraction?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            GradientButton(
              child: const Text(
                'DELETE',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                _delete(id);
                Navigator.pop(context);
              },
            ),
          ],
        ),
  );

  void _editDialog(Map<String, dynamic> data) => _upsertDialog(data: data);
  void _addDialog() => _upsertDialog();

  void _upsertDialog({Map<String, dynamic>? data}) {
    final isEdit = data != null;
    final cName = TextEditingController(text: data?['name']),
        cCat = TextEditingController(text: data?['subCategory']),
        cDesc = TextEditingController(text: data?['description']),
        cImg = TextEditingController(text: data?['image_url']),
        cRat = TextEditingController(text: data?['rating']?.toString() ?? ''),
        cLon = TextEditingController(
          text: data?['longitude']?.toString() ?? '',
        ),
        cLat = TextEditingController(text: data?['latitude']?.toString() ?? ''),
        cLoc = TextEditingController(text: data?['location']);
    final key = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEdit ? 'Edit Attraction' : 'Add Attraction',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: key,
                      child: Column(
                        children: [
                          _field(cName, 'Name', Icons.place),
                          _field(cCat, 'Category', Icons.category),
                          _field(
                            cDesc,
                            'Description',
                            Icons.description,
                            maxLines: 3,
                          ),
                          _field(cImg, 'Image URL', Icons.image),
                          _field(cRat, 'Rating', Icons.star, num: true),
                          _field(cLon, 'Longitude', Icons.explore, num: true),
                          _field(cLat, 'Latitude', Icons.explore, num: true),
                          _field(cLoc, 'Location', Icons.location_on),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GradientButton(
                  child: Text(
                    isEdit ? 'SAVE CHANGES' : 'ADD',
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    if (!key.currentState!.validate()) return;
                    final map = {
                      'name': cName.text,
                      'subCategory': cCat.text,
                      'description': cDesc.text,
                      'image_url': cImg.text,
                      'rating': double.tryParse(cRat.text) ?? 0.0,
                      'longitude': double.tryParse(cLon.text) ?? 0.0,
                      'latitude': double.tryParse(cLat.text) ?? 0.0,
                      'location': cLoc.text,
                    };
                    if (isEdit) {
                      _update(data!['id'], map);
                    } else {
                      FirebaseFirestore.instance
                          .collection('karachi')
                          .add(map)
                          .then((_) => _snack('Added!'));
                    }
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  Widget _field(
    TextEditingController c,
    String l,
    IconData ic, {
    bool num = false,
    int maxLines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      controller: c,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: l,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(4),
          child: GradientIcon(ic),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      keyboardType: num ? TextInputType.number : TextInputType.text,
      validator: (v) => v!.isEmpty ? 'Required' : null,
    ),
  );
}
