import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/cell.dart';
import '../../domain/entities/game_state.dart';
import '../providers/game_provider.dart';
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
  static const double _zoomStep = 0.1;

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

        return Stack(
          children: [
            // Main game content
            Column(
              children: [
                // Game header with stats
                _buildGameHeader(context, gameProvider),
                
                // Game board with zoom
                Expanded(
                  child: _buildBoardWithZoom(context, gameProvider, gameState),
                ),
              ],
            ),
            
            // Zoom controls - always visible, positioned at top-right
            Positioned(
              top: 16.0,
              right: 16.0,
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
      padding: const EdgeInsets.all(16.0),
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
            builder: (context, provider, child) {
              final elapsed = provider.timerService.elapsed;
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
    return GestureDetector(
      onScaleStart: (details) {
        // Store initial zoom level for pinch gesture
      },
      onScaleUpdate: (details) {
        // Handle pinch-to-zoom
        if (details.scale != 1.0) {
          setState(() {
            _zoomLevel = (_zoomLevel * details.scale).clamp(_minZoom, _maxZoom);
          });
        }
      },
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: SizedBox(
            width: gameState.columns * 40 * _zoomLevel, // Fixed cell size * zoom
            height: gameState.rows * 40 * _zoomLevel,   // Fixed cell size * zoom
            child: Transform.scale(
              scale: _zoomLevel,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(8.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gameState.columns,
                  childAspectRatio: 1.0,
                ),
                itemCount: gameState.rows * gameState.columns,
                itemBuilder: (context, index) {
                  final row = index ~/ gameState.columns;
                  final col = index % gameState.columns;
                  
                  return CellWidget(
                    row: row,
                    col: col,
                    onTap: () => gameProvider.revealCell(row, col),
                    onLongPress: () => gameProvider.toggleFlag(row, col),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon) {
    return Card(
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