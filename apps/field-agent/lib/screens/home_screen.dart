import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';
import '../providers/signal_provider.dart';

import 'submit_signal_screen.dart';
import 'past_reports_screen.dart';
import 'global_feed_screen.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'stats_screen.dart';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SignalProvider>().checkConnectivity();
      setState(() => _hasAnimated = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Premium Typography
    final headerStyle = TextStyle(
      fontSize: 34, 
      fontWeight: FontWeight.w900, 
      color: AppColors.primary,
      letterSpacing: -1.2,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Gradient Blob
          Positioned(
            top: -80,
            right: -40,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.08),
                    AppColors.primary.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ).animate(target: _hasAnimated ? 1 : 0).fadeIn(duration: 1200.ms).scale(begin: const Offset(0.4, 0.4)),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('ResourceRadar', style: headerStyle)
                          .animate(target: _hasAnimated ? 1 : 0).fadeIn(duration: 500.ms).slideX(begin: -0.1),
                        const SizedBox(height: 2),
                        Text('FIELD AGENT CONSOLE', style: TextStyle(
                          fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        )).animate(target: _hasAnimated ? 1 : 0).fadeIn(delay: 200.ms, duration: 500.ms),
                      ]),
                      Consumer<SignalProvider>(
                        builder: (_, p, __) => _ConnectivityBadge(isOnline: p.isOnline),
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  // Hero Submit Card with Glassmorphism & Hover/Tap Scaling
                  _AnimatedCardWrapper(
                    delay: 400.ms,
                    hasAnimated: _hasAnimated,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubmitSignalScreen())),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryLight],
                                begin: Alignment.topLeft, end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.35),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                )
                              ],
                            ),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                ),
                                child: Icon(LucideIcons.send, color: Colors.white, size: 28),
                              ),
                              const SizedBox(height: 24),
                              const Text('Report New Signal', style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white, 
                                letterSpacing: -0.8
                              )),
                              const SizedBox(height: 10),
                              Text('Submit humanitarian needs with multimodal verification.',
                                style: TextStyle(fontSize: 15, color: Colors.white.withValues(alpha: 0.85), height: 1.5)),
                              const SizedBox(height: 28),
                              Row(children: [
                                const Text('START SUBMISSION', style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5
                                )),
                                const SizedBox(width: 8),
                                Icon(LucideIcons.arrowRight, color: Colors.white, size: 16),
                              ]),
                            ]),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  const Text('Navigation', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.5)),
                  const SizedBox(height: 20),

                  // Quick Action Tiles
                  Row(children: [
                    Expanded(child: _QuickTile(
                      icon: LucideIcons.map, label: 'Nearby Needs', color: AppColors.primary,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GlobalFeedScreen())),
                      hasAnimated: _hasAnimated,
                      delay: 600.ms,
                    )),
                    const SizedBox(width: 16),
                    Expanded(child: _QuickTile(
                      icon: LucideIcons.fileText, label: 'My Reports', color: AppColors.info,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PastReportsScreen())),
                      hasAnimated: _hasAnimated,
                      delay: 700.ms,
                    )),
                  ]),

                  const SizedBox(height: 16),

                  _QuickTile(
                    icon: LucideIcons.chartBar, label: 'My Impact & Statistics', color: AppColors.accent,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen())),
                    isWide: true,
                    hasAnimated: _hasAnimated,
                    delay: 800.ms,
                  ),

                  const Spacer(),

                  // Footer
                  Center(
                    child: Opacity(
                      opacity: 0.5,
                      child: Text('v1.0.0 — SECURE AGENT NODE', style: TextStyle(
                        fontSize: 9, color: AppColors.textHint, fontWeight: FontWeight.w900, letterSpacing: 2.0,
                      )),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedCardWrapper extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final bool hasAnimated;
  const _AnimatedCardWrapper({required this.child, required this.delay, required this.hasAnimated});

  @override
  Widget build(BuildContext context) {
    return child.animate(target: hasAnimated ? 1 : 0).fadeIn(delay: delay, duration: 600.ms).scale(begin: const Offset(0.96, 0.96), curve: Curves.easeOut);
  }
}

class _ConnectivityBadge extends StatelessWidget {
  final bool isOnline;
  const _ConnectivityBadge({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: (isOnline ? AppColors.online : AppColors.offline).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: (isOnline ? AppColors.online : AppColors.offline).withValues(alpha: 0.15)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isOnline ? AppColors.online : AppColors.offline,
            boxShadow: [
              if (isOnline) BoxShadow(color: AppColors.online.withValues(alpha: 0.5), blurRadius: 4, spreadRadius: 1),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          isOnline ? 'SECURE' : 'OFFLINE',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isOnline ? AppColors.online : AppColors.offline, letterSpacing: 1.0),
        ),
      ]),
    );
  }
}

class _QuickTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isWide;
  final bool hasAnimated;
  final Duration delay;
  const _QuickTile({required this.icon, required this.label, required this.color, required this.onTap, this.isWide = false, required this.hasAnimated, required this.delay});

  @override
  Widget build(BuildContext context) {
    return _AnimatedCardWrapper(
      hasAnimated: hasAnimated,
      delay: delay,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 8))
          ],
        ),
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.divider.withValues(alpha: 0.4)),
              ),
              child: isWide 
                ? Row(children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                      child: Icon(icon, color: color, size: 22),
                    ),
                    const SizedBox(width: 20),
                    Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.3)),
                    const Spacer(),
                    Icon(LucideIcons.chevronRight, color: AppColors.textHint, size: 18),
                  ])
                : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                      child: Icon(icon, color: color, size: 22),
                    ),
                    const SizedBox(height: 20),
                    Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.2)),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
