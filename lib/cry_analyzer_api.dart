import 'dart:convert';
import 'package:http/http.dart' as http;

class CryAnalyzer {
  final String baseUrl; // e.g., "http://192.168.100.186:5000"

  CryAnalyzer({required this.baseUrl});

  Future<Map<String, dynamic>> analyzeMode1() async {
    // Microphone (mode 1)
    return _postAnalyze({"mode": "1"});
  }

  Future<Map<String, dynamic>> analyzeMode2(String filePath) async {
    // Specific file (mode 2)
    return _postAnalyze({"mode": "2", "file_path": filePath});
  }

  Future<Map<String, dynamic>> analyzeMode3(String category) async {
    // Random file from category (mode 3)
    return _postAnalyze({"mode": "3", "category": category});
  }

  Future<Map<String, dynamic>> analyzeMode4(int nFiles) async {
    // Batch N files per category (mode 4)
    return _postAnalyze({"mode": "4", "n_files": nFiles});
  }

  Future<Map<String, dynamic>> _postAnalyze(Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/analyze"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"error": "Server returned ${response.statusCode}", "details": response.body};
      }
    } catch (e) {
      return {"error": e.toString()};
    }
  }
}
