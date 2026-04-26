import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class UrgencySliderWidget extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const UrgencySliderWidget({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final color = _color(value);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(_label(value), style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 16)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(999)),
            child: Text('$value / 5', style: TextStyle(fontWeight: FontWeight.w600, color: color, fontSize: 14)),
          ),
        ]),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color, inactiveTrackColor: color.withValues(alpha: 0.15),
            thumbColor: color, overlayColor: color.withValues(alpha: 0.12), trackHeight: 6,
          ),
          child: Slider(value: value.toDouble(), min: 1, max: 5, divisions: 4, onChanged: (v) => onChanged(v.round())),
        ),
      ]),
    );
  }

  Color _color(int v) => v >= 5 ? AppColors.urgencyCritical : v >= 4 ? AppColors.urgencyHigh : v >= 3 ? AppColors.urgencyMedium : AppColors.urgencyLow;
  String _label(int v) => v >= 5 ? '🔴 CRITICAL' : v >= 4 ? '🟠 HIGH' : v >= 3 ? '🟡 MEDIUM' : v >= 2 ? '🟢 LOW' : '⚪ MINIMAL';
}
