import 'package:flutter/foundation.dart';
import '../models/api_log.dart';

/// Manages the in-memory log of HTTP requests and controls console visibility.
class NetworkLogController extends ChangeNotifier {
  final List<ApiLog> _logs = [];
  ApiLog? _selectedLog;
  bool _showConsole = true;

  List<ApiLog> get logs => List.unmodifiable(_logs);
  ApiLog? get selectedLog => _selectedLog;
  bool get showConsole => _showConsole;

  /// Toggles visibility of the diagnostic dashboard/console.
  void toggleConsole() {
    _showConsole = !_showConsole;
    notifyListeners();
  }

  void setShowConsole(bool value) {
    if (_showConsole != value) {
      _showConsole = value;
      notifyListeners();
    }
  }

  void selectLog(ApiLog? log) {
    _selectedLog = log;
    notifyListeners();
  }

  /// Inserts a new log or updates an in-flight log when the response arrives.
  void addOrUpdateLog(ApiLog log) {
    final index = _logs.indexWhere((l) => l.id == log.id);
    if (index >= 0) {
      _logs[index] = log;
      if (_selectedLog?.id == log.id) {
        _selectedLog = log;
      }
    } else {
      _logs.insert(0, log);
      // Auto-select newest log
      _selectedLog = log;
    }
    notifyListeners();
  }

  void clearLogs() {
    _logs.clear();
    _selectedLog = null;
    notifyListeners();
  }
}
