import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class ConnectivityBadge extends StatelessWidget {
  final bool isOnline;
  const ConnectivityBadge({super.key, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: isOnline ? AppColors.online : AppColors.offline)),
        const SizedBox(width: 6),
        Text(isOnline ? 'Online' : 'Offline', style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ]),
    );
  }
}
