import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../constants/app_theme.dart';
import '../models/need_signal.dart';

class NeedTypeGrid extends StatelessWidget {
  final NeedType selected;
  final ValueChanged<NeedType> onChanged;
  const NeedTypeGrid({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: NeedType.values.map((type) {
        final sel = type == selected;
        return GestureDetector(
          onTap: () => onChanged(type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: sel ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: sel ? AppColors.primary : AppColors.divider, width: sel ? 2 : 1),
              boxShadow: sel ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2))] : null,
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(_icon(type), size: 18, color: sel ? Colors.white : AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(_label(type), style: TextStyle(color: sel ? Colors.white : AppColors.textPrimary, fontWeight: sel ? FontWeight.w600 : FontWeight.w500, fontSize: 13)),
            ]),
          ),
        );
      }).toList(),
    );
  }

  IconData _icon(NeedType t) => switch (t) {
    NeedType.food => LucideIcons.utensils,
    NeedType.water => LucideIcons.droplet,
    NeedType.medicine => LucideIcons.pill,
    NeedType.shelter => LucideIcons.house,
    NeedType.clothing => LucideIcons.shirt,
    NeedType.other => LucideIcons.circleQuestionMark,
  };

  String _label(NeedType t) => switch (t) {
    NeedType.food => 'Food',
    NeedType.water => 'Water',
    NeedType.medicine => 'Medicine',
    NeedType.shelter => 'Shelter',
    NeedType.clothing => 'Clothing',
    NeedType.other => 'Other',
  };
}
