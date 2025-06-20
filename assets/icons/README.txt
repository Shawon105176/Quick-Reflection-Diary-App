INSTRUCTIONS FOR ADDING YOUR NEW APP LOGO:

1. Save your purple gradient "M" logo image as: app_icon.png
2. Make sure the image is:
   - 1024x1024 pixels (high resolution)
   - PNG format
   - Square aspect ratio
   - The logo should be centered with some padding around the edges

3. Place the app_icon.png file in this directory: assets/icons/

4. After placing the image, run these commands in terminal:
   - flutter pub get
   - dart run flutter_launcher_icons
   
5. This will automatically generate all required icon sizes for Android and iOS

The configuration is already set up in pubspec.yaml to use this icon.
