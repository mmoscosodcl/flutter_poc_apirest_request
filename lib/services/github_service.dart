import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/api_log.dart';
import '../models/github_user.dart';
import '../models/github_repo.dart';

class GitHubService {
  final http.Client _client;

  GitHubService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches a GitHub user profile.
  ///
  /// Can be called without authentication ([token] is null),
  /// or with authentication ([token] provided as Bearer token).
  ///
  /// If [username] is provided, queries `https://api.github.com/users/$username`.
  /// If [username] is empty and [token] is provided, queries `https://api.github.com/user`.
  Future<GitHubUser> fetchUser({
    String? username,
    String? token,
    required void Function(ApiLog) onLog,
  }) async {
    final cleanUsername = username?.trim();
    final cleanToken = token?.trim();

    final Uri uri;
    if (cleanUsername != null && cleanUsername.isNotEmpty) {
      uri = Uri.parse('https://api.github.com/users/$cleanUsername');
    } else {
      uri = Uri.parse('https://api.github.com/user');
    }

    final requestHeaders = <String, String>{
      'Accept': 'application/vnd.github+json',
      'User-Agent': 'Flutter-PoC-ApiRest/1.0',
      'X-GitHub-Api-Version': '2022-11-28',
    };

    if (cleanToken != null && cleanToken.isNotEmpty) {
      requestHeaders['Authorization'] = 'Bearer $cleanToken';
    }

    final logId = DateTime.now().microsecondsSinceEpoch.toString();

    // 1. Log in-flight request
    var log = ApiLog(
      id: logId,
      timestamp: DateTime.now(),
      method: 'GET',
      url: uri.toString(),
      requestHeaders: requestHeaders,
      isLoading: true,
    );
    onLog(log);

    final stopwatch = Stopwatch()..start();

    try {
      final response = await _client
          .get(uri, headers: requestHeaders)
          .timeout(const Duration(seconds: 10));

      stopwatch.stop();

      final responseHeaders = Map<String, String>.from(response.headers);

      log = log.copyWith(
        isLoading: false,
        statusCode: response.statusCode,
        statusPhrase: response.reasonPhrase,
        durationMs: stopwatch.elapsedMilliseconds,
        responseHeaders: responseHeaders,
        responseBody: response.body,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        onLog(log);
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        return GitHubUser.fromJson(decoded);
      } else {
        String errorMsg =
            'HTTP ${response.statusCode}: ${response.reasonPhrase}';
        try {
          final errorJson = json.decode(response.body) as Map<String, dynamic>;
          if (errorJson.containsKey('message')) {
            errorMsg = errorJson['message'].toString();
          }
        } catch (_) {}

        if (response.statusCode == 401) {
          errorMsg =
              '401 Unauthorized: $errorMsg (Check your token credentials)';
        } else if (response.statusCode == 404) {
          errorMsg = '404 Not Found: User "$cleanUsername" does not exist.';
        } else if (response.statusCode == 403 &&
            responseHeaders.containsKey('x-ratelimit-remaining') &&
            responseHeaders['x-ratelimit-remaining'] == '0') {
          errorMsg = '403 Forbidden: GitHub API rate limit exceeded for your IP address.';
        }

        log = log.copyWith(errorMessage: errorMsg);
        onLog(log);
        throw Exception(errorMsg);
      }
    } on TimeoutException {
      stopwatch.stop();
      log = log.copyWith(
        isLoading: false,
        durationMs: stopwatch.elapsedMilliseconds,
        errorMessage: 'Request timed out after 10 seconds.',
      );
      onLog(log);
      throw Exception('Request timed out after 10s.');
    } catch (e) {
      if (stopwatch.isRunning) {
        stopwatch.stop();
      }
      if (log.statusCode == null) {
        log = log.copyWith(
          isLoading: false,
          durationMs: stopwatch.elapsedMilliseconds,
          errorMessage: e.toString(),
        );
        onLog(log);
      }
      rethrow;
    }
  }

  // Busca repositorios públicos en GitHub ordenados por cantidad de estrellas.
  Future<List<GitHubRepo>> searchRepositories(
    String query, {
    required void Function(ApiLog) onLog,
  }) async {
    final cleanQuery = query.trim();

    if (cleanQuery.isEmpty) {
      throw ArgumentError('Search query cannot be empty.');
    }

    // Construye la URL con los parámetros de búsqueda.
    final uri = Uri.https('api.github.com', '/search/repositories', {
      'q': cleanQuery,
      'sort': 'stars',
    });

    final requestHeaders = <String, String>{
      'Accept': 'application/vnd.github+json',
      'User-Agent': 'Flutter-PoC-ApiRest/1.0',
      'X-GitHub-Api-Version': '2022-11-28',
    };

    // Registra la solicitud HTTP en el Network Inspector.
    final logId = DateTime.now().microsecondsSinceEpoch.toString();

    var log = ApiLog(
      id: logId,
      timestamp: DateTime.now(),
      method: 'GET',
      url: uri.toString(),
      requestHeaders: requestHeaders,
      isLoading: true,
    );

    onLog(log);

    final stopwatch = Stopwatch()..start();

    try {
      final response = await _client
          .get(uri, headers: requestHeaders)
          .timeout(const Duration(seconds: 10));

      stopwatch.stop();

      final responseHeaders = Map<String, String>.from(response.headers);

      log = log.copyWith(
        isLoading: false,
        statusCode: response.statusCode,
        statusPhrase: response.reasonPhrase,
        durationMs: stopwatch.elapsedMilliseconds,
        responseHeaders: responseHeaders,
        responseBody: response.body,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        onLog(log);

        // Convierte los repositorios recibidos en una lista de objetos GitHubRepo.
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        final items = decoded['items'] as List<dynamic>;

        return items
            .map((item) => GitHubRepo.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        String errorMsg =
            'HTTP ${response.statusCode}: ${response.reasonPhrase}';

        try {
          final errorJson = json.decode(response.body) as Map<String, dynamic>;
          if (errorJson.containsKey('message')) {
            errorMsg = errorJson['message'].toString();
          }
        } catch (_) {}

        if (response.statusCode == 403 &&
            responseHeaders['x-ratelimit-remaining'] == '0') {
          errorMsg = '403 Forbidden: GitHub API rate limit exceeded.';
        }

        log = log.copyWith(errorMessage: errorMsg);
        onLog(log);

        throw Exception(errorMsg);
      }
    } on TimeoutException {
      stopwatch.stop();

      log = log.copyWith(
        isLoading: false,
        durationMs: stopwatch.elapsedMilliseconds,
        errorMessage: 'Request timed out after 10 seconds.',
      );

      onLog(log);
      throw Exception('Request timed out after 10s.');
    } catch (e) {
      if (stopwatch.isRunning) {
        stopwatch.stop();
      }

      if (log.statusCode == null) {
        log = log.copyWith(
          isLoading: false,
          durationMs: stopwatch.elapsedMilliseconds,
          errorMessage: e.toString(),
        );
        onLog(log);
      }

      rethrow;
    }
  }
}
