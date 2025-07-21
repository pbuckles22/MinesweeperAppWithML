import 'package:flutter/foundation.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/cell.dart';
import '../../domain/repositories/game_repository.dart';
import '../../data/repositories/game_repository_impl.dart';
import '../../services/timer_service.dart';
import '../../services/haptic_service.dart';
import '../../core/feature_flags.dart';
import '../../services/native_5050_solver.dart';

class GameProvider extends ChangeNotifier {
  final GameRepository _repository;
  final TimerService _timerService;
  GameState? _gameState;
  bool _isLoading = false;
  String? _error;

  // 50/50 detection state
  List<List<int>> _fiftyFiftyCells = [];
  List<List<int>> get fiftyFiftyCells => _fiftyFiftyCells;

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

  // Initialize game
  Future<void> initializeGame(String difficulty) async {
    try {
      _setLoading(true);
      _clearError();
      
      _gameState = await _repository.initializeGame(difficulty);
      _timerService.reset();
      await updateFiftyFiftyDetection();
      notifyListeners();
    } catch (e) {
      _setError('Failed to initialize game: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Reveal cell
  Future<void> revealCell(int row, int col) async {
    if (isGameOver) return; // Prevent revealing after game over
    try {
      _setLoading(true);
      _clearError();
      
      _gameState = await _repository.revealCell(row, col);
      await updateFiftyFiftyDetection();
      notifyListeners();
      
      if (isGameOver) {
        _timerService.stop();
        _handleGameOver();
      }
    } catch (e) {
      _setError('Failed to reveal cell: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Toggle flag
  Future<void> toggleFlag(int row, int col) async {
    try {
      _setLoading(true);
      _clearError();
      
      _gameState = await _repository.toggleFlag(row, col);
      await updateFiftyFiftyDetection();
      notifyListeners();
    } catch (e) {
      _setError('Failed to toggle flag: $e');
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
      return cell.isUnrevealed || cell.isFlagged;
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

  // Loading and error helpers
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void _handleGameOver() {
    // Placeholder for game over logic (show dialog, etc.)
  }

  /// Build a probability map and call the native 50/50 solver.
  Future<void> updateFiftyFiftyDetection() async {
    if (!FeatureFlags.enable5050Detection || _gameState == null) {
      _fiftyFiftyCells = [];
      notifyListeners();
      return;
    }
    // Placeholder: assign 0.5 to all unrevealed cells for demonstration
    final probabilityMap = <String, double>{};
    for (final row in _gameState!.board) {
      for (final cell in row) {
        if (cell.isUnrevealed) {
          probabilityMap['(${cell.row}, ${cell.col})'] = 0.5; // TODO: Replace with real probability
        }
      }
    }
    try {
      _fiftyFiftyCells = await Native5050Solver.find5050(probabilityMap);
    } catch (e) {
      _fiftyFiftyCells = [];
    }
    notifyListeners();
  }

  /// Check if a cell is in a 50/50 situation
  bool isCellIn5050Situation(int row, int col) {
    return _fiftyFiftyCells.any((cell) => cell[0] == row && cell[1] == col);
  }

  /// Reveal a cell as a 50/50 safe move if allowed
  Future<void> execute5050SafeMove(int row, int col) async {
    if (!FeatureFlags.enable5050SafeMove) return;
    if (!isCellIn5050Situation(row, col)) return;
    await revealCell(row, col);
  }

  /// Stub for forceResetRepository to satisfy UI/tests
  void forceResetRepository() {
    // Optionally, reset repository or game state here
    // For now, this is a no-op stub
  }
} 