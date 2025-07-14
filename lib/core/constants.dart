class GameConstants {
  // Board dimensions
  static const int defaultRowCount = 18;
  static const int defaultColumnCount = 10;
  
  // Bomb generation
  static const int defaultBombProbability = 3;
  static const int defaultMaxProbability = 15;
  
  // Difficulty levels
  static const Map<String, Map<String, int>> difficultyLevels = {
    'beginner': {
      'rows': 9,
      'columns': 9,
      'mines': 10,
    },
    'intermediate': {
      'rows': 16,
      'columns': 16,
      'mines': 40,
    },
    'expert': {
      'rows': 16,
      'columns': 30,
      'mines': 99,
    },
    'custom': {
      'rows': defaultRowCount,
      'columns': defaultColumnCount,
      'mines': 0, // Calculated based on probability
    },
  };
  
  // Game states
  static const String gameStatePlaying = 'playing';
  static const String gameStateWon = 'won';
  static const String gameStateLost = 'lost';
  
  // Animation durations
  static const Duration tileRevealDuration = Duration(milliseconds: 150);
  static const Duration flagPlacementDuration = Duration(milliseconds: 100);
} 