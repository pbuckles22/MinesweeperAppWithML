# Test Coverage Report

## Summary
- **Overall Coverage**: 23.9% (367 of 1538 lines)
- **Source Files**: 16 files covered
- **Test Files**: 10 test files (excluding problematic ones)
- **Total Tests**: 260 tests passing, 34 tests skipped

## Coverage by File

### High Coverage (>80%)
- **game_board.dart**: 91.2% (93/102 lines) ✅

### Good Coverage (40-80%)
- **game_mode_config.dart**: 54.2% (45/83 lines) ✅
- **game_page.dart**: 47.8% (33/69 lines) ✅
- **cell_widget.dart**: 46.2% (36/78 lines) ✅

### Moderate Coverage (20-40%)
- **timer_service.dart**: 35.1% (20/57 lines) ✅
- **game_state.dart**: 30.0% (18/60 lines) ✅
- **game_provider.dart**: 29.0% (36/124 lines) ✅
- **cell.dart**: 25.5% (14/55 lines) ✅
- **settings_provider.dart**: 20.3% (12/59 lines) ✅

### Low Coverage (1-20%)
- **game_repository_impl.dart**: 17.0% (59/348 lines) ⚠️
- **settings_page.dart**: 0.4% (1/236 lines) ❌

### No Coverage (0%)
- **constants.dart**: 0.0% (0/2 lines) ❌
- **icon_utils.dart**: 0.0% (0/20 lines) ❌
- **game_over_dialog.dart**: 0.0% (0/56 lines) ❌
- **fifty_fifty_detector.dart**: 0.0% (0/179 lines) ❌
- **haptic_service.dart**: 0.0% (0/10 lines) ❌

## Test Files Included
✅ **Safe test files** (no segfaults):
- `cell_test.dart` (55 tests)
- `timer_service_test.dart` (3 tests)
- `game_mode_config_test.dart` (14 tests)
- `fifty_fifty_detection_test.dart` (23 tests)
- `game_logic_test.dart` (46 tests)
- `chaotic_mode_test.dart` (6 tests)
- `duplicate_validation_test.dart` (3 tests)
- `first_click_guarantee_test.dart` (8 tests)
- `game_over_dialog_test.dart` (2 tests)
- `zoom_widget_test.dart` (2 tests)
- `integration/` - Complete integration test suite (Settings Page, Main App, End-to-End Game Flow)

❌ **Problematic test files** (cause segfaults with coverage):
- `dynamic_config_test.dart`
- `game_repository_test.dart`
- `widget_test.dart`

## Recommendations

### Immediate Actions
1. **Add tests for zero-coverage files**:
   - `constants.dart` - Core constants
   - `icon_utils.dart` - Icon utility functions
   - `haptic_service.dart` - Haptic feedback service
   - `game_over_dialog.dart` - Game over dialog widget

2. **Improve coverage for low-coverage files**:
   - `game_repository_impl.dart` - Core game logic (17% → target 80%)
   - `settings_page.dart` - Settings UI (0.4% → target 60%)

3. **Investigate segfault issues**:
   - Research why certain test files cause segmentation faults
   - Consider alternative coverage tools or approaches

### Coverage Goals
- **Overall target**: 80% coverage
- **Core logic files**: 90%+ coverage
- **UI files**: 60%+ coverage
- **Utility files**: 80%+ coverage

## Tools
- **Coverage script**: `run_safe_coverage.sh` - Runs coverage on safe test files
- **Analysis script**: `analyze_coverage.sh` - Analyzes coverage data
- **Coverage data**: `coverage/lcov.info` - Raw coverage data

## Notes
- Coverage tool has known issues with certain test files causing segmentation faults
- Workaround: Run coverage on individual test files or use the safe coverage script
- All normal tests pass consistently (260 tests)
- Focus on improving coverage for core business logic first 