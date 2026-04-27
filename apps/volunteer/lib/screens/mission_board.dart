import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MissionBoardScreen extends StatelessWidget {
  const MissionBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Mission Board',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell, color: Colors.blueGrey),
            onPressed: () {},
          ),
          const CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=vol1'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          _buildStatusBanner(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSectionHeader('Nearby Missions', 'Matched to your skills'),
                const SizedBox(height: 16),
                _buildMissionCard(
                  title: 'Medical Supplies Delivery',
                  distance: '1.2 km away',
                  urgency: 'Critical',
                  time: 'Requested 10m ago',
                  icon: LucideIcons.stethoscope,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 16),
                _buildMissionCard(
                  title: 'Food Distribution Assist',
                  distance: '0.8 km away',
                  urgency: 'High',
                  time: 'Requested 25m ago',
                  icon: LucideIcons.utensils,
                  color: Colors.orangeAccent,
                ),
                const SizedBox(height: 32),
                _buildSectionHeader('Your Impact', 'Weekly summary'),
                const SizedBox(height: 16),
                _buildImpactStats(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.tealAccent.withOpacity(0.1), Colors.tealAccent.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.tealAccent.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.circleCheck, color: Colors.tealAccent, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'You are Active & Discoverable',
              style: TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Switch(
            value: true,
            onChanged: (v) {},
            activeColor: Colors.tealAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          subtitle,
          style: TextStyle(fontSize: 13, color: Colors.blueGrey[500]),
        ),
      ],
    );
  }

  Widget _buildMissionCard({
    required String title,
    required String distance,
    required String urgency,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      distance,
                      style: TextStyle(color: Colors.blueGrey[400], fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  urgency.toUpperCase(),
                  style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(time, style: TextStyle(color: Colors.blueGrey[600], fontSize: 12)),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
                child: const Row(
                  children: [
                    Text('Accept Mission'),
                    SizedBox(width: 4),
                    Icon(LucideIcons.arrowRight, size: 14),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImpactStats() {
    return Row(
      children: [
        _buildStatCard('12', 'Assists', LucideIcons.users, Colors.blueAccent),
        const SizedBox(width: 12),
        _buildStatCard('48h', 'Volunteered', LucideIcons.clock, Colors.purpleAccent),
      ],
    );
  }

  Widget _buildStatCard(String val, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 12),
            Text(val, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: Colors.blueGrey[500], fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(LucideIcons.layoutGrid, color: Colors.blueAccent),
          Icon(LucideIcons.map, color: Colors.blueGrey),
          Icon(LucideIcons.history, color: Colors.blueGrey),
          Icon(LucideIcons.settings, color: Colors.blueGrey),
        ],
      ),
    );
  }
}
