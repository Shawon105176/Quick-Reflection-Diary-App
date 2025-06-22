# Mindful - Premium Daily Reflection & Mood Tracking App

Mindful is a comprehensive diary and mindfulness app that helps users reflect on their daily lives, track moods, set goals, and grow through AI-powered insights. Featuring voice notes, photo attachments, advanced analytics, and beautiful themes, it's designed for modern users who value both functionality and aesthetics.

## ✨ New Premium Features

### 🎨 Beautiful Multi-Theme Support
- **6 Stunning Themes**: Mindful Purple, Ocean Blue, Forest Green, Sunset Orange, Rose Gold, Charcoal Dark
- **Google Fonts Integration**: Beautiful typography with Inter font family
- **Material 3 Design**: Modern, responsive UI with smooth animations
- **Theme Selection Screen**: Easy theme switching from settings

### 🎙️ Voice Notes & Audio Recordings
- **Voice Recording**: Record voice reflections with professional quality
- **Audio Playback**: Listen to past voice notes with intuitive controls
- **Voice-to-Text**: Automatic transcription support
- **Audio Attachments**: Combine text and voice in reflections

### 📸 Photo Attachments
- **Photo Integration**: Add photos to mood entries and reflections
- **Image Gallery**: Beautiful gallery view of attached photos
- **Memory Enhancement**: Visual memories alongside written thoughts
- **Photo Management**: Easy photo organization and viewing

### 📊 Advanced Analytics & Insights
- **Mood Charts**: Beautiful FL Chart visualizations of mood patterns
- **Trend Analysis**: Track mood trends over time with detailed graphs
- **Insights Dashboard**: AI-powered insights and recommendations
- **Progress Tracking**: Monitor emotional growth and reflection consistency

### 🔍 Powerful Search
- **Global Search**: Search across moods, reflections, and goals
- **Filter Options**: Filter by date, mood type, or content
- **Quick Find**: Instant search results with highlighting
- **Search History**: Remember frequent searches

### 🎯 Enhanced Mood Tracking
- **Comprehensive Mood Types**: Happy, Sad, Angry, Anxious, Excited, Calm, Frustrated, Content, Energetic, Tired
- **Mood Triggers**: Track what influences your moods
- **Intensity Levels**: Rate mood intensity on a scale
- **Visual Mood Calendar**: See mood patterns at a glance

### 📝 Enhanced Reflection Experience
- **Rich Text Editor**: Flutter Quill-powered rich text editing
- **Writing Prompts**: AI-generated reflection prompts
- **Word Count**: Track reflection length and progress
- **Auto-Save**: Never lose your thoughts

### 🌅 Onboarding & First-Time Experience
- **Beautiful Onboarding**: Introduction screen with app features
- **Theme Selection**: Choose your preferred theme during setup
- **Getting Started**: Guided setup for new users
- **Feature Tour**: Interactive feature introduction

## 🚀 Core Features (Enhanced)

### 1. Smart Daily Prompts
- AI-generated daily reflection questions
- Contextual prompts based on mood and history
- Seasonal and time-aware prompts
- Custom prompt creation

### 2. Multi-Modal Reflections
- **Text**: Rich text editing with formatting
- **Voice**: High-quality audio recording
- **Photos**: Visual memory integration
- **Mood**: Comprehensive mood tracking

### 3. Advanced Calendar
- **Interactive Calendar**: Beautiful table_calendar with mood indicators
- **Daily Overview**: Quick view of entries, moods, and photos
- **Monthly Insights**: Summary of monthly patterns
- **Export Options**: Share or backup calendar data

### 4. Premium Security
- **Biometric Lock**: Fingerprint and face recognition
- **PIN Protection**: Custom 4-digit PIN codes
- **Local Encryption**: All data encrypted locally
- **Privacy First**: No cloud storage, complete privacy

### 5. Smart Notifications
- **Intelligent Reminders**: Time-based reflection reminders
- **Mood Check-ins**: Periodic mood tracking notifications
- **Customizable Schedule**: Set your preferred reminder times
- **Gentle Nudges**: Non-intrusive motivation

### 6. Analytics & Progress
- **Detailed Charts**: Mood trends, reflection consistency
- **Progress Insights**: AI-powered growth analysis
- **Achievement Tracking**: Milestone celebrations
- **Export Reports**: PDF reports of your progress

## 🎨 Design & User Experience

### Visual Excellence
- **Modern UI**: Clean, intuitive Material 3 design
- **Smooth Animations**: Delightful micro-interactions
- **Accessibility**: High contrast, readable fonts, screen reader support
- **Responsive Design**: Beautiful on all screen sizes

