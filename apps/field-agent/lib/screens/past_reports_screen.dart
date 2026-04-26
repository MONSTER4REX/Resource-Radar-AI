import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../constants/app_theme.dart';
import '../models/need_signal.dart';
import '../providers/signal_provider.dart';
import 'signal_status_screen.dart';

class PastReportsScreen extends StatelessWidget {
  const PastReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Reports'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<SignalProvider>(builder: (ctx, provider, _) {
        return StreamBuilder<List<NeedSignal>>(
          stream: provider.getMySignals(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: 16),
                Text('Error loading reports', style: TextStyle(color: AppColors.textSecondary)),
              ]));
            }

            final signals = snapshot.data ?? [];
            if (signals.isEmpty) {
              return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(LucideIcons.inbox, size: 64, color: AppColors.textHint),
                const SizedBox(height: 16),
                const Text('No reports yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Text('Submit your first signal to see it here.', style: TextStyle(color: AppColors.textHint)),
              ]));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: signals.length,
              itemBuilder: (ctx, i) {
                final s = signals[i];
                return _SignalCard(signal: s, index: i).animate().fadeIn(delay: (50 * i).ms, duration: 300.ms).slideX(begin: 0.05);
              },
            );
          },
        );
      }),
    );
  }
}

class _SignalCard extends StatelessWidget {
  final NeedSignal signal;
  final int index;
  const _SignalCard({required this.signal, required this.index});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, y · h:mm a').format(signal.createdAt);
    final urgencyColor = _urgencyColor(signal.urgencyTier);

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => SignalStatusScreen(signalId: signal.signalId),
      )),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          // Need type icon
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_needIcon(signal.needType), color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(_needLabel(signal.needType), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const Spacer(),
              if (signal.urgencyTier != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: urgencyColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(999)),
                  child: Text(signal.urgencyTier!.name.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: urgencyColor)),
                ),
            ]),
            const SizedBox(height: 4),
            Text('Ward: ${signal.wardId} · ${signal.peopleCount} people', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 2),
            Text(dateStr, style: TextStyle(fontSize: 11, color: AppColors.textHint)),
          ])),
          const SizedBox(width: 8),
          // Status indicator
          _StatusDot(status: signal.status),
        ]),
      ),
    );
  }

  Color _urgencyColor(UrgencyTier? tier) => switch (tier) {
    UrgencyTier.critical => AppColors.urgencyCritical,
    UrgencyTier.high => AppColors.urgencyHigh,
    UrgencyTier.medium => AppColors.urgencyMedium,
    UrgencyTier.low => AppColors.urgencyLow,
    null => AppColors.textHint,
  };

  IconData _needIcon(NeedType t) => switch (t) {
    NeedType.food => LucideIcons.utensils,
    NeedType.water => LucideIcons.droplet,
    NeedType.medicine => LucideIcons.pill,
    NeedType.shelter => LucideIcons.house,
    NeedType.clothing => LucideIcons.shirt,
    NeedType.other => LucideIcons.circleQuestionMark,
  };

  String _needLabel(NeedType t) => t.name[0].toUpperCase() + t.name.substring(1);
}

class _StatusDot extends StatelessWidget {
  final SignalStatus status;
  const _StatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      SignalStatus.active => AppColors.info,
      SignalStatus.assigned => AppColors.accent,
      SignalStatus.resolved => AppColors.success,
      SignalStatus.duplicate => AppColors.textHint,
      SignalStatus.false_report => AppColors.error,
    };
    return Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color));
  }
}
