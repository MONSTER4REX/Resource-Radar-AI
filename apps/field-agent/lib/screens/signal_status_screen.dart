import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../constants/app_theme.dart';
import '../models/need_signal.dart';
import '../providers/signal_provider.dart';

/// Post-submission screen showing Gemini triage results in real-time.
class SignalStatusScreen extends StatelessWidget {
  final String signalId;
  const SignalStatusScreen({super.key, required this.signalId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Signal Status'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<SignalProvider>(builder: (ctx, provider, _) {
        return StreamBuilder<NeedSignal?>(
          stream: provider.getSignalStream(signalId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _LoadingState();
            }

            final signal = snapshot.data;
            if (signal == null) {
              return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(LucideIcons.clock, size: 48, color: AppColors.accent),
                const SizedBox(height: 16),
                const Text('Signal syncing...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.5)),
                const SizedBox(height: 8),
                Text('Your signal will appear once it syncs with the server.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
              ]));
            }

            return ListView(padding: const EdgeInsets.all(24), children: [
              // Status Header
              _StatusHeader(signal: signal).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 24),

              // Urgency Score (from Gemini)
              if (signal.urgencyScore != null) ...[
                _UrgencyScoreCard(signal: signal).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                const SizedBox(height: 16),
              ] else ...[
                _PendingTriageCard().animate().fadeIn(delay: 200.ms, duration: 400.ms),
                const SizedBox(height: 16),
              ],

              // Gemini Reasoning
              if (signal.geminiReasoning != null) ...[
                _ReasoningCard(reasoning: signal.geminiReasoning!).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                const SizedBox(height: 16),
              ],

              // Photo Verification
              if (signal.photoMatchesClaim != null)
                _PhotoVerificationCard(matches: signal.photoMatchesClaim!).animate().fadeIn(delay: 400.ms, duration: 400.ms),

              const SizedBox(height: 16),

              // Signal Details
              _DetailsCard(signal: signal).animate().fadeIn(delay: 500.ms, duration: 400.ms),
            ]);
          },
        );
      }),
    );
  }
}

class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      CircularProgressIndicator(),
      SizedBox(height: 16),
      Text('Loading signal data...', style: TextStyle(color: AppColors.textSecondary)),
    ]));
  }
}

class _StatusHeader extends StatelessWidget {
  final NeedSignal signal;
  const _StatusHeader({required this.signal});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (signal.verificationStatus) {
      VerificationStatus.verified => AppColors.success,
      VerificationStatus.suspicious => AppColors.error,
      VerificationStatus.needs_review => AppColors.warning,
      VerificationStatus.pending => AppColors.info,
    };
    final statusLabel = signal.verificationStatus.name.replaceAll('_', ' ').toUpperCase();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
          child: Icon(
            signal.verificationStatus == VerificationStatus.verified ? LucideIcons.shieldCheck
                : signal.verificationStatus == VerificationStatus.suspicious ? LucideIcons.shieldAlert
                : LucideIcons.clock,
            color: statusColor, size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(statusLabel, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: statusColor, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text('Signal ID: ${signal.signalId.substring(0, 8)}...', style: const TextStyle(fontSize: 12, color: AppColors.textHint, fontFamily: 'monospace')),
        ])),
      ]),
    );
  }
}

class _UrgencyScoreCard extends StatelessWidget {
  final NeedSignal signal;
  const _UrgencyScoreCard({required this.signal});

  @override
  Widget build(BuildContext context) {
    final score = signal.urgencyScore!;
    final color = score >= 80 ? AppColors.urgencyCritical : score >= 60 ? AppColors.urgencyHigh : score >= 40 ? AppColors.urgencyMedium : AppColors.urgencyLow;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
      child: Column(children: [
        const Text('AI Urgency Score', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 1)),
        const SizedBox(height: 12),
        Text('$score', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 4),
        Text('out of 100', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: score / 100, backgroundColor: color.withValues(alpha: 0.1), color: color, minHeight: 8),
        ),
        if (signal.urgencyTier != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(999)),
            child: Text('${signal.urgencyTier!.name.toUpperCase()} PRIORITY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.8)),
          ),
        ],
      ]),
    );
  }
}

class _PendingTriageCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
      child: const Row(children: [
        SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.accent)),
        SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Gemini AI Triage Pending', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          SizedBox(height: 4),
          Text('Your signal is being analyzed by Gemini 1.5 Pro for urgency scoring and verification.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ])),
      ]),
    );
  }
}

class _ReasoningCard extends StatelessWidget {
  final String reasoning;
  const _ReasoningCard({required this.reasoning});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(LucideIcons.zap, color: AppColors.primary, size: 20),
          SizedBox(width: 8),
          Text('Gemini Reasoning', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 0.5)),
        ]),
        const SizedBox(height: 12),
        Text(reasoning, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.5)),
      ]),
    );
  }
}

class _PhotoVerificationCard extends StatelessWidget {
  final bool matches;
  const _PhotoVerificationCard({required this.matches});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (matches ? AppColors.success : AppColors.error).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: (matches ? AppColors.success : AppColors.error).withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        Icon(matches ? LucideIcons.circleCheck : LucideIcons.octagonAlert, color: matches ? AppColors.success : AppColors.error),
        const SizedBox(width: 12),
        Expanded(child: Text(
          matches ? 'Photo evidence matches the reported claim.' : 'Photo evidence may not match the claim — flagged for review.',
          style: TextStyle(fontSize: 13, color: matches ? AppColors.success : AppColors.error, fontWeight: FontWeight.w500),
        )),
      ]),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final NeedSignal signal;
  const _DetailsCard({required this.signal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Signal Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        _row('Need Type', signal.needType.name),
        _row('Ward', signal.wardId),
        _row('People', '${signal.peopleCount}'),
        _row('Field Urgency', '${signal.urgencyRaw} / 5'),
        _row('GPS', '${signal.latitude.toStringAsFixed(4)}, ${signal.longitude.toStringAsFixed(4)}'),
        if (signal.notes != null) _row('Notes', signal.notes!),
      ]),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textHint, fontWeight: FontWeight.w500))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
    ]),
  );
}
