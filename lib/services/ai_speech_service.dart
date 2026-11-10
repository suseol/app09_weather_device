import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// 수업용 임시 설정: 실제 키가 제공되지 않아 아래 값을 직접 교체해야 한다.
// 학생에게 배포하거나 실제 서비스에 출시할 때는 반드시 서버 호출로 변경한다.
const openAiApiKey = 'PASTE_OPENAI_API_KEY_HERE';

class AiSpeechService {
  Future<String> cleanSpeech(String audioPath) async {
    if (openAiApiKey == 'PASTE_OPENAI_API_KEY_HERE') {
      throw Exception('AI API 키를 먼저 설정하세요.');
    }

    final bytes = await File(audioPath).readAsBytes();
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $openAiApiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-audio-1.5',
        'modalities': ['text'],
        'store': false,
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text': '한국어 날씨 현장 설명 음성을 한 문장 또는 짧은 문단으로 정리하세요. '
                    '음, 어 같은 군더더기와 반복은 제거하고, '
                    '아니, 다시 말해 등으로 고친 표현은 마지막 표현을 사용하세요. '
                    '원래 뜻과 사실은 유지하고 새 날씨 정보를 만들지 마세요. '
                    '교정된 한국어 문장만 출력하세요.',
              },
              {
                'type': 'input_audio',
                'input_audio': {
                  'data': base64Encode(bytes),
                  'format': 'wav',
                },
              },
            ],
          },
        ],
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('AI 요청 실패 (HTTP ${response.statusCode})');
    }

    final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final choice = (json['choices'] as List).first as Map<String, dynamic>;
    final message = choice['message'] as Map<String, dynamic>;
    final content = message['content'] as String?;
    final answer = content?.trim() ?? '';
    if (answer.isEmpty) throw Exception('교정된 문장이 없습니다.');
    return answer;
  }
}
