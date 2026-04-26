import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';
import '../providers/signal_provider.dart';
import '../utils/validators.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../widgets/need_type_grid.dart';
import '../widgets/urgency_slider.dart';
import '../widgets/photo_capture.dart';
import '../widgets/location_card.dart';
import '../widgets/connectivity_badge.dart';
import 'signal_status_screen.dart';

class SubmitSignalScreen extends StatefulWidget {
  const SubmitSignalScreen({super.key});
  @override
  State<SubmitSignalScreen> createState() => _SubmitSignalScreenState();
}

class _SubmitSignalScreenState extends State<SubmitSignalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _wardCtrl = TextEditingController();
  final _peopleCtrl = TextEditingController(text: '1');
  final _notesCtrl = TextEditingController();
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SignalProvider>().captureLocation();
      setState(() => _hasAnimated = true);
    });
  }

  @override
  void dispose() {
    _wardCtrl.dispose();
    _peopleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  InputDecoration _inputDeco({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Future<void> _submit(SignalProvider p) async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await p.submitSignal();
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Row(children: [
          Icon(Icons.check_circle, color: Colors.white),
          SizedBox(width: 8),
          Text('Signal submitted!'),
        ]),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ));
      if (p.lastSubmittedSignalId != null) {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => SignalStatusScreen(signalId: p.lastSubmittedSignalId!),
        ));
      }
      _wardCtrl.clear();
      _peopleCtrl.text = '1';
      _notesCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Report Need Signal'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<SignalProvider>(
            builder: (_, p, __) => ConnectivityBadge(isOnline: p.isOnline),
          ),
        ],
      ),
      body: Consumer<SignalProvider>(builder: (ctx, p, _) {
        return Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              LocationCard(provider: p).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: 16),
              _label('1. Type of Need', LucideIcons.layoutGrid),
              const SizedBox(height: 8),
              NeedTypeGrid(selected: p.needType, onChanged: p.setNeedType)
                  .animate(target: _hasAnimated ? 1 : 0).fadeIn(delay: 100.ms),
              const SizedBox(height: 24),
              _label('2. Ward / Area', LucideIcons.mapPin),
              const SizedBox(height: 8),
              TextFormField(
                controller: _wardCtrl,
                decoration: _inputDeco(hint: 'e.g. Ward-23', icon: LucideIcons.map),
                validator: Validators.validateWardId,
                onChanged: p.setWardId,
              ).animate(target: _hasAnimated ? 1 : 0).fadeIn(delay: 200.ms),
              const SizedBox(height: 24),
              _label('3. People Affected', LucideIcons.users),
              const SizedBox(height: 8),
              TextFormField(
                controller: _peopleCtrl,
                decoration: _inputDeco(hint: 'Number', icon: LucideIcons.users),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: Validators.validatePeopleCount,
                onChanged: (v) => p.setPeopleCount(int.tryParse(v) ?? 1),
              ).animate(target: _hasAnimated ? 1 : 0).fadeIn(delay: 300.ms),
              const SizedBox(height: 24),
              _label('4. Urgency Level', LucideIcons.triangleAlert),
              const SizedBox(height: 8),
              UrgencySliderWidget(value: p.urgencyRaw, onChanged: p.setUrgencyRaw)
                  .animate(target: _hasAnimated ? 1 : 0).fadeIn(delay: 400.ms),
              const SizedBox(height: 24),
              _label('5. Photo Evidence', LucideIcons.camera),
              const SizedBox(height: 8),
              PhotoCaptureWidget(
                photo: p.capturedPhoto,
                onCapture: p.capturePhoto,
                onPick: p.pickPhoto,
                onRemove: p.removePhoto,
              ).animate(target: _hasAnimated ? 1 : 0).fadeIn(delay: 500.ms),
              const SizedBox(height: 24),
              _label('6. Additional Notes', LucideIcons.pencil),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesCtrl,
                decoration: _inputDeco(hint: 'Details...', icon: LucideIcons.fileText),
                maxLines: 3,
                maxLength: 2000,
                validator: Validators.validateNotes,
                onChanged: p.setNotes,
              ).animate(target: _hasAnimated ? 1 : 0).fadeIn(delay: 600.ms),
              const SizedBox(height: 32),
              if (p.errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(p.errorMessage!, style: const TextStyle(color: AppColors.error)),
                ),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: p.isSubmitting ? null : () => _submit(p),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: p.isSubmitting
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : Text(p.isOnline ? 'SUBMIT SIGNAL' : 'SAVE OFFLINE',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                ),
              ).animate(target: _hasAnimated ? 1 : 0).fadeIn(delay: 700.ms),
              const SizedBox(height: 48),
            ],
          ),
        );
      }),
    );
  }

  Widget _label(String text, IconData icon) => Row(children: [
    Icon(icon, size: 18, color: AppColors.primary),
    const SizedBox(width: 8),
    Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
  ]);
}
