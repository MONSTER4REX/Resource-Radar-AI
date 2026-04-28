import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ActiveTaskScreen extends StatefulWidget {
  final String signalId;

  const ActiveTaskScreen({super.key, required this.signalId});

  @override
  State<ActiveTaskScreen> createState() => _ActiveTaskScreenState();
}

class _ActiveTaskScreenState extends State<ActiveTaskScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Chandigarh Default for Demo
  static const LatLng _initialPosition = LatLng(30.7333, 76.7794);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('need_signals').doc(widget.signalId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final location = data['location'];
          LatLng targetLatLng = _initialPosition;
          if (location is GeoPoint) {
            targetLatLng = LatLng(location.latitude, location.longitude);
          } else if (location is Map) {
            targetLatLng = LatLng(location['latitude'], location['longitude']);
          }

          return Stack(
            children: [
              // 1. Google Map Background
              Positioned.fill(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(target: targetLatLng, zoom: 14),
                  onMapCreated: (controller) {}, // No-op if controller not needed for simple view
                  myLocationEnabled: true,
                  zoomControlsEnabled: false,
                  markers: {
                    Marker(
                      markerId: const MarkerId('target'),
                      position: targetLatLng,
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                    ),
                  },
                ),
              ),

              // 2. Header with Back Button
              Positioned(
                top: 40,
                left: 20,
                child: CircleAvatar(
                  backgroundColor: const Color(0xFF0F172A),
                  child: IconButton(
                    icon: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),

              // 3. Bottom Navigation Info Overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildNavigationOverlay(data, targetLatLng),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNavigationOverlay(Map<String, dynamic> data, LatLng target) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, -10)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${data['need_type']?.toString().toUpperCase()} ASSISTANCE',
                    style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['ward_id'] ?? 'Target Location',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ],
              ),
              _buildETAChip(),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(LucideIcons.users, '${data['people_count']} People Affected'),
          const SizedBox(height: 8),
          _buildInfoRow(LucideIcons.triangleAlert, 'Urgency: ${data['urgency_tier'] ?? "High"}'),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _launchExternalMaps(target),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.05),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.navigation, size: 18),
                      SizedBox(width: 8),
                      Text('Start Navigation'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _markAsComplete(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Arrived & Help Provided', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => _callCoordinator(),
              child: const Text('Contact Coordinator', style: TextStyle(color: Colors.blueGrey)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildETAChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.tealAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(LucideIcons.clock, color: Colors.tealAccent, size: 16),
          SizedBox(width: 6),
          Text('12 min', style: TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueGrey, size: 16),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(color: Colors.blueGrey, fontSize: 14)),
      ],
    );
  }

  Future<void> _launchExternalMaps(LatLng target) async {
    final url = 'google.navigation:q=${target.latitude},${target.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      // Fallback to web
      final webUrl = 'https://www.google.com/maps/dir/?api=1&destination=${target.latitude},${target.longitude}';
      await launchUrl(Uri.parse(webUrl));
    }
  }

  Future<void> _markAsComplete() async {
    await _firestore.collection('need_signals').doc(widget.signalId).update({
      'status': 'completed',
      'completed_at': FieldValue.serverTimestamp(),
    });
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mission Completed! Good work.'), backgroundColor: Colors.tealAccent),
    );
  }

  void _callCoordinator() async {
    const url = 'tel:1234567890';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}
