import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../models/need_signal.dart';
import 'dart:typed_data';

/// Handles signal writes to Firestore with offline persistence.
/// Firestore SDK automatically queues writes when offline and syncs on reconnect.
class SignalService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const String _collection = 'need_signals';

  SignalService() {
    // Enable Firestore offline persistence
    _db.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  /// Submit a new need signal. Works offline — Firestore SDK queues the write.
  Future<String> submitSignal(NeedSignal signal, {XFile? photoFile}) async {
    String? uploadedPhotoUrl;
    bool isOnline = await this.isOnline();

    // Upload photo if available and online
    if (photoFile != null && isOnline) {
      uploadedPhotoUrl = await _uploadPhoto(photoFile, signal.signalId);
    }

    final data = signal.toFirestore();
    if (uploadedPhotoUrl != null) {
      data['photo_url'] = uploadedPhotoUrl;
      data['photo_pending'] = false;
    } else if (photoFile != null) {
      data['photo_pending'] = true;
    }

    await _db.collection(_collection).doc(signal.signalId).set(data);
    return signal.signalId;
  }

  /// Upload photo to Firebase Storage with compression. Returns download URL.
  Future<String?> _uploadPhoto(XFile file, String signalId) async {
    try {
      final ref = _storage
          .ref()
          .child('signal_photos')
          .child('$signalId.jpg');

      // 1. Read original bytes
      final originalBytes = await file.readAsBytes();
      
      // 2. Compress image (target < 500KB as per roadmap)
      Uint8List compressedBytes;
      try {
        final result = await FlutterImageCompress.compressWithList(
          originalBytes,
          minHeight: 1080,
          minWidth: 1080,
          quality: 85,
          format: CompressFormat.jpeg,
        );
        compressedBytes = Uint8List.fromList(result);
        print('DEBUG: Compressed image from ${originalBytes.length} to ${compressedBytes.length} bytes');
      } catch (e) {
        print('WARNING: Compression failed, using original bytes: $e');
        compressedBytes = originalBytes;
      }

      // 3. Upload to Storage
      final uploadTask = await ref.putData(
        compressedBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final url = await uploadTask.ref.getDownloadURL();
      
      await _db.collection(_collection).doc(signalId).update({
        'photo_url': url,
        'photo_pending': false,
      });

      return url;
    } catch (e) {
      return null;
    }
  }

  /// Get all signals submitted by a specific reporter, ordered by creation date.
  Stream<List<NeedSignal>> getSignalsByReporter(String reporterId) {
    return _db
        .collection(_collection)
        .where('reporter_id', isEqualTo: reporterId)
        .orderBy('created_at', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NeedSignal.fromFirestore(doc.data()))
            .toList());
  }

  /// Get all active signals (Global Feed), ordered by creation date.
  Stream<List<NeedSignal>> getActiveSignals() {
    return _db
        .collection(_collection)
        .where('status', isEqualTo: 'active')
        .orderBy('created_at', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NeedSignal.fromFirestore(doc.data()))
            .toList());
  }

  /// Get a single signal by ID (real-time updates).
  Stream<NeedSignal?> getSignalStream(String signalId) {
    return _db
        .collection(_collection)
        .doc(signalId)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return NeedSignal.fromFirestore(doc.data()!);
    });
  }

  /// Check connectivity status.
  Future<bool> isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// Get pending (locally cached, not yet synced) writes count.
  /// Note: Firestore doesn't expose this directly, so we track via metadata.
  Stream<bool> hasPendingWrites(String signalId) {
    return _db
        .collection(_collection)
        .doc(signalId)
        .snapshots(includeMetadataChanges: true)
        .map((doc) => doc.metadata.hasPendingWrites);
  }

  /// Simulate Gemini Triage for hackathon demo.
  /// Transitions status from pending to verified/critical after 3-5s.
  Future<void> simulateTriage(String signalId) async {
    await Future.delayed(const Duration(seconds: 4));
    
    // Check if signal still exists and is pending
    final doc = await _db.collection(_collection).doc(signalId).get();
    if (!doc.exists) return;
    
    final data = doc.data()!;
    if (data['verification_status'] != 'pending') return;

    // Simulate Gemini's output
    await _db.collection(_collection).doc(signalId).update({
      'verification_status': 'verified',
      'urgency_score': 85 + (signalId.hashCode % 15), // Random high score
      'gemini_reasoning': 'Multimodal analysis confirms density of need in the provided photo. GPS proximity to known crisis center validates location. Urgency elevated due to volume of people identified.',
      'status': 'active', // Ensure it stays active
    });
  }
}
