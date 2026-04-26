import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image_picker/image_picker.dart';
import '../models/need_signal.dart';
import '../services/signal_service.dart';
import '../services/location_service.dart';
import '../services/photo_service.dart';
import '../services/auth_service.dart';

/// Central state management for signal submission workflow.
class SignalProvider extends ChangeNotifier {
  final SignalService _signalService = SignalService();
  final LocationService _locationService = LocationService();
  final PhotoService _photoService = PhotoService();
  final AuthService _authService = AuthService();

  // Form state
  NeedType _needType = NeedType.food;
  int _peopleCount = 1;
  int _urgencyRaw = 3;
  String _wardId = '';
  String _cityId = 'default_city';
  String _notes = '';
  XFile? _capturedPhoto;
  Position? _currentPosition;

  // Submission state
  bool _isSubmitting = false;
  bool _isCapturingLocation = false;
  String? _lastSubmittedSignalId;
  String? _errorMessage;
  bool _isOnline = true;

  // Getters
  NeedType get needType => _needType;
  int get peopleCount => _peopleCount;
  int get urgencyRaw => _urgencyRaw;
  String get wardId => _wardId;
  String get cityId => _cityId;
  String get notes => _notes;
  XFile? get capturedPhoto => _capturedPhoto;
  Position? get currentPosition => _currentPosition;
  bool get isSubmitting => _isSubmitting;
  bool get isCapturingLocation => _isCapturingLocation;
  String? get lastSubmittedSignalId => _lastSubmittedSignalId;
  String? get errorMessage => _errorMessage;
  bool get isOnline => _isOnline;
  String get userId => _authService.userId;

  // Setters
  void setNeedType(NeedType type) {
    _needType = type;
    notifyListeners();
  }

  void setPeopleCount(int count) {
    _peopleCount = count.clamp(1, 99999);
    notifyListeners();
  }

  void setUrgencyRaw(int urgency) {
    _urgencyRaw = urgency.clamp(1, 5);
    notifyListeners();
  }

  void setWardId(String ward) {
    _wardId = ward;
    notifyListeners();
  }

  void setCityId(String city) {
    _cityId = city;
    notifyListeners();
  }

  void setNotes(String text) {
    _notes = text;
    notifyListeners();
  }

  /// Capture GPS location.
  Future<void> captureLocation() async {
    _isCapturingLocation = true;
    _errorMessage = null;
    notifyListeners();

    _currentPosition = await _locationService.getCurrentPosition();
    _isCapturingLocation = false;

    if (_currentPosition == null) {
      _errorMessage = 'Could not get GPS location. Please ensure location services are enabled.';
    }
    notifyListeners();
  }

  /// Capture photo from camera.
  Future<void> capturePhoto() async {
    final file = await _photoService.captureAndCompress();
    if (file != null) {
      _capturedPhoto = file;
      notifyListeners();
    }
  }

  /// Pick photo from gallery.
  Future<void> pickPhoto() async {
    final file = await _photoService.pickAndCompress();
    if (file != null) {
      _capturedPhoto = file;
      notifyListeners();
    }
  }

  /// Remove captured photo.
  void removePhoto() {
    if (_capturedPhoto != null) {
      _photoService.cleanupTempFile(_capturedPhoto!);
      _capturedPhoto = null;
      notifyListeners();
    }
  }

  /// Check connectivity.
  Future<void> checkConnectivity() async {
    _isOnline = await _signalService.isOnline();
    notifyListeners();

    // Also listen for changes
    Connectivity().onConnectivityChanged.listen((results) {
      _isOnline = !results.contains(ConnectivityResult.none);
      notifyListeners();
    });
  }

  /// Validate form before submission.
  String? validateForm() {
    if (_wardId.trim().isEmpty) return 'Ward/Area ID is required';
    if (_peopleCount < 1) return 'People count must be at least 1';
    if (_urgencyRaw < 1 || _urgencyRaw > 5) return 'Urgency must be 1-5';
    return null;
  }

  /// Submit the signal to Firestore.
  Future<bool> submitSignal() async {
    final validation = validateForm();
    if (validation != null) {
      _errorMessage = validation;
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Auto-capture location if not already done
      if (_currentPosition == null) {
        await captureLocation();
      }

      final signal = NeedSignal(
        signalId: const Uuid().v4(),
        wardId: _wardId,
        cityId: _cityId,
        needType: _needType,
        peopleCount: _peopleCount,
        urgencyRaw: _urgencyRaw,
        notes: _notes.isNotEmpty ? _notes : null,
        reporterId: _authService.userId,
        reporterRole: 'field_agent',
        latitude: _currentPosition?.latitude ?? 0,
        longitude: _currentPosition?.longitude ?? 0,
        createdAt: DateTime.now(),
      );

      _lastSubmittedSignalId = await _signalService.submitSignal(
        signal,
        photoFile: _capturedPhoto,
      );

      // Start triage simulation in background (Hackathon Demo Only)
      _signalService.simulateTriage(_lastSubmittedSignalId!);

      // Reset form
      _resetForm();
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Submission failed: ${e.toString()}';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  /// Get signal stream for status tracking.
  Stream<NeedSignal?> getSignalStream(String signalId) {
    return _signalService.getSignalStream(signalId);
  }

  /// Get reporter's past signals.
  Stream<List<NeedSignal>> getMySignals() {
    return _signalService.getSignalsByReporter(_authService.userId);
  }
  
  /// Get all active signals globally.
  Stream<List<NeedSignal>> getGlobalSignals() {
    return _signalService.getActiveSignals();
  }

  void _resetForm() {
    _needType = NeedType.food;
    _peopleCount = 1;
    _urgencyRaw = 3;
    _wardId = '';
    _notes = '';
    if (_capturedPhoto != null) {
      _photoService.cleanupTempFile(_capturedPhoto!);
    }
    _capturedPhoto = null;
    _currentPosition = null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
