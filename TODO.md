# TODO List for Minesweeper Game Modernization & Bug Fixing

## ✅ Completed Tasks

- [x] **Review and fix all known game logic bugs (cascade logic, flag toggling, win/loss detection, etc.) using deterministic tests.**
- [x] **Implement classic Minesweeper chording (right-click) functionality.**
- [x] **Add comprehensive edge case tests for all game scenarios.**
- [x] **Ensure code coverage is high for all core game logic, including edge cases and error handling.**
- [x] **Track and mark off each bug fix and test improvement as completed in this TODO list.**

## 🚧 Current Status

**All core Minesweeper functionality is now working with comprehensive test coverage (43 tests).**

### ✅ What's Working:
- Board initialization and mine placement
- Cell revealing and cascade logic
- Flag management (toggle, validation)
- Chording (right-click) functionality
- Win/loss detection
- Game state management
- All edge cases and error handling
- Performance validation for large boards

### ❌ Known Issues:
- ~~**Android APK build still failing** - Gradle plugin configuration needs further fixes~~ ✅ **FIXED**

## 📋 Next Priority Features

### **🚨 IMMEDIATE TODOs:**
1. **Create Constants File** - Centralize game configuration
   - [ ] Create `lib/constants/game_constants.dart` with all game modes, sizes, mine counts
   - [ ] Replace hardcoded values throughout codebase with constants
   - [ ] Add easy configuration for new game modes
   - [ ] Ensure all files use centralized constants

2. **Settings UI Improvements**
   - [ ] When board size changes and user confirms, hide settings panel
   - [ ] Automatically restart game with new settings
   - [ ] Improve UX flow for settings changes

3. **50/50 Situation Detection & Resolution**
   - [ ] Identify classic Minesweeper 50/50 scenarios (two cells with equal probability)
   - [ ] Implement detection algorithm for unsolvable situations
   - [ ] Add visual indicators for 50/50 scenarios
   - [ ] Consider auto-resolve or hint system for 50/50s
   - [ ] Add tests for 50/50 detection and handling

### **1. First Click Guarantee** (Feature Flag: `enableFirstClickGuarantee`)
- [ ] Implement first click never hits a mine
- [ ] Move mines if first click would hit one
- [ ] Add tests for first click guarantee
- [ ] Update UI to reflect this behavior

### **2. Game Statistics & Timer** (Feature Flag: `enableGameStatistics`)
- [ ] Implement timer functionality
- [ ] Add mine counter (remaining mines display)
- [ ] Track game duration
- [ ] Add best times tracking

### **3. Board Reset/New Game** (Feature Flag: `enableBoardReset`)
- [ ] Implement new game functionality
- [ ] Test that reset preserves difficulty settings
- [ ] Add reset button to UI

### **4. Custom Difficulty** (Feature Flag: `enableCustomDifficulty`)
- [ ] Allow custom board sizes
- [ ] Allow custom mine counts
- [ ] Validate custom settings

## 🔮 Future Features

### **Advanced Game Features:**
- [ ] Undo move functionality (`enableUndoMove`)
- [ ] Hint system (`enableHintSystem`)
- [ ] Auto-flagging (`enableAutoFlag`)
- [ ] Best times tracking (`enableBestTimes`)

### **UI/UX Enhancements:**
- [ ] Dark mode (`enableDarkMode`)
- [ ] Smooth animations (`enableAnimations`)
- [ ] Sound effects (`enableSoundEffects`)
- [ ] Haptic feedback (`enableHapticFeedback`)

### **ML/AI Integration:**
- [ ] ML-powered assistance (`enableMLAssistance`)
- [ ] Auto-play functionality (`enableAutoPlay`)
- [ ] Difficulty prediction (`enableDifficultyPrediction`)

### **Development Tools:**
- [ ] Debug mode (`enableDebugMode`)
- [ ] Performance metrics (`enablePerformanceMetrics`)
- [ ] Test mode (`enableTestMode`)

## 🎯 Immediate Next Steps

1. ✅ **Fix Android APK build** - Resolved: installed Java 17, regenerated Android folder with Kotlin DSL
2. **Enable First Click Guarantee** - Set `enableFirstClickGuarantee = true` and implement
3. **Add tests for first click guarantee**
4. **Update UI to reflect new behavior**
5. **Test manually to ensure smooth gameplay**

---

**Current Test Coverage: 43 tests covering all standard Minesweeper functionality**
**Next Feature: First Click Guarantee (core UX improvement)**