import '../entities/game_state.dart';
import '../entities/cell.dart';

abstract class GameRepository {
  /// Initialize a new game with the specified difficulty
  Future<GameState> initializeGame(String difficulty);
  
  /// Reveal a cell at the specified position
  Future<GameState> revealCell(int row, int col);
  
  /// Toggle flag on a cell at the specified position
  Future<GameState> toggleFlag(int row, int col);
  
  /// Get the current game state
  GameState getCurrentState();
  
  /// Check if the game is won
  bool isGameWon();
  
  /// Check if the game is lost
  bool isGameLost();
  
  /// Get the number of remaining mines
  int getRemainingMines();
  
  /// Get game statistics
  Map<String, dynamic> getGameStatistics();
  
  /// Reset the game
  Future<GameState> resetGame();
} 