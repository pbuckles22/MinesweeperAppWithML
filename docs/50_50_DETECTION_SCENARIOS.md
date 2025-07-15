# 50/50 Detection Scenarios Documentation

This document provides detailed explanations of the 50/50 detection scenarios implemented in the Minesweeper app, including test board configurations and the logic behind each scenario.

## Overview

The 50/50 detection system identifies situations where two unrevealed cells have equal probability of being mines, making it impossible to determine which one is safe using standard Minesweeper logic. The system detects two main types of 50/50 situations:

1. **Classic 50/50**: A revealed numbered cell with exactly 2 unrevealed neighbors and exactly 1 remaining mine
2. **Shared Constraint 50/50**: Two revealed cells that share exactly 2 unrevealed neighbors, with the sum of their remaining mines equaling 2

## Scenario 1: Classic Blocked 50/50

### Board Configuration
```
[F][2][ ]
[?][?][ ]
[ ][ ][ ]
```

### Detailed Explanation
This is the classic Minesweeper 50/50 pattern:
- A "2" cell has one flagged neighbor (F) and two unrevealed neighbors (?)
- The "2" needs exactly 1 more mine, but both unrevealed neighbors are equally likely
- This creates a true 50/50 situation where no logical deduction can determine which cell is safe

### Test Board Code
```dart
final board = [
  [
    Cell(row: 0, col: 0, hasBomb: true, bombsAround: 0, state: CellState.flagged),
    Cell(row: 0, col: 1, hasBomb: false, bombsAround: 2, state: CellState.revealed),
    Cell(row: 0, col: 2, hasBomb: false, bombsAround: 0, state: CellState.revealed),
  ],
  [
    Cell(row: 1, col: 0, hasBomb: false, bombsAround: 0, state: CellState.unrevealed), // candidate
    Cell(row: 1, col: 1, hasBomb: false, bombsAround: 0, state: CellState.unrevealed), // candidate
    Cell(row: 1, col: 2, hasBomb: false, bombsAround: 0, state: CellState.revealed),
  ],
  [
    Cell(row: 2, col: 0, hasBomb: false, bombsAround: 0, state: CellState.revealed),
    Cell(row: 2, col: 1, hasBomb: false, bombsAround: 0, state: CellState.revealed),
    Cell(row: 2, col: 2, hasBomb: false, bombsAround: 0, state: CellState.revealed),
  ],
];
```

### Detection Logic
- The "2" at (0,1) has 1 flagged neighbor and 2 unrevealed neighbors
- Remaining mines = 2 - 1 = 1
- Since remaining mines (1) equals unrevealed neighbors (2), this is a classic 50/50

---

## Scenario 2: Shared Constraint 50/50 (Screenshot-Matched)

### Board Configuration
```
[1][F][1][1][?][?]
[2][3][4][4][?][?]
[1][F][F][F][F][?]
[2][2][4][F][?][?]
```

### Detailed Explanation
This is a complex shared constraint 50/50 where two revealed cells share the same two unrevealed neighbors:
- The "1" at (0,3) has unrevealed neighbors: (0,4), (1,4)
- The "4" at (1,3) has 3 flagged neighbors and unrevealed neighbors: (0,4), (1,4)
- Both cells constrain the same two unrevealed cells
- The sum of remaining mines: 1 (from "1") + 1 (from "4" - 3 flags) = 2
- Since 2 remaining mines equals 2 shared unrevealed cells, this is a 50/50

