import 'package:flutter/foundation.dart';
import '../models/weather_data.dart';
import '../services/weather_service.dart';
import 'network_log_controller.dart';

class WeatherController extends ChangeNotifier {
  final WeatherService _service;
  final NetworkLogController logController;

  WeatherController({
    WeatherService? service,
    required this.logController,
  })  : _service = service ?? WeatherService();

  WeatherData? _weather;
  bool _isLoading = false;
  String? _errorMessage;
  int? _lastStatusCode;

  WeatherData? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get lastStatusCode => _lastStatusCode;

  Future<void> fetchWeather({
    required double latitude,
    required double longitude,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.fetchWeather(
        latitude: latitude,
        longitude: longitude,
        onLog: (log) {
          logController.addOrUpdateLog(log);
          if (!log.isLoading) {
            _lastStatusCode = log.statusCode;
          }
        },
      );
      _weather = result;
      _errorMessage = null;
    } catch (e) {
      _weather = null;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Preset 1: Talca, Chile (Valid 200 OK)
  Future<void> loadTalca() => fetchWeather(latitude: -35.4264, longitude: -71.6554);

  /// Preset 2: Tokyo, Japan (Valid 200 OK)
  Future<void> loadTokyo() => fetchWeather(latitude: 35.6762, longitude: 139.6503);

  /// Preset 3: Invalid Latitude 150.0 (Triggers HTTP 400 Bad Request)
  Future<void> loadInvalidCoords() => fetchWeather(latitude: 150.0, longitude: 0.0);
}
