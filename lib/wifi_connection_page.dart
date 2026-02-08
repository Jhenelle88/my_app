import 'package:flutter/material.dart';
import 'package:my_app/cry_analyzer_api.dart';
import 'dart:convert';

class WifiConnectionPage extends StatefulWidget {
  final Function(String) onPredictionReceived;

  const WifiConnectionPage({super.key, required this.onPredictionReceived});

  @override
  State<WifiConnectionPage> createState() => _WifiConnectionPageState();
}

class _WifiConnectionPageState extends State<WifiConnectionPage> with SingleTickerProviderStateMixin {
  final CryAnalyzer _api = CryAnalyzer(baseUrl: 'http://192.168.1.46:5000');
  String _status = "Select a mode to start";
  bool _isLoading = false;

  String _selectedCategory = "hunger";
  final List<String> _categories = ["discomfort", "hunger", "pain", "sleepiness"];

  final _filePathController = TextEditingController();

  @override
  void dispose() {
    _filePathController.dispose();
    super.dispose();
  }

  Future<void> _callApi(Map<String, dynamic> payload) async {
    setState(() {
      _isLoading = true;
      _status = 'Processing...';
    });

    try {
      Map<String, dynamic> result;
      String mode = payload['mode'] ?? '0';

      switch (mode) {
        case '1':
          result = await _api.analyzeMode1();
          break;
        case '2':
          result = await _api.analyzeMode2(payload['file_path'] ?? '');
          break;
        case '3':
          result = await _api.analyzeMode3(payload['category'] ?? '');
          break;
        default:
          throw Exception("Invalid mode");
      }

      if (result.containsKey('error')) {
        throw Exception(result['error']);
      }

      final prediction = result['prediction'] ?? 'N/A';
      widget.onPredictionReceived(prediction);
      
      setState(() {
        JsonEncoder encoder = const JsonEncoder.withIndent('  ');
        _status = encoder.convert(result);
      });

    } catch (e) {
      setState(() {
        _status = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wi-Fi Cry Analyzer'),
        backgroundColor: Colors.lightBlue[400],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Choose Mode:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // 🎤 Mic Test
            buildButton("🎤 Mic Test", {"mode": "1"}),

            const SizedBox(height: 20),

            // 🎲 Random Test
            Row(
              children: [
                const Text("Category: "),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    items: _categories
                        .map((cat) => DropdownMenuItem<String>(
                              value: cat,
                              child: Text(cat),
                            ))
                        .toList(),
                    onChanged: _isLoading
                        ? null
                        : (val) {
                            setState(() {
                              _selectedCategory = val!;
                            });
                          },
                  ),
                ),
              ],
            ),
            buildButton("🎲 Random WAV Test", {
              "mode": "3",
              "category": _selectedCategory
            }),

            const SizedBox(height: 20),

            // 📂 Specific File Test
            TextField(
              controller: _filePathController,
              decoration: const InputDecoration(
                labelText: "File path on Raspberry Pi",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            buildButton("📂 Specific File Test", {
              "mode": "2",
              "file_path": _filePathController.text.trim(),
            }),

            const SizedBox(height: 20),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade200,
              ),
              child: Text(
                _status,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButton(String label, Map<String, dynamic> payload) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
        onPressed: _isLoading ? null : () => _callApi(payload),
        child: Text(label),
      ),
    );
  }
}