### Test Board Code
```dart
final board = [
  [
    Cell(row: 0, col: 0, hasBomb: false, bombsAround: 1, state: CellState.revealed),
    Cell(row: 0, col: 1, hasBomb: true, state: CellState.flagged),
    Cell(row: 0, col: 2, hasBomb: false, bombsAround: 1, state: CellState.revealed),
    Cell(row: 0, col: 3, hasBomb: false, bombsAround: 1, state: CellState.revealed),
    Cell(row: 0, col: 4, hasBomb: false, state: CellState.unrevealed), // candidate
    Cell(row: 0, col: 5, hasBomb: false, state: CellState.unrevealed),
  ],
  [
    Cell(row: 1, col: 0, hasBomb: false, bombsAround: 2, state: CellState.revealed),
    Cell(row: 1, col: 1, hasBomb: false, bombsAround: 3, state: CellState.revealed),
    Cell(row: 1, col: 2, hasBomb: false, bombsAround: 4, state: CellState.revealed),
    Cell(row: 1, col: 3, hasBomb: false, bombsAround: 4, state: CellState.revealed),
    Cell(row: 1, col: 4, hasBomb: false, state: CellState.unrevealed), // candidate
    Cell(row: 1, col: 5, hasBomb: false, state: CellState.unrevealed),
  ],
  [
    Cell(row: 2, col: 0, hasBomb: false, bombsAround: 1, state: CellState.revealed),
    Cell(row: 2, col: 1, hasBomb: true, state: CellState.flagged),
    Cell(row: 2, col: 2, hasBomb: true, state: CellState.flagged),
    Cell(row: 2, col: 3, hasBomb: true, state: CellState.flagged),
    Cell(row: 2, col: 4, hasBomb: true, state: CellState.flagged),
    Cell(row: 2, col: 5, hasBomb: false, state: CellState.unrevealed),
  ],
  [
    Cell(row: 3, col: 0, hasBomb: false, bombsAround: 2, state: CellState.revealed),
    Cell(row: 3, col: 1, hasBomb: false, bombsAround: 2, state: CellState.revealed),
    Cell(row: 3, col: 2, hasBomb: false, bombsAround: 4, state: CellState.revealed),
    Cell(row: 3, col: 3, hasBomb: true, state: CellState.flagged),
    Cell(row: 3, col: 4, hasBomb: false, state: CellState.unrevealed),
    Cell(row: 3, col: 5, hasBomb: false, state: CellState.unrevealed),
  ],
];
```

### Detection Logic
- Find intersection of unrevealed neighbors between revealed cells
- Check if intersection length = 2 (exactly 2 shared unrevealed cells)
- Calculate sum of remaining mines for both revealed cells
- If sum equals 2, it's a shared constraint 50/50

---

## Scenario 3: False 50/50 Due to Definitely Known Mines

### Board Configuration
```
[ ][1][1][1][ ]
[ ][1][?][1][ ]
[ ][1][?][3][ ]
[?][?][?][?][?]
```

### Detailed Explanation
This scenario tests that the system correctly excludes definitely known mines from 50/50 detection:
- The cell at (1,2) is definitely a mine because the "1" at (0,2) has only one unrevealed neighbor - (1,2)
- The "1" at (0,2) needs exactly 1 mine, and (1,2) is its only unrevealed neighbor, so (1,2) must be a mine
- Since one of the candidate cells is definitely a mine, this should NOT be detected as a 50/50
- The other candidate cell at (2,2) is truly uncertain, but the 50/50 detection should be skipped

### Test Board Code
```dart
final board = [
  [
    Cell(row: 0, col: 0, hasBomb: false, bombsAround: 0, state: CellState.revealed),
    Cell(row: 0, col: 1, hasBomb: false, bombsAround: 1, state: CellState.revealed),
    Cell(row: 0, col: 2, hasBomb: false, bombsAround: 1, state: CellState.revealed),
    Cell(row: 0, col: 3, hasBomb: false, bombsAround: 1, state: CellState.revealed),
    Cell(row: 0, col: 4, hasBomb: false, bombsAround: 0, state: CellState.revealed),
  ],
  [
    Cell(row: 1, col: 0, hasBomb: false, bombsAround: 0, state: CellState.revealed),
    Cell(row: 1, col: 1, hasBomb: false, bombsAround: 1, state: CellState.revealed),
    Cell(row: 1, col: 2, hasBomb: false, bombsAround: 0, state: CellState.unrevealed), // definitely a mine
    Cell(row: 1, col: 3, hasBomb: false, bombsAround: 1, state: CellState.revealed),
    Cell(row: 1, col: 4, hasBomb: false, bombsAround: 0, state: CellState.revealed),
  ],
  [
    Cell(row: 2, col: 0, hasBomb: false, bombsAround: 0, state: CellState.revealed),
    Cell(row: 2, col: 1, hasBomb: false, bombsAround: 1, state: CellState.revealed),
    Cell(row: 2, col: 2, hasBomb: false, bombsAround: 0, state: CellState.unrevealed), // candidate
    Cell(row: 2, col: 3, hasBomb: false, bombsAround: 3, state: CellState.revealed),
    Cell(row: 2, col: 4, hasBomb: false, bombsAround: 0, state: CellState.revealed),
  ],
  [
    Cell(row: 3, col: 0, hasBomb: false, bombsAround: 0, state: CellState.unrevealed),
    Cell(row: 3, col: 1, hasBomb: false, bombsAround: 0, state: CellState.unrevealed),
    Cell(row: 3, col: 2, hasBomb: false, bombsAround: 0, state: CellState.unrevealed),
    Cell(row: 3, col: 3, hasBomb: false, bombsAround: 0, state: CellState.unrevealed),
    Cell(row: 3, col: 4, hasBomb: false, bombsAround: 0, state: CellState.unrevealed),
  ],
];
```

