import 'package:flutter/material.dart';
import '../services/weather_services.dart';
import '../models/weather_model.dart';
import 'package:logger/logger.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({Key? key}) : super(key: key);

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _cityController = TextEditingController();
  final _logger = Logger();
  WeatherModel? _weatherModel;

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _getWeather() async {
    // Create an instance of WeatherService with apiKey and locationKey
    // WeatherService weatherService = WeatherService('G1usZqiScCgfbTuGMqHdf9lTFcoOkEVz', );
    WeatherService weatherService = WeatherService('G1usZqiScCgfbTuGMqHdf9lTFcoOkEVz', _cityController.text);


    try {
      // Get weather data
      final weatherData = await weatherService.getWeather();

      // Update the UI
      setState(() {
        _weatherModel = weatherData;
      });
    } catch (e) {
      _logger.e(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_weatherModel != null)
              Column(
                children: [
                  Text(
                    _weatherModel!.cityName,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${_weatherModel!.temperature}°C',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _weatherModel!.condition,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _getWeather,
              child: const Text('Get Weather'),
            ),
          ],
        ),
      ),
    );
  }
}