import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationMapPopup extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String? locationName;

  const LocationMapPopup({
    Key? key,
    required this.latitude,
    required this.longitude,
    this.locationName,
  }) : super(key: key);

  @override
  State<LocationMapPopup> createState() => _LocationMapPopupState();
}

class _LocationMapPopupState extends State<LocationMapPopup> {
  late MapController _mapController;
  double _zoomLevel = 14.0;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  Future<void> _openMapsApp() async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${widget.latitude},${widget.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not launch maps')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return AnimatedContainer(
      duration: 300.ms,
      height: _isExpanded ? size.height * 0.9 : size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with drag handle
          GestureDetector(
            onVerticalDragUpdate: (details) {
              if (details.primaryDelta! > 5) {
                setState(() => _isExpanded = false);
              } else if (details.primaryDelta! < -5) {
                setState(() => _isExpanded = true);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
          ),

          // Title and close button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.locationName ?? "Location Map",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    Text(
                      "${widget.latitude.toStringAsFixed(4)}, ${widget.longitude.toStringAsFixed(4)}",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.deepPurple),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Map Container
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      center: LatLng(widget.latitude, widget.longitude),
                      zoom: _zoomLevel,
                      interactiveFlags:
                          InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c'],
                        userAgentPackageName: 'com.example.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(widget.latitude, widget.longitude),
                            width: 50,
                            height: 50,
                            builder:
                                (ctx) =>
                                    Icon(
                                      Icons.location_pin,
                                      color: Colors.red,
                                      size: 50,
                                    ).animate().shakeX(),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Zoom controls
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: Column(
                      children: [
                        FloatingActionButton.small(
                          heroTag: 'zoomIn',
                          backgroundColor: Colors.white,
                          onPressed: () {
                            setState(() => _zoomLevel += 1);
                            _mapController.move(
                              _mapController.center,
                              _zoomLevel,
                            );
                          },
                          child: Icon(Icons.add, color: Colors.deepPurple),
                        ),
                        const SizedBox(height: 8),
                        FloatingActionButton.small(
                          heroTag: 'zoomOut',
                          backgroundColor: Colors.white,
                          onPressed: () {
                            setState(() => _zoomLevel -= 1);
                            _mapController.move(
                              _mapController.center,
                              _zoomLevel,
                            );
                          },
                          child: Icon(Icons.remove, color: Colors.deepPurple),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.directions, color: Colors.deepPurple),
                    label: Text(
                      'Directions',
                      style: TextStyle(color: Colors.deepPurple),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.deepPurple),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _openMapsApp,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.share, color: Colors.white),
                    label: Text('Share', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // Implement share functionality
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Share location')));
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().slide(begin: const Offset(0, 0.5), curve: Curves.easeOutQuart);
  }
}
