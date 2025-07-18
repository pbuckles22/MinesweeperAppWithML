import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/cell.dart';
import '../../domain/entities/game_state.dart';
import '../providers/game_provider.dart';
import '../../services/timer_service.dart';
import 'cell_widget.dart';
import '../../core/feature_flags.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({Key? key}) : super(key: key);

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  double _zoomLevel = 1.0;
  static const double _minZoom = 0.5;
  static const double _maxZoom = 3.0;
  static const double _zoomStep = 0.05;

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

        return Column(
          children: [
            // Game header with stats
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
                child: _buildGameHeader(context, gameProvider),
              ),
            ),
            
            // Game board with zoom - constrained to available space
            Expanded(
              child: _buildBoardWithZoom(context, gameProvider, gameState),
            ),
            
            // Zoom controls - directly above bottom bar
            _buildZoomControls(context),
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
    // Use consistent cell size across all difficulties
    const double baseCellSize = 40.0; // Standard cell size for all difficulties
    
    final cellSize = baseCellSize * _zoomLevel;
    final spacing = 2.0 * _zoomLevel; // Scale spacing with zoom level
    
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onScaleStart: (details) {
        // Only handle multi-touch gestures for zoom
        if (details.pointerCount > 1) {
          // Store initial zoom level for pinch gesture
        }
      },
      onScaleUpdate: (details) {
        // Only handle multi-touch gestures for zoom
        if (details.pointerCount > 1 && details.scale != 1.0) {
          setState(() {
            // Use a much smaller scale factor for pinch gestures to make it less sensitive
            // Fix zoom out by properly handling scale < 1.0
            double scaleFactor;
            if (details.scale > 1.0) {
              scaleFactor = 1.005; // Zoom in
            } else {
              scaleFactor = 0.995; // Zoom out
            }
            _zoomLevel = (_zoomLevel * scaleFactor).clamp(_minZoom, _maxZoom);
          });
        }
      },
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: Container(
            width: gameState.columns * cellSize + (gameState.columns - 1) * spacing,
            height: gameState.rows * cellSize + (gameState.rows - 1) * spacing,
            child: GridView.builder(
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
                      // Check if this is a 50/50 cell and safe move is enabled
                      final is5050Cell = gameProvider.isCellIn5050Situation(row, col);
                      final is5050SafeMoveEnabled = FeatureFlags.enable5050SafeMove;
                      
                      // print('DEBUG: GameBoard onTap - Cell ($row,$col):');
                      // print('DEBUG:   isCellIn5050Situation: $is5050Cell');
                      // print('DEBUG:   enable5050SafeMove: $is5050SafeMoveEnabled');
                      // print('DEBUG:   FeatureFlags.enable5050Detection: ${FeatureFlags.enable5050Detection}');
                      
                      if (is5050Cell && is5050SafeMoveEnabled) {
                        // print('DEBUG: GameBoard onTap - Executing 50/50 safe move');
                        gameProvider.execute5050SafeMove(row, col);
                      } else {
                        // print('DEBUG: GameBoard onTap - Executing normal reveal');
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

  String _progressString(double progress) {
    if (progress.isNaN || progress.isInfinite || progress < 0) return '0%';
    final percent = (progress * 100).clamp(0, 100).toInt();
    return '$percent%';
  }
} 