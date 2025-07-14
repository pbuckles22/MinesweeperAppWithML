import 'dart:async';
import 'package:flutter/foundation.dart';

class TimerService extends ChangeNotifier {
  Timer? _timer;
  DateTime? _startTime;
  Duration _elapsed = Duration.zero;
  bool _isRunning = false;

  Duration get elapsed => _elapsed;
  bool get isRunning => _isRunning;

  void start() {
    if (_isRunning) return;
    
    _startTime = DateTime.now();
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateElapsed();
    });
    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    notifyListeners();
  }

  void reset() {
    stop();
    _elapsed = Duration.zero;
    _startTime = null;
    notifyListeners();
  }

  void _updateElapsed() {
    if (_startTime != null) {
      _elapsed = DateTime.now().difference(_startTime!);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
} 