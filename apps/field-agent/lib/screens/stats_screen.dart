import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../constants/app_theme.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Impact & Stats'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Impact Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'TOTAL LIVES IMPACTED',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '1,248',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                    ),
                  ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.award, color: Colors.white, size: 14),
                        SizedBox(width: 6),
                        Text(
                          'Top 5% of Field Agents',
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            const Text(
              'Activity Metrics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),

            // Metrics Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _StatTile(
                  label: 'Signals Sent',
                  value: '42',
                  icon: LucideIcons.radio,
                  color: AppColors.primary,
                ),
                _StatTile(
                  label: 'Verified',
                  value: '38',
                  icon: LucideIcons.shieldCheck,
                  color: AppColors.success,
                ),
                _StatTile(
                  label: 'Avg Response',
                  value: '18m',
                  icon: LucideIcons.activity,
                  color: AppColors.accent,
                ),
                _StatTile(
                  label: 'Rank',
                  value: '#12',
                  icon: LucideIcons.trendingUp,
                  color: AppColors.info,
                ),
              ],
            ),

            const SizedBox(height: 32),

            const Text(
              'Contribution History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),

            // Fake chart representation
            Container(
              height: 200,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Weekly Signals', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('+12% vs last week', style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(7, (index) {
                      final heights = [40, 70, 45, 90, 60, 80, 50];
                      return Container(
                        width: 12,
                        height: heights[index].toDouble(),
                        decoration: BoxDecoration(
                          color: index == 3 ? AppColors.primary : AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ).animate().scaleY(
                        delay: (index * 100).ms,
                        duration: 500.ms,
                        begin: 0,
                        alignment: Alignment.bottomCenter,
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                        .map((day) => Text(day, style: TextStyle(fontSize: 10, color: AppColors.textHint, fontWeight: FontWeight.w700)))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95));
  }
}
