import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'active_task_screen.dart';
import 'settings_screen.dart';
import 'global_map_screen.dart';
import 'history_screen.dart';

class MissionBoardScreen extends StatefulWidget {
  const MissionBoardScreen({super.key});

  @override
  State<MissionBoardScreen> createState() => _MissionBoardScreenState();
}

class _MissionBoardScreenState extends State<MissionBoardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String get _currentUserId => FirebaseAuth.instance.currentUser?.uid ?? 'vol_mock_1';
  bool _isOnline = true;
  int _completedMissionsCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchImpactStats();
  }

  void _fetchImpactStats() {
    _firestore
        .collection('need_signals')
        .where('assigned_volunteers', arrayContains: _currentUserId)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        final completed = snapshot.docs.where((d) {
          final data = d.data();
          return data['status'] == 'completed';
        }).length;
        setState(() {
          _completedMissionsCount = completed;
        });
      }
    });

    _firestore
        .collection('volunteers')
        .doc(_currentUserId)
        .snapshots()
        .listen((snapshot) {
      if (mounted && snapshot.exists) {
        final data = snapshot.data();
        if (data != null && data.containsKey('status')) {
          setState(() {
            _isOnline = data['status'] == 'active';
          });
        }
      }
    });
  }

  void _toggleOnline(bool val) {
    setState(() => _isOnline = val);
    _firestore.collection('volunteers').doc(_currentUserId).set({
      'status': val ? 'active' : 'offline',
    }, SetOptions(merge: true));
  }
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
            icon: const Icon(LucideIcons.bell, color: Colors.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: const Color(0xFF1E293B),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                builder: (context) => Container(
                  padding: const EdgeInsets.all(24),
                  height: 300,
                  child: Column(
                    children: [
                      const Text('Notifications', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 32),
                      Icon(LucideIcons.bellOff, size: 48, color: Colors.blueGrey.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      const Text('No new notifications', style: TextStyle(color: Colors.blueGrey)),
                    ],
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              },
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blueAccent,
                child: Icon(LucideIcons.user, size: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusBanner(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('need_signals')
                  .where('status', whereIn: ['active', 'assigned'])
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
                }

                final allDocs = snapshot.data?.docs ?? [];
                
                final myAssignedDocs = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final isAssigned = data['status'] == 'assigned';
                  final volunteers = data['assigned_volunteers'] as List?;
                  return isAssigned && volunteers != null && volunteers.contains(_currentUserId);
                }).toList();

                final nearbyActiveDocs = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['status'] == 'active';
                }).toList();

                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (myAssignedDocs.isNotEmpty) ...[
                      _buildSectionHeader('Current Missions', 'Missions you have accepted'),
                      const SizedBox(height: 16),
                      ...myAssignedDocs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildMissionCard(
                            id: doc.id,
                            title: '${data['need_type']?.toString().toUpperCase()} Support',
                            distance: 'Nearby Ward ${data['ward_id']}',
                            urgency: data['urgency_tier'] ?? 'High',
                            time: _formatTimestamp(data['created_at']),
                            icon: _getIconForNeed(data['need_type']),
                            color: _getColorForUrgency(data['urgency_tier']),
                            isAssigned: true,
                          ),
                        );
                      }),
                      const SizedBox(height: 32),
                    ],

                    _buildSectionHeader('Nearby Missions', 'Matched to your skills'),
                    const SizedBox(height: 16),
                    if (nearbyActiveDocs.isEmpty)
                      _buildEmptyState()
                    else
                      ...nearbyActiveDocs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildMissionCard(
                            id: doc.id,
                            title: '${data['need_type']?.toString().toUpperCase()} Support',
                            distance: 'Nearby Ward ${data['ward_id']}',
                            urgency: data['urgency_tier'] ?? 'High',
                            time: _formatTimestamp(data['created_at']),
                            icon: _getIconForNeed(data['need_type']),
                            color: _getColorForUrgency(data['urgency_tier']),
                            isAssigned: false,
                          ),
                        );
                      }),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Your Impact', 'Overall summary'),
                    const SizedBox(height: 16),
                    _buildImpactStats(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final now = DateTime.now();
      final diff = now.difference(timestamp.toDate());
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    }
    return 'Just now';
  }

  IconData _getIconForNeed(String? type) {
    switch (type?.toLowerCase()) {
      case 'food': return LucideIcons.utensils;
      case 'water': return LucideIcons.droplets;
      case 'medicine': return LucideIcons.stethoscope;
      case 'shelter': return LucideIcons.house;
      default: return LucideIcons.info;
    }
  }

  Color _getColorForUrgency(String? tier) {
    switch (tier?.toLowerCase()) {
      case 'critical': return Colors.redAccent;
      case 'high': return Colors.orangeAccent;
      default: return Colors.blueAccent;
    }
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(LucideIcons.shieldCheck, size: 48, color: Colors.blueGrey.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text(
            'All clear! No pending missions.',
            style: TextStyle(color: Colors.blueGrey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isOnline 
              ? [Colors.tealAccent.withOpacity(0.1), Colors.tealAccent.withOpacity(0.05)]
              : [Colors.blueGrey.withOpacity(0.1), Colors.blueGrey.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _isOnline ? Colors.tealAccent.withOpacity(0.2) : Colors.blueGrey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(_isOnline ? LucideIcons.circleCheck : LucideIcons.moon, 
               color: _isOnline ? Colors.tealAccent : Colors.blueGrey, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _isOnline ? 'You are Active & Discoverable' : 'You are currently Offline',
              style: TextStyle(
                color: _isOnline ? Colors.tealAccent : Colors.blueGrey, 
                fontWeight: FontWeight.w600, 
                fontSize: 13,
              ),
            ),
          ),
          Switch(
            value: _isOnline,
            onChanged: _toggleOnline,
            activeColor: Colors.tealAccent,
            inactiveThumbColor: Colors.blueGrey,
            inactiveTrackColor: Colors.blueGrey.withOpacity(0.3),
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
    required String id,
    required String title,
    required String distance,
    required String urgency,
    required String time,
    required IconData icon,
    required Color color,
    required bool isAssigned,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAssigned ? Colors.blueAccent.withOpacity(0.08) : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isAssigned ? Colors.blueAccent.withOpacity(0.3) : Colors.white.withOpacity(0.05),
          width: isAssigned ? 1.5 : 1,
        ),
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
              isAssigned 
                ? ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ActiveTaskScreen(signalId: id),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent,
                      foregroundColor: const Color(0xFF0F172A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    ),
                    child: const Text('Open Mission', style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                : ElevatedButton(
                    onPressed: () => _acceptMission(id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    ),
                    child: const Text('Accept Mission'),
                  ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _acceptMission(String signalId) async {
    try {
      await _firestore.collection('need_signals').doc(signalId).update({
        'status': 'assigned',
        'assigned_volunteers': FieldValue.arrayUnion([_currentUserId]),
        'triaged_at': FieldValue.serverTimestamp(),
      });
      
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ActiveTaskScreen(signalId: signalId),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mission Accepted! Opening navigation...'),
          backgroundColor: Colors.tealAccent,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  Widget _buildImpactStats() {
    return Row(
      children: [
        _buildStatCard('$_completedMissionsCount', 'Missions', LucideIcons.circleCheck, Colors.blueAccent),
        const SizedBox(width: 12),
        _buildStatCard('${_completedMissionsCount * 2}h', 'Volunteered', LucideIcons.clock, Colors.purpleAccent),
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
          IconButton(
            icon: const Icon(LucideIcons.layoutGrid, color: Colors.blueAccent),
            onPressed: () {},
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
            icon: const Icon(LucideIcons.settings, color: Colors.blueGrey),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
    );
  }
}
