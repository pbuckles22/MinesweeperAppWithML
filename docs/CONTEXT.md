# CONTEXT.md

## Project Overview
This project is a modernized Flutter Minesweeper game, with a focus on robust game logic, test coverage, and future integration with ML features. The codebase is being updated for null safety, modern Flutter best practices, and maintainability.

## Current Status
- ✅ **Core game logic is fully functional** with comprehensive test coverage (261 tests)
- ✅ **All known bugs fixed** including cascade logic, flag toggling, win/loss detection, and 50/50 scenario detection
- ✅ **Chording functionality implemented** (right-click to reveal unflagged neighbors)
- ✅ **UI improvements completed** including zoom controls, haptic feedback, and game over dialog
- ✅ **Android build issues resolved** with Java 17 and Kotlin DSL
- ✅ **Game configuration validation implemented** with compile-time validation
- ✅ **50/50 Safe Move feature implemented** - Auto-resolve 50/50 situations with mine movement
- ✅ **Comprehensive testing strategy complete** - All high-impact tests implemented and passing
- ✅ **Feature flags system implemented** - Centralized configuration via JSON with UI toggles
- ✅ **Settings page enhanced** - Complete UI with grouped feature toggles and educational tooltips
- ✅ **Python integration infrastructure ready** - Native 50/50 solver with timeout protection

## Recent Improvements
- **Feature Flags System**: Centralized configuration management via `assets/config/game_modes.json`
  - All feature flags configurable via JSON with UI toggles in settings
  - Default values loaded at app startup
  - Settings page organized into logical groups (General Gameplay, Appearance & UX, Advanced/Experimental)
  - Educational tooltips for each feature
- **Enhanced Settings Page**: Complete UI overhaul with:
  - Grouped feature toggles with clear sections
  - Disabled toggles for unimplemented features with tooltips
  - Consistent auto-close behavior for game-affecting changes
  - Educational help icons explaining each feature
- **50/50 Safe Move Feature**: Users can now click on highlighted 50/50 cells to automatically resolve the situation
  - If clicked cell has a mine, it's moved to the other 50/50 cell
  - Board is refreshed with minimal changes to affected cells
  - Game continues normally after safe move
  - Controlled by "50/50 Safe Move" toggle in settings
- **Python Integration Infrastructure**: Native 50/50 solver with robust error handling
  - Swift/PythonKit bridge for iOS
  - MethodChannel communication with timeout protection
  - Graceful fallback when native solver unavailable
  - CSP solver integration ready for activation
- **Enhanced Integration Testing**: Complete coverage of settings page, main app, and end-to-end game flow
- **Robust Error Handling**: Comprehensive error handling and edge case coverage
- **Performance Optimization**: Efficient board updates and minimal UI rebuilds

## Immediate TODOs
1. **Python 50/50 Solver Activation** - Enable and test the native Python-based 50/50 detection
2. **Feature Testing & Polish** - Test 50/50 safe move in various game scenarios
3. **User Experience Validation** - Ensure smooth interaction with safe move feature
4. **Documentation Updates** - Update user guides and feature documentation
5. **Performance Monitoring** - Monitor safe move performance in different game modes

## Recent Major Improvements (Latest Session)
1. **✅ Feature Flags System** - Complete centralized configuration management:
   - JSON-based configuration with UI toggles
   - All feature flags exposed in settings page
   - Default values loaded from JSON at startup
   - Educational tooltips and organized sections
2. **✅ Enhanced Settings Page** - Complete UI overhaul with grouped toggles and help system
3. **✅ Python Integration Infrastructure** - Native 50/50 solver ready for activation:
   - Swift/PythonKit bridge implemented
   - MethodChannel with timeout protection
   - CSP solver integration prepared
4. **✅ Complete Testing Strategy** - Comprehensive test suite with:
   - 261 tests passing, robust and reliable execution
   - Complete integration testing (Settings Page, Main App, End-to-End Game Flow)
   - Performance testing for large boards and rapid interactions
   - Provider integration and widget testing
   - Error handling and edge case coverage
5. **✅ End-to-End Game Flow Tests** - Complete simulation of user interactions:
   - Full game flow from start to win/lose
   - Game reset and restart functionality
   - Flag placement and removal
   - Difficulty changes during gameplay
6. **✅ Provider Architecture** - Robust state management with proper integration testing
7. **✅ Test Stability** - No more hanging tests, reliable test execution

## Immediate TODOs (Next Session)
1. **Python 50/50 Solver Activation** - Enable and test the native Python-based 50/50 detection
2. **Advanced Game Features** - Implement undo, hints, and auto-flagging
3. **UI Polish** - Dark mode and smooth animations

## Current Goals
- ✅ **Feature Flags System Complete** - Centralized configuration with UI toggles
- ✅ **Testing Strategy Complete** - All high-impact tests implemented and passing
- 🎯 **Python 50/50 Solver Activation** - Enable and test the native Python-based 50/50 detection
- **Advanced Game Features** - Add undo, hints, and auto-flagging capabilities
- **UI/UX Enhancement** - Dark mode, animations, and sound effects
- **ML Integration Preparation** - Set up infrastructure for future ML-powered assistance

## Workflow
- All tasks, bugs, and improvements are tracked in `TODO.md`.
- As you work, update `TODO.md` to reflect progress, add new tasks, and mark completed items.
- Use this CONTEXT.md to quickly onboard new contributors or recall project state between sessions.

# Integration Test Status

- ✅ **Settings Page Integration Tests** - Complete UI and provider state testing
- ✅ **Main App Integration Tests** - App launch, navigation, and provider initialization
- ✅ **End-to-End Game Flow Integration Tests** - Complete game experience simulation
- ✅ **Provider Integration Tests** - GameProvider and SettingsProvider state management
- ✅ **Widget Integration Tests** - GameBoard rendering and interactions
- ✅ **Performance Tests** - Large board operations and rapid state changes

**Status**: ✅ ALL INTEGRATION TESTS COMPLETE AND PASSING (261 tests)

# Python Integration Status

- ✅ **Infrastructure Ready** - Swift/PythonKit bridge implemented
- ✅ **MethodChannel Setup** - Dart-to-Swift communication with timeout protection
- ✅ **CSP Solver Integration** - Python files included in iOS bundle
- ✅ **Error Handling** - Graceful fallback when native solver unavailable
- 🎯 **Next Step** - Enable 50/50 detection in JSON config and test activation 