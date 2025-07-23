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
    
    // Calculate real probabilities based on game state
    final probabilityMap = _calculateRealProbabilities();
    
    try {
      _fiftyFiftyCells = await Native5050Solver.find5050(probabilityMap);
    } catch (e) {
      print('DEBUG: 50/50 detection failed: $e');
      _fiftyFiftyCells = [];
    }
    notifyListeners();
  }

  /// Calculate real probabilities for 50/50 detection
  Map<String, double> _calculateRealProbabilities() {
    final probabilityMap = <String, double>{};
    
    if (_gameState == null) return probabilityMap;
    
    // Get all unrevealed cells
    final unrevealedCells = <List<int>>[];
    for (int row = 0; row < _gameState!.board.length; row++) {
      for (int col = 0; col < _gameState!.board[row].length; col++) {
        final cell = _gameState!.getCell(row, col);
        if (cell.isUnrevealed && !cell.isFlagged) {
          unrevealedCells.add([row, col]);
        }
      }
    }
    
    // Calculate probabilities based on revealed numbers
    for (final cellPos in unrevealedCells) {
      final row = cellPos[0];
      final col = cellPos[1];
      
      // Get revealed neighbors
      final revealedNeighbors = _getRevealedNeighbors(row, col);
      
      if (revealedNeighbors.isEmpty) {
        // No revealed neighbors, use neutral probability
        probabilityMap['($row, $col)'] = 0.3;
        continue;
      }
      
      // Calculate probability based on revealed neighbors
      double totalProbability = 0.0;
      int neighborCount = 0;
      
      for (final neighbor in revealedNeighbors) {
        final neighborRow = neighbor[0];
        final neighborCol = neighbor[1];
        final neighborCell = _gameState!.getCell(neighborRow, neighborCol);
        
        if (neighborCell.isRevealed && neighborCell.bombsAround > 0) {
          // Count unrevealed neighbors of this revealed cell
          final unrevealedNeighbors = _getUnrevealedNeighbors(neighborRow, neighborCol);
          final flaggedNeighbors = _getFlaggedNeighbors(neighborRow, neighborCol);
          
          if (unrevealedNeighbors.isNotEmpty) {
            // Calculate local probability
            final remainingMines = neighborCell.bombsAround - flaggedNeighbors.length;
            final localProbability = remainingMines / unrevealedNeighbors.length;
            totalProbability += localProbability;
            neighborCount++;
          }
        }
      }
      
      if (neighborCount > 0) {
        final avgProbability = totalProbability / neighborCount;
        probabilityMap['($row, $col)'] = avgProbability;
      } else {
        probabilityMap['($row, $col)'] = 0.3; // Neutral probability
      }
    }
    
    return probabilityMap;
  }

  /// Get revealed neighbors of a cell
  List<List<int>> _getRevealedNeighbors(int row, int col) {
    final neighbors = <List<int>>[];
    
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        
        final nr = row + dr;
        final nc = col + dc;
        
        if (_isValidPosition(nr, nc)) {
          final cell = _gameState!.getCell(nr, nc);
          if (cell.isRevealed) {
            neighbors.add([nr, nc]);
          }
        }
      }
    }
    
    return neighbors;
  }

  /// Get unrevealed neighbors of a cell
  List<List<int>> _getUnrevealedNeighbors(int row, int col) {
    final neighbors = <List<int>>[];
    
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        
        final nr = row + dr;
        final nc = col + dc;
        
        if (_isValidPosition(nr, nc)) {
          final cell = _gameState!.getCell(nr, nc);
          if (cell.isUnrevealed && !cell.isFlagged) {
            neighbors.add([nr, nc]);
          }
        }
      }
    }
    
    return neighbors;
  }

  /// Get flagged neighbors of a cell
  List<List<int>> _getFlaggedNeighbors(int row, int col) {
    final neighbors = <List<int>>[];
    
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        
        final nr = row + dr;
        final nc = col + dc;
        
        if (_isValidPosition(nr, nc)) {
          final cell = _gameState!.getCell(nr, nc);
          if (cell.isFlagged) {
            neighbors.add([nr, nc]);
          }
        }
      }
    }
    
    return neighbors;
  }

  /// Check if position is valid
  bool _isValidPosition(int row, int col) {
    if (_gameState == null) return false;
    return row >= 0 && row < _gameState!.board.length &&
           col >= 0 && col < _gameState!.board[0].length;
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