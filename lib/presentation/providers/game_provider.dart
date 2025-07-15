import 'package:flutter/foundation.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/cell.dart';
import '../../domain/repositories/game_repository.dart';
import '../../data/repositories/game_repository_impl.dart';
import '../../services/timer_service.dart';
import '../../services/haptic_service.dart';
import '../../services/fifty_fifty_detector.dart';
import '../../core/feature_flags.dart';

class GameProvider extends ChangeNotifier {
  final GameRepository _repository;
  final TimerService _timerService;
  GameState? _gameState;
  bool _isLoading = false;
  String? _error;
  List<FiftyFiftySituation> _current5050Situations = [];

  GameProvider({GameRepository? repository, TimerService? timerService}) 
      : _repository = repository ?? GameRepositoryImpl(),
        _timerService = timerService ?? TimerService();

  // Getters
  GameState? get gameState => _gameState;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isGameInitialized => _gameState != null;
  bool get isGameOver => _gameState?.isGameOver ?? false;
  bool get isGameWon => _gameState?.isWon ?? false;
  bool get isGameLost => _gameState?.isLost ?? false;
  bool get isPlaying => _gameState?.isPlaying ?? false;
  TimerService get timerService => _timerService;
  List<FiftyFiftySituation> get current5050Situations => _current5050Situations;
  bool get has5050Situations => _current5050Situations.isNotEmpty;

  // Initialize game
  Future<void> initializeGame(String difficulty) async {
    try {
      _setLoading(true);
      _clearError();
      
      _gameState = await _repository.initializeGame(difficulty);
      _timerService.reset();
      _current5050Situations = [];
      notifyListeners();
    } catch (e) {
      _setError('Failed to initialize game: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Reveal cell
  Future<void> revealCell(int row, int col) async {
    if (!isGameInitialized || isGameOver) return;
    
    try {
      _clearError();
      
      // Start timer on first move
      if (!_timerService.isRunning) {
        _timerService.start();
      }
      
      _gameState = await _repository.revealCell(row, col);
      
      // Update 50/50 detection after revealing a cell
      _update5050Detection();
      
      notifyListeners();
      
      // Check if game is over and show appropriate dialog
      if (isGameOver) {
        _timerService.stop();
        _handleGameOver();
      }
    } catch (e) {
      _setError('Failed to reveal cell: $e');
    }
  }

  // Toggle flag
  Future<void> toggleFlag(int row, int col) async {
    if (!isGameInitialized || isGameOver) return;
    
    try {
      _clearError();
      
      // Start timer on first move
      if (!_timerService.isRunning) {
        _timerService.start();
      }
      
      _gameState = await _repository.toggleFlag(row, col);
      
      // Update 50/50 detection after flagging
      _update5050Detection();
      
      // Provide haptic feedback for flag toggle
      HapticService.lightImpact();
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to toggle flag: $e');
    }
  }

  // Reset game
  Future<void> resetGame() async {
    if (!isGameInitialized) return;
    
    try {
      _setLoading(true);
      _clearError();
      
      _gameState = await _repository.resetGame();
      _timerService.reset();
      _current5050Situations = [];
      notifyListeners();
    } catch (e) {
      _setError('Failed to reset game: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get game statistics
  Map<String, dynamic> getGameStatistics() {
    final stats = _repository.getGameStatistics();
    if (FeatureFlags.enableGameStatistics) {
      stats['timerElapsed'] = _timerService.elapsed.inSeconds;
      stats['timerRunning'] = _timerService.isRunning;
    }
    if (FeatureFlags.enable5050Detection) {
      stats['5050Situations'] = _current5050Situations.length;
    }
    return stats;
  }

  // Get remaining mines
  int getRemainingMines() {
    return _repository.getRemainingMines();
  }

  // Check if action is valid
  bool isValidAction(int row, int col) {
    if (!isGameInitialized || isGameOver) return false;
    
    try {
      final cell = _gameState!.getCell(row, col);
      return cell.isUnrevealed || (cell.isFlagged && isPlaying);
    } catch (e) {
      return false;
    }
  }

  // Get cell at position
  Cell? getCell(int row, int col) {
    if (!isGameInitialized) return null;
    
    try {
      return _gameState!.getCell(row, col);
    } catch (e) {
      return null;
    }
  }

  // Get neighbors of a cell
  List<Cell> getNeighbors(int row, int col) {
    if (!isGameInitialized) return [];
    
    try {
      return _gameState!.getNeighbors(row, col);
    } catch (e) {
      return [];
    }
  }

  // 50/50 Detection Methods
  void _update5050Detection() {
    if (!FeatureFlags.enable5050Detection || _gameState == null) {
      _current5050Situations = [];
      return;
    }

    // Clear previous 50/50 markings
    _clear5050Markings();
    
    // Detect new 50/50 situations
    _current5050Situations = FiftyFiftyDetector.detect5050Situations(_gameState!);
    
    // Mark cells that are in 50/50 situations
    _mark5050Cells();
  }

  void _clear5050Markings() {
    if (_gameState == null) return;
    
    for (int row = 0; row < _gameState!.rows; row++) {
      for (int col = 0; col < _gameState!.columns; col++) {
        final cell = _gameState!.getCell(row, col);
        if (cell.isFiftyFifty) {
          cell.unmarkFiftyFifty();
        }
      }
    }
  }

  void _mark5050Cells() {
    if (_gameState == null) return;
    
    for (final situation in _current5050Situations) {
      // Mark both cells in the 50/50 situation
      final cell1 = _gameState!.getCell(situation.row1, situation.col1);
      final cell2 = _gameState!.getCell(situation.row2, situation.col2);
      
      if (cell1.isUnrevealed) {
        cell1.markAsFiftyFifty();
      }
      if (cell2.isUnrevealed) {
        cell2.markAsFiftyFifty();
      }
    }
  }

  // Check if a specific cell is in a 50/50 situation
  bool isCellIn5050Situation(int row, int col) {
    if (!FeatureFlags.enable5050Detection || _gameState == null) {
      return false;
    }
    
    return FiftyFiftyDetector.isCellIn5050Situation(_gameState!, row, col);
  }

  // Get 50/50 situations for a specific cell
  List<FiftyFiftySituation> get5050SituationsForCell(int row, int col) {
    if (!FeatureFlags.enable5050Detection || _gameState == null) {
      return [];
    }
    
    return FiftyFiftyDetector.get5050SituationsForCell(_gameState!, row, col);
  }

  // Safe move for 50/50 situations (if enabled)
  Future<void> makeSafeMove(int row, int col) async {
    if (!FeatureFlags.enable5050SafeMove || !isCellIn5050Situation(row, col)) {
      return;
    }
    
    // For now, we'll just reveal the cell normally
    // In a full implementation, this might involve more sophisticated logic
    await revealCell(row, col);
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void _handleGameOver() {
    // Clear 50/50 situations when game is over
    _current5050Situations = [];
    _clear5050Markings();
    // This will be handled by the UI layer
    // The provider just notifies that the game is over
  }

  @override
  void dispose() {
    _timerService.dispose();
    super.dispose();
  }
} 