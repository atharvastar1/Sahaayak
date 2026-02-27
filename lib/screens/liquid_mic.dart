import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/sahaayak_theme.dart';
import '../services/haptic_service.dart';

class LiquidMicButton extends StatefulWidget {
  final bool isListening;
  final VoidCallback onTap;

  const LiquidMicButton({
    super.key,
    required this.isListening,
    required this.onTap,
  });

  @override
  State<LiquidMicButton> createState() => _LiquidMicButtonState();
}

class _LiquidMicButtonState extends State<LiquidMicButton> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    if (widget.isListening) _pulseController.repeat();
  }

  @override
  void didUpdateWidget(LiquidMicButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening && !oldWidget.isListening) {
      _pulseController.repeat();
    } else if (!widget.isListening && oldWidget.isListening) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticService.light();
        setState(() {});
      },
      onTapUp: (_) => setState(() {}),
      onTap: () {
        HapticService.medium();
        widget.onTap();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. LIFE-PULSE AURA (Ethereal Glow)
          if (widget.isListening)
            ...List.generate(2, (index) {
              return AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final progress = (_pulseController.value + (index * 0.5)) % 1.0;
                  return Container(
                    width: 140 + (progress * 160),
                    height: 140 + (progress * 160),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: SahaayakTheme.primary.withValues(alpha: 0.15 * (1.0 - progress)),
                          blurRadius: 40,
                          spreadRadius: 20 * progress,
                        ),
                      ],
                    ),
                  );
                },
              );
            }),

          // 2. SILICON ORB BASE (Tactile Depth)
          AnimatedContainer(
            duration: 400.ms,
            width: 160,
            height: 160,
            decoration: SahaayakTheme.siliconOrb(
              glowColor: widget.isListening ? SahaayakTheme.primary : null,
            ),
          ),

          // 3. INTERNAL LIQUID CORE (Animated Aura)
          AnimatedContainer(
            duration: 800.ms,
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: widget.isListening 
                  ? SahaayakTheme.aiAura 
                  : SahaayakTheme.appleGradient,
            ),
            child: widget.isListening 
              ? _buildLiquidWaves()
              : const Center(
                  child: Icon(
                    Icons.mic_rounded,
                    size: 56,
                    color: Colors.white,
                  ),
                ),
          ).animate(target: widget.isListening ? 1 : 0)
           .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), curve: Curves.easeInOut),

          // 4. GLASS SHINE (Top Layer highlighting)
          IgnorePointer(
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.4),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiquidWaves() {
    return Stack(
      children: [
        const Center(
          child: Icon(
            Icons.stop_rounded,
            size: 48,
            color: Colors.white,
          ),
        ),
        // Simple liquid simulation using animated containers or icons
        Positioned.fill(
          child: CustomPaint(
            painter: _WavePainter(
              animation: _pulseController,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
        ),
      ],
    );
  }
}

class _WavePainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  _WavePainter({required this.animation, required this.color}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    
    const waveHeight = 10.0;
    final speed = animation.value * 2 * math.pi;
    
    path.moveTo(0, size.height * 0.6);
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(i, size.height * 0.6 + math.sin(speed + i * 0.05) * waveHeight);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

