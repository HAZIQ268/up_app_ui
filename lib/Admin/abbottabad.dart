import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AbbottabadAttractions extends StatefulWidget {
  const AbbottabadAttractions({super.key});

  @override
  State<AbbottabadAttractions> createState() => _AbbottabadAttractionsState();
}

class _AbbottabadAttractionsState extends State<AbbottabadAttractions> {
  List<Map<String, dynamic>> _attractions = [];
  List<Map<String, dynamic>> _filteredAttractions = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  String _sortCriteria = 'Rating';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final userdata =
          await FirebaseFirestore.instance.collection('abbottabad').get();
      final rawdata =
          userdata.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

      setState(() {
        _attractions = rawdata;
        _filteredAttractions = List.from(rawdata);
        _sortAttractions();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() => isLoading = false);
    }
  }

  void _sortAttractions() {
    setState(() {
      if (_sortCriteria == 'Rating') {
        _filteredAttractions.sort((a, b) {
          double ratingA = double.tryParse(a["rating"].toString()) ?? 0.0;
          double ratingB = double.tryParse(b["rating"].toString()) ?? 0.0;
          return ratingB.compareTo(ratingA);
        });
      } else {
        _filteredAttractions.sort(
          (a, b) => a['name'].toString().compareTo(b['name'].toString()),
        );
      }
    });
  }

  Future<void> _updateAttraction(
    String docId,
    Map<String, dynamic> newData,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('abbottabad')
          .doc(docId)
          .update(newData);
      fetchData();
    } catch (e) {
      print("Error updating data: $e");
    }
  }

  Future<void> _deleteAttraction(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('abbottabad')
          .doc(docId)
          .delete();
      fetchData();
    } catch (e) {
      print("Error deleting data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Abbottabad Attractions')),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: 'Search by name',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (query) {
                        setState(() {
                          _filteredAttractions =
                              _attractions
                                  .where(
                                    (attr) => attr['name']
                                        .toString()
                                        .toLowerCase()
                                        .contains(query.toLowerCase()),
                                  )
                                  .toList();
                          _sortAttractions();
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip(
                          label: Text('Rating'),
                          selected: _sortCriteria == 'Rating',
                          onSelected: (val) {
                            setState(() {
                              _sortCriteria = 'Rating';
                              _sortAttractions();
                            });
                          },
                        ),
                        SizedBox(width: 10),
                        ChoiceChip(
                          label: Text('Name'),
                          selected: _sortCriteria == 'Name',
                          onSelected: (val) {
                            setState(() {
                              _sortCriteria = 'Name';
                              _sortAttractions();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredAttractions.length,
                      itemBuilder: (context, index) {
                        final item = _filteredAttractions[index];
                        return Card(
                          margin: EdgeInsets.all(8),
                          child: ListTile(
                            leading:
                                item['image_url'] != null &&
                                        item['image_url'].toString().isNotEmpty
                                    ? Image.network(
                                      item['image_url'],
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    )
                                    : Icon(Icons.location_on),
                            title: Text(item['name'] ?? 'No Name'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['description'] ?? ''),
                                Text("Rating: ${item['rating']}"),
                              ],
                            ),
                            isThreeLine: true,
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteAttraction(item['id']),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}
