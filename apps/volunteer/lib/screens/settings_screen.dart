import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'mission_board.dart';
import 'global_map_screen.dart';
import 'history_screen.dart';
import 'auth_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.blueAccent,
            child: Icon(LucideIcons.user, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              FirebaseAuth.instance.currentUser?.email ?? 'Unknown User',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(LucideIcons.bell, color: Colors.white70),
            title: const Text('Notifications', style: TextStyle(color: Colors.white)),
            trailing: Switch(value: true, onChanged: (v) {}, activeThumbColor: Colors.tealAccent),
          ),
          ListTile(
            leading: const Icon(LucideIcons.shield, color: Colors.white70),
            title: const Text('Privacy & Security', style: TextStyle(color: Colors.white)),
            trailing: const Icon(LucideIcons.chevronRight, color: Colors.white70),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF1E293B),
                  title: const Text('Privacy & Security', style: TextStyle(color: Colors.white)),
                  content: const Text(
                    'Your data is encrypted end-to-end. Location tracking is only active during accepted missions.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it', style: TextStyle(color: Colors.tealAccent)),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(LucideIcons.info, color: Colors.white70),
            title: const Text('Help & Support', style: TextStyle(color: Colors.white)),
            trailing: const Icon(LucideIcons.chevronRight, color: Colors.white70),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF1E293B),
                  title: const Text('Help & Support', style: TextStyle(color: Colors.white)),
                  content: const Text(
                    'For emergency assistance, please call the local authorities.\n\nFor app support, email:\nsupport@resourceradar.ai',
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close', style: TextStyle(color: Colors.tealAccent)),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
              }
            },
            icon: const Icon(LucideIcons.logOut),
            label: const Text('Log Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
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
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MissionBoardScreen()));
              },
            ),
            IconButton(
              icon: const Icon(LucideIcons.map, color: Colors.blueGrey),
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const GlobalMapScreen()));
              },
            ),
            IconButton(
              icon: const Icon(LucideIcons.history, color: Colors.blueGrey),
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
              },
            ),
            IconButton(
              icon: const Icon(LucideIcons.settings, color: Colors.blueAccent),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
