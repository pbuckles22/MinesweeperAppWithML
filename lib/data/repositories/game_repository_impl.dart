import 'dart:math';
import '../../domain/repositories/game_repository.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/cell.dart';
import '../../core/constants.dart';

class GameRepositoryImpl implements GameRepository {
  GameState? _currentState;
  final Random _random = Random();

  @override
  Future<GameState> initializeGame(String difficulty) async {
    final config = GameConstants.difficultyLevels[difficulty] ?? 
                   GameConstants.difficultyLevels['custom']!;
    
    final rows = config['rows']!;
    final columns = config['columns']!;
    final mines = config['mines']!;
    
    // Create empty board
    final board = List.generate(rows, (row) {
      return List.generate(columns, (col) {
        return Cell(row: row, col: col, hasBomb: false);
      });
    });
    
    // Place mines
    final actualMines = mines > 0 ? mines : _calculateMines(rows, columns);
    _placeMines(board, actualMines);
    
    // Calculate bomb counts
    _calculateBombCounts(board);
    
    _currentState = GameState(
      board: board,
      gameStatus: GameConstants.gameStatePlaying,
      minesCount: actualMines,
      flaggedCount: 0,
      revealedCount: 0,
      totalCells: rows * columns,
      startTime: DateTime.now(),
      difficulty: difficulty,
    );
    
    return _currentState!;
  }

  @override
  Future<GameState> revealCell(int row, int col) async {
    if (_currentState == null || _currentState!.isGameOver) {
      throw StateError('Game not initialized or already over');
    }
    
    if (!_currentState!.isValidPosition(row, col)) {
      throw RangeError('Invalid position ($row, $col)');
    }
    
    final cell = _currentState!.getCell(row, col);
    if (cell.isRevealed || cell.isFlagged) {
      return _currentState!; // No action needed
    }
    
    // Create a copy of the board to modify
    final newBoard = _copyBoard(_currentState!.board);
    final newCell = newBoard[row][col];
    
    // Reveal the cell
    newCell.reveal();
    
    if (newCell.isExploded) {
      // Game over - reveal all mines
      _revealAllMines(newBoard);
      _currentState = _currentState!.copyWith(
        board: newBoard,
        gameStatus: GameConstants.gameStateLost,
        endTime: DateTime.now(),
      );
    } else {
      // Safe reveal - cascade if empty
      if (newCell.isEmpty) {
        print('Cell is empty, calling cascade');
        _cascadeReveal(newBoard, row, col);
      }
      
      // Count revealed and flagged cells
      final counts = _countCells(newBoard);
      
      // Check for win
      final isWon = counts['revealed'] == (_currentState!.totalCells - _currentState!.minesCount);
      
      _currentState = _currentState!.copyWith(
        board: newBoard,
        gameStatus: isWon ? GameConstants.gameStateWon : GameConstants.gameStatePlaying,
        revealedCount: counts['revealed'],
        flaggedCount: counts['flagged'],
        endTime: isWon ? DateTime.now() : null,
      );
    }
    
    return _currentState!;
  }

  @override
  Future<GameState> toggleFlag(int row, int col) async {
    if (_currentState == null || _currentState!.isGameOver) {
      throw StateError('Game not initialized or already over');
    }
    
    if (!_currentState!.isValidPosition(row, col)) {
      throw RangeError('Invalid position ($row, $col)');
    }
    
    final cell = _currentState!.getCell(row, col);
    if (cell.isRevealed) {
      return _currentState!; // Cannot flag revealed cells
    }
    
    // Create a copy of the board to modify
    final newBoard = _copyBoard(_currentState!.board);
    final newCell = newBoard[row][col];
    
    // Toggle flag
    newCell.toggleFlag();
    
    // Count flagged cells
    final counts = _countCells(newBoard);
    
    _currentState = _currentState!.copyWith(
      board: newBoard,
      flaggedCount: counts['flagged'],
    );
    
    return _currentState!;
  }

  @override
  GameState getCurrentState() {
    if (_currentState == null) {
      throw StateError('Game not initialized');
    }
    return _currentState!;
  }

  @override
  bool isGameWon() {
    return _currentState?.isWon ?? false;
  }

  @override
  bool isGameLost() {
    return _currentState?.isLost ?? false;
  }

  @override
  int getRemainingMines() {
    return _currentState?.remainingMines ?? 0;
  }

