import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class CryClassifierPage extends StatefulWidget {
  const CryClassifierPage({super.key});

  @override
  State<CryClassifierPage> createState() => _CryClassifierPageState();
}

class _CryClassifierPageState extends State<CryClassifierPage> {
  String statusText = "Select a mode to start";
  bool isLoading = false;

  final String piUrl = "http://192.168.12.153:5000";

  String selectedCategory = "hunger";
  final List<String> categories = [
    "discomfort",
    "hunger",
    "pain",
    "sleepiness"
  ];

  List<String> segmentLogs = [];


  Future<void> sendRequest(Map<String, dynamic> payload) async {
    setState(() {
      isLoading = true;
      statusText = "Processing...";
      segmentLogs = [];
    });

    try {
      final response = await http.post(
        Uri.parse("$piUrl/analyze"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          statusText =
          "Prediction: ${data['prediction']}\nConfidence: ${(data['confidence'] * 100).toStringAsFixed(1)}%";
          segmentLogs = List<String>.from(data['segment_logs'] ?? []);
        });
      } else {
        setState(() {
          statusText = "Error: ${data['error']}";
        });
      }
    } catch (e) {
      setState(() {
        statusText = "Connection failed: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  Future<void> uploadWavFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['wav'],
    );

    if (result == null) return;

    setState(() {
      isLoading = true;
      statusText = "Uploading file...";
      segmentLogs = [];
    });

    try {
      var fileBytes = result.files.single.bytes;
      var fileName = result.files.single.name;

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$piUrl/upload"),
      );

      request.files.add(
        http.MultipartFile.fromBytes('file', fileBytes!, filename: fileName),
      );

      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200) {
        setState(() {
          statusText =
          "Prediction: ${data['prediction']}\nConfidence: ${(data['confidence'] * 100).toStringAsFixed(1)}%";
          segmentLogs = List<String>.from(data['segment_logs'] ?? []);
        });
      } else {
        setState(() {
          statusText = "Error: ${data['error']}";
        });
      }
    } catch (e) {
      setState(() {
        statusText = "Upload failed: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  Widget buildButton(String label, VoidCallback onPressed) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            onPressed: isLoading ? null : onPressed,
            child: Text(label),
          ),
        );
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Baby Cry Recognition")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Choose Mode:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),


            buildButton("🎤 Mic Test", () => sendRequest({"mode": "1"})),

            const SizedBox(height: 10),


            Row(
              children: [
                const Text("Category: "),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    items: categories
                        .map(
                          (cat) => DropdownMenuItem<String>(
                        value: cat,
                        child: Text(cat),
                      ),
                    )
                        .toList(),
                    onChanged: isLoading
                        ? null
                        : (val) {
                      setState(() {
                        selectedCategory = val!;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            buildButton("🎲 Random Test (Selected Category)", () {
              sendRequest({"mode": "3", "category": selectedCategory});
            }),

            const SizedBox(height: 10),


            buildButton("📁 Upload WAV from Phone", uploadWavFile),

            const SizedBox(height: 20),

            if (isLoading)
              const Center(child: CircularProgressIndicator()),

            const SizedBox(height: 20),


            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    if (segmentLogs.isNotEmpty)
                      const Text(
                        "🔍 Segment Analysis:",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    for (var log in segmentLogs)
                      Text(
                        log,
                        style: const TextStyle(fontSize: 14),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
