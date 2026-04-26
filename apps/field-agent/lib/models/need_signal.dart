import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors the backend NeedSignal schema exactly.
/// Used for both local creation and Firestore serialization.

enum NeedType { food, water, medicine, shelter, clothing, other }

enum UrgencyTier { critical, high, medium, low }

enum VerificationStatus { verified, suspicious, needs_review, pending }

enum SourceChannel { field_form, whatsapp, sms, civic_api }

enum SignalStatus { active, assigned, resolved, duplicate, false_report }

class NeedSignal {
  final String signalId;
  final String wardId;
  final String cityId;
  final NeedType needType;
  final int peopleCount;
  final int urgencyRaw; // 1-5 from field agent
  final String? photoUrl;
  final String? notes;
  final String reporterId;
  final String reporterRole;
  final SourceChannel sourceChannel;

  // Filled by backend triage
  final int? urgencyScore; // 0-100 (Gemini)
  final UrgencyTier? urgencyTier;
  final bool? photoMatchesClaim;
  final VerificationStatus verificationStatus;
  final bool duplicateRisk;
  final String? geminiReasoning;

  // Location
  final double latitude;
  final double longitude;

  // Status
  final SignalStatus status;
  final List<String> assignedVolunteers;
  final String? assignedVehicleRoute;

  // Timestamps
  final DateTime createdAt;
  final DateTime? triagedAt;
  final DateTime? resolvedAt;

  final String ngoId;

  NeedSignal({
    required this.signalId,
    required this.wardId,
    required this.cityId,
    required this.needType,
    required this.peopleCount,
    required this.urgencyRaw,
    this.photoUrl,
    this.notes,
    required this.reporterId,
    required this.reporterRole,
    this.sourceChannel = SourceChannel.field_form,
    this.urgencyScore,
    this.urgencyTier,
    this.photoMatchesClaim,
    this.verificationStatus = VerificationStatus.pending,
    this.duplicateRisk = false,
    this.geminiReasoning,
    required this.latitude,
    required this.longitude,
    this.status = SignalStatus.active,
    this.assignedVolunteers = const [],
    this.assignedVehicleRoute,
    required this.createdAt,
    this.triagedAt,
    this.resolvedAt,
    this.ngoId = 'NGO_ROOT',
  });

  /// Convert to Firestore-compatible map for writing.
  Map<String, dynamic> toFirestore() {
    return {
      'signal_id': signalId,
      'ward_id': wardId,
      'city_id': cityId,
      'need_type': needType.name,
      'people_count': peopleCount,
      'urgency_raw': urgencyRaw,
      'photo_url': photoUrl,
      'notes': notes,
      'reporter_id': reporterId,
      'reporter_role': reporterRole,
      'source_channel': sourceChannel.name,
      'verification_status': verificationStatus.name,
      'duplicate_risk': duplicateRisk,
      'location': {
        'latitude': latitude,
        'longitude': longitude,
      },
      'status': status.name,
      'assigned_volunteers': assignedVolunteers,
      'created_at': Timestamp.fromDate(createdAt),
      'ngo_id': ngoId,
    };
  }

  /// Create a NeedSignal from a Firestore document snapshot.
  factory NeedSignal.fromFirestore(Map<String, dynamic> data) {
    final location = data['location'] as Map<String, dynamic>? ?? {};
    return NeedSignal(
      signalId: data['signal_id'] ?? '',
      wardId: data['ward_id'] ?? '',
      cityId: data['city_id'] ?? '',
      needType: NeedType.values.firstWhere(
        (e) => e.name == data['need_type'],
        orElse: () => NeedType.other,
      ),
      peopleCount: data['people_count'] ?? 0,
      urgencyRaw: data['urgency_raw'] ?? 1,
      photoUrl: data['photo_url'],
      notes: data['notes'],
      reporterId: data['reporter_id'] ?? '',
      reporterRole: data['reporter_role'] ?? 'field_agent',
      sourceChannel: SourceChannel.values.firstWhere(
        (e) => e.name == data['source_channel'],
        orElse: () => SourceChannel.field_form,
      ),
      urgencyScore: data['urgency_score'],
      urgencyTier: data['urgency_tier'] != null
          ? UrgencyTier.values.firstWhere(
              (e) => e.name == data['urgency_tier'],
              orElse: () => UrgencyTier.low,
            )
          : null,
      photoMatchesClaim: data['photo_matches_claim'],
      verificationStatus: VerificationStatus.values.firstWhere(
        (e) => e.name == data['verification_status'],
        orElse: () => VerificationStatus.pending,
      ),
      duplicateRisk: data['duplicate_risk'] ?? false,
      geminiReasoning: data['gemini_reasoning'],
      latitude: (location['latitude'] ?? 0).toDouble(),
      longitude: (location['longitude'] ?? 0).toDouble(),
      status: SignalStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => SignalStatus.active,
      ),
      assignedVolunteers: List<String>.from(data['assigned_volunteers'] ?? []),
      assignedVehicleRoute: data['assigned_vehicle_route'],
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      triagedAt: (data['triaged_at'] as Timestamp?)?.toDate(),
      resolvedAt: (data['resolved_at'] as Timestamp?)?.toDate(),
      ngoId: data['ngo_id'] ?? 'NGO_ROOT',
    );
  }
}
