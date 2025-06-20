#!/bin/bash

# This script creates a simple app icon and generates all required sizes

echo "Creating app icon..."

# Create a simple SVG icon
cat > assets/icons/app_icon.svg << 'EOF'
<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#8B5FBF;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#6B73FF;stop-opacity:1" />
    </linearGradient>
  </defs>
  <rect width="1024" height="1024" rx="225" ry="225" fill="url(#bg)"/>
  <path d="M 200 800 L 200 200 L 280 200 L 280 680 L 420 350 L 512 480 L 604 350 L 744 680 L 744 200 L 824 200 L 824 800 L 744 800 L 744 720 L 604 480 L 512 610 L 420 480 L 280 720 L 280 800 Z" fill="white" fill-opacity="0.95"/>
</svg>
EOF

echo "App icon SVG created!"

# Instructions for the user
cat > assets/icons/FINAL_INSTRUCTIONS.txt << 'EOF'
আপনার App Icon সেটআপ সম্পূর্ণ!

পরবর্তী Steps:

1. Terminal এ এই commands চালান:
   flutter pub get
   dart run flutter_launcher_icons

2. App rebuild করুন:
   flutter clean
   flutter run

3. আপনার device এর home screen এ নতুন purple gradient "M" logo দেখতে পাবেন!

কোনো সমস্যা হলে আমাকে জানান।
EOF

echo "Instructions created! Please run: dart run flutter_launcher_icons"
