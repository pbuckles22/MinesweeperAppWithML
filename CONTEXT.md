# CONTEXT.md

## Project Overview
This project is a modernized Flutter Minesweeper game, with a focus on robust game logic, test coverage, and future integration with ML features. The codebase is being updated for null safety, modern Flutter best practices, and maintainability.

## Current Status
- ✅ **Core game logic is fully functional** with comprehensive test coverage (43 tests)
- ✅ **All known bugs fixed** including cascade logic, flag toggling, and win/loss detection
- ✅ **Chording functionality implemented** (right-click to reveal unflagged neighbors)
- ✅ **UI improvements completed** including zoom controls, haptic feedback, and game over dialog
- ✅ **Android build issues resolved** with Java 17 and Kotlin DSL
- ✅ **Game configuration validation implemented** with compile-time duplicate detection
- ✅ **Bomb explosion display fixed** with clear visual distinction for different cell states
- ✅ **Settings UX improved** with consistent auto-close behavior and educational tooltips
- ✅ **Auto-generated descriptions** for game modes to reduce maintenance

## Recent Major Improvements (Latest Session)
1. **✅ Game Configuration Validation** - App now fails to start if there are duplicate game mode IDs or names
2. **✅ Bomb Display Enhancement** - Clear visual distinction between:
   - 💣 (Red bomb on yellow background): The bomb that killed you
   - 💣 (Bomb on red background): Other hidden bombs
   - 🚩 (Flag): Correctly flagged mines
   - ❌ (Black X): Incorrectly flagged non-mines
3. **✅ Settings UX Consistency** - All game-affecting changes now auto-close settings
4. **✅ Educational Tooltips** - Help icon explains kickstarter mode vs classic mode
5. **✅ Auto-generated Descriptions** - Game mode descriptions generated from grid dimensions

## Immediate TODOs (Next Session)
1. **50/50 Situation Detection** - Identify and handle classic Minesweeper scenarios where two cells have equal probability
2. **Advanced Game Features** - Implement undo, hints, and auto-flagging
3. **ML Integration Preparation** - Set up infrastructure for future ML-powered assistance

## Current Goals
- Ensure all core game logic is bug-free and well-tested
- Use deterministic boards for all logic/unit/integration tests
- Track all bug fixes, test improvements, and code coverage requirements in TODO.md
- Prepare for future ML integration and advanced analytics

## Workflow
- All tasks, bugs, and improvements are tracked in `TODO.md`.
- As you work, update `TODO.md` to reflect progress, add new tasks, and mark completed items.
- Use this CONTEXT.md to quickly onboard new contributors or recall project state between sessions. 