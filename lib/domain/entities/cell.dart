enum CellState {
  unrevealed,
  revealed,
  flagged,
  exploded,
  incorrectlyFlagged,
}

class Cell {
  final bool hasBomb;
  final int bombsAround;
  CellState state;
  final int row;
  final int col;

  Cell({
    required this.hasBomb,
    this.bombsAround = 0,
    this.state = CellState.unrevealed,
    required this.row,
    required this.col,
  });

  bool get isRevealed => state == CellState.revealed;
  bool get isFlagged => state == CellState.flagged;
  bool get isExploded => state == CellState.exploded;
  bool get isUnrevealed => state == CellState.unrevealed;
  bool get isIncorrectlyFlagged => state == CellState.incorrectlyFlagged;
  bool get isEmpty => !hasBomb && bombsAround == 0;

  void reveal() {
    if (state == CellState.unrevealed) {
      state = hasBomb ? CellState.exploded : CellState.revealed;
    }
  }

  void toggleFlag() {
    if (state == CellState.unrevealed) {
      state = CellState.flagged;
    } else if (state == CellState.flagged) {
      state = CellState.unrevealed;
    }
  }

  void forceReveal({bool exploded = true, bool showIncorrectFlag = false}) {
    if (state == CellState.flagged) {
      if (showIncorrectFlag && !hasBomb) {
        // Show black X for incorrectly flagged non-mines
        state = CellState.incorrectlyFlagged;
      } else {
        // Remove flag and reveal normally
        state = CellState.unrevealed;
        if (state == CellState.unrevealed) {
          if (hasBomb) {
            state = exploded ? CellState.exploded : CellState.revealed;
          } else {
            state = CellState.revealed;
          }
        }
      }
    } else if (state == CellState.unrevealed) {
      if (hasBomb) {
        state = exploded ? CellState.exploded : CellState.revealed;
      } else {
        state = CellState.revealed;
      }
    }
  }

  Cell copyWith({
    bool? hasBomb,
    int? bombsAround,
    CellState? state,
    int? row,
    int? col,
  }) {
    return Cell(
      hasBomb: hasBomb ?? this.hasBomb,
      bombsAround: bombsAround ?? this.bombsAround,
      state: state ?? this.state,
      row: row ?? this.row,
      col: col ?? this.col,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Cell &&
        other.hasBomb == hasBomb &&
        other.bombsAround == bombsAround &&
        other.state == state &&
        other.row == row &&
        other.col == col;
  }

  @override
  int get hashCode {
    return Object.hash(hasBomb, bombsAround, state, row, col);
  }

  @override
  String toString() {
    return 'Cell(row: $row, col: $col, hasBomb: $hasBomb, bombsAround: $bombsAround, state: $state)';
  }
} 