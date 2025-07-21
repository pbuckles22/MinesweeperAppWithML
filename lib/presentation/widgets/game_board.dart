import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/cell.dart';
import '../../domain/entities/game_state.dart';
import '../providers/game_provider.dart';
import '../../services/timer_service.dart';
import 'cell_widget.dart';
import '../../core/feature_flags.dart';

class GameBoard extends StatefulWidget {
  final double bottomBarHeight;
  const GameBoard({Key? key, required this.bottomBarHeight}) : super(key: key);

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  double _zoomLevel = 1.0;
  static const double _minZoom = 0.5;
  static const double _maxZoom = 3.0;
  static const double _zoomStep = 0.05;
  String? _lastBoardKey; // Track board size changes
  
  // GlobalKeys for measuring header, zoom controls, board, expanded, grid, and bottom bar
  final GlobalKey _headerKey = GlobalKey();
  final GlobalKey _zoomKey = GlobalKey();
  final GlobalKey _expandedKey = GlobalKey();
  final GlobalKey _boardContainerKey = GlobalKey();
  final GlobalKey _gridViewKey = GlobalKey();
  double _headerHeight = 80.0; // fallback
  double _zoomControlsHeight = 60.0; // fallback
  
  double _lastExpandedHeight = 0.0;
  double _lastBoardContainerHeight = 0.0;
  double _lastGridViewHeight = 0.0;

  // Calculate optimal cell size based on available height and board rows
  double _calculateOptimalCellSize(BuildContext context, GameState gameState) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = MediaQuery.of(context).padding.top + kToolbarHeight;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final verticalPadding = 0.0; // Set to 0.0 for perfect fit
    final headerHeight = _headerHeight;
    final zoomControlsHeight = _zoomControlsHeight;
    final bottomBarHeight = widget.bottomBarHeight;
    final availableHeight = screenHeight - appBarHeight - headerHeight - zoomControlsHeight - bottomPadding - verticalPadding - bottomBarHeight;
    const minCellSize = 20.0;
    const maxCellSize = 80.0;
    final spacing = 2.0 * _zoomLevel;
    final totalSpacing = (gameState.rows - 1) * spacing;
    final optimalCellSize = (availableHeight - totalSpacing) / gameState.rows;
    final cellSize = optimalCellSize.clamp(minCellSize, maxCellSize);
    final totalBoardHeight = cellSize * gameState.rows + totalSpacing;
    print('DEBUG: screenHeight: $screenHeight');
    print('DEBUG: appBarHeight: $appBarHeight');
    print('DEBUG: headerHeight: $headerHeight');
    print('DEBUG: zoomControlsHeight: $zoomControlsHeight');
    print('DEBUG: bottomPadding: $bottomPadding');
    print('DEBUG: verticalPadding: $verticalPadding');
    print('DEBUG: bottomBarHeight: $bottomBarHeight');
    print('DEBUG: availableHeight: $availableHeight');
    print('DEBUG: cellSize: $cellSize');
    print('DEBUG: totalBoardHeight: $totalBoardHeight');
    print('DEBUG: lastExpandedHeight: $_lastExpandedHeight');
    print('DEBUG: lastBoardContainerHeight: $_lastBoardContainerHeight');
    print('DEBUG: lastGridViewHeight: $_lastGridViewHeight');
    return cellSize;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final gameState = gameProvider.gameState;
        
        if (gameState == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        // Reset zoom level when game state changes (new game, different difficulty)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Check if this is a new game state (different board size)
          final currentBoardKey = '${gameState.rows}x${gameState.columns}';
          if (_lastBoardKey != currentBoardKey) {
            _lastBoardKey = currentBoardKey;
            _resetZoomLevel();
          }
          // Measure header and zoom controls heights
          final headerContext = _headerKey.currentContext;
          final zoomContext = _zoomKey.currentContext;
          final headerHeight = headerContext?.size?.height;
          final zoomHeight = zoomContext?.size?.height;
          if (headerHeight != null && headerHeight != _headerHeight) {
            setState(() {
              _headerHeight = headerHeight;
            });
            print('DEBUG: Measured header height: $_headerHeight');
          }
          if (zoomHeight != null && zoomHeight != _zoomControlsHeight) {
            setState(() {
              _zoomControlsHeight = zoomHeight;
            });
            print('DEBUG: Measured zoom controls height: $_zoomControlsHeight');
          }
          // Measure Expanded parent and board container heights
          final expandedContext = _expandedKey.currentContext;
          final boardContainerContext = _boardContainerKey.currentContext;
          final gridViewContext = _gridViewKey.currentContext;
          final expandedHeight = expandedContext?.size?.height;
          final boardContainerHeight = boardContainerContext?.size?.height;
          final gridViewHeight = gridViewContext?.size?.height;
          if (expandedHeight != null && expandedHeight != _lastExpandedHeight) {
            setState(() {
              _lastExpandedHeight = expandedHeight;
            });
            print('DEBUG: Measured Expanded height: $_lastExpandedHeight');
          }
          if (boardContainerHeight != null && boardContainerHeight != _lastBoardContainerHeight) {
            setState(() {
              _lastBoardContainerHeight = boardContainerHeight;
            });
            print('DEBUG: Measured board container height: $_lastBoardContainerHeight');
          }
          if (gridViewHeight != null && gridViewHeight != _lastGridViewHeight) {
            setState(() {
              _lastGridViewHeight = gridViewHeight;
            });
            print('DEBUG: Measured GridView height: $_lastGridViewHeight');
          }
        });

        return Column(
          children: [
            // Game header with stats
            Center(
              child: Container(
                key: _headerKey,
                width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
                child: _buildGameHeader(context, gameProvider),
              ),
            ),
            
            // Game board with zoom - constrained to available space
            Expanded(
              key: _expandedKey,
              child: _buildBoardWithZoom(context, gameProvider, gameState),
            ),
            
            // Zoom controls - directly above bottom bar
            Container(
              key: _zoomKey,
              child: _buildZoomControls(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGameHeader(BuildContext context, GameProvider gameProvider) {
    final gameState = gameProvider.gameState!;
    final stats = gameProvider.getGameStatistics();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Mine counter
          _buildStatCard(
            context,
            'Mines',
            '${gameProvider.getRemainingMines()}',
            Icons.warning,
          ),
          
          // Timer with continuous updates
          Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              final elapsed = gameProvider.timerService.elapsed;
              final timeString = '${elapsed.inMinutes.toString().padLeft(2, '0')}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}';
              return _buildStatCard(
                context,
                'Time',
                timeString,
                Icons.timer,
              );
            },
          ),
          
          // Progress
          _buildStatCard(
            context,
            'Progress',
            _progressString(gameState.progressPercentage),
            Icons.bar_chart,
          ),
        ],
      ),
    );
  }

  Widget _buildZoomControls(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: _zoomOut,
            icon: const Icon(Icons.zoom_out),
            tooltip: 'Zoom Out',
            iconSize: 20,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '${(_zoomLevel * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: _zoomIn,
            icon: const Icon(Icons.zoom_in),
            tooltip: 'Zoom In',
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildBoardWithZoom(BuildContext context, GameProvider gameProvider, GameState gameState) {
    final spacing = 2.0 * _zoomLevel;
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final baseCellSize = (availableHeight - (gameState.rows - 1) * spacing) / gameState.rows;
        final cellSize = baseCellSize * _zoomLevel;
        final totalBoardHeight = cellSize * gameState.rows + (gameState.rows - 1) * spacing;
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onScaleStart: (details) {
            if (details.pointerCount > 1) {}
          },
          onScaleUpdate: (details) {
            if (details.pointerCount > 1 && details.scale != 1.0) {
              setState(() {
                double scaleFactor;
                if (details.scale > 1.0) {
                  scaleFactor = 1.005;
                } else {
                  scaleFactor = 0.995;
                }
                _zoomLevel = (_zoomLevel * scaleFactor).clamp(_minZoom, _maxZoom);
              });
            }
          },
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
                child: Container(
                  key: _boardContainerKey,
                  width: gameState.columns * cellSize + (gameState.columns - 1) * spacing,
                  height: totalBoardHeight,
                  child: GridView.builder(
                    key: _gridViewKey,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gameState.columns,
                      childAspectRatio: 1.0,
                      mainAxisSpacing: spacing,
                      crossAxisSpacing: spacing,
                    ),
                    itemCount: gameState.rows * gameState.columns,
                    itemBuilder: (context, index) {
                      final row = index ~/ gameState.columns;
                      final col = index % gameState.columns;
                      return SizedBox(
                        width: cellSize,
                        height: cellSize,
                        child: CellWidget(
                          row: row,
                          col: col,
                          onTap: () {
                            final is5050Cell = gameProvider.isCellIn5050Situation(row, col);
                            final is5050SafeMoveEnabled = FeatureFlags.enable5050SafeMove;
                            if (is5050Cell && is5050SafeMoveEnabled) {
                              gameProvider.execute5050SafeMove(row, col);
                            } else {
                              gameProvider.revealCell(row, col);
                            }
                          },
                          onLongPress: () => gameProvider.toggleFlag(row, col),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon) {
    return Card(
      color: Colors.transparent, // Make card background transparent
      elevation: 0, // Remove shadow
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  void _zoomIn() {
    if (_zoomLevel < _maxZoom) {
      setState(() {
        _zoomLevel = (_zoomLevel + _zoomStep).clamp(_minZoom, _maxZoom);
      });
    }
  }

  void _zoomOut() {
    if (_zoomLevel > _minZoom) {
      setState(() {
        _zoomLevel = (_zoomLevel - _zoomStep).clamp(_minZoom, _maxZoom);
      });
    }
  }

  // Reset zoom level when game state changes (new game, different difficulty)
  void _resetZoomLevel() {
    setState(() {
      _zoomLevel = 1.0; // Reset to 100% zoom for optimal sizing
    });
  }

  String _progressString(double progress) {
    if (progress.isNaN || progress.isInfinite || progress < 0) return '0%';
    final percent = (progress * 100).clamp(0, 100).toInt();
    return '$percent%';
  }
} 