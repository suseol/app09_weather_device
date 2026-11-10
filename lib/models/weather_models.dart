// 11주차에는 모델을 제공하고, 화면에서 객체를 생성해 사용한다.
class Region {
  final String id; // 앱 안에서 지역을 구분하는 값
  final String name; // 화면에 표시할 지역명
  final double latitude; // 날씨 조회에 사용할 위도
  final double longitude; // 날씨 조회에 사용할 경도

  const Region(this.id, this.name, this.latitude, this.longitude);
}

// Region 목록: 위치 좌표는 제공 데이터이다.
const regions = <Region>[
  Region('seoul', '서울', 37.5665, 126.9780),
  Region('daejeon', '대전', 36.3504, 127.3845),
  Region('cheonan', '천안', 36.8151, 127.1139),
  Region('busan', '부산', 35.1796, 129.0756),
  Region('jeju', '제주', 33.4996, 126.5312),
];

class WeatherInfo {
  final double temperature;
  final int humidity;
  final double windSpeed;
  final int weatherCode; // Open-Meteo의 숫자형 날씨 코드
  final DateTime observedAt; // 날씨 데이터의 기준 시각

  const WeatherInfo({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.observedAt,
  });

  // getter: weatherCode를 한국어 문구로 계산한다.
  String get condition {
    if (weatherCode >= 71 && weatherCode <= 77) return '눈';
    if (weatherCode >= 51 && weatherCode <= 67 ||
        weatherCode >= 80 && weatherCode <= 82 ||
        weatherCode >= 95) return '비';
    if (weatherCode >= 2) return '흐림';
    return '맑음';
  }

  // condition에 맞는 기본 배경 파일 경로를 고른다.
  String get backgroundAsset {
    if (condition == '눈') return 'assets/images/weather/snow.jpg';
    if (condition == '비') return 'assets/images/weather/rain.jpg';
    if (condition == '흐림') return 'assets/images/weather/cloudy.jpg';
    return 'assets/images/weather/clear.jpg';
  }
}

class WeatherRecord {
  final String regionId; // Region.id와 비교할 값
  final String imagePath; // 기기에 있는 이미지 파일 경로
  final String description; // S03은 빈 문자열, S04부터 AI 설명
  final bool fromCamera;
  final double? latitude;
  final double? longitude;
  final DateTime? capturedAt; // 촬영 시각, 모르면 null
  final DateTime createdAt; // 앱에 기록을 등록한 시각

  const WeatherRecord({
    required this.regionId,
    required this.imagePath,
    required this.description,
    required this.fromCamera,
    required this.latitude,
    required this.longitude,
    required this.capturedAt,
    required this.createdAt,
  });

  String get sourceLabel {
    if (!fromCamera || capturedAt == null) {
      return '갤러리 사진 (촬영 시각 미확인)';
    }
    final time = capturedAt!;
    final month = time.month.toString().padLeft(2, '0');
    final day = time.day.toString().padLeft(2, '0');
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '${time.year}/$month/$day $hour:$minute';
  }
}
