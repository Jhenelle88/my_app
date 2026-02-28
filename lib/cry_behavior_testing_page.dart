import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:my_app/cry_reason_details_page.dart';

class CryBehaviorTestingPage extends StatefulWidget {
  final int userId;

  const CryBehaviorTestingPage({super.key, required this.userId});

  @override
  State<CryBehaviorTestingPage> createState() => _CryBehaviorTestingPageState();
}

class _CryBehaviorTestingPageState extends State<CryBehaviorTestingPage> {
  String _serverUrl = '';
  bool _isLoading = false;
  String _prediction = 'No test performed yet'; 
  String _confidence = '';
  String _rawScores = '';
  List<String> _segmentPredictions = [];
  String _matchedFile = '';
  String? _detectedImagePath;
  bool _isResultExpanded = false;

  Future<bool> _findServerIP() async {
    setState(() {
      _isLoading = true;
      _prediction = "Searching for Raspberry Pi...";
    });

    try {
      final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      socket.broadcastEnabled = true;
      final broadcastAddr = InternetAddress('255.255.255.255');
      socket.send(utf8.encode('CRYCOM_DISCOVER'), broadcastAddr, 5001);

      await for (RawSocketEvent event in socket.timeout(const Duration(seconds: 3))) {
        if (event == RawSocketEvent.read) {
          Datagram? dg = socket.receive();
          if (dg != null) {
            final message = utf8.decode(dg.data);
            if (message == 'CRYCOM_SERVER') {
              String discoveredIp = dg.address.address;
              _serverUrl = 'http://$discoveredIp:5000';
              socket.close();
              return true;
            }
          }
        }
      }
      socket.close();
    } catch (e) {
      print("Discovery failed: $e");
    }

    setState(() {
      _isLoading = false;
      _prediction = "Device Not Found. Ensure Pi is on the same network.";
    });
    return false;
  }

  Future<void> _startMicAnalysis() async {
    bool found = await _findServerIP();
    if (!found || !mounted) return;

    setState(() {
      _isLoading = true;
      _prediction = "Pi is recording for 4 seconds...";
      _confidence = "";
      _rawScores = "";
      _segmentPredictions = [];
      _detectedImagePath = null;
    });

    try {
      final response = await http
          .post(Uri.parse('$_serverUrl/analyze/mic'))
          .timeout(const Duration(seconds: 15));

      _handleServerResponse(response.statusCode, response.body);
    } on TimeoutException {
      setState(() {
        _isLoading = false;
        _prediction = "Connection Timed Out.";
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _prediction = "Error: $e";
      });
    }
  }

