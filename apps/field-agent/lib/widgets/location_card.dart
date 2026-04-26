import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../providers/signal_provider.dart';

class LocationCard extends StatelessWidget {
  final SignalProvider provider;
  const LocationCard({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final hasPos = provider.currentPosition != null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: hasPos ? AppColors.success.withValues(alpha: 0.3) : AppColors.divider),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: (hasPos ? AppColors.success : AppColors.info).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: provider.isCapturingLocation
              ? const Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(strokeWidth: 2))
              : Icon(hasPos ? Icons.gps_fixed_rounded : Icons.gps_not_fixed_rounded, color: hasPos ? AppColors.success : AppColors.info),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(hasPos ? 'GPS Locked' : 'Acquiring GPS...', style: TextStyle(fontWeight: FontWeight.w600, color: hasPos ? AppColors.success : AppColors.textSecondary)),
          if (hasPos)
            Text('${provider.currentPosition!.latitude.toStringAsFixed(4)}, ${provider.currentPosition!.longitude.toStringAsFixed(4)}',
              style: const TextStyle(fontSize: 12, color: AppColors.textHint, fontFamily: 'monospace')),
        ])),
        IconButton(onPressed: provider.captureLocation, icon: const Icon(Icons.refresh_rounded), color: AppColors.primary, tooltip: 'Refresh GPS'),
      ]),
    );
  }
}
