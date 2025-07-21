# TODO List for Minesweeper Game Modernization & Bug Fixing

## ✅ Completed Tasks

- [x] **Review and fix all known game logic bugs (cascade logic, flag toggling, win/loss detection, etc.) using deterministic tests.**
- [x] **Implement classic Minesweeper chording (right-click) functionality.**
- [x] **Add comprehensive edge case tests for all game scenarios.**
- [x] **Ensure code coverage is high for all core game logic, including edge cases and error handling.**
- [x] **Track and mark off each bug fix and test improvement as completed in this TODO list.**
- [x] **Fix Android APK build issues** - Resolved with Java 17 and Kotlin DSL
- [x] **Implement First Click Guarantee (Kickstarter Mode)** - First click always reveals a cascade
- [x] **Add game configuration validation** - Compile-time duplicate detection for game modes
- [x] **Fix bomb explosion display** - Clear visual distinction for different cell states
- [x] **Improve settings UX** - Consistent auto-close behavior and educational tooltips
- [x] **Add auto-generated descriptions** - Game mode descriptions from grid dimensions
- [x] **Identify classic Minesweeper 50/50 scenarios (two cells with equal probability)**
- [x] **Add visual indicators for 50/50 scenarios**
- [x] **Add tests for 50/50 detection and handling (all known scenarios covered)**

## 🚧 Current Status

**All core Minesweeper functionality is now working with comprehensive test coverage (123+ tests).**

### ✅ What's Working:
- Board initialization and mine placement
- Cell revealing and cascade logic
- Flag management (toggle, validation)
- Chording (right-click) functionality
- Win/loss detection
- Game state management
- All edge cases and error handling
- Performance validation for large boards
- First Click Guarantee (Kickstarter Mode)
- Game configuration validation
- Enhanced visual feedback for game end states
- Consistent settings UX with educational tooltips

### ✅ Recent Major Improvements:
- **Game Configuration Validation** - App fails to start with duplicate IDs/names
- **Bomb Display Enhancement** - Clear visual distinction between different cell states
- **Settings UX Consistency** - All game-affecting changes auto-close settings
- **Educational Tooltips** - Help icons explain game modes
- **Auto-generated Descriptions** - Reduced maintenance for game mode descriptions

## 📋 Next Priority Features

### **🚨 IMMEDIATE TODOs:**
1. **50/50 Situation Detection & Resolution**
   - [ ] Implement detection algorithm for unsolvable situations
   - [ ] Consider auto-resolve or hint system for 50/50s

2. **Advanced Game Features**
   - [ ] Undo move functionality (`enableUndoMove`)
   - [ ] Hint system (`enableHintSystem`)
   - [ ] Auto-flagging (`enableAutoFlag`)
   - [ ] Best times tracking (`enableBestTimes`)

3. **UI/UX Enhancements**
   - [ ] Dark mode (`enableDarkMode`)
   - [ ] Smooth animations (`enableAnimations`)
   - [ ] Sound effects (`enableSoundEffects`)
   - [ ] Enhanced haptic feedback patterns

### **🔮 Future Features**

### **ML/AI Integration:**
- [ ] ML-powered assistance (`enableMLAssistance`)
- [ ] Auto-play functionality (`enableAutoPlay`)
- [ ] Difficulty prediction (`enableDifficultyPrediction`)
- [ ] Smart hint system using ML

### **Development Tools:**
- [ ] Debug mode (`enableDebugMode`)
- [ ] Performance metrics (`enablePerformanceMetrics`)
- [ ] Test mode (`enableTestMode`)
- [ ] Analytics and user behavior tracking

### **Advanced Game Modes:**
- [ ] Time trial mode
- [ ] Puzzle mode with predefined boards
- [ ] Multiplayer mode (future consideration)
- [ ] Tournament mode

## 🎯 Immediate Next Steps

1. **50/50 Situation Detection** - Implement detection and handling of unsolvable scenarios
2. **Advanced Game Features** - Add undo, hints, and auto-flagging
3. **UI Polish** - Dark mode and smooth animations
4. **ML Integration Preparation** - Set up infrastructure for future ML features

---

**Current Test Coverage: 123+ tests covering all standard Minesweeper functionality and 50/50 scenarios**
**Next Major Feature: 50/50 Situation Detection (advanced gameplay improvement)**

# CSP Probability Integration TODO

## Native Swift/PythonKit Integration Plan (Ordered Steps)

1. **Add Python CSP+Probability Solver as Submodule**
   - Use `git submodule add https://github.com/pbuckles22/MinewsweeperSolver_CSPProbablistic external/csp_solver`
   - Run `git submodule update --init --recursive`
   - Ensure the Python files are present in `external/csp_solver`

2. **Extend the Python Codebase for Explicit 50/50 Detection**
   - In the submodule, add a function (e.g., `find_5050_situations(board_state)`) in `probabilistic_guesser.py` or a new module.
   - This function should:
     - Run the probability analysis.
     - Identify and return all pairs/groups of cells with exactly 50% mine probability (i.e., true 50/50s).
     - Optionally, return the "best guess" cell(s) if there are multiple 50/50s.

3. **Test the New Python Function**
   - Write and run unit tests in the Python repo to ensure the new 50/50 detection works as expected.
   - Run the full test suite (`pytest`) to maintain high coverage.

4. **Include Python Files in iOS App Bundle**
   - In Xcode, add the relevant `.py` files from `external/csp_solver` to the Runner target.
   - Ensure they are copied into the app bundle at build time.

5. **Set Up Flutter MethodChannel (Dart Side)**
   - Create a `MethodChannel` in Dart for communication with iOS.
   - Implement a function to send board state and receive solver results.
   - Test Dart-to-Swift communication with a dummy response.

6. **Set Up Swift Side with PythonKit**
   - Add PythonKit to the iOS project via Swift Package Manager.
   - In `AppDelegate.swift`, set up the `FlutterMethodChannel` handler.
   - On `solveMove`, import and call the Python solver script using PythonKit.
   - Test Swift-to-Python integration with a simple script.

7. **Integrate and Test End-to-End**
   - After full integration, test end-to-end: Dart → Swift → Python → Swift → Dart.
   - Ensure the 50/50 detection results are returned and displayed in the Flutter app.

8. **Update UI Toggles and Logic**
   - Keep 50/50 toggles and UI in place.
   - Wire up toggles to call the new native integration.

9. **Ongoing**
   - When updating the Python repo, use `git submodule update --remote` to pull changes.
   - Ensure all changes are tested at each stage before moving to the next.

---

**Current Step:**
- [ ] 1. Add Python CSP+Probability Solver as Submodule and test file presence.
- [ ] 2. Extend the Python codebase for explicit 50/50 detection and test in Python.

---