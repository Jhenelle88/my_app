import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:my_app/about_us_page.dart';
import 'package:my_app/basic_information_page.dart';
import 'package:my_app/cry_behavior_testing_page.dart';
import 'package:my_app/cry_history_page.dart';
import 'package:my_app/cry_reason_details_page.dart';
import 'package:my_app/cry_reason_info_page.dart'; // Import the new info page
import 'package:my_app/database_helper.dart';
import 'package:my_app/faq_page.dart';
import 'package:my_app/terms_and_conditions_page.dart';

class MainMenu extends StatefulWidget {
  final Map<String, dynamic> user;

  const MainMenu({super.key, required this.user});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  // --- STATE FROM ORIGINAL APP ---
  late Map<String, dynamic> _user;
  File? _image;
  bool _isNotificationExpanded = false;
  late Future<Map<String, int>> _cryCountsFuture;
  DateTime _selectedDate = DateTime.now();
  List<String> _segmentPredictions = [];

  // --- STATE FOR RASPBERRY PI CONNECTION ---
  String _serverUrl = '';
  bool _isLoading = false;
  String _prediction = 'Waiting for input...';
  String _confidence = '';
  String _matchedFile = '';
  String _errorMessage = '';
  String _rawScores = '';
  String? _detectedImagePath;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    if (_user['imagePath'] != null) {
      _image = File(_user['imagePath']);
    }
    _cryCountsFuture = DatabaseHelper.instance.getCryReasonCountsByDate(
        _user['id'], DateFormat.yMMMd().format(_selectedDate));
  }

  // =================================================================
  // ============ RASPBERRY PI CONNECTION & ANALYSIS LOGIC ===========
  // =================================================================

  Future<bool> _findServerIP() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
      _confidence = "";
      _matchedFile = "";
      _rawScores = "";
      _detectedImagePath = null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Searching for Raspberry Pi...'),
            duration: Duration(seconds: 4)),
      );
    });

    try {
      final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      socket.broadcastEnabled = true;
      final broadcastAddr = InternetAddress('255.255.255.255');
      socket.send(utf8.encode('CRYCOM_DISCOVER'), broadcastAddr, 5001);

      await for (RawSocketEvent event
      in socket.timeout(const Duration(seconds: 3))) {
        if (event == RawSocketEvent.read) {
          Datagram? dg = socket.receive();
          if (dg != null) {
            final message = utf8.decode(dg.data);
            if (message == 'CRYCOM_SERVER') {
              String discoveredIp = dg.address.address;
              _serverUrl = 'http://$discoveredIp:5002';
              print('✅ Found Raspberry Pi at: $_serverUrl');
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
      _showErrorDialog(
          "Device Not Found",
          "Could not find Raspberry Pi. Please ensure both your phone and the Pi are on the exact same Wi-Fi network and the Pi's server script is running.",
          context);
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
      _matchedFile = "";
      _rawScores = "";
      _detectedImagePath = null;
      _segmentPredictions = [];
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Recording & Analyzing via Pi...'),
            duration: Duration(seconds: 15)),
      );
    });

    try {
      final response = await http
          .post(
        Uri.parse('$_serverUrl/analyze/mic'),
        headers: {'Content-Type': 'application/json'},
      )
          .timeout(const Duration(seconds: 15));

      _handleServerResponse(response.statusCode, response.body, context);
    } on TimeoutException {
      setState(() {
        _isLoading = false;
        _prediction = "Connection Timed Out. Ensure the Pi is running the server.";
      });
    } catch (e) {
      _handleNetworkError(e, context);
    }
  }

  Future<void> _startFileAnalysis() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['wav'],
    );

    if (result == null || result.files.single.path == null) {
      return;
    }

    File audioFile = File(result.files.single.path!);

    bool found = await _findServerIP();
    if (!found || !mounted) return;

    setState(() {
      _isLoading = true;
      _prediction = "Uploading and analyzing file...";
      _confidence = "";
      _matchedFile = "";
      _rawScores = "";
      _detectedImagePath = null;
      _segmentPredictions = [];
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Uploading & Analyzing via Pi...'),
            duration: Duration(seconds: 15)),
      );
    });

    try {
      var request =
      http.MultipartRequest('POST', Uri.parse('$_serverUrl/analyze/file'));
      request.files
          .add(await http.MultipartFile.fromPath('file', audioFile.path));

      var streamedResponse =
      await request.send().timeout(const Duration(seconds: 15));
      var response = await http.Response.fromStream(streamedResponse);

      _handleServerResponse(response.statusCode, response.body, context);
    } on TimeoutException {
      setState(() {
        _isLoading = false;
        _prediction = "Connection Timed Out.";
      });
    } catch (e) {
      _handleNetworkError(e, context);
    }
  }

  void _handleServerResponse(
      int statusCode, String responseBody, BuildContext context) {
    if (!mounted) return;

    final data = jsonDecode(responseBody);

    if (statusCode == 500 &&
        data['error'] != null &&
        data['error'].toString().contains('Invalid sample rate')) {
      setState(() {
        _isLoading = false;
        _prediction = 'Analysis Failed';
      });
      _showErrorDialog(
          "Microphone Error on Raspberry Pi",
          "The app connected to the Pi, but the Pi's microphone failed to record.\n\nReason: Invalid Sample Rate.\n\nThis is a hardware mismatch on the Pi. Please check that the microphone connected to the Pi supports the required sample rate.",
          context);
      return;
    }

    if (statusCode == 200) {
      final prediction = data['prediction']?.toString().toLowerCase();
      final segments = data['segment_logs'] as List<dynamic>?;
      final confidenceVal = data['confidence'];
      final matchedFileVal = data['matched_file'];
      final rawScoresData = data['raw_scores'];

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
      String? imagePath;

      switch (prediction) {
        case 'sleepiness':
          reason = 'Sleeping';
          imagePath = 'assets/sleeping.png';
          break;
        case 'hungry':
        case 'hunger':
          reason = 'Hunger';
          imagePath = 'assets/hunger.png';
          break;
        case 'pain':
          reason = 'Pain';
          imagePath = 'assets/pain.png';
          break;
        case 'discomfort':
          reason = 'Discomfort';
          imagePath = 'assets/discomfort.png';
          break;
        default:
          setState(() {
            _prediction = "Cry Detected: Non Cry";
            _segmentPredictions = segments?.map((s) => s.toString()).toList() ?? [];
            _confidence = confidenceVal != null ? "Confidence: ${(confidenceVal * 100).toStringAsFixed(1)}%" : "";
            _matchedFile = matchedFileVal != null ? "Matched: $matchedFileVal" : "";
            _rawScores = formattedRaw;
            _detectedImagePath = 'assets/NON CRY.png';
            _isLoading = false;
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CryReasonDetailsPage(
                reason: 'Non Cry',
                details: const {},
                imagePath: 'assets/NON CRY.png',
                userId: _user['id'],
                segmentPredictions: _segmentPredictions,
                confidence: _confidence,
                matchedFile: _matchedFile,
                rawScores: _rawScores,
              ),
            ),
          ).then((_) {
            _refreshCryCounts();
          });
          return;
      }

      setState(() {
        _prediction = "Cry Detected: $reason";
        _segmentPredictions = segments?.map((s) => s.toString()).toList() ?? [];
        _confidence = confidenceVal != null ? "Confidence: ${(confidenceVal * 100).toStringAsFixed(1)}%" : "";
        _matchedFile = matchedFileVal != null ? "Matched Pristine File: $matchedFileVal" : "";
        _rawScores = formattedRaw;
        _detectedImagePath = imagePath;
        _isLoading = false;
      });

      // Automatically navigate to details page on detection
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CryReasonDetailsPage(
            reason: reason!,
            details: const {}, // Pass empty details for detection results
            imagePath: imagePath!,
            userId: _user['id'],
            segmentPredictions: _segmentPredictions,
            confidence: _confidence,
            matchedFile: _matchedFile,
            rawScores: _rawScores,
          ),
        ),
      ).then((_) {
        _refreshCryCounts();
      });

    } else {
      setState(() {
        _isLoading = false;
        _prediction = "Analysis Failed";
      });
      _showErrorDialog("Server Error: $statusCode", data['error'] ?? responseBody, context);
    }
  }

  void _handleNetworkError(dynamic error, BuildContext context) {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _prediction = "Connection Failed";
      _confidence = error.toString();
    });
    _showNetworkErrorDialog(
        "Network Error",
        "Could not connect to Raspberry Pi.\n\n$error",
        context);
  }

  void _showErrorDialog(String title, String content, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(child: Text(content)),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showNetworkErrorDialog(String title, String content, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(child: Text(content)),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _refreshCryCounts() {
    setState(() {
      _cryCountsFuture = DatabaseHelper.instance.getCryReasonCountsByDate(
          _user['id'], DateFormat.yMMMd().format(_selectedDate));
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100), // Allow picking future dates
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _refreshCryCounts();
      });
    }
  }

  void _changeDate(int days) {
    final newDate = _selectedDate.add(Duration(days: days));
    setState(() {
      _selectedDate = newDate;
      _refreshCryCounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4.0,
        backgroundColor: Colors.lightBlue[400],
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            Image.asset(
              'assets/LOGO.png',
              height: 40,
            ),
            const SizedBox(width: 8),
            const Text(
              'CRYCOM',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.lightBlue[400],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/trans.png',
                    height: 60,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'CRYCOM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.lightBlue),
              title: const Text('Cry History'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CryHistoryPage(userId: _user['id'], initialDate: _selectedDate)),
                ).then((_) => _refreshCryCounts());
              },
            ),
            const Divider(),
            ListTile(
              title: Text(
                'FAQ & Resources',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.description, color: Colors.lightBlue),
              title: const Text('Terms and Conditions'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TermsAndConditionsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.lightBlue),
              title: const Text('About Us'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutUsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline, color: Colors.lightBlue),
              title: const Text('FAQs'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FaqPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.lightBlue[50],
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildNotificationContent(),
                const SizedBox(height: 24.0),
                _buildControlsSection(),
                const SizedBox(height: 24.0),
                Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildBarGraphContent(),
                        const SizedBox(height: 16.0),
                        const Divider(),
                        const SizedBox(height: 16.0),
                        _buildHistorySection(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildReasonForCrySection(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationContent() {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: Colors.red[100],
      child: ExpansionTile(
        leading: _detectedImagePath != null
            ? Image.asset(_detectedImagePath!, height: 40)
            : Icon(Icons.notifications_active, color: Colors.red[800], size: 32.0),
        title: Text(
          'Baby Status',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.red[800],
          ),
        ),
        subtitle: Text(
          _prediction,
          style: TextStyle(fontSize: 16.0, color: Colors.red[700]),
        ),
        trailing: Icon(
          _isNotificationExpanded
              ? Icons.arrow_drop_up
              : Icons.arrow_drop_down,
          color: Colors.red[800],
        ),
        onExpansionChanged: (bool expanded) {
          setState(() {
            _isNotificationExpanded = expanded;
          });
        },
        children: [
          if (_prediction != 'Waiting for input...')
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Check Result", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey)),
                  const Divider(),
                  if (_confidence.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(_confidence, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  if (_rawScores.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(_rawScores, style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
                    ),
                ],
              ),
            ),
          if (_matchedFile.isNotEmpty)
            ListTile(title: Text(_matchedFile, style: const TextStyle(fontStyle: FontStyle.italic))),
          ..._segmentPredictions
              .map((segment) => ListTile(title: Text(segment)))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildControlsSection() {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Analyze Cry',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
            const SizedBox(height: 16.0),
            if (_isLoading)
              const Center(child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ))
            else
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                      ),
                      onPressed: _startMicAnalysis,
                      icon: const Icon(Icons.mic, color: Colors.white, size: 18),
                      label: const Text('Trigger Mic',
                          style: TextStyle(color: Colors.white, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        padding: const EdgeInsets.symmetric( vertical: 10.0),
                      ),
                      onPressed: _startFileAnalysis,
                      icon: const Icon(Icons.upload_file, color: Colors.white, size: 18),
                      label: const Text('Upload File',
                          style: TextStyle(color: Colors.white, fontSize: 13)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarGraphContent() {
    bool isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());

    return FutureBuilder<Map<String, int>>(
      future: _cryCountsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final cryCounts = snapshot.data ?? {};
        final double maxCount =
        (cryCounts.values.isEmpty ? 0 : cryCounts.values.reduce(max))
            .toDouble();

        double getNiceMaxValue(double maxValue) {
          if (maxValue <= 0) return 10;
          final exponent = (log(maxValue) / ln10).floor();
          final powerOf10 = pow(10, exponent);
          final msd = (maxValue / powerOf10).ceil();
          if (msd > 5) return 10 * powerOf10.toDouble();
          if (msd > 2) return 5 * powerOf10.toDouble();
          return 2 * powerOf10.toDouble();
        }

        final double maxY = getNiceMaxValue(maxCount);
        final double interval = (maxY / 5).ceilToDouble();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Cry Analysis',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_left),
                  onPressed: () => _changeDate(-1),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isToday
                              ? 'Today'
                              : DateFormat.yMMMd().format(_selectedDate),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[700],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.calendar_today,
                            color: Colors.lightBlue, size: 20),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_right),
                  onPressed: () => _changeDate(1), // Always allow navigating forward
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            if (cryCounts.isEmpty)
              const Center(child: Text('No cry data to display for this date.'))
            else
              AspectRatio(
                aspectRatio: 1.6,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (group) => Colors.blueGrey[800]!,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            rod.toY.round().toString(),
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            final style = TextStyle(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            );
                            String text;
                            switch (value.toInt()) {
                              case 0:
                                text = 'Pain';
                                break;
                              case 1:
                                text = 'Hunger';
                                break;
                              case 2:
                                text = 'Sleep';
                                break;
                              case 3:
                                text = 'Discomfort';
                                break;
                              default:
                                text = '';
                                break;
                            }
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 8.0,
                              child: Text(text, style: style),
                            );
                          },
                          reservedSize: 38,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: interval,
                          getTitlesWidget: (value, meta) {
                            if (value > meta.max) {
                              return Container();
                            }
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                  color: Colors.grey[700], fontSize: 10),
                              textAlign: TextAlign.left,
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: interval,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey[300]!,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    barGroups: [
                      _buildBarChartGroupData(
                          0, cryCounts['Pain']?.toDouble() ?? 0, Colors.orange, maxY),
                      _buildBarChartGroupData(1,
                          cryCounts['Hunger']?.toDouble() ?? 0, Colors.green, maxY),
                      _buildBarChartGroupData(2,
                          cryCounts['Sleeping']?.toDouble() ?? 0, Colors.blue, maxY),
                      _buildBarChartGroupData(
                          3,
                          cryCounts['Discomfort']?.toDouble() ?? 0,
                          Colors.purple,
                          maxY),
                    ],
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 375),
                  swapAnimationCurve: Curves.easeIn,
                ),
              ),
          ],
        );
      },
    );
  }

  BarChartGroupData _buildBarChartGroupData(
      int x, double y, Color color, double maxY) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 22,
          color: color.withOpacity(0.8),
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: maxY,
            color: Colors.grey[200],
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySection() {
    return Center(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightBlue[400],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding:
          const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CryHistoryPage(
                    userId: _user['id'], initialDate: _selectedDate)),
          ).then((_) => _refreshCryCounts());
        },
        icon: const Icon(Icons.history, color: Colors.white),
        label: const Text('View Full History',
            style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }

  Widget _buildReasonForCrySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Reason for Cry',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[800],
          ),
        ),
        const SizedBox(height: 16.0),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            _buildReasonButton('Sleeping', Icons.nightlight_round, Colors.blue),
            _buildReasonButton(
                'Hunger', Icons.restaurant_menu, Colors.green),
            _buildReasonButton('Pain', Icons.healing, Colors.orange),
            _buildReasonButton(
                'Discomfort', Icons.thermostat, Colors.purple),
          ],
        ),
      ],
    );
  }

  Widget _buildReasonButton(String reason, IconData icon, Color color) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () => _showReasonDetails(reason),
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8.0),
              Text(
                reason,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.blueGrey[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReasonDetails(String reason) {
    Map<String, String> details;
    String imagePath;
    switch (reason) {
      case 'Sleeping':
        imagePath = 'assets/sleeping.png';
        details = {
          'Cry Pattern': 'Soft, rhythmic, low intensity',
          'Detected By':
          'Low audio frequency\nShort cry duration\nMinimal body movement (motion sensor)',
          'Indicator': 'Baby is drowsy or transitioning to sleep',
          'What to Do':
          'Dim lights and reduce noise\nGently rock or swaddle the baby\nPlace the baby in a comfortable sleeping position',
        };
        break;
      case 'Hunger':
        imagePath = 'assets/hunger.png';
        details = {
          'Cry Pattern': 'Repetitive, rising pitch, rhythmic',
          'Detected By':
          'Increasing cry intensity over time\nRegular intervals between cries\nTime elapsed since last feeding (timer/log data)',
          'Indicator': 'Feeding likely needed',
          'What to Do':
          'Feed the baby immediately\nEnsure proper feeding position\nBurp the baby after feeding',
        };
        break;
      case 'Discomfort':
        imagePath = 'assets/discomfort.png';
        details = {
          'Cry Pattern': 'Irregular, fussy, moderate pitch',
          'Detected By':
          'Sudden cry onset\nTemperature sensor (too hot/cold)\nMoisture sensor (wet diaper)\nIncreased body movement',
          'Indicator': 'Environmental or physical discomfort',
          'What to Do':
          'Check and change diaper if needed\nAdjust clothing or room temperature\nReposition the baby for comfort',
        };
        break;
      case 'Pain':
        imagePath = 'assets/pain.png';
        details = {
          'Cry Pattern': 'Loud, sharp, high-pitched, continuous',
          'Detected By':
          'High audio frequency and amplitude\nProlonged crying with no pauses\nStrong, erratic movements (motion sensor)',
          'Indicator': 'Possible pain, illness, or distress',
          'What to Do':
          'Check for signs of pain (teething, gas, fever)\nComfort and soothe the baby\nSeek medical attention if crying continues',
        };
        break;
      default:
        imagePath = 'assets/NON CRY.png';
        details = {};
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CryReasonInfoPage(
          reason: reason,
          details: details,
          imagePath: imagePath,
        ),
      ),
    ).then((_) => _refreshCryCounts());
  }
}
