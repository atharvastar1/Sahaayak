import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/sahaayak_theme.dart';

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
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (widget.isListening) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(LiquidMicButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening && !oldWidget.isListening) {
      _controller.repeat();
    } else if (!widget.isListening && oldWidget.isListening) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.isListening)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: LiquidPainter(_controller.value),
                  size: const Size(220, 220),
                );
              },
            ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: widget.isListening ? SahaayakTheme.appleGradient : null,
              color: widget.isListening ? null : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (widget.isListening ? SahaayakTheme.primaryBlue : Colors.black).withValues(alpha: 0.15),
                  blurRadius: 40,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Icon(
              widget.isListening ? Icons.stop_rounded : Icons.mic_rounded,
              size: 64,
              color: widget.isListening ? Colors.white : SahaayakTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class LiquidPainter extends CustomPainter {
  final double progress;
  LiquidPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..shader = SahaayakTheme.appleGradient.createShader(Offset.zero & size)
      ..style = PaintingStyle.fill;

    final path = Path();
    final double radius = size.width / 2.5;
    
    // Create organic blob shape using sine waves 
    const int points = 120;
    for (int i = 0; i < points; i++) {
       double angle = (i / points) * 2 * math.pi;
       double variance = 10 * math.sin(angle * 4 + progress * 2 * math.pi) +
                         8 * math.sin(angle * 7 - progress * 4 * math.pi);
       
       double currentRadius = radius + variance;
       double x = center.dx + currentRadius * math.cos(angle);
       double y = center.dy + currentRadius * math.sin(angle);
       
       if (i == 0) {
         path.moveTo(x, y);
       } else {
         path.lineTo(x, y);
       }
    }
    path.close();
    
    // Draw multiple layers with different opacities for "rich" look
    canvas.drawPath(path, Paint()..shader = paint.shader!..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15));
    canvas.drawPath(path, Paint()..shader = paint.shader!..color = Colors.white.withValues(alpha: 0.2));
  }

  @override
  bool shouldRepaint(LiquidPainter oldDelegate) => true;
}
