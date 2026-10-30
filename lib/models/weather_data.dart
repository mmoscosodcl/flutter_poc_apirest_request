import 'package:flutter/material.dart';

/// Parsed domain data from Open-Meteo REST API (HTTP 200).
class WeatherData {
  final double latitude;
  final double longitude;
  final String timezone;
  final double temperature;
  final double apparentTemperature;
  final int humidity;
  final double precipitation;
  final double windSpeed;
  final int weatherCode;

  const WeatherData({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.precipitation,
    required this.windSpeed,
    required this.weatherCode,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>? ?? {};
    return WeatherData(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      timezone: json['timezone'] as String? ?? 'UTC',
      temperature: (current['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      apparentTemperature: (current['apparent_temperature'] as num?)?.toDouble() ?? 0.0,
      humidity: (current['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      precipitation: (current['precipitation'] as num?)?.toDouble() ?? 0.0,
      windSpeed: (current['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (current['weather_code'] as num?)?.toInt() ?? 0,
    );
  }

  /// WMO Weather interpretation code description
  String get weatherDescription {
    switch (weatherCode) {
      case 0:
        return 'Clear sky';
      case 1:
        return 'Mainly clear';
      case 2:
        return 'Partly cloudy';
      case 3:
        return 'Overcast';
      case 45:
      case 48:
        return 'Fog / Depositing rime fog';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain (Slight / Moderate / Heavy)';
      case 71:
      case 73:
      case 75:
        return 'Snow fall';
      case 80:
      case 81:
      case 82:
        return 'Rain showers';
      case 95:
      case 96:
      case 99:
        return 'Thunderstorm';
      default:
        return 'Weather condition ($weatherCode)';
    }
  }

  IconData get weatherIcon {
    switch (weatherCode) {
      case 0:
        return Icons.wb_sunny;
      case 1:
      case 2:
        return Icons.wb_cloudy;
      case 3:
        return Icons.cloud;
      case 45:
      case 48:
        return Icons.foggy;
      case 51:
      case 53:
      case 55:
      case 61:
      case 63:
      case 65:
      case 80:
      case 81:
      case 82:
        return Icons.grain;
      case 71:
      case 73:
      case 75:
        return Icons.ac_unit;
      case 95:
      case 96:
      case 99:
        return Icons.bolt;
      default:
        return Icons.wb_cloudy_outlined;
    }
  }
}
