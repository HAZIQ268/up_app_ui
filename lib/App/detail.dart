import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class Detail extends StatefulWidget {
  final Map<String, dynamic> listing;
  final String collection;
  final String documentId;

  const Detail({
    Key? key,
    required this.listing,
    required this.collection,
    required this.documentId,
  }) : super(key: key);

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  bool _isLiked = false;
  bool _showFullDescription = false;

  // Color Scheme
  final Color primaryColor = const Color(0xFF6A11CB);
  final Color secondaryColor = const Color(0xFF2575FC);
  final Color accentColor = const Color(0xFF7C4FDC);
  final Color backgroundColor = const Color(0xFFF8F9FA);
  final Color textColor = const Color(0xFF333333);
  final Color lightTextColor = const Color(0xFF666666);

  LinearGradient get _primaryGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, secondaryColor],
  );

  void _openMapPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: LocationMapPopup(
              latitude: widget.listing['latitude'] ?? 0.0,
              longitude: widget.listing['longitude'] ?? 0.0,
              locationName: widget.listing['name'] ?? 'Location',
            ),
          ),
    );
  }

  void _showReviewsPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: ReviewsPopup(
              collection: widget.collection,
              documentId: widget.documentId,
              listingName: widget.listing['name'] ?? 'Place',
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// HERO IMAGE
          Hero(
            tag: '${widget.collection}-${widget.documentId}',
            child: CachedNetworkImage(
              imageUrl: widget.listing['image_url'] ?? '',
              height: 400,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder:
                  (c, _) => Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    ),
                  ),
              errorWidget:
                  (c, _, __) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported),
                  ),
            ),
          ),

          /// BACK BUTTON
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: FloatingActionButton.small(
              heroTag: 'backButton',
              backgroundColor: Colors.white.withOpacity(.8),
              foregroundColor: textColor,
              onPressed: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back),
            ),
          ),

          /// LIKE BUTTON
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'likeButton',
              backgroundColor: Colors.white.withOpacity(.8),
              foregroundColor: _isLiked ? Colors.red : textColor,
              onPressed: () {
                setState(() => _isLiked = !_isLiked);
                HapticFeedback.lightImpact();
              },
              child: Icon(_isLiked ? Icons.favorite : Icons.favorite_border),
            ),
          ),

          /// SLIDING SHEET
          DraggableScrollableSheet(
            initialChildSize: .6,
            minChildSize: .5,
            maxChildSize: .9,
            builder:
                (context, controller) => Container(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ListView(
                    controller: controller,
                    padding: const EdgeInsets.all(24),
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: lightTextColor.withOpacity(.2),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      /// TITLE + RATING
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.listing['name'] ?? 'Place',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: _showReviewsPopup,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: _primaryGradient,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    (widget.listing['rating'] as num?)
                                            ?.toStringAsFixed(1) ??
                                        '0.0',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      /// LOCATION
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.listing['location'] ??
                                'Location not available',
                            style: TextStyle(color: textColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      /// DESCRIPTION
                      Text(
                        'About',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap:
                            () => setState(
                              () =>
                                  _showFullDescription = !_showFullDescription,
                            ),
                        child: Text(
                          widget.listing['description'] ??
                              'No description available.',
                          maxLines: _showFullDescription ? null : 3,
                          overflow:
                              _showFullDescription
                                  ? null
                                  : TextOverflow.ellipsis,
                          style: TextStyle(color: textColor),
                        ),
                      ),
                      if (!_showFullDescription &&
                          (widget.listing['description'] ?? '').length > 100)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Read more',
                            style: TextStyle(color: primaryColor),
                          ),
                        ),
                      const SizedBox(height: 32),

                      /// SHOW REVIEWS BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _showReviewsPopup,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.grey[200],
                            foregroundColor: textColor,
                          ),
                          child: const Text('Show Reviews'),
                        ),
                      ),
                      const SizedBox(height: 16),

                      /// VIEW ON MAP BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _openMapPopup,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            foregroundColor: Colors.white,
                          ).copyWith(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                                  (states) =>
                                      states.contains(MaterialState.pressed)
                                          ? secondaryColor
                                          : primaryColor,
                                ),
                          ),
                          icon: const Icon(Icons.map),
                          label: const Text('View on Map'),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class LocationMapPopup extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String locationName;

  const LocationMapPopup({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.locationName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF6A11CB);

    return SizedBox(
      height: MediaQuery.of(context).size.height * .9,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryColor, const Color(0xFF2575FC)],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  locationName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: FlutterMap(
                options: MapOptions(
                  center: LatLng(latitude, longitude),
                  zoom: 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                    userAgentPackageName: 'com.example.city_guide_app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(latitude, longitude),
                        width: 50,
                        height: 50,
                        builder:
                            (_) => Icon(
                              Icons.location_pin,
                              color: primaryColor,
                              size: 50,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewsPopup extends StatefulWidget {
  final String collection;
  final String documentId;
  final String listingName;

  const ReviewsPopup({
    Key? key,
    required this.collection,
    required this.documentId,
    required this.listingName,
  }) : super(key: key);

  @override
  State<ReviewsPopup> createState() => _ReviewsPopupState();
}

class _ReviewsPopupState extends State<ReviewsPopup> {
  final TextEditingController _controller = TextEditingController();
  double _rating = 0;
  bool _showForm = false;
  String? _editingDocId;
  List<Map<String, dynamic>> _reviews = [];

  final primaryColor = const Color(0xFF6A11CB);
  final secondaryColor = const Color(0xFF2575FC);

  LinearGradient get _primaryGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, secondaryColor],
  );

  @override
  void initState() {
    super.initState();
    _listenReviews();
  }

  void _listenReviews() {
    FirebaseFirestore.instance
        .collection(widget.collection)
        .doc(widget.documentId)
        .collection('reviews')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snap) {
          setState(() {
            _reviews =
                snap.docs.map((d) {
                  final data = d.data();
                  return {
                    'docId': d.id,
                    'userId': data['userId'] ?? '',
                    'username': data['username'] ?? 'Anonymous',
                    'text': data['text'] ?? '',
                    'rating': (data['rating'] as num?)?.toDouble() ?? 0,
                    'profileImage': data['profileImage'] ?? '',
                    'timestamp': data['timestamp'] ?? Timestamp.now(),
                  };
                }).toList();
          });
        });
  }

  String _timeAgo(Timestamp ts) {
    final diff = DateTime.now().difference(ts.toDate());
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  Future<void> _submit() async {
    if (_controller.text.isEmpty || _rating == 0) {
      _showSnack('Please add both rating & review', Colors.red);
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnack('Login required', Colors.red);
      return;
    }

    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      final userData = userDoc.data() ?? {};

      final data = {
        'userId': user.uid,
        'username': userData['name'] ?? 'Anonymous',
        'text': _controller.text,
        'rating': _rating,
        'profileImage': userData['profileImage'] ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      };

      final ref = FirebaseFirestore.instance
          .collection(widget.collection)
          .doc(widget.documentId)
          .collection('reviews');

      if (_editingDocId == null) {
        await ref.add(data);
      } else {
        await ref.doc(_editingDocId).update(data);
      }

      await _recalcAverage();

      setState(() {
        _showForm = false;
        _controller.clear();
        _rating = 0;
        _editingDocId = null;
      });

      _showSnack('Review saved successfully!', Colors.green);
    } catch (e) {
      _showSnack('Error saving review: ${e.toString()}', Colors.red);
    }
  }

  Future<void> _delete(String docId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete review?'),
            content: const Text('This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (ok != true) return;

    await FirebaseFirestore.instance
        .collection(widget.collection)
        .doc(widget.documentId)
        .collection('reviews')
        .doc(docId)
        .delete();
    await _recalcAverage();
  }

  Future<void> _recalcAverage() async {
    final snap =
        await FirebaseFirestore.instance
            .collection(widget.collection)
            .doc(widget.documentId)
            .collection('reviews')
            .get();
    if (snap.docs.isEmpty) return;
    final sum = snap.docs.fold<double>(
      0,
      (p, e) => p + (e['rating'] as num).toDouble(),
    );
    await FirebaseFirestore.instance
        .collection(widget.collection)
        .doc(widget.documentId)
        .update({'rating': sum / snap.docs.length});
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = const Color(0xFF333333);
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return SizedBox(
      height: MediaQuery.of(context).size.height * .9,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: _primaryGradient,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reviews for ${widget.listingName}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (!_showForm)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    foregroundColor: Colors.white,
                  ).copyWith(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (states) =>
                          states.contains(MaterialState.pressed)
                              ? secondaryColor
                              : primaryColor,
                    ),
                  ),
                  onPressed: () => setState(() => _showForm = true),
                  child: const Text('Add Review'),
                ),
              ),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                if (_showForm) _buildForm(),
                Text(
                  'Recent Reviews',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
                if (_reviews.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Text('No reviews yet'),
                    ),
                  )
                else
                  ..._reviews.map((r) => _buildReviewTile(r, uid)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    final isUpdate = _editingDocId != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isUpdate ? 'Edit Review' : 'Write a Review',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Share your experience...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Your Rating:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        RatingBar.builder(
          initialRating: _rating,
          minRating: 1,
          allowHalfRating: true,
          itemCount: 5,
          itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber),
          onRatingUpdate: (r) => setState(() => _rating = r),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _showForm = false;
                    _controller.clear();
                    _rating = 0;
                    _editingDocId = null;
                  });
                },
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: primaryColor,
                ),
                onPressed: _submit,
                child: Text(isUpdate ? 'Update' : 'Submit'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildReviewTile(Map<String, dynamic> r, String? uid) {
    final isOwner = uid == r['userId'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage:
                    (r['profileImage'] as String).isNotEmpty
                        ? NetworkImage(r['profileImage'])
                        : null,
                child:
                    (r['profileImage'] as String).isEmpty
                        ? const Icon(Icons.person)
                        : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r['username'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _timeAgo(r['timestamp']),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              const Spacer(),
              RatingBarIndicator(
                rating: r['rating'],
                itemBuilder:
                    (_, __) => const Icon(Icons.star, color: Colors.amber),
                itemSize: 16,
              ),
              if (isOwner) ...[
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: () {
                    setState(() {
                      _showForm = true;
                      _editingDocId = r['docId'];
                      _controller.text = r['text'];
                      _rating = r['rating'];
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18),
                  onPressed: () => _delete(r['docId']),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(r['text']),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
