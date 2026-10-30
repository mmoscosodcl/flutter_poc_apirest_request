import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_log.dart';
import '../models/weather_data.dart';

class WeatherService {
  final http.Client _client;

  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches weather from Open-Meteo (No Authentication required).
  ///
  /// Emits an [ApiLog] twice via [onLog]:
  /// 1. Immediately when the request is dispatched (in-flight state).
  /// 2. Once the response (or network error) is received with full diagnostics.
  Future<WeatherData> fetchWeather({
    required double latitude,
    required double longitude,
    required void Function(ApiLog) onLog,
  }) async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?'
      'latitude=$latitude&longitude=$longitude'
      '&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m',
    );

    final logId = DateTime.now().microsecondsSinceEpoch.toString();
    final requestHeaders = <String, String>{
      'Accept': 'application/json',
      'User-Agent': 'Flutter-PoC-ApiRest/1.0',
    };

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

      // Convert response headers to simple Map
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
        return WeatherData.fromJson(decoded);
      } else {
        // e.g. 400 Bad Request if latitude > 90
        String clientErrorReason = 'Server returned HTTP ${response.statusCode}';
        try {
          final errorJson = json.decode(response.body) as Map<String, dynamic>;
          if (errorJson.containsKey('reason')) {
            clientErrorReason = errorJson['reason'].toString();
          }
        } catch (_) {}

        log = log.copyWith(errorMessage: clientErrorReason);
        onLog(log);
        throw Exception(clientErrorReason);
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
      if (!stopwatch.isRunning) {
        // already stopped
      } else {
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
