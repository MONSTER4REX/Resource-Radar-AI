import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'mission_board.dart';
import 'global_map_screen.dart';
import 'settings_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'vol_mock_1';
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('History Log', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('need_signals')
                  .where('assigned_volunteers', arrayContains: currentUserId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                final completedDocs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['status'] == 'completed';
                }).toList();

                if (completedDocs.isEmpty) {
                  return const Center(
                    child: Text('No completed missions yet.', style: TextStyle(color: Colors.white70)),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: completedDocs.length,
                  itemBuilder: (context, index) {
                    final data = completedDocs[index].data() as Map<String, dynamic>;
                    final title = data['type'] ?? 'Unknown Mission';
                    final desc = data['description'] ?? 'No description';
                    final timestamp = data['completed_at'] as Timestamp?;
                    final timeStr = timestamp != null ? DateFormat('MMM d, yyyy - h:mm a').format(timestamp.toDate()) : 'Recently';

                    return Card(
                      color: const Color(0xFF1E293B),
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const Icon(LucideIcons.circleCheck, color: Colors.greenAccent),
                        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(desc, style: const TextStyle(color: Colors.white70)),
                            const SizedBox(height: 8),
                            Text(timeStr, style: const TextStyle(color: Colors.blueGrey, fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
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
              icon: const Icon(LucideIcons.map, color: Colors.blueGrey),
              onPressed: () {
                Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_, __, ___) => const GlobalMapScreen()));
              },
            ),
            IconButton(
              icon: const Icon(LucideIcons.history, color: Colors.blueAccent),
              onPressed: () {},
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