  @override
  Map<String, dynamic> getGameStatistics() {
    if (_currentState == null) {
      return {};
    }
    
    return {
      'difficulty': _currentState!.difficulty,
      'minesCount': _currentState!.minesCount,
      'flaggedCount': _currentState!.flaggedCount,
      'revealedCount': _currentState!.revealedCount,
      'remainingMines': _currentState!.remainingMines,
      'progressPercentage': _currentState!.progressPercentage,
      'gameDuration': _currentState!.gameDuration?.inSeconds,
      'isGameOver': _currentState!.isGameOver,
      'isWon': _currentState!.isWon,
      'isLost': _currentState!.isLost,
    };
  }

  @override
  Future<GameState> resetGame() async {
    if (_currentState == null) {
      throw StateError('Game not initialized');
    }
    
    return await initializeGame(_currentState!.difficulty);
  }

  // Private helper methods

  int _calculateMines(int rows, int columns) {
    final totalCells = rows * columns;
    final probability = GameConstants.defaultBombProbability / GameConstants.defaultMaxProbability;
    return (totalCells * probability).round();
  }

  void _placeMines(List<List<Cell>> board, int mineCount) {
    final rows = board.length;
    final columns = board[0].length;
    final totalCells = rows * columns;
    
    if (mineCount > totalCells) {
      throw ArgumentError('Too many mines for board size');
    }
    
    // Create list of all positions
    final positions = <int>[];
    for (int i = 0; i < totalCells; i++) {
      positions.add(i);
    }
    
    // Shuffle and place mines
    positions.shuffle(_random);
    for (int i = 0; i < mineCount; i++) {
      final pos = positions[i];
      final row = pos ~/ columns;
      final col = pos % columns;
      board[row][col] = board[row][col].copyWith(hasBomb: true);
    }
  }

  void _calculateBombCounts(List<List<Cell>> board) {
    final rows = board.length;
    final columns = board[0].length;
    
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        if (!board[row][col].hasBomb) {
          int count = 0;
          for (int dr = -1; dr <= 1; dr++) {
            for (int dc = -1; dc <= 1; dc++) {
              if (dr == 0 && dc == 0) continue;
              final nr = row + dr;
              final nc = col + dc;
              if (nr >= 0 && nr < rows && nc >= 0 && nc < columns) {
                if (board[nr][nc].hasBomb) count++;
              }
            }
          }
          board[row][col] = board[row][col].copyWith(bombsAround: count);
        }
      }
    }
  }

  // Public for testing
  void revealCascade(List<List<Cell>> board, int row, int col) {
    if (row < 0 || row >= board.length || col < 0 || col >= board[0].length) return;
    final cell = board[row][col];
    if (cell.isRevealed || cell.isFlagged) return;
    print('Revealing cell at ($row, $col), isEmpty: ${cell.isEmpty}');
    cell.reveal();
    if (cell.isEmpty) {
      print('Cell is empty, checking neighbors...');
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          final nr = row + dr;
          final nc = col + dc;
          if (nr < 0 || nr >= board.length || nc < 0 || nc >= board[0].length) continue;
          final neighbor = board[nr][nc];
          print('Checking neighbor at ($nr, $nc): isRevealed=${neighbor.isRevealed}, isFlagged=${neighbor.isFlagged}');
          if (!neighbor.isRevealed && !neighbor.isFlagged) {
            print('Revealing neighbor at ($nr, $nc)');
            neighbor.reveal();
            if (neighbor.isEmpty) {
              print('Neighbor is empty, recursing...');
              revealCascade(board, nr, nc);
            }
          }
        }
      }
    }
  }

  // Old cascade logic (used in app, will be replaced)
  void _cascadeReveal(List<List<Cell>> board, int row, int col) {
    revealCascade(board, row, col);
  }

  void _revealAllMines(List<List<Cell>> board) {
    for (int row = 0; row < board.length; row++) {
      for (int col = 0; col < board[0].length; col++) {
        final cell = board[row][col];
        if (cell.hasBomb && !cell.isFlagged) {
          cell.forceReveal();
        }
      }
    }
  }

  List<List<Cell>> _copyBoard(List<List<Cell>> board) {
    return board.map((row) => row.map((cell) => cell.copyWith()).toList()).toList();
  }

  Map<String, int> _countCells(List<List<Cell>> board) {
    int revealed = 0;
    int flagged = 0;
    
    for (final row in board) {
      for (final cell in row) {
        if (cell.isRevealed) revealed++;
        if (cell.isFlagged) flagged++;
      }
    }
    
    return {'revealed': revealed, 'flagged': flagged};
  }
} 