# Flutter Minesweeper

A modern, feature-rich Minesweeper clone built with Flutter, featuring robust game logic, comprehensive testing, and enhanced user experience.

![Screenshot](screenshot.png)

## 🎮 Features

### Core Gameplay
- **Classic Minesweeper Rules** - Traditional gameplay with flagging and chording
- **Multiple Difficulty Levels** - Easy, Normal, Hard, Expert, and Custom modes
- **First Click Guarantee** - Kickstarter mode ensures your first click always reveals a cascade
- **Visual Feedback** - Clear distinction between different cell states when game ends

### Enhanced UX
- **Zoom Controls** - Pinch to zoom and pan around large boards
- **Haptic Feedback** - Tactile response for flag toggles and game events
- **Auto-Generated Descriptions** - Game mode descriptions automatically generated from grid dimensions
- **Educational Tooltips** - Help icons explain game modes and features
- **Consistent Settings** - All game-affecting changes auto-close settings and restart game

### Game Modes
- **Classic Mode** - Traditional Minesweeper with random first-click behavior
- **Kickstarter Mode** - Beginner-friendly mode where first click always reveals a cascade
- **Custom Mode** - Configure your own board size and mine count

### Visual States
When the game ends, you'll see:
- **💣 (Red bomb on yellow background)** - The bomb that killed you
- **💣 (Bomb on red background)** - Other hidden bombs you didn't hit
- **🚩 (Flag)** - Correctly flagged mines
- **❌ (Black X)** - Incorrectly flagged non-mines

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- iOS Simulator or Android Emulator (or physical device)

### Installation
```bash
# Clone the repository
git clone <repository-url>
cd FlutterMinesweeper

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Building
```bash
# For iOS
flutter build ios

# For Android
flutter build apk

# For Web
flutter build web
```

## 🧪 Testing

The app includes comprehensive test coverage:
```bash
# Run all tests
flutter test

# Run specific test files
flutter test test/game_logic_test.dart
flutter test test/duplicate_validation_test.dart
```

## 🛠️ Development

### Project Structure
```
lib/
├── core/                 # Core configuration and constants
├── data/                 # Data layer and repositories
├── domain/               # Business logic and entities
├── presentation/         # UI layer and widgets
└── services/             # External services (timer, haptics)
```

### Key Features
- **Clean Architecture** - Separation of concerns with clear layers
- **Feature Flags** - Easy toggling of experimental features
- **Comprehensive Testing** - 43+ tests covering all game logic
- **Configuration Validation** - Compile-time validation of game modes
- **Null Safety** - Full Dart null safety compliance

## 🐛 Bug Reports & Feature Requests

Please use the GitHub Issues page to report bugs or request new features. Include:
- Device/OS information
- Steps to reproduce
- Expected vs actual behavior
- Screenshots if applicable

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow Flutter/Dart best practices
- Add tests for new features
- Update documentation as needed
- Ensure all tests pass before submitting PR

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Original Minesweeper game by Microsoft
- Flutter team for the amazing framework
- All contributors who have helped improve this project
