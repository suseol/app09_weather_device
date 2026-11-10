import 'package:flutter/material.dart';

import '../models/weather_models.dart';

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  WeatherInfo? _weather; // 제공: 조회 전에는 null
  bool _loading = false; // 제공: 조회 중 표시용 상태

  @override
  Widget build(BuildContext context) {
    final weather = _weather; // State를 읽는 지역변수, 새 State가 아님
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              weather?.backgroundAsset ??
                  'assets/images/weather/clear.jpg',
              fit: BoxFit.cover,
            ),
          ),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x77000000),
                    Color(0x00000000),
                    Color(0xB8000000),
                  ],
                  stops: [0, 0.48, 1],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Text(
                        '조회 지역', // S01에서 실제 지역명 연결
                        style: TextStyle(color: Colors.white),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: null, // S01에서 조회 함수 연결
                        color: Colors.white,
                        tooltip: '날씨 새로고침',
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 42),
                  Text(
                    weather == null
                        ? '--°' : '${weather.temperature.round()}°',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 86,
                      fontWeight: FontWeight.w200,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    weather?.condition ?? '새로고침을 눌러 주세요.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, color: Colors.white),
                  ),
                  if (weather != null)
                    Text(
                      '습도 ${weather.humidity}%  |  '
                      '풍속 ${weather.windSpeed.round()}km/h',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  if (weather != null)
                    Text(
                      '기상 기준 ${weather.observedAt.hour.toString().padLeft(2, '0')}:'
                      '${weather.observedAt.minute.toString().padLeft(2, '0')}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  if (_loading) const LinearProgressIndicator(),
                  const Spacer(),
                  const Text(
                    '기본 날씨 배경 (현장 사진 없음)',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