### Detection Logic
- The definitely mine detection identifies cells that are definitely mines based on individual revealed cells
- If either candidate cell is in the definitely mine list, the 50/50 detection is skipped
- This prevents false positives when one candidate is logically determined to be a mine

---

## Scenario 4: Multiple 50/50s (Combined Scenarios)

### Board Configuration
This scenario combines Scenario 1 (classic 50/50) and Scenario 2 (shared constraint 50/50) on a large board to test that only one 50/50 is returned when multiple exist.

### Test Logic
- The system should detect both 50/50 situations
- But the current implementation returns only one 50/50 to avoid overwhelming the user
- This tests the "single 50/50" behavior when multiple valid 50/50s exist

---

## Scenario 5: Multiple Independent Classic 50/50s

### Board Configuration
```
[1][2][2][2][2]
[F][3][F][F][1]
[?][?][4][3][1]
[?][?][F][1][0]
[?][?][3][2][2]
```

### Detailed Explanation
This scenario tests that the system can detect multiple independent classic 50/50 situations on the same board:

**First 50/50 (Row 2):**
- The "3" at (1,1) has 2 flagged neighbors and 2 unrevealed neighbors
- The 2 unrevealed neighbors at (2,0) and (2,1) form a classic 50/50
- Remaining mines: 3 - 2 flags = 1 mine needed

**Second 50/50 (Row 4):**
- The "3" at (4,2) has 3 mines and 2 unrevealed neighbors
- The 2 unrevealed neighbors at (4,0) and (4,1) form a classic 50/50
- Remaining mines: 3 - 0 flags = 3 mines needed, but only 2 unrevealed neighbors

Both 50/50s are independent of each other and should be detected by the same classic 50/50 logic. The system should return one of the valid 50/50 cells.

