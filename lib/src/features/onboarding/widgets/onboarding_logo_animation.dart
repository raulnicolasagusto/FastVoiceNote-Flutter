import 'package:flutter/material.dart';

enum EntranceType { top, left, none }

class OnboardingLogoAnimation extends StatefulWidget {
  final String imagePath;
  final double size;
  final EntranceType entranceType;

  const OnboardingLogoAnimation({
    super.key,
    this.imagePath = 'assets/main1.png',
    this.size = 250,
    this.entranceType = EntranceType.top,
  });

  @override
  State<OnboardingLogoAnimation> createState() =>
      _OnboardingLogoAnimationState();
}

class _OnboardingLogoAnimationState extends State<OnboardingLogoAnimation>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<Offset> _slideAnimation;

  late AnimationController _floatController;
  late Animation<Offset> _floatAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Entrance Controller
    Duration duration = const Duration(milliseconds: 800);
    Curve curve = Curves.easeOutBack;

    if (widget.entranceType == EntranceType.left) {
      duration = const Duration(milliseconds: 2000); // Slower for side entrance
      curve = Curves.easeOut; // Smoother slide without bounce
    }

    _entranceController = AnimationController(vsync: this, duration: duration);

    Offset beginOffset = Offset.zero;
    if (widget.entranceType == EntranceType.top) {
      beginOffset = const Offset(0, -2.5);
    } else if (widget.entranceType == EntranceType.left) {
      beginOffset = const Offset(
        -1.5,
        0,
      ); // Start from left (reduced distance slightly)
    }

    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceController, curve: curve));

    // 2. Float Controller (Breathing/Hovering)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _floatAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0),
          end: const Offset(0, 0.05),
        ).animate(
          CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
        );

    // Start Sequence
    if (widget.entranceType == EntranceType.none) {
      // If no entrance, just start floating immediately
      _floatController.repeat(reverse: true);
    } else {
      _entranceController.forward().then((_) {
        _floatController.repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: SlideTransition(
        position: _floatAnimation,
        child: Image.asset(
          widget.imagePath,
          width: widget.size,
          height: widget.size,
        ),
      ),
    );
  }
}
