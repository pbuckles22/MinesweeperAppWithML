#!/bin/bash

# Run coverage on test files that don't cause segfaults
# Exclude: dynamic_config_test.dart, game_repository_test.dart, widget_test.dart

echo "Running coverage on safe test files..."

# Clear previous coverage data
rm -rf coverage/

# Run coverage on individual test files that work
flutter test test/cell_test.dart --coverage
flutter test test/timer_service_test.dart --coverage
flutter test test/game_mode_config_test.dart --coverage
flutter test test/fifty_fifty_detection_test.dart --coverage
flutter test test/game_logic_test.dart --coverage
flutter test test/chaotic_mode_test.dart --coverage
flutter test test/duplicate_validation_test.dart --coverage
flutter test test/first_click_guarantee_test.dart --coverage
flutter test test/game_over_dialog_test.dart --coverage
flutter test test/zoom_widget_test.dart --coverage

echo "Coverage data generated in coverage/lcov.info"
echo "Analyzing coverage..."

# Use lcov to generate a report
if command -v lcov &> /dev/null; then
    lcov --summary coverage/lcov.info
else
    echo "lcov not found. Install with: brew install lcov"
    echo "Raw coverage data available in coverage/lcov.info"
fi 