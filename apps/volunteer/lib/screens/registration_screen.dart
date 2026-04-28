import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'mission_board.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  final List<String> _skills = ['Medical', 'Logistics', 'Driving', 'Food Prep', 'Search & Rescue'];
  final Set<String> _selectedSkills = {};
  bool _isLoading = false;

  // In a production environment, this would come from an environment config
  final String _matchingServiceUrl = 'http://localhost:8001';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(LucideIcons.heartHandshake, color: Colors.blueAccent, size: 32),
              ),
              const SizedBox(height: 24),
              const Text(
                'Join the Radar',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your skills can save lives. Register as a verified volunteer to receive real-time alerts.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blueGrey[400],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      label: 'Full Name',
                      hint: 'John Doe',
                      icon: LucideIcons.user,
                      controller: _nameController,
                      validator: (v) => v!.isEmpty ? 'Name required' : null,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'Phone Number',
                      hint: '+91 98765 43210',
                      icon: LucideIcons.phone,
                      keyboardType: TextInputType.phone,
                      controller: _phoneController,
                      validator: (v) => v!.isEmpty ? 'Phone required' : null,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Core Skills',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _skills.map((skill) {
                        final isSelected = _selectedSkills.contains(skill);
                        return ChoiceChip(
                          label: Text(skill),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedSkills.add(skill);
                              } else {
                                _selectedSkills.remove(skill);
                              }
                            });
                          },
                          backgroundColor: Colors.white.withOpacity(0.05),
                          selectedColor: Colors.blueAccent.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.blueAccent : Colors.blueGrey[400],
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected ? Colors.blueAccent.withOpacity(0.5) : Colors.transparent,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 48),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegistration,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Complete Registration',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one skill.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Create Anonymous User for Demo (In real app, use Phone Auth)
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      final uid = userCredential.user!.uid;

      // 2. Save Profile to Firestore
      final profile = {
        'volunteer_id': uid,
        'display_name': _nameController.text,
        'phone': _phoneController.text,
        'skills': _selectedSkills.toList(),
        'status': 'active',
        'location': {'latitude': 30.7333, 'longitude': 76.7794}, // Mock location
        'created_at': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('volunteers').doc(uid).set(profile);

      // 3. Trigger Matching Service Sync (Crucial for Production Vector Search)
      try {
        await http.post(
          Uri.parse('$_matchingServiceUrl/sync-volunteer'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'volunteer_id': uid}),
        );
      } catch (e) {
        print('Matching Service Sync Error: $e');
        // We don't block registration if sync fails, it will be picked up by batch sync
      }

      if (!mounted) return;
      
      // 4. Navigate to Mission Board
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MissionBoardScreen()),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.blueGrey,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.blueGrey[600]),
            prefixIcon: Icon(icon, color: Colors.blueGrey[500], size: 20),
            filled: true,
            fillColor: Colors.white.withOpacity(0.03),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.blueAccent),
            ),
          ),
        ),
      ],
    );
  }
}
