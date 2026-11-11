# App09: 지금 날씨 보여줘 (11주차 모바일 장치 활용)

Flutter로 현재 날씨를 조회하고 카메라, 갤러리, GPS, 마이크를 연결하는 **학생용 실습 Starter**입니다. 12주차 Firebase, 13주차 AI 기능을 추가할 때도 같은 앱을 확장합니다.

## 실행 준비

Flutter SDK와 Android 기기 또는 에뮬레이터를 준비한 뒤 프로젝트 폴더에서 실행합니다.

```bash
flutter create --platforms=android --project-name lab09_show_me_weather .
flutter pub get
flutter run
```

이 저장소에는 학습할 코드와 `android/app/src/main/AndroidManifest.xml`의 시작 설정만 포함되어 있습니다. Android 플랫폼 기본 파일은 `flutter create`로 생성합니다.

## 실습 순서

| 단계 | 내용 |
| --- | --- |
| S00 | Starter 실행, 제공 모델과 화면 코드 읽기 |
| S01 | `Region` 선택, 날씨 조회 함수와 새로고침 연결 |
| S02 | Android 위치 권한 설정, 현재 GPS 좌표로 날씨 조회 |
| S03 | 사진 촬영 및 선택, 사진만 등록하여 홈 배경에 표시 |
| S04 | 마이크 녹음, AI가 정리한 날씨 설명 추가 |
| S05 | 여러 사진을 좌우로 넘기기 |
| S06 (선택) | BottomSheet로 다른 지역 조회 |

실습 진행서는 수업 시간에 별도로 제공합니다.

## 파일 구성

- `lib/main.dart`: 앱 시작 코드
- `lib/models/`: 제공 모델 (`Region`, `WeatherInfo`, `WeatherRecord`)
- `lib/screens/`: 날씨 홈과 사진 등록 화면
- `lib/services/`: 날씨 API와 AI 음성 교정의 제공 코드
- `assets/images/weather/`: 기본 날씨 배경 4종
- `android/app/src/main/AndroidManifest.xml`: INTERNET만 있는 기본 설정. 위치와 마이크 권한은 수업 중 직접 추가

**Starter에는 완성된 학생 실습 코드가 들어 있지 않습니다.** 단계별로 파일을 수정하여 기능을 완성합니다. `solution/`과 `steps/` 전체 완성본은 이 공개 저장소에 포함하지 않습니다. `checkpoints/`는 수업 중 실습 진도를 놓쳤을 때 복구하는 용도로 제공합니다.

## 실습 복구 파일

`checkpoints/`에는 위치 권한(S02), 사진 등록(S03), 음성 설명(S04) 단계의 복구용 전체 파일이 있습니다. 필요한 파일을 원래 `lib/` 경로 또는 `android/app/src/main/AndroidManifest.xml`로 복사해 복구합니다. 실습 진행서는 수업 시간에 별도로 제공합니다.

## API 키 주의

`lib/services/ai_speech_service.dart`에는 `PASTE_OPENAI_API_KEY_HERE` 자리표시자만 있습니다. **실제 OpenAI API 키를 이 공개 저장소에 커밋하지 마세요.** 수업 시에는 별도로 제공된 실행 지침을 따르고, 서비스 배포 환경에서는 서버를 통해 API를 호출해야 합니다.

날씨 조회는 [Open-Meteo](https://open-meteo.com/)를 사용합니다. 실습 데이터는 앱 실행 중 메모리에만 저장되며 Firebase 업로드는 12주차 범위입니다.
