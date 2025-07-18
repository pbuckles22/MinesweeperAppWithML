import 'package:flutter/foundation.dart';
import '../../core/feature_flags.dart';
import '../../core/game_mode_config.dart';

class SettingsProvider extends ChangeNotifier {
  // Game mode settings
  bool _isFirstClickGuaranteeEnabled = false;
  bool _isClassicMode = true; // Classic vs Kickstarter mode
  
  // 50/50 detection settings
  bool _is5050DetectionEnabled = false;
  bool _is5050SafeMoveEnabled = false;
  
  // Difficulty settings
  String _selectedDifficulty = 'easy';

  // Getters
  bool get isFirstClickGuaranteeEnabled => _isFirstClickGuaranteeEnabled;
  bool get isClassicMode => _isClassicMode;
  bool get isKickstarterMode => !_isClassicMode;
  bool get is5050DetectionEnabled => _is5050DetectionEnabled;
  bool get is5050SafeMoveEnabled => _is5050SafeMoveEnabled;
  String get selectedDifficulty => _selectedDifficulty;

  // Initialize settings
  SettingsProvider() {
    _loadSettings();
    notifyListeners(); // Ensure listeners are notified after loading settings
  }

  // Toggle first click guarantee (Classic vs Kickstarter mode)
  void toggleFirstClickGuarantee() {
    _isFirstClickGuaranteeEnabled = !_isFirstClickGuaranteeEnabled;
    _isClassicMode = !_isFirstClickGuaranteeEnabled;
    
    // Update feature flags
    FeatureFlags.enableFirstClickGuarantee = _isFirstClickGuaranteeEnabled;
    
    _saveSettings();
    notifyListeners();
  }

  // Toggle 50/50 detection
  void toggle5050Detection() {
    _is5050DetectionEnabled = !_is5050DetectionEnabled;
    
    // Update feature flags
    FeatureFlags.enable5050Detection = _is5050DetectionEnabled;
    
    // If disabling 50/50 detection, also disable safe move
    if (!_is5050DetectionEnabled) {
      _is5050SafeMoveEnabled = false;
      FeatureFlags.enable5050SafeMove = false;
    }
    
    _saveSettings();
    notifyListeners();
  }

  // Toggle 50/50 safe move
  void toggle5050SafeMove() {
    if (!_is5050DetectionEnabled) return; // Can't enable safe move without detection
    
    _is5050SafeMoveEnabled = !_is5050SafeMoveEnabled;
    
    // Update feature flags
    FeatureFlags.enable5050SafeMove = _is5050SafeMoveEnabled;
    
    _saveSettings();
    notifyListeners();
  }

  // Set specific mode
  void setGameMode(bool isKickstarterMode) {
    _isClassicMode = !isKickstarterMode;
    _isFirstClickGuaranteeEnabled = isKickstarterMode;
    
    // Update feature flags
    FeatureFlags.enableFirstClickGuarantee = _isFirstClickGuaranteeEnabled;
    
    _saveSettings();
    notifyListeners();
  }

  // Set difficulty
  void setDifficulty(String difficulty) {
    if (GameModeConfig.instance.hasGameMode(difficulty)) {
      _selectedDifficulty = difficulty;
      _saveSettings();
      notifyListeners();
    }
  }

  // Load settings from storage (placeholder for now)
  void _loadSettings() {
    // TODO: Implement persistent storage
    // For now, read defaults from GameModeConfig (single source of truth)
    _isFirstClickGuaranteeEnabled = GameModeConfig.instance.defaultKickstarterMode;
    _isClassicMode = !GameModeConfig.instance.defaultKickstarterMode;
    _is5050DetectionEnabled = GameModeConfig.instance.default5050Detection;
    _is5050SafeMoveEnabled = GameModeConfig.instance.default5050SafeMove;
    _selectedDifficulty = GameModeConfig.instance.defaultGameMode?.id ?? 'hard';
    
    // Note: FeatureFlags are already initialized in main.dart from JSON
    // We don't need to set them again here
    
    // Debug logging
    // print('DEBUG: SettingsProvider._loadSettings - Loaded settings from JSON:');
    // print('DEBUG:   Kickstarter mode: $_isFirstClickGuaranteeEnabled');
    // print('DEBUG:   50/50 detection: $_is5050DetectionEnabled');
    // print('DEBUG:   50/50 safe move: $_is5050SafeMoveEnabled');
    // print('DEBUG:   Difficulty: $_selectedDifficulty');
    // print('DEBUG:   FeatureFlags (already set in main.dart):');
    // print('DEBUG:     enableFirstClickGuarantee: ${FeatureFlags.enableFirstClickGuarantee}');
    // print('DEBUG:     enable5050Detection: ${FeatureFlags.enable5050Detection}');
    // print('DEBUG:     enable5050SafeMove: ${FeatureFlags.enable5050SafeMove}');
  }

  // Save settings to storage (placeholder for now)
  void _saveSettings() {
    // TODO: Implement persistent storage
    // For now, just update feature flags
  }

  // Reset to defaults
  void resetToDefaults() {
    // Read defaults from GameModeConfig (single source of truth)
    _isFirstClickGuaranteeEnabled = GameModeConfig.instance.defaultKickstarterMode;
    _isClassicMode = !GameModeConfig.instance.defaultKickstarterMode;
    _is5050DetectionEnabled = GameModeConfig.instance.default5050Detection;
    _is5050SafeMoveEnabled = GameModeConfig.instance.default5050SafeMove;
    _selectedDifficulty = GameModeConfig.instance.defaultGameMode?.id ?? 'hard';
    
    // Update feature flags (this is needed for reset functionality)
    FeatureFlags.enableFirstClickGuarantee = _isFirstClickGuaranteeEnabled;
    FeatureFlags.enable5050Detection = _is5050DetectionEnabled;
    FeatureFlags.enable5050SafeMove = _is5050SafeMoveEnabled;
    
    _saveSettings();
    notifyListeners();
  }
} 