import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_theme.dart';

class PhotoCaptureWidget extends StatelessWidget {
  final XFile? photo;
  final VoidCallback onCapture;
  final VoidCallback onPick;
  final VoidCallback onRemove;
  const PhotoCaptureWidget({super.key, required this.photo, required this.onCapture, required this.onPick, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    if (photo != null) {
      return Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(photo!.path, height: 200, width: double.infinity, fit: BoxFit.cover),
        ),
        Positioned(top: 8, right: 8, child: GestureDetector(
          onTap: onRemove,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(999)),
            child: const Icon(Icons.close, color: Colors.white, size: 18),
          ),
        )),
        Positioned(bottom: 8, left: 8, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(8)),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.check_circle, color: Colors.white, size: 14),
            SizedBox(width: 4),
            Text('Photo attached', style: TextStyle(color: Colors.white, fontSize: 11)),
          ]),
        )),
      ]);
    }
    return Row(children: [
      Expanded(child: OutlinedButton.icon(
        onPressed: onCapture, icon: const Icon(Icons.camera_alt_rounded), label: const Text('Camera'),
        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), side: const BorderSide(color: AppColors.primary)),
      )),
      const SizedBox(width: 8),
      Expanded(child: OutlinedButton.icon(
        onPressed: onPick, icon: const Icon(Icons.photo_library_rounded), label: const Text('Gallery'),
        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5))),
      )),
    ]);
  }
}
