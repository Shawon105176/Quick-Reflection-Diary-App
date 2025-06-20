import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:math' as math;

class IconGenerator {
  static Future<void> generateAppIcon() async {
    // Create a custom painter for the icon
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(1024, 1024);

    // Draw background gradient
    final backgroundPaint =
        Paint()
          ..shader = ui.Gradient.linear(
            const Offset(0, 0),
            const Offset(1024, 1024),
            [
              const Color(0xFF8B5FBF), // Purple
              const Color(0xFF6B73FF), // Blue
            ],
          );

    // Draw rounded rectangle background
    final rrect = RRect.fromLTRBR(0, 0, 1024, 1024, const Radius.circular(225));
    canvas.drawRRect(rrect, backgroundPaint);

    // Draw the "M" letter
    final mPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.95)
          ..style = PaintingStyle.fill;

    final path = Path();

    // M letter dimensions
    final double centerX = 512;
    final double centerY = 512;
    final double letterWidth = 400;
    final double letterHeight = 400;

    final double left = centerX - letterWidth / 2;
    final double right = centerX + letterWidth / 2;
    final double top = centerY - letterHeight / 2;
    final double bottom = centerY + letterHeight / 2;

    // Create M shape
    path.moveTo(left, bottom);
    path.lineTo(left, top);
    path.lineTo(left + 60, top);
    path.lineTo(left + 60, bottom - 120);
    path.lineTo(centerX - 30, top + 120);
    path.lineTo(centerX, top + 160);
    path.lineTo(centerX + 30, top + 120);
    path.lineTo(right - 60, bottom - 120);
    path.lineTo(right - 60, top);
    path.lineTo(right, top);
    path.lineTo(right, bottom);
    path.lineTo(right - 60, bottom);
    path.lineTo(right - 60, bottom - 60);
    path.lineTo(centerX + 30, top + 200);
    path.lineTo(centerX, top + 240);
    path.lineTo(centerX - 30, top + 200);
    path.lineTo(left + 60, bottom - 60);
    path.lineTo(left + 60, bottom);
    path.close();

    canvas.drawPath(path, mPaint);

    // Add shadow effect
    final shadowPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.3)
          ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 10);

    canvas.translate(5, 5);
    canvas.drawPath(path, shadowPaint);

    final picture = recorder.endRecording();
    final img = await picture.toImage(1024, 1024);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null) {
      final buffer = byteData.buffer.asUint8List();

      // Save to assets/icons/
      final file = File('assets/icons/app_icon.png');
      await file.writeAsBytes(buffer);

      print('App icon generated successfully at: ${file.path}');
    }
  }
}
