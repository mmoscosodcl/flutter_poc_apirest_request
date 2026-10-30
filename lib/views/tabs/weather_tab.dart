import 'package:flutter/material.dart';
import '../../models/weather_data.dart';
import '../../state/weather_controller.dart';
import '../widgets/status_badge.dart';

class WeatherTab extends StatefulWidget {
  final WeatherController controller;

  const WeatherTab({super.key, required this.controller});

  @override
  State<WeatherTab> createState() => _WeatherTabState();
}

class _WeatherTabState extends State<WeatherTab> {
  final _latController = TextEditingController(text: '-35.4264');
  final _lonController = TextEditingController(text: '-71.6554');

  @override
  void dispose() {
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  void _submit() {
    final lat = double.tryParse(_latController.text.trim());
    final lon = double.tryParse(_lonController.text.trim());

    if (lat == null || lon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid numeric coordinates.')),
      );
      return;
    }

    widget.controller.fetchWeather(latitude: lat, longitude: lon);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final weather = widget.controller.weather;
        final isLoading = widget.controller.isLoading;
        final errorMessage = widget.controller.errorMessage;
        final lastStatusCode = widget.controller.lastStatusCode;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Card(
                elevation: 0,
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.wb_sunny_rounded, color: theme.colorScheme.primary, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Open-Meteo REST API',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Type: Public REST (No authentication required)\nEndpoints: /v1/forecast',
                              style: TextStyle(fontSize: 12, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Preset Quick Action Buttons
              Text(
                'Test Presets (Status Code Simulation)',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                    label: const Text('Talca, CL (200 OK)'),
                    onPressed: isLoading
                        ? null
                        : () {
                            _latController.text = '-35.4264';
                            _lonController.text = '-71.6554';
                            widget.controller.loadTalca();
                          },
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                    label: const Text('Tokyo, JP (200 OK)'),
                    onPressed: isLoading
                        ? null
                        : () {
                            _latController.text = '35.6762';
                            _lonController.text = '139.6503';
                            widget.controller.loadTokyo();
                          },
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange),
                    label: const Text('Invalid Lat 150° (400 Bad Request)'),
                    onPressed: isLoading
                        ? null
                        : () {
                            _latController.text = '150.0';
                            _lonController.text = '0.0';
                            widget.controller.loadInvalidCoords();
                          },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Input Fields
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lonController,
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              FilledButton.icon(
                icon: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(isLoading ? 'Dispatching HTTP Request...' : 'Send GET Request'),
                onPressed: isLoading ? null : _submit,
              ),
              const SizedBox(height: 20),

              // Status and Result Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Result & State Presentation',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  StatusBadge(
                    statusCode: lastStatusCode,
                    isLoading: isLoading,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (isLoading)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: const [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Awaiting Open-Meteo response...'),
                      ],
                    ),
                  ),
                )
              else if (errorMessage != null)
                Card(
                  color: Colors.amber.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.amber.shade400),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning_rounded, color: Colors.amber.shade900),
                            const SizedBox(width: 8),
                            Text(
                              'HTTP Error Occurred',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          errorMessage,
                          style: const TextStyle(color: Color(0xFF78350F)),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Tip: Open the Live Network Inspector below to inspect the server response body.',
                          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                )
              else if (weather != null)
                _WeatherCard(weather: weather)
              else
                Card(
                  elevation: 0,
                  color: Colors.grey.shade100,
                  child: const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'Select a preset or click "Send GET Request" to fetch live data.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _WeatherCard extends StatelessWidget {
  final WeatherData weather;

  const _WeatherCard({required this.weather});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade600,
              Colors.lightBlue.shade300,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weather.timezone,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Lat: ${weather.latitude.toStringAsFixed(2)} | Lon: ${weather.longitude.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
                Icon(weather.weatherIcon, size: 48, color: Colors.amber.shade200),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${weather.temperature.toStringAsFixed(1)}°C',
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  weather.weatherDescription,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white24),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _WeatherMetric(label: 'Feels like', value: '${weather.apparentTemperature.toStringAsFixed(1)}°C'),
                _WeatherMetric(label: 'Humidity', value: '${weather.humidity}%'),
                _WeatherMetric(label: 'Wind', value: '${weather.windSpeed.toStringAsFixed(1)} km/h'),
                _WeatherMetric(label: 'Precip.', value: '${weather.precipitation} mm'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherMetric extends StatelessWidget {
  final String label;
  final String value;

  const _WeatherMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }
}
