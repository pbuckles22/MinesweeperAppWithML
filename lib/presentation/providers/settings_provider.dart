import 'package:flutter/foundation.dart';
import '../../core/feature_flags.dart';

class SettingsProvider extends ChangeNotifier {
  // Game mode settings
  bool _isFirstClickGuaranteeEnabled = false;
  bool _isClassicMode = true; // Classic vs Kickstarter mode

  // Getters
  bool get isFirstClickGuaranteeEnabled => _isFirstClickGuaranteeEnabled;
  bool get isClassicMode => _isClassicMode;
  bool get isKickstarterMode => !_isClassicMode;

  // Initialize settings
  SettingsProvider() {
    _loadSettings();
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

  // Set specific mode
  void setGameMode(bool isKickstarterMode) {
    _isClassicMode = !isKickstarterMode;
    _isFirstClickGuaranteeEnabled = isKickstarterMode;
    
    // Update feature flags
    FeatureFlags.enableFirstClickGuarantee = _isFirstClickGuaranteeEnabled;
    
    _saveSettings();
    notifyListeners();
  }

  // Load settings from storage (placeholder for now)
  void _loadSettings() {
    // TODO: Implement persistent storage
    // For now, use default values
    _isFirstClickGuaranteeEnabled = false;
    _isClassicMode = true;
    FeatureFlags.enableFirstClickGuarantee = _isFirstClickGuaranteeEnabled;
  }

  // Save settings to storage (placeholder for now)
  void _saveSettings() {
    // TODO: Implement persistent storage
    // For now, just update feature flags
  }

  // Reset to defaults
  void resetToDefaults() {
    _isFirstClickGuaranteeEnabled = false;
    _isClassicMode = true;
    FeatureFlags.enableFirstClickGuarantee = _isFirstClickGuaranteeEnabled;
    
    _saveSettings();
    notifyListeners();
  }
} 