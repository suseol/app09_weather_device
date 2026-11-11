import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getCurrent() async { // 현재 위치를 비동기로 조회
    if (!await Geolocator.isLocationServiceEnabled()) { // 기기 설정
      throw Exception('기기 위치 서비스를 켜 주세요.');
    }
    var permission = await Geolocator.checkPermission(); // 이 앱의 권한
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission(); // 권한 요청
    }
    // denied: 현재 거부, 다시 요청할 수 있음
    // deniedForever: 앱에서 재요청 불가, 기기 설정에서 변경
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('위치 권한이 필요합니다.'); // 둘 다 조회 중단
    }
    return Geolocator.getCurrentPosition(); // 위치 조회 Future 반환
  }
}