### Test Code
```dart
final board = [
  [
    Cell(row: 0, col: 0, hasBomb: false, bombsAround: 1, state: CellState.revealed),
    Cell(row: 0, col: 1, hasBomb: false, bombsAround: 2, state: CellState.revealed),
    Cell(row: 0, col: 2, hasBomb: false, bombsAround: 2, state: CellState.revealed),
    Cell(row: 0, col: 3, hasBomb: false, bombsAround: 2, state: CellState.revealed),
    Cell(row: 0, col: 4, hasBomb: false, bombsAround: 2, state: CellState.revealed),
  ],
  [
    Cell(row: 1, col: 0, hasBomb: true, bombsAround: 0, state: CellState.flagged),
    Cell(row: 1, col: 1, hasBomb: false, bombsAround: 3, state: CellState.revealed),
    Cell(row: 1, col: 2, hasBomb: true, bombsAround: 0, state: CellState.flagged),
    Cell(row: 1, col: 3, hasBomb: true, bombsAround: 0, state: CellState.flagged),
    Cell(row: 1, col: 4, hasBomb: false, bombsAround: 1, state: CellState.revealed),
  ],
  [
    Cell(row: 2, col: 0, hasBomb: false, bombsAround: 0, state: CellState.unrevealed), // 50/50 candidate 1
    Cell(row: 2, col: 1, hasBomb: false, bombsAround: 0, state: CellState.unrevealed), // 50/50 candidate 1
    Cell(row: 2, col: 2, hasBomb: false, bombsAround: 4, state: CellState.revealed),
    Cell(row: 2, col: 3, hasBomb: false, bombsAround: 3, state: CellState.revealed),
    Cell(row: 2, col: 4, hasBomb: false, bombsAround: 1, state: CellState.revealed),
  ],
  [
    Cell(row: 3, col: 0, hasBomb: false, bombsAround: 0, state: CellState.unrevealed),
    Cell(row: 3, col: 1, hasBomb: false, bombsAround: 0, state: CellState.unrevealed),
    Cell(row: 3, col: 2, hasBomb: true, bombsAround: 0, state: CellState.flagged),
    Cell(row: 3, col: 3, hasBomb: false, bombsAround: 1, state: CellState.revealed),
    Cell(row: 3, col: 4, hasBomb: false, bombsAround: 0, state: CellState.revealed),
  ],
  [
    Cell(row: 4, col: 0, hasBomb: false, bombsAround: 0, state: CellState.unrevealed), // 50/50 candidate 2
    Cell(row: 4, col: 1, hasBomb: false, bombsAround: 0, state: CellState.unrevealed), // 50/50 candidate 2
    Cell(row: 4, col: 2, hasBomb: false, bombsAround: 3, state: CellState.revealed),
    Cell(row: 4, col: 3, hasBomb: false, bombsAround: 2, state: CellState.revealed),
    Cell(row: 4, col: 4, hasBomb: false, bombsAround: 2, state: CellState.revealed),
  ],
];
```

### Expected Behavior
- Should detect at least one of the two 50/50 situations
- Both 50/50s are independent and should be found by the same classic 50/50 logic
- The system should return one valid 50/50 cell from either scenario

---

## Classic 50/50 Detection Logic Update
- Classic 50/50 detection **no longer requires candidate cells to be "blocked"** (i.e., only constrained by one revealed cell).
- Any revealed numbered cell with exactly 2 unrevealed neighbors and exactly 1 remaining mine will be detected as a classic 50/50, even if those cells have other revealed neighbors.
- The system supports multiple independent classic 50/50s on the same board (though only one is returned at a time).

---

## Implementation Details

### Key Detection Methods

1. **`_findDefinitelyMineCells()`**: Identifies cells that are definitely mines based on individual revealed cells
2. **`_detectClassic5050()`**: Detects classic 50/50 patterns (1 revealed cell, 2 unrevealed neighbors, 1 remaining mine)
3. **`_detectSharedConstraint5050()`**: Detects shared constraint 50/50s (2 revealed cells sharing 2 unrevealed neighbors)

### Debug Output
The system provides detailed debug output showing:
- Trigger cell analysis (number, unrevealed neighbors, flagged count)
- Intersection calculations for shared constraints
- Remaining mine calculations
- 50/50 detection decisions

### Test Coverage
Each scenario is thoroughly tested with:
- Positive tests (should detect 50/50)
- Negative tests (should NOT detect 50/50)
- Edge cases and boundary conditions
- Performance tests for large boards

---

## Future Enhancements

Potential improvements to consider:
1. **Advanced 50/50 patterns**: More complex constraint patterns
2. **Probability calculations**: Assigning confidence scores to 50/50 detections
3. **User preferences**: Allow users to configure 50/50 detection sensitivity
4. **Visual indicators**: Different UI treatments for different types of 50/50s

---

## Orientation-Agnostic Testing
To ensure the 50/50 detection logic is robust and not biased by board orientation, the test suite includes mirrored (left-right flipped) and rotated (upside-down) versions of key scenarios. For every new 50/50 scenario, consider adding mirrored and/or rotated versions to future-proof against directional bias in the detection logic.

**Current Coverage:**
- Scenario 1: Original, Mirrored (left-right), and Rotated (upside-down) versions
- Future scenarios should follow the same pattern for comprehensive testing

*This documentation should be updated whenever new 50/50 scenarios are added or existing logic is modified.* 