import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class CryAnalyzer {
  final String baseUrl;
  CryAnalyzer({required this.baseUrl});

  Future<Map<String, dynamic>> analyzeMode1() async {

    return _postAnalyze({"mode": "1"});
  }

  Future<Map<String, dynamic>> analyzeMode3(String category) async {

    return _postAnalyze({"mode": "3", "category": category});
  }

  Future<Map<String, dynamic>> uploadCryFile(File file) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/upload"),
      );
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType('audio', 'wav'),
      ));
      var response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        return jsonDecode(respStr);
      } else {
        return {"error": "Server returned ${response.statusCode}"};
      }
    } catch (e) {
      return {"error": e.toString()};
    }
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
