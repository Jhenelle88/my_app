import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/database_helper.dart';

class CryReasonDetailsPage extends StatefulWidget {
  final String reason;
  final Map<String, String> details;
  final String? imagePath;
  final int userId;
  final List<String> segmentPredictions;
  final String confidence;
  final String matchedFile;
  final String rawScores;

  const CryReasonDetailsPage({
    super.key,
    required this.reason,
    required this.details,
    this.imagePath,
    required this.userId,
    this.segmentPredictions = const [],
    this.confidence = '',
    this.matchedFile = '',
    this.rawScores = '',
  });

  @override
  State<CryReasonDetailsPage> createState() => _CryReasonDetailsPageState();
}

class _CryReasonDetailsPageState extends State<CryReasonDetailsPage> {
  bool _isExpanded = false;

  Color _getColorForReason(String reason) {
    switch (reason) {
      case 'Sleeping':
        return Colors.blue;
      case 'Hunger':
        return Colors.green;
      case 'Pain':
        return Colors.orange;
      case 'Discomfort':
        return Colors.purple;
      case 'Non Cry':
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }

  Color _getBackgroundColorForReason(String reason) {
    switch (reason) {
      case 'Sleeping':
        return Colors.blue[50]!;
      case 'Hunger':
        return Colors.green[50]!;
      case 'Pain':
        return Colors.orange[50]!;
      case 'Discomfort':
        return Colors.purple[50]!;
      case 'Non Cry':
        return Colors.blueGrey[50]!;
      default:
        return Colors.grey[200]!;
    }
  }

  String _getMainTextForReason(String reason) {
    switch (reason) {
      case 'Sleeping':
        return 'Baby is Sleepy!';
      case 'Hunger':
        return 'Baby is Hungry!';
      case 'Pain':
        return 'Baby is in Pain!';
      case 'Discomfort':
        return 'Baby is in Discomfort!';
      case 'Non Cry':
        return 'No Cry Detected!';
      default:
        return 'Cry Detected!';
    }
  }

  void _handleFeedback(bool isCorrect) async {
    final now = DateTime.now();
    final time = DateFormat('hh:mm a').format(now);
    final date = DateFormat.yMMMd().format(now);
    final newRecord = {
      'userId': widget.userId,
      'time': time,
      'date': date,
      'output': widget.reason,
      'accuracy': isCorrect ? 'True' : 'False',
      'segments': jsonEncode(widget.segmentPredictions),
    };
    await DatabaseHelper.instance.insertCryRecord(newRecord);

    if (mounted) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color reasonColor = _getColorForReason(widget.reason);
    final Color backgroundColor = _getBackgroundColorForReason(widget.reason);
    final String mainText = _getMainTextForReason(widget.reason);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  color: Colors.white,
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          mainText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: reasonColor,
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            leading: widget.imagePath != null ? Image.asset(widget.imagePath!, height: 32) : null,
                            title: Text('Check Result', style: TextStyle(color: reasonColor, fontWeight: FontWeight.bold, fontSize: 14)),
                            tilePadding: EdgeInsets.zero,
                            initiallyExpanded: _isExpanded,
                            onExpansionChanged: (bool expanded) {
                              setState(() {
                                _isExpanded = expanded;
                              });
                            },
                            children: [
                              if (widget.confidence.isNotEmpty)
                                ListTile(
                                  dense: true,
                                  title: const Text('Confidence', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  subtitle: Text(widget.confidence, style: const TextStyle(fontSize: 12)),
                                  leading: Icon(Icons.bar_chart, color: reasonColor, size: 20),
                                ),
                              if (widget.rawScores.isNotEmpty)
                                ListTile(
                                  dense: true,
                                  title: const Text('Raw Scores', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  subtitle: Text(widget.rawScores, style: const TextStyle(fontSize: 11)),
                                  leading: Icon(Icons.list, color: reasonColor, size: 20),
                                ),
                              if (widget.matchedFile.isNotEmpty)
                                ListTile(
                                  dense: true,
                                  title: const Text('Matched File', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  subtitle: Text(widget.matchedFile, style: const TextStyle(fontSize: 11)),
                                  leading: Icon(Icons.audio_file, color: reasonColor, size: 20),
                                ),
                            ],
                          ),
                        ),
                        if (widget.imagePath != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Image.asset(
                              widget.imagePath!,
                              fit: BoxFit.contain,
                              height: MediaQuery.of(context).size.height * 0.25,
                            ),
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _handleFeedback(true),
                                icon: const Icon(Icons.check, color: Colors.white, size: 18),
                                label: const Text('Correct', style: TextStyle(color: Colors.white, fontSize: 14)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _handleFeedback(false),
                                icon: const Icon(Icons.close, color: Colors.white, size: 18),
                                label: const Text('Incorrect', style: TextStyle(color: Colors.white, fontSize: 14)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}