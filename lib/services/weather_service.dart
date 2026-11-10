import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/weather_models.dart';

// 기존 HTTP/JSON 학습을 활용하되, 11주차에는 API 파서를 제공한다.
class WeatherService {
  Future<WeatherInfo> fetch(Region region) async {
    final url = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': '${region.latitude}',
      'longitude': '${region.longitude}',
      'current': 'temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code',
      'timezone': 'auto',
    });

    final response = await http.get(url);
    if (response.statusCode != 200) throw Exception('날씨 조회 실패');

    final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final current = data['current'] as Map<String, dynamic>;
    return WeatherInfo(
      temperature: (current['temperature_2m'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).round(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      weatherCode: (current['weather_code'] as num).toInt(),
      observedAt: DateTime.parse(current['time'] as String),
    );
  }
}
