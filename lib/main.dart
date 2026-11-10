import 'package:flutter/material.dart';

import 'screens/weather_home_page.dart';

void main() => runApp(const WeatherLabApp());

class WeatherLabApp extends StatelessWidget {
  const WeatherLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '지금 날씨 보여줘',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const WeatherHomePage(),
    );
  }
}
