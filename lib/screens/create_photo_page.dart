import 'package:flutter/material.dart';

import '../models/weather_models.dart';

class CreatePhotoPage extends StatefulWidget {
  final Region region; // 홈에서 전달받은 지역
  final WeatherInfo? weather; // 날씨 조회 실패 시 null 가능

  const CreatePhotoPage({
    super.key,
    required this.region,
    required this.weather,
  });

  @override
  State<CreatePhotoPage> createState() => _CreatePhotoPageState();
}

class _CreatePhotoPageState extends State<CreatePhotoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('날씨 사진 등록')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 330,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      widget.weather?.backgroundAsset ??
                          'assets/images/weather/clear.jpg',
                      fit: BoxFit.cover,
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0x99000000)],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Text(
                        '${widget.region.name}   '
                        '${widget.weather?.temperature.round() ?? '--'}°',
                        style: const TextStyle(
                          fontSize: 22, color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text('사진을 선택해 주세요.'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('카메라'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('갤러리'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