  Future<void> _startFileAnalysis() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['wav'],
    );

    if (result == null || result.files.single.path == null) return;

    File audioFile = File(result.files.single.path!);

    bool found = await _findServerIP();
    if (!found || !mounted) return;

    setState(() {
      _isLoading = true;
      _prediction = "Uploading and analyzing file...";
      _confidence = "";
      _rawScores = "";
      _segmentPredictions = [];
      _detectedImagePath = null;
    });

    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_serverUrl/analyze/file'));
      request.files.add(await http.MultipartFile.fromPath('file', audioFile.path));

      var streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      var response = await http.Response.fromStream(streamedResponse);

      _handleServerResponse(response.statusCode, response.body);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _prediction = "Error: $e";
      });
    }
  }

  void _handleServerResponse(int statusCode, String responseBody) {
    if (!mounted) return;
    final data = jsonDecode(responseBody);

    if (statusCode == 200) {
      final predictionVal = data['prediction']?.toString().toLowerCase();
      final confidenceVal = data['confidence'];
      final rawScoresData = data['raw_scores'];
      final segments = data['segment_logs'] as List<dynamic>?;

      String formattedRaw = "";
      if (rawScoresData != null && rawScoresData is Map) {
        formattedRaw = rawScoresData.entries.map((e) {
          double val = (e.value is num) ? e.value.toDouble() : 0.0;
          String key = e.key.toString();
          if (key.isNotEmpty) {
            key = key[0].toUpperCase() + key.substring(1);
          }
          return "$key: ${val.toStringAsFixed(1)}";
        }).join('\n');
      }

      String? reason;
      String? img;
      switch (predictionVal) {
        case 'sleepiness': reason = 'Sleeping'; img = 'assets/sleeping.png'; break;
        case 'hunger': reason = 'Hunger'; img = 'assets/hunger.png'; break;
        case 'pain': reason = 'Pain'; img = 'assets/pain.png'; break;
        case 'discomfort': reason = 'Discomfort'; img = 'assets/discomfort.png'; break;
        default: reason = data['prediction'] ?? 'Unknown'; img = null;
      }

      setState(() {
        _prediction = reason!;
        _detectedImagePath = img;
        _confidence = confidenceVal != null ? "Confidence: ${(confidenceVal * 100).toStringAsFixed(1)}%" : "";
        _rawScores = formattedRaw;
        _segmentPredictions = segments?.map((s) => s.toString()).toList() ?? [];
        _matchedFile = data['matched_file'] ?? "";
        _isLoading = false;
        _isResultExpanded = true;
      });
    } else {
      setState(() {
        _isLoading = false;
        _prediction = "Analysis Failed: ${data['error'] ?? 'Server Error'}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cry Behavior (Testing)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.lightBlue[400],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.lightBlue[50],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLiveTestingSection(),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text("Cry Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              const SizedBox(height: 8),
              _buildReasonForCrySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveTestingSection() {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Analyze Cry via Pi',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()))
            else
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _startMicAnalysis,
                      icon: const Icon(Icons.mic, size: 16),
                      label: const Text("Mic", overflow: TextOverflow.ellipsis),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, 
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _startFileAnalysis,
                      icon: const Icon(Icons.upload_file, size: 16),
                      label: const Text("File", overflow: TextOverflow.ellipsis),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, 
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            _buildResultExpansionTile(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultExpansionTile() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 8),
        title: const Text("Check Result", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(_prediction, style: TextStyle(color: Colors.blueGrey[700], fontSize: 12)),
        initiallyExpanded: _isResultExpanded,
        onExpansionChanged: (val) => setState(() => _isResultExpanded = val),
        children: [
          if (_detectedImagePath != null)
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Image.asset(_detectedImagePath!, height: 60),
            ),
          if (_confidence.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
              child: Row(
                children: [
                  const Icon(Icons.bar_chart, color: Colors.blue, size: 16),
                  const SizedBox(width: 8),
                  Text(_confidence, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          if (_rawScores.isNotEmpty)
             Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.list, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_rawScores, style: const TextStyle(fontSize: 11))),
                ],
              ),
            ),
          if (_prediction != 'No test performed yet' && !_prediction.startsWith('Analysis Failed'))
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CryReasonDetailsPage(
                          reason: _prediction,
                          details: const {},
                          imagePath: _detectedImagePath,
                          userId: widget.userId,
                          confidence: _confidence,
                          rawScores: _rawScores,
                          segmentPredictions: _segmentPredictions,
                          matchedFile: _matchedFile,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 0),
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text("View Details", style: TextStyle(fontSize: 12)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReasonForCrySection() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10.0,
      mainAxisSpacing: 10.0,
      childAspectRatio: 1.2,
      children: [
        _buildReasonButton('Sleeping', Icons.nightlight_round, Colors.blue, 'assets/sleeping.png'),
        _buildReasonButton('Hunger', Icons.restaurant_menu, Colors.green, 'assets/hunger.png'),
        _buildReasonButton('Pain', Icons.healing, Colors.orange, 'assets/pain.png'),
        _buildReasonButton('Discomfort', Icons.thermostat, Colors.purple, 'assets/discomfort.png'),
      ],
    );
  }

  Widget _buildReasonButton(String reason, IconData icon, Color color, String imagePath) {
    return Card(
      elevation: 2.0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: InkWell(
        onTap: () => _showReasonDetails(reason, imagePath),
        borderRadius: BorderRadius.circular(10.0),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(height: 2.0),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    reason,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blueGrey[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReasonDetails(String reason, String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CryReasonDetailsPage(
          reason: reason,
          details: const {},
          imagePath: imagePath,
          userId: widget.userId,
        ),
      ),
    );
  }
}
