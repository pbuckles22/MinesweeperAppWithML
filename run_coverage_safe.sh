#!/bin/bash

# Safe coverage script - runs coverage on individual test files
# Avoids problematic files that cause segmentation faults

echo "Running safe coverage analysis..."

# Clean previous coverage data
rm -rf coverage/

# Test files that are safe to run with coverage
# Note: game_state_test.dart is excluded due to segfaults caused by:
# - Platform channel calls (rootBundle.loadString) in GameModeConfig
# - File I/O operations in singleton initialization
# - DateTime.now() calls in GameState.gameDuration getter
# - Complex data structures in difficultyLevels getter
# The tests work correctly (8/8 pass) but coverage tool crashes
SAFE_TESTS=(
    "test/cell_test.dart"
    "test/constants_test.dart"
    "test/icon_utils_test.dart"
    "test/haptic_service_test.dart"
    "test/game_over_dialog_test.dart"
    "test/fifty_fifty_detector_test.dart"
    "test/game_logic_test.dart"
    "test/game_repository_test.dart"
    "test/timer_service_test.dart"
    "test/game_mode_config_test.dart"
    "test/chaotic_mode_test.dart"
    "test/duplicate_validation_test.dart"
    "test/dynamic_config_test.dart"
    "test/first_click_guarantee_test.dart"
    "test/board_square_test.dart"
    "test/feature_flags_test.dart"
    # "test/game_state_test.dart"  # Excluded due to coverage tool segfaults
)

# Run each safe test with coverage
for test_file in "${SAFE_TESTS[@]}"; do
    if [ -f "$test_file" ]; then
        echo "Running coverage for $test_file..."
        flutter test --coverage "$test_file" || echo "Failed to run coverage for $test_file"
    else
        echo "Test file $test_file not found, skipping..."
    fi
done

# Generate coverage report
if [ -d "coverage/" ]; then
    echo "Generating coverage report..."
    genhtml coverage/lcov.info -o coverage/html
    echo "Coverage report generated in coverage/html/"
    
    # Show summary
    echo "Coverage summary:"
    lcov --summary coverage/lcov.info 2>/dev/null || echo "Could not generate summary"
else
    echo "No coverage data found"
fi 