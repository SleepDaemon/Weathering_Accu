import 'package:logger/logger.dart';
import '../models/weather_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> getLocationKey() async {
  // Check if the app has location permissions
  LocationPermission permission = await Geolocator.checkPermission();
  
  if (permission == LocationPermission.denied) {
    // Request location permissions if not granted
    permission = await Geolocator.requestPermission();
    
    if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
      // Handle the case when the user denies location permission
      return 'Permission Denied';
    }
  }

  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  // if (position == null) {
  //   // Handle location not available
  //   return 'null';
  // }

  const apiKey = 'G1usZqiScCgfbTuGMqHdf9lTFcoOkEVz';
  final url = 'http://dataservice.accuweather.com/locations/v1/cities/geoposition/search?apikey=$apiKey&q=${position.latitude},${position.longitude}';

  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final locationKey = data['Key'] as String;
    return locationKey;
  } else {
    // Handle API error
    return 'Error';
  }
}

void main() async {
  var logger = Logger();

  try {
    // Assume you have already obtained the locationKey using getLocationKey()
    String locationKey = await getLocationKey();

    if (locationKey == 'Permission Denied') {
      logger.e('Location permission denied.');
    } else if (locationKey == 'null') {
      logger.e('Location not available.');
    } else if (locationKey == 'Error') {
      logger.e('Error occurred while getting location key.');
    } else {
      // Create an instance of WeatherService with apiKey and locationKey
      WeatherService weatherService = WeatherService('G1usZqiScCgfbTuGMqHdf9lTFcoOkEVz', locationKey);

      // Now you can use the constructed URL with the locationKey
      String completeUrl = weatherService.constructUrl();

      // Log the completeUrl to check if it's correctly constructed
      logger.d('Complete URL: $completeUrl');

      // ... perform API request using completeUrl
    }
  } catch (error) {
    logger.e('An error occurred: $error');
  }
}

class WeatherService {
  // ignore: constant_identifier_names
  static const BASE_URL = 'http://dataservice.accuweather.com/forecasts/v1/daily/1day/{locationKey}';
  final String apiKey;
  final String locationKey;

  WeatherService(this.apiKey, this.locationKey);

  String constructUrl() {
    return BASE_URL.replaceFirst('{locationKey}', locationKey);
  }

  Future <WeatherModel> getWeather() async {
    // Your logic to fetch weather data goes here
    // Replace the placeholder URL with your actual API endpoint
    final url = constructUrl();

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return WeatherModel.fromJson(data);
    } else {
      // Handle API error
      throw Exception('Failed to load weather data');
    }

  // ... other methods related to weather service
  }
}