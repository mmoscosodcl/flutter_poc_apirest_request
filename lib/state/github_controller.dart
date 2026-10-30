import 'package:flutter/foundation.dart';
import '../models/github_user.dart';
import '../services/github_service.dart';
import 'network_log_controller.dart';

class GitHubController extends ChangeNotifier {
  final GitHubService _service;
  final NetworkLogController logController;

  GitHubController({
    GitHubService? service,
    required this.logController,
  })  : _service = service ?? GitHubService();

  GitHubUser? _user;
  bool _isLoading = false;
  String? _errorMessage;
  int? _lastStatusCode;

  GitHubUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get lastStatusCode => _lastStatusCode;

  Future<void> fetchUser({
    String? username,
    String? token,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.fetchUser(
        username: username,
        token: token,
        onLog: (log) {
          logController.addOrUpdateLog(log);
          if (!log.isLoading) {
            _lastStatusCode = log.statusCode;
          }
        },
      );
      _user = result;
      _errorMessage = null;
    } catch (e) {
      _user = null;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Preset 1: Valid Public User (HTTP 200 OK)
  Future<void> loadFlutterUser() => fetchUser(username: 'flutter');

  /// Preset 2: Valid Public User (HTTP 200 OK)
  Future<void> loadTorvaldsUser() => fetchUser(username: 'torvalds');

  /// Preset 3: User Not Found (HTTP 404 Not Found)
  Future<void> loadNonExistentUser() =>
      fetchUser(username: 'non-existent-user-test-xyz-999');

  /// Preset 4: Invalid Authentication Token (HTTP 401 Unauthorized)
  Future<void> loadInvalidAuthToken() =>
      fetchUser(token: 'ghp_invalid_dummy_token_1234567890');
}
