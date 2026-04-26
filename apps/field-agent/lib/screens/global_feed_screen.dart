import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../constants/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/need_signal.dart';
import '../providers/signal_provider.dart';
import 'signal_status_screen.dart';

class GlobalFeedScreen extends StatelessWidget {
  const GlobalFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nearby Needs'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(LucideIcons.listFilter),
            onPressed: () {
              // Future: implementation of filters
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.primary.withValues(alpha: 0.05),
            child: Row(
              children: [
                Icon(LucideIcons.info, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Showing all active reports in your region.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<SignalProvider>(builder: (ctx, provider, _) {
              return StreamBuilder<List<NeedSignal>>(
                stream: provider.getGlobalSignals(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text('Error connecting to feed', style: TextStyle(color: AppColors.textSecondary)),
                    ]));
                  }

                  final signals = snapshot.data ?? [];
                  if (signals.isEmpty) {
                    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.check_circle_outline_rounded, size: 64, color: AppColors.success.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      const Text('All clear!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Text('No active resource needs found nearby.', style: TextStyle(color: AppColors.textHint)),
                    ]));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: signals.length,
                    itemBuilder: (ctx, i) {
                      final s = signals[i];
                      return _GlobalSignalCard(signal: s, index: i)
                          .animate()
                          .fadeIn(delay: (50 * i).ms, duration: 300.ms)
                          .slideY(begin: 0.05);
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _GlobalSignalCard extends StatelessWidget {
  final NeedSignal signal;
  final int index;
  const _GlobalSignalCard({required this.signal, required this.index});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d · h:mm a').format(signal.createdAt);
    final urgencyColor = _urgencyColor(signal.urgencyTier);
    final isCritical = signal.urgencyTier == UrgencyTier.critical;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => SignalStatusScreen(signalId: signal.signalId),
      )),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCritical ? AppColors.urgencyCritical.withValues(alpha: 0.3) : AppColors.divider,
            width: isCritical ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isCritical 
                  ? AppColors.urgencyCritical.withValues(alpha: 0.05) 
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section: Icon, Type, Urgency
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: _typeColor(signal.needType).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_needIcon(signal.needType), color: _typeColor(signal.needType), size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _needLabel(signal.needType),
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.textPrimary, letterSpacing: -0.4),
                            ),
                            const Spacer(),
                            if (signal.urgencyTier != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: urgencyColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  signal.urgencyTier!.name.toUpperCase(),
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: urgencyColor, letterSpacing: 1.0),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(LucideIcons.mapPin, size: 12, color: AppColors.textHint),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                signal.wardId,
                                style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Middle Section: Stats & Meta
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _MetaChip(icon: LucideIcons.users, label: '${signal.peopleCount} people'),
                  const SizedBox(width: 8),
                  _MetaChip(icon: LucideIcons.clock, label: dateStr),
                ],
              ),
            ),
            
            if (signal.notes != null && signal.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    signal.notes!,
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            else
              const SizedBox(height: 16),
              
            // Footer: Verification Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.divider.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(
                    signal.verificationStatus == VerificationStatus.verified 
                        ? LucideIcons.shieldCheck 
                        : LucideIcons.clock,
                    size: 14,
                    color: signal.verificationStatus == VerificationStatus.verified 
                        ? AppColors.success 
                        : AppColors.textHint,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    signal.verificationStatus == VerificationStatus.verified ? 'Verified Report' : 'Awaiting Verification',
                    style: TextStyle(
                      fontSize: 11, 
                      fontWeight: FontWeight.w600, 
                      color: signal.verificationStatus == VerificationStatus.verified 
                          ? AppColors.success 
                          : AppColors.textHint
                    ),
                  ),
                  const Spacer(),
                  const Text('VIEW DETAILS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 0.5)),
                ],
              ),
            ),
          ],
        ),
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

  Color _typeColor(NeedType t) => switch (t) {
    NeedType.food => Colors.orange,
    NeedType.water => Colors.blue,
    NeedType.medicine => Colors.red,
    NeedType.shelter => Colors.brown,
    NeedType.clothing => Colors.purple,
    NeedType.other => Colors.grey,
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

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.divider.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
