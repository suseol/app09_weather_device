// S04 완료: 이 파일을 lib/screens/create_photo_page.dart에 복사한다.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

import '../services/ai_speech_service.dart';

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
  String? _imagePath; // 선택한 사진 경로
  bool _fromCamera = false; // 직접 촬영인지 구분
  DateTime? _capturedAt; // 갤러리 촬영 시각은 미확인
  final _recorder = AudioRecorder(); // 녹음 도구
  bool _isRecording = false;
  bool _isProcessing = false;
  String _description = ''; // AI가 정리한 설명

  Future<void> _pickPhoto(ImageSource source) async {
    final image = await ImagePicker().pickImage(
      source: source, maxWidth: 1200,
    );
    if (image == null || !mounted) return; // 취소 또는 화면 종료
    setState(() {
      _imagePath = image.path; // 선택 결과를 화면 상태에 저장
      _fromCamera = source == ImageSource.camera;
      _capturedAt = _fromCamera ? DateTime.now() : null;
    });
  }

  void _saveRecord() {
    if (_imagePath == null) return; // 사진이 없으면 등록하지 않음
    final record = WeatherRecord(
      regionId: widget.region.id, // 홈과 같은 지역 식별자
      imagePath: _imagePath!,
      description: _description, // 비어 있어도 사진 등록 가능
      fromCamera: _fromCamera,
      latitude: _fromCamera ? widget.region.latitude : null,
      longitude: _fromCamera ? widget.region.longitude : null,
      capturedAt: _capturedAt,
      createdAt: DateTime.now(), // 앱에 등록한 시각
    );
    Navigator.pop(context, record); // 현재 화면을 닫으며 결과 전달
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop(); // 녹음 종료 후 파일 경로
      if (!mounted) return;
      setState(() => _isRecording = false);
      if (path == null) return;
      setState(() => _isProcessing = true);
      try {
        final result = await AiSpeechService().cleanSpeech(path);
        if (!mounted) return;
        setState(() => _description = result); // 설명을 화면에 반영
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI 교정 실패: API 키와 연결을 확인하세요.')),
        );
      } finally {
        if (mounted) setState(() => _isProcessing = false);
      }
    } else {
      if (!await _recorder.hasPermission()) return; // 마이크 권한
      final dir = await getTemporaryDirectory(); // 임시 저장 위치
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav, sampleRate: 16000, numChannels: 1,
        ),
        path: '${dir.path}/weather_note.wav',
      );
      if (mounted) setState(() => _isRecording = true);
    }
  }

  @override
  void dispose() {
    _recorder.dispose(); // 화면 종료 시 녹음 도구 정리
    super.dispose();
  }

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
                    _imagePath == null
                        ? Image.asset(
                            widget.weather?.backgroundAsset ??
                                'assets/images/weather/clear.jpg',
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(_imagePath!), fit: BoxFit.cover,
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
            Text(_imagePath == null ? '사진을 선택해 주세요.' : '사진 미리보기'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickPhoto(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('카메라'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickPhoto(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('갤러리'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              _description.isEmpty
                  ? '마이크로 현장 날씨를 설명해 주세요.' : _description,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _isProcessing ? null : _toggleRecording,
              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
              label: Text(_isProcessing
                  ? 'AI가 문장을 정리하는 중...'
                  : (_isRecording ? '녹음 종료' : '설명 녹음하기')),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _imagePath == null || _isRecording || _isProcessing
                  ? null : _saveRecord,
              child: const Text('현장 사진 등록'),
            ),
          ],
        ),
      ),
    );
  }
}
