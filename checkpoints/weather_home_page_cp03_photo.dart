// S03 완료: 이 파일을 lib/screens/weather_home_page.dart에 복사한다.
import 'dart:io';
import 'package:flutter/material.dart';

import '../models/weather_models.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import 'create_photo_page.dart';

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  Region _region = regions.first; // 처음 조회할 지역
  WeatherInfo? _weather; // 제공: 조회 전에는 null
  bool _loading = false; // 제공: 조회 중 표시용 상태
  bool _openingCreatePage = false; // 화면 중복 열기 방지
  final List<WeatherRecord> _records = []; // 실행 중에만 보관

  Future<void> _loadWeather() async {
    setState(() { _loading = true; _weather = null; });
    try {
      final result = await WeatherService().fetch(_region); // 지역 좌표로 조회
      if (!mounted) return; // 화면 종료 후 갱신 방지
      setState(() => _weather = result); // 결과 저장과 rebuild 요청
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('날씨를 불러오지 못했습니다.')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _useCurrentLocation() async {
    try {
      final position = await LocationService().getCurrent(); // 기기 좌표
      if (!mounted) return;
      setState(() {
        _region = Region(
          'current', '현재 위치', position.latitude, position.longitude,
        ); // 기기 좌표로 새로운 지역 객체 생성
      });
      await _loadWeather(); // 기존 날씨 조회 재사용
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('현재 위치와 권한을 확인해 주세요.')),
      );
    }
  }

  Future<void> _openCreatePage() async {
    if (_openingCreatePage) return; // 연속 클릭은 무시
    _openingCreatePage = true;
    try {
      if (_region.id != 'current') {
        await _useCurrentLocation();
        if (!mounted || _region.id != 'current') return;
      }
      final record = await Navigator.push<WeatherRecord>(
        context,
        MaterialPageRoute(
          builder: (context) => CreatePhotoPage(
            region: _region, weather: _weather,
          ),
        ),
      );
      if (record == null || !mounted) return; // 취소하면 결과 없음
      setState(() => _records.insert(0, record)); // 최신 사진을 맨 앞에
    } finally {
      _openingCreatePage = false; // 돌아오면 다시 열기 허용
    }
  }

  @override
  Widget build(BuildContext context) {
    final weather = _weather; // State를 읽는 지역변수, 새 State가 아님
    final photos = _records.where((r) => r.regionId == _region.id).toList();
    final shownPhoto = photos.isEmpty ? null : photos.first; // 최신 한 장
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: shownPhoto == null
                ? Image.asset(
                    weather?.backgroundAsset ??
                        'assets/images/weather/clear.jpg',
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    File(shownPhoto.imagePath), fit: BoxFit.cover,
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
                      Text(
                        _region.name, // 객체의 지역명 표시
                        style: const TextStyle(color: Colors.white),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _useCurrentLocation,
                        color: Colors.white,
                        tooltip: '현재 위치',
                        icon: const Icon(Icons.my_location),
                      ),
                      IconButton(
                        onPressed: _loading ? null : _loadWeather,
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
                  Text(
                    shownPhoto?.sourceLabel ?? '기본 날씨 배경 (현장 사진 없음)',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FloatingActionButton(
                      onPressed: _openCreatePage,
                      tooltip: '사진 등록',
                      child: const Icon(Icons.add_a_photo_outlined),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
