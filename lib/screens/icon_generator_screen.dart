import 'package:flutter/material.dart';
import '../widgets/icon_generator_widget.dart';

class IconGeneratorScreen extends StatelessWidget {
  const IconGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Icon Generator'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Long press the icon below to generate app_icon.png',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Transform.scale(
              scale: 0.2, // Scale down for display
              child: IconGeneratorWidget(),
            ),
            const SizedBox(height: 20),
            const Text(
              'After generating, run:\ndart run flutter_launcher_icons',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back to App'),
            ),
          ],
        ),
      ),
    );
  }
}
