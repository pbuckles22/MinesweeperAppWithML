import 'package:flutter/foundation.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/cell.dart';
import '../../domain/repositories/game_repository.dart';
import '../../data/repositories/game_repository_impl.dart';
import '../../services/timer_service.dart';
import '../../services/haptic_service.dart';
import '../../core/feature_flags.dart';

class GameProvider extends ChangeNotifier {
  final GameRepository _repository;
  final TimerService _timerService;
  GameState? _gameState;
  bool _isLoading = false;
  String? _error;

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
    // This will be handled by the UI layer
    // The provider just notifies that the game is over
  }

  @override
  void dispose() {
    _timerService.dispose();
    super.dispose();
  }
} 