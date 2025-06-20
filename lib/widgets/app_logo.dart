import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showBackground;

  const AppLogo({super.key, this.size = 100, this.showBackground = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration:
          showBackground
              ? BoxDecoration(
                borderRadius: BorderRadius.circular(size * 0.22),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF8B5FBF), // Purple top
                    Color(0xFF6B73FF), // Blue bottom
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: size * 0.1,
                    offset: Offset(0, size * 0.05),
                  ),
                ],
              )
              : null,
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.6, size * 0.6),
          painter: MLogoPainter(),
        ),
      ),
    );
  }
}

class MLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.fill
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.9),
              Colors.white.withOpacity(0.7),
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();

    // Create the "M" shape with 3D effect
    final double width = size.width;
    final double height = size.height;

    // Left vertical line
    path.moveTo(width * 0.1, height * 0.9);
    path.lineTo(width * 0.1, height * 0.1);
    path.lineTo(width * 0.25, height * 0.1);
    path.lineTo(width * 0.25, height * 0.75);

    // First diagonal (left peak)
    path.lineTo(width * 0.4, height * 0.35);
    path.lineTo(width * 0.5, height * 0.5);

    // Second diagonal (right peak)
    path.lineTo(width * 0.6, height * 0.35);
    path.lineTo(width * 0.75, height * 0.75);

    // Right vertical line
    path.lineTo(width * 0.75, height * 0.1);
    path.lineTo(width * 0.9, height * 0.1);
    path.lineTo(width * 0.9, height * 0.9);
    path.lineTo(width * 0.75, height * 0.9);
    path.lineTo(width * 0.75, height * 0.75);

    // Complete the M shape
    path.lineTo(width * 0.6, height * 0.5);
    path.lineTo(width * 0.5, height * 0.65);
    path.lineTo(width * 0.4, height * 0.5);
    path.lineTo(width * 0.25, height * 0.75);
    path.lineTo(width * 0.25, height * 0.9);
    path.lineTo(width * 0.1, height * 0.9);

    path.close();

    canvas.drawPath(path, paint);

    // Add shadow/depth effect
    final shadowPaint =
        Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.black.withOpacity(0.2);

    final shadowPath = Path();
    shadowPath.addPath(path, Offset(width * 0.03, height * 0.03));
    canvas.drawPath(shadowPath, shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