### Theme System
- **6 Carefully Crafted Themes**: Each with unique color palette
- **Dark/Light Modes**: Automatic or manual switching
- **Consistent Branding**: Cohesive visual identity
- **Personal Expression**: Choose themes that match your mood

## 📱 App Architecture
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

### Enhanced Navigation
- **6-Tab Bottom Navigation**: Home, Calendar, Mood, Analytics, Search, Settings
- **Intuitive Flow**: Easy access to all features
- **Context-Aware**: Smart navigation based on user actions

## 🛠️ Technology Stack

### Core Framework
- **Flutter 3.7.2+**: Cross-platform mobile development
- **Dart 3.0+**: Modern programming language
- **Material 3**: Latest Material Design system

### State Management & Storage
- **Provider**: Reactive state management
- **Hive**: Fast, lightweight NoSQL database
- **Shared Preferences**: Settings and preferences storage

### UI & Animations
- **Google Fonts**: Beautiful typography (Inter font family)
- **FL Chart**: Professional charts and graphs
- **Lottie**: Smooth animations and micro-interactions
- **Shimmer**: Loading states and skeleton screens

### Media & Input
- **Image Picker**: Photo selection and capture
- **Record**: High-quality audio recording
- **Audio Players**: Audio playback and controls
- **Flutter Quill**: Rich text editor

### Features & Services
- **Introduction Screen**: Beautiful onboarding experience
- **Table Calendar**: Interactive calendar widget
- **Speech to Text**: Voice-to-text conversion
- **Local Notifications**: Smart reminder system
- **Local Auth**: Biometric and PIN authentication
- **Permission Handler**: Runtime permission management

### Development Tools
- **Flutter Lints**: Code quality and best practices
- **Build Runner**: Code generation for Hive
- **Flutter Launcher Icons**: Custom app icons

## 🚀 Getting Started

### Prerequisites
- Flutter 3.7.2 or higher
- Dart 3.0 or higher
- Android Studio / VS Code
- Android SDK (for Android development)
- Xcode (for iOS development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/mindful-app.git
   cd mindful-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**
   ```bash
   dart run build_runner build
   ```

4. **Generate app icons**
   ```bash
   flutter pub run flutter_launcher_icons:main
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

### Platform-Specific Setup

#### Android
- Minimum SDK: 21 (Android 5.0)
- Target SDK: 34 (Android 14)
- Permissions: Camera, Microphone, Storage, Biometric
- All permissions configured in AndroidManifest.xml

#### iOS
- Minimum iOS version: 12.0
- Required permissions in Info.plist
- Biometric and notification permissions
- Camera and microphone access

## ⚙️ Configuration & Features

### Premium Security
- **Multi-Factor Authentication**: Biometric + PIN options
- **Local Encryption**: All data encrypted on device
- **Privacy First**: No cloud storage, complete privacy
- **Secure Storage**: Hive encrypted boxes

### Smart Notifications
- **Daily Reminders**: Customizable reflection prompts
- **Mood Check-ins**: Periodic emotional well-being checks
- **Achievement Alerts**: Celebrate milestones and streaks
- **Gentle Nudges**: Non-intrusive motivation

### Theme Customization
- **6 Beautiful Themes**: Each with unique personality
- **Dark/Light Modes**: Automatic or manual switching
- **Google Fonts**: Professional typography
- **Color Harmony**: Carefully crafted color palettes

### Data Export & Backup
- **PDF Reports**: Monthly and yearly reflection summaries
- **CSV Export**: Raw data for external analysis
- **Photo Backup**: Organize and export photo memories
- **Audio Archive**: Save and organize voice recordings

## 📊 App Performance

### Storage Efficiency
- **Optimized Hive Database**: Fast local storage
- **Image Compression**: Smart photo optimization
- **Audio Compression**: Efficient voice note storage
- **Minimal App Size**: Optimized build size

### Battery Life
- **Background Optimization**: Minimal background usage
- **Smart Notifications**: Efficient notification system
- **Resource Management**: Optimized memory usage

## 🎯 Roadmap & Future Features

### Coming Soon
- **AI Insights**: Machine learning-powered mood analysis
- **Social Features**: Share insights with trusted friends
- **Cloud Sync**: Optional encrypted cloud backup
- **Apple Watch**: Companion app for quick mood tracking
- **Widgets**: Home screen widgets for quick access

### Advanced Features
- **Habit Tracking**: Integration with daily habits
- **Goal Setting**: SMART goals with progress tracking
- **Meditation Timer**: Guided meditation sessions
- **Journal Templates**: Pre-designed reflection templates

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
