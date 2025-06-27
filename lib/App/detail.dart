import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/scheduler.dart';

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

class _DetailState extends State<Detail> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  bool _isLiked = false;
  bool _showFullDescription = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _openMapPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: LocationMapPopup(
            latitude: widget.listing['latitude'],
            longitude: widget.listing['longitude'],
          ),
        );
      },
    );
  }

  void _showReviewsPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: ReviewsPopup(
            collection: widget.collection,
            documentId: widget.documentId,
            listingName: widget.listing['name'] ?? "Unknown Place",
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Stack(
            children: [
              // Hero Image
              Hero(
                tag: '${widget.collection}-${widget.documentId}',
                child: Container(
                  height: 350,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.listing['image_url'] ?? ''),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              // Back Button
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 10,
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // Like Button
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 10,
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      color: _isLiked ? Colors.red : Colors.white,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _isLiked = !_isLiked;
                    });
                    // Add haptic feedback
                    HapticFeedback.lightImpact();
                  },
                ),
              ),

              // Content
              Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: DraggableScrollableSheet(
                    initialChildSize: 0.6,
                    minChildSize: 0.6,
                    maxChildSize: 0.9,
                    builder: (context, scrollController) {
                      return Container(
                        decoration: BoxDecoration(
                          color: colorScheme.background,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Drag Handle
                                Center(
                                  child: Container(
                                    width: 40,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: colorScheme.onSurface.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Title
                                Text(
                                  widget.listing['name'] ?? "Unknown Place",
                                  style: textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // Location
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 20,
                                      color: colorScheme.primary,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      widget.listing['location'] ??
                                          "Location not available",
                                      style: textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // Rating and Reviews
                                GestureDetector(
                                  onTap: _showReviewsPopup,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceVariant,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          double.tryParse(widget.listing['rating']
                                                  .toString())
                                              ?.toStringAsFixed(1) ??
                                              '0.0',
                                          style: textTheme.bodyMedium,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          "View Reviews",
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: colorScheme.primary,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Description
                                Text(
                                  "Description",
                                  style: textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _showFullDescription =
                                          !_showFullDescription;
                                    });
                                  },
                                  child: Text(
                                    widget.listing['description'] ??
                                        "No description available.",
                                    style: textTheme.bodyLarge,
                                    maxLines: _showFullDescription ? null : 3,
                                    overflow: _showFullDescription
                                        ? null
                                        : TextOverflow.ellipsis,
                                  ),
                                ),
                                if (!_showFullDescription &&
                                    (widget.listing['description'] ?? '')
                                        .length > 100)
                                  Text(
                                    "Tap to read more",
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                const SizedBox(height: 30),

                                // Map Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _openMapPopup,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      backgroundColor: colorScheme.primary,
                                      foregroundColor: colorScheme.onPrimary,
                                      elevation: 5,
                                      shadowColor: colorScheme.primary
                                          .withOpacity(0.3),
                                    ),
                                    icon: const Icon(Icons.map),
                                    label: const Text("View on Map"),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class LocationMapPopup extends StatelessWidget {
  final double latitude;
  final double longitude;

  const LocationMapPopup({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.9,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Location",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                center: LatLng(latitude, longitude),
                zoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(latitude, longitude),
                      builder: (ctx) => const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewsPopup extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.9,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Reviews for $listingName",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 5, // Replace with actual reviews count
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: const Text("User Name"),
                  subtitle: const Text("Great place! Would visit again."),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      5,
                      (starIndex) => Icon(
                        Icons.star,
                        color: starIndex < 4 ? Colors.amber : Colors.grey,
                        size: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                // Add review functionality
              },
              child: const Text("Add Review"),
            ),
          ),
        ],
      ),
    );
  }
}