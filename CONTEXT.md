# CONTEXT.md

## Project Overview
This project is a modernized Flutter Minesweeper game, with a focus on robust game logic, test coverage, and future integration with ML features. The codebase is being updated for null safety, modern Flutter best practices, and maintainability.

## Current Status
- ✅ **Core game logic is fully functional** with comprehensive test coverage (43 tests)
- ✅ **All known bugs fixed** including cascade logic, flag toggling, and win/loss detection
- ✅ **Chording functionality implemented** (right-click to reveal unflagged neighbors)
- ✅ **UI improvements completed** including zoom controls, haptic feedback, and game over dialog
- ✅ **Android build issues resolved** with Java 17 and Kotlin DSL

## Immediate TODOs (Next Session)
1. **Create Constants File** - Centralize game configuration for easy adjustment of game modes, sizes, and mine counts
2. **Settings UI Improvements** - Hide settings panel and restart game when board size changes are confirmed
3. **50/50 Situation Detection** - Identify and handle classic Minesweeper scenarios where two cells have equal probability

## Current Goals
- Ensure all core game logic is bug-free and well-tested
- Use deterministic boards for all logic/unit/integration tests
- Track all bug fixes, test improvements, and code coverage requirements in TODO.md
- Prepare for future ML integration and advanced analytics

## Workflow
- All tasks, bugs, and improvements are tracked in `TODO.md`.
- As you work, update `TODO.md` to reflect progress, add new tasks, and mark completed items.
- Use this CONTEXT.md to quickly onboard new contributors or recall project state between sessions. 