# CONTEXT.md

## Project Overview
This project is a modernized Flutter Minesweeper game, with a focus on robust game logic, test coverage, and future integration with ML features. The codebase is being updated for null safety, modern Flutter best practices, and maintainability.

## Current Status
- ✅ **Core game logic is fully functional** with comprehensive test coverage (126+ tests)
- ✅ **All known bugs fixed** including cascade logic, flag toggling, win/loss detection, and 50/50 scenario detection
- ✅ **Chording functionality implemented** (right-click to reveal unflagged neighbors)
- ✅ **UI improvements completed** including zoom controls, haptic feedback, and game over dialog
- ✅ **Android build issues resolved** with Java 17 and Kotlin DSL
- ✅ **Game configuration validation implemented** with compile-time duplicate detection
- ✅ **Bomb explosion display fixed** with clear visual distinction for different cell states
- ✅ **Settings UX improved** with consistent auto-close behavior and educational tooltips
- ✅ **Auto-generated descriptions** for game modes to reduce maintenance
- ✅ **Smart Timer System** - Battery-efficient timer with app lifecycle awareness, pauses in background
- 🏳️ **50/50 Situation Detection** - Identifies classic and shared constraint 50/50 scenarios, with scenario-based tests for each

## Recent Major Improvements (Latest Session)
1. **✅ Smart Timer Implementation** - Continuous timer that:
   - Updates every second during active gameplay
   - Pauses automatically when app goes to background
   - Resumes when app returns to foreground
   - Maintains accurate timing by accounting for pause duration
   - Saves battery by stopping background processing
2. **✅ App Lifecycle Management** - Timer integrates with Flutter's `WidgetsBindingObserver`
3. **✅ Provider Architecture** - Proper state management with `GameProvider` and `TimerService`
4. **✅ Test Coverage** - All 126+ tests pass, including widget tests with proper provider setup

## Immediate TODOs (Next Session)
1. **Advanced Game Features** - Implement undo, hints, and auto-flagging
2. **ML Integration Preparation** - Set up infrastructure for future ML-powered assistance

## Current Goals
- Ensure all core game logic is bug-free and well-tested, including 50/50 detection
- Use deterministic boards for all logic/unit/integration tests, including 50/50 scenarios
- Track all bug fixes, test improvements, and code coverage requirements in TODO.md
- Prepare for future ML integration and advanced analytics

## Workflow
- All tasks, bugs, and improvements are tracked in `TODO.md`.
- As you work, update `TODO.md` to reflect progress, add new tasks, and mark completed items.
- Use this CONTEXT.md to quickly onboard new contributors or recall project state between sessions.

# Integration Test Status

- Settings Page: All integration tests pass, using direct provider calls for robust state changes.
- Main App: Integration tests for launch, navigation, and provider initialization all pass.
- Next: End-to-End Game Flow integration tests. 