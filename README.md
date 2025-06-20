# Mindful - Daily Reflection App

Mindful is a personal diary and mindfulness app that helps users reflect on their daily lives, thoughts, and emotions using short, AI-generated prompts, encouraging mindfulness and self-growth in a private, secure environment.

## 🌟 Key Features

### 1. Daily AI-Generated Prompts
- Unique daily questions like "What made you smile today?" or "What challenge did you overcome today?"
- Built-in prompt library with thoughtful reflection questions
- Consistent prompts based on date to maintain routine

### 2. Quick Reflections
- Write short paragraph responses to daily prompts
- Timestamped entries for tracking
- Easy editing and updating of past reflections

### 3. Calendar View
- Beautiful calendar interface showing reflection history
- Tap any date to read or edit reflections
- Visual indicators for days with entries

### 4. Secure Access
- Biometric authentication (fingerprint/face unlock)
- 4-digit PIN lock option
- All data encrypted and stored locally

### 5. Theme Support
- Dark and light mode toggle
- Modern Material 3 design
- Consistent user experience

### 6. Daily Notifications
- Customizable reminder times
- Gentle prompts to maintain reflection habit
- Easy to enable/disable

## 📱 App Screens

- **Splash Screen**: Beautiful animated app introduction
- **Onboarding**: Feature introduction and theme selection
- **Home/Dashboard**: Today's prompt with input field
- **Calendar**: Interactive calendar with reflection history
- **History**: Searchable list of all past reflections
- **Settings**: Theme, security, and notification preferences

## 🛠️ Technology Stack

- **Framework**: Flutter 3.7.2+
- **State Management**: Provider
- **Local Storage**: Hive (NoSQL database)
- **Calendar UI**: table_calendar
- **Notifications**: flutter_local_notifications
- **Authentication**: local_auth (biometrics)
- **Date Handling**: intl

## 📦 Key Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  table_calendar: ^3.0.9
  flutter_local_notifications: ^16.3.2
  local_auth: ^2.1.8
  intl: ^0.19.0
  shared_preferences: ^2.2.2
  uuid: ^4.2.2

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.7
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.7.2 or higher
- Dart SDK 3.0.0 or higher
- Android SDK for Android development
- Xcode for iOS development (Mac only)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd dairy_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**
   ```bash
   dart run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Platform-Specific Setup

#### Android
- Minimum SDK: 21 (Android 5.0)
- Target SDK: 34 (Android 14)
- Required permissions are already configured in AndroidManifest.xml

#### iOS
- Minimum iOS version: 12.0
- Biometric permissions configured in Info.plist
- Notification permissions handled at runtime

## 🔧 Configuration

### Notifications
The app requests notification permissions automatically. Users can:
- Enable/disable daily reminders in Settings
- Set custom reminder times
- Receive gentle prompts to maintain reflection habits

### Security
Users can secure their app with:
- **Biometric Authentication**: Fingerprint or face unlock
- **PIN Lock**: 4-digit PIN for device security
- **Local Encryption**: All data stored securely on device

### Themes
- **Light Mode**: Clean, bright interface
- **Dark Mode**: Easy on the eyes for night use
- **System Theme**: Follows device preference

## 📊 Data Storage

- **Local Storage**: Hive database for fast, efficient data handling
- **No Cloud Dependency**: All data stays on your device
- **Privacy First**: No data collection or sharing
- **Export Option**: Future feature for data portability

## 🎨 Design Philosophy

- **Minimalist Interface**: Clean, distraction-free design
- **Intuitive Navigation**: Easy access to all features
- **Accessibility**: High contrast, readable fonts
- **Performance**: Smooth animations and fast loading

## 🔐 Privacy & Security

- **Offline First**: No internet required for core functionality
- **Local Encryption**: Hive provides built-in encryption
- **No Analytics**: No tracking or data collection
- **Biometric Protection**: Secure access to personal thoughts

## 🌱 Mindfulness Features

- **Daily Prompts**: Curated questions for deep reflection
- **Habit Building**: Consistent daily practice encouragement
- **Progress Tracking**: Visual calendar of reflection journey
- **Personal Growth**: Self-discovery through guided questions

## 📈 Future Enhancements

- [ ] Export reflections to PDF or text
- [ ] Advanced search with tags and categories
- [ ] Mood tracking integration
- [ ] Custom prompt creation
- [ ] Cloud backup (optional)
- [ ] Reflection statistics and insights
- [ ] Voice-to-text input support

## 🤝 Contributing

This is a personal mindfulness app focused on privacy and simplicity. While not currently open for contributions, feedback and suggestions are welcome.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Hive for efficient local storage
- Material Design for beautiful UI components
- Open source community for inspiration

---

**Start your mindfulness journey today with Mindful - your personal space for reflection and growth.**
