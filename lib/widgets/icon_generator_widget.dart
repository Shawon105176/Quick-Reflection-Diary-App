import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';

class IconGeneratorWidget extends StatelessWidget {
  final GlobalKey _globalKey = GlobalKey();

  IconGeneratorWidget({super.key});

  Future<void> _captureAndSaveIcon() async {
    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 1.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();

        // Create directory if it doesn't exist
        final directory = Directory('assets/icons');
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        // Save the icon
        final file = File('assets/icons/app_icon.png');
        await file.writeAsBytes(pngBytes);

        debugPrint('✅ App icon saved to: ${file.path}');
        debugPrint('Now run: dart run flutter_launcher_icons');
      }
    } catch (e) {
      debugPrint('❌ Error saving icon: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _captureAndSaveIcon,
      child: RepaintBoundary(
        key: _globalKey,
        child: Container(
          width: 1024,
          height: 1024,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(225),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF8B5FBF), // Purple
                Color(0xFF6B73FF), // Blue
              ],
            ),
          ),
          child: Center(
            child: CustomPaint(
              size: const Size(600, 600),
              painter: MIconPainter(),
            ),
          ),
        ),
      ),
    );
  }
}

class MIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.95)
          ..style = PaintingStyle.fill;

    final path = Path();

    // M letter coordinates scaled to size
    final double w = size.width;
    final double h = size.height;

    // Create the M shape
    path.moveTo(w * 0.15, h * 0.85); // Bottom left
    path.lineTo(w * 0.15, h * 0.15); // Top left
    path.lineTo(w * 0.25, h * 0.15); // Top left inner
    path.lineTo(w * 0.25, h * 0.65); // Left side down
    path.lineTo(w * 0.42, h * 0.35); // First peak
    path.lineTo(w * 0.5, h * 0.45); // Center valley
    path.lineTo(w * 0.58, h * 0.35); // Second peak
    path.lineTo(w * 0.75, h * 0.65); // Right side down
    path.lineTo(w * 0.75, h * 0.15); // Top right inner
    path.lineTo(w * 0.85, h * 0.15); // Top right
    path.lineTo(w * 0.85, h * 0.85); // Bottom right
    path.lineTo(w * 0.75, h * 0.85); // Bottom right inner
    path.lineTo(w * 0.75, h * 0.75); // Right side up
    path.lineTo(w * 0.58, h * 0.55); // Right peak inner
    path.lineTo(w * 0.5, h * 0.65); // Center valley inner
    path.lineTo(w * 0.42, h * 0.55); // Left peak inner
    path.lineTo(w * 0.25, h * 0.75); // Left side up
    path.lineTo(w * 0.25, h * 0.85); // Bottom left inner
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
