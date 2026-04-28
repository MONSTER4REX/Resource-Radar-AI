import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'mission_board.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class GlobalMapScreen extends StatefulWidget {
  const GlobalMapScreen({super.key});

  @override
  State<GlobalMapScreen> createState() => _GlobalMapScreenState();
}

class _GlobalMapScreenState extends State<GlobalMapScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _fetchSignals();
  }

  void _fetchSignals() {
    _firestore.collection('need_signals').where('status', isEqualTo: 'active').snapshots().listen((snapshot) {
      if (!mounted) return;
      final markers = snapshot.docs.map((doc) {
        final data = doc.data();
        final GeoPoint loc = data['location'] ?? const GeoPoint(0, 0);
        return Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(loc.latitude, loc.longitude),
          infoWindow: InfoWindow(
            title: data['type'] ?? 'Help Needed',
            snippet: data['description'] ?? '',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        );
      }).toSet();

      setState(() {
        _markers = markers;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('Global Map', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(0, 0),
          zoom: 2,
        ),
        markers: _markers,
        onMapCreated: (controller) => _mapController = controller,
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFF1E293B),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(LucideIcons.layoutGrid, color: Colors.blueGrey),
              onPressed: () {
                Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_, __, ___) => const MissionBoardScreen()));
              },
            ),
            IconButton(
              icon: const Icon(LucideIcons.map, color: Colors.blueAccent),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(LucideIcons.history, color: Colors.blueGrey),
              onPressed: () {
                Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_, __, ___) => const HistoryScreen()));
              },
            ),
            IconButton(
              icon: const Icon(LucideIcons.settings, color: Colors.blueGrey),
              onPressed: () {
                Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_, __, ___) => const SettingsScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
