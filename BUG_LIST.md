# Flutter Minesweeper Bug List

## 🚨 Critical Bugs

### 1. Cascade Logic Failure
**Issue**: The cascade (flood fill) logic is not working correctly. Some tiles that should be opened during cascade are not being opened.

**Location**: `lib/game_activity.dart` - `_handleTap()` method (lines ~250-290)

**Root Cause**: 
- The cascade logic only checks if the **current cell** has `bombsAround == 0` before recursing
- It should check if the **neighbor cell** has `bombsAround == 0` before recursing to that neighbor
- The logic is backwards - it's checking the wrong cell's bomb count

**Current (Broken) Logic**:
```dart
if (!board[i - 1][j].hasBomb &&
    openedSquares[((i - 1) * columnCount) + j] != true) {
  if (board[i][j].bombsAround == 0) {  // ❌ Wrong! Checking current cell
    _handleTap(i - 1, j);
  }
}
```

**Expected Logic** (based on reference environment):
```dart
if (!board[i - 1][j].hasBomb &&
    openedSquares[((i - 1) * columnCount) + j] != true) {
  if (board[i - 1][j].bombsAround == 0) {  // ✅ Check neighbor cell
    _handleTap(i - 1, j);
  }
}
```

**Impact**: 
- Large areas of safe cells remain unopened
- Game becomes much harder than intended
- Inconsistent with standard Minesweeper behavior

### 2. Flag Toggle Not Working
**Issue**: Once a bomb is flagged, it cannot be unflagged. Long-pressing a flagged cell should toggle the flag off.

**Location**: `lib/game_activity.dart` - `onLongPress` handler (lines ~130-135)

**Root Cause**:
- The flag logic only sets flags to `true`, never toggles them
- No logic to remove flags when long-pressing an already flagged cell

**Current (Broken) Logic**:
```dart
onLongPress: () {
  if (openedSquares[position] == false) {
    setState(() {
      flaggedSquares[position] = true;  // ❌ Always sets to true
    });
  }
},
```

**Expected Logic**:
```dart
onLongPress: () {
  if (openedSquares[position] == false) {
    setState(() {
      flaggedSquares[position] = !flaggedSquares[position];  // ✅ Toggle flag
    });
  }
},
```

**Impact**:
- Players cannot correct mistaken flags
- Game becomes frustrating when flags are placed incorrectly
- Inconsistent with standard Minesweeper behavior

## ⚠️ Major Issues

### 3. Inconsistent Game State Management
**Issue**: The game state is managed through multiple separate arrays (`board`, `openedSquares`, `flaggedSquares`) which can become inconsistent.

**Location**: Throughout `lib/game_activity.dart`

**Problems**:
- No validation that arrays stay in sync
- Potential for state corruption
- Difficult to debug and maintain

**Impact**: 
- Potential for game-breaking bugs
- Hard to add new features
- Poor foundation for ML integration

### 4. Missing Game Rules Validation
**Issue**: The app doesn't validate that clicked cells are actually clickable according to Minesweeper rules.

**Location**: `lib/game_activity.dart` - `onTap` handler

**Problems**:
- Can click on already opened cells
- Can click on flagged cells
- No validation of game state before actions

**Expected Behavior** (from reference environment):
- Cannot click on already revealed cells
- Cannot click on flagged cells
- Should validate action before processing

### 5. Poor Error Handling
**Issue**: No error handling for edge cases or invalid states.

**Location**: Throughout the codebase

**Problems**:
- No bounds checking in many places
- No validation of game state
- Silent failures can occur

## 🔧 Minor Issues

### 6. Inefficient Cascade Algorithm
**Issue**: The cascade algorithm uses recursion which can cause stack overflow on large boards.

**Location**: `lib/game_activity.dart` - `_handleTap()` method

**Problem**: 
- Recursive calls can exceed stack limits
- Not scalable for larger boards
- Should use iterative approach with queue/stack

### 7. Hard-coded Values
**Issue**: Many game parameters are hard-coded throughout the code.

**Location**: Throughout `lib/game_activity.dart`

**Problems**:
- `rowCount = 18`, `columnCount = 10` hard-coded
- `bombProbability = 3`, `maxProbability = 15` hard-coded
- No difficulty levels or configuration

### 8. Missing Game Features
**Issue**: Several standard Minesweeper features are missing.

**Missing Features**:
- Game timer
- Mine counter
- Difficulty levels
- Game statistics
- Sound effects
- Proper win/lose screens

## 🎯 Priority Fixes

### High Priority (Fix Immediately)
1. **Fix cascade logic** - This breaks core gameplay
2. **Fix flag toggle** - This breaks user interaction
3. **Add action validation** - Prevent invalid clicks

### Medium Priority (Fix Soon)
4. **Improve state management** - Foundation for ML integration
5. **Add error handling** - Prevent crashes
6. **Optimize cascade algorithm** - Prepare for larger boards

### Low Priority (Fix Later)
7. **Remove hard-coded values** - Add configuration
8. **Add missing features** - Improve user experience

## 🔍 Testing Required

### Cascade Logic Testing
- [ ] Test cascade on empty areas (should open all connected empty cells)
- [ ] Test cascade on edge cases (corners, edges)
- [ ] Test cascade with mixed numbered cells
- [ ] Test cascade on large boards

### Flag Logic Testing
- [ ] Test flag placement on unrevealed cells
- [ ] Test flag removal by long-pressing flagged cells
- [ ] Test flag behavior on revealed cells (should not work)
- [ ] Test flag count validation

### Game State Testing
- [ ] Test win condition validation
- [ ] Test lose condition validation
- [ ] Test invalid action handling
- [ ] Test state consistency after actions

## 📋 Reference Implementation Notes

Based on the reference environment (`minesweeper_env.py`):

### Correct Cascade Logic
```python
def _reveal_cell(self, row: int, col: int) -> None:
    if not (0 <= row < self.current_board_height and 0 <= col < self.current_board_width):
        return
    if self.revealed[row, col]:
        return

    self.revealed[row, col] = True
    cell_value = self._get_cell_value(row, col)
    self.state[0, row, col] = cell_value

    # Check if this is a cascade (cell with value 0)
    if cell_value == 0:
        # Reveal all neighbors
        for dr in [-1, 0, 1]:
            for dc in [-1, 0, 1]:
                if dr == 0 and dc == 0:
                    continue
                self._reveal_cell(row + dr, col + dc)
```

### Key Differences
1. **Cascade trigger**: Reveal neighbors when current cell value is 0 (not when neighbor value is 0)
2. **State management**: Uses proper state objects instead of separate arrays
3. **Validation**: Comprehensive action validation before processing
4. **Error handling**: Proper bounds checking and state validation

## 🚀 Next Steps

1. **Immediate**: Fix cascade and flag logic bugs
2. **Short term**: Implement proper state management
3. **Medium term**: Add comprehensive testing
4. **Long term**: Prepare for ML integration with proper architecture 