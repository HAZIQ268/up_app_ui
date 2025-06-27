import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Attractions extends StatefulWidget {
  const Attractions({super.key});

  @override
  State<Attractions> createState() => _AttractionsState();
}

class _AttractionsState extends State<Attractions> {
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  String _sortBy = 'Rating';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      final userdata = await FirebaseFirestore.instance.collection('Attractions').get();
      final rawdata = userdata.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      setState(() {
        _products = rawdata;
        _filteredProducts = List.from(rawdata)..sort((a, b) {
          double ratingA = double.tryParse(a["rating"]?.toString() ?? '0') ?? 0;
          double ratingB = double.tryParse(b["rating"]?.toString() ?? '0') ?? 0;
          return ratingB.compareTo(ratingA);
        });
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void searchProducts(String query) {
    _filteredProducts = _products
        .where((product) =>
            product['name']?.toLowerCase().contains(query.toLowerCase()) ?? false)
        .toList();
  }

  void sortProducts(String sortBy) {
    if (sortBy == 'Rating') {
      _filteredProducts.sort((a, b) {
        double ratingA = double.tryParse(a["rating"]?.toString() ?? '0') ?? 0;
        double ratingB = double.tryParse(b["rating"]?.toString() ?? '0') ?? 0;
        return ratingB.compareTo(ratingA);
      });
    } else if (sortBy == 'Name') {
      _filteredProducts.sort((a, b) {
        return (a["name"] ?? '').toString().compareTo((b["name"] ?? '').toString());
      });
    }
  }

  void showAddProductDialog() {
    // Add your logic here
  }

  void showEditDialog(Map<String, dynamic> attraction) {
    // Add your logic here
  }

  void deleteDialog(String id) {
    // Add your logic here
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text('City Attractions', style: TextStyle(
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimary,
        )),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: FaIcon(FontAwesomeIcons.plus, size: 20),
            onPressed: showAddProductDialog,
            tooltip: 'Add Attraction',
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary)))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: Offset(0, 2))],
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search attractions...',
                        prefixIcon: Icon(Icons.search, color: colorScheme.onSurface.withOpacity(0.6)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      ),
                      style: TextStyle(color: colorScheme.onSurface),
                      onChanged: (value) {
                        setState(() {
                          if (value.isEmpty) {
                            _filteredProducts = List.from(_products);
                            sortProducts(_sortBy);
                          } else {
                            searchProducts(value);
                          }
                        });
                      },
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildSortChip('Rating', FontAwesomeIcons.star),
                      SizedBox(width: 8),
                      _buildSortChip('Name', FontAwesomeIcons.sortAlphaDown),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Expanded(
                  child: _filteredProducts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(FontAwesomeIcons.magnifyingGlass, size: 48, color: colorScheme.onSurface.withOpacity(0.3)),
                              SizedBox(height: 16),
                              Text('No attractions found', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 18)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.only(bottom: 16),
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            final attraction = _filteredProducts[index];
                            return _buildAttractionCard(attraction, colorScheme);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildSortChip(String label, IconData icon) {
    final isSelected = _sortBy == label;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 14, color: isSelected ? Colors.white : null),
          SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _sortBy = label;
          sortProducts(label);
        });
      },
      selectedColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildAttractionCard(Map<String, dynamic> attraction, ColorScheme colorScheme) {
    final rating = double.tryParse(attraction["rating"]?.toString() ?? '0') ?? 0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                child: attraction["image_url"] != null && attraction["image_url"].toString().isNotEmpty
                    ? Image.network(
                        attraction["image_url"],
                        height: 180,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 180,
                            color: colorScheme.surface,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 180,
                          color: colorScheme.surface,
                          child: Center(
                            child: FaIcon(FontAwesomeIcons.image, size: 40, color: colorScheme.onSurface.withOpacity(0.3)),
                          ),
                        ),
                      )
                    : Container(
                        height: 180,
                        color: colorScheme.surface,
                        child: Center(
                          child: FaIcon(FontAwesomeIcons.image, size: 40, color: colorScheme.onSurface.withOpacity(0.3)),
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
                            attraction["name"] ?? 'Unnamed Attraction',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            FaIcon(FontAwesomeIcons.solidStar, size: 16, color: Colors.amber),
                            SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    if ((attraction["subCategory"] ?? '').toString().isNotEmpty)
                      Row(
                        children: [
                          FaIcon(FontAwesomeIcons.tag, size: 12, color: colorScheme.onSurface.withOpacity(0.6)),
                          SizedBox(width: 6),
                          Text(attraction["subCategory"], style: TextStyle(color: colorScheme.onSurface.withOpacity(0.8), fontSize: 12)),
                        ],
                      ),
                    SizedBox(height: 12),
                    if ((attraction["description"] ?? '').toString().isNotEmpty)
                      Text(attraction["description"], style: TextStyle(color: colorScheme.onSurface.withOpacity(0.8)), maxLines: 2, overflow: TextOverflow.ellipsis),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: FaIcon(FontAwesomeIcons.penToSquare, size: 18),
                          color: colorScheme.primary,
                          onPressed: () => showEditDialog(attraction),
                          tooltip: 'Edit',
                        ),
                        IconButton(
                          icon: FaIcon(FontAwesomeIcons.trash, size: 18),
                          color: colorScheme.error,
                          onPressed: () => deleteDialog(attraction["id"]),
                          tooltip: 'Delete',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
