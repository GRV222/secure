import 'dart:convert';
import 'package:http/http.dart' as http;

class ClaudeService {
  static const String _baseUrl = 'https://api.anthropic.com/v1/messages';
  final String _apiKey;

  ClaudeService(this._apiKey);

  Future<String> moderateContent(String content) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'x-api-key': _apiKey,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      },
      body: jsonEncode({
        'model': 'claude-haiku-4-5-20251001',
        'max_tokens': 256,
        'messages': [
          {
            'role': 'user',
            'content': 'Moderate this content and reply with only "safe" or "unsafe": $content',
          }
        ],
      }),
    );

    if (response.statusCode != 200) throw Exception('Claude API error: ${response.statusCode}');
    final data = jsonDecode(response.body);
    return data['content'][0]['text'] as String;
  }

  Future<List<String>> suggestHashtags(String content) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'x-api-key': _apiKey,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      },
      body: jsonEncode({
        'model': 'claude-haiku-4-5-20251001',
        'max_tokens': 128,
        'messages': [
          {
            'role': 'user',
            'content': 'Suggest 5 relevant hashtags for this post (comma-separated, no # symbol): $content',
          }
        ],
      }),
    );

    if (response.statusCode != 200) throw Exception('Claude API error: ${response.statusCode}');
    final data = jsonDecode(response.body);
    final text = data['content'][0]['text'] as String;
    return text.split(',').map((s) => s.trim()).toList();
  }
}
