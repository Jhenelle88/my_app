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

  const CryReasonDetailsPage({
    super.key,
    required this.reason,
    required this.details,
    this.imagePath,
    required this.userId,
    this.segmentPredictions = const [],
  });

  @override
  State<CryReasonDetailsPage> createState() => _CryReasonDetailsPageState();
}

class _CryReasonDetailsPageState extends State<CryReasonDetailsPage> {
  bool _isExpanded = false;

  IconData _getIconForDetail(String detailKey) {
    switch (detailKey) {
      case 'Cry Pattern':
        return Icons.waves;
      case 'Detected By':
        return Icons.sensors;
      case 'Indicator':
        return Icons.lightbulb_outline;
      case 'What to Do':
        return Icons.healing;
      default:
        return Icons.info_outline;
    }
  }

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
      default:
        return Colors.grey;
    }
  }

  Color _getBackgroundColorForReason(String reason) {
    switch (reason) {
      case 'Sleeping':
        return Colors.blue[100]!;
      case 'Hunger':
        return Colors.green[100]!;
      case 'Pain':
        return Colors.orange[100]!;
      case 'Discomfort':
        return Colors.purple[100]!;
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
        return 'Baby has Abdominal Pain!';
      case 'Discomfort':
        return 'Baby is in Discomfort!';
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
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color reasonColor = _getColorForReason(widget.reason);
    final Color backgroundColor = _getBackgroundColorForReason(widget.reason);
    final String mainText = _getMainTextForReason(widget.reason);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        color: backgroundColor.withOpacity(0.9),
        child: widget.details.isNotEmpty
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: widget.details.entries.length,
                    itemBuilder: (context, index) {
                      final entry = widget.details.entries.elementAt(index);
                      final lines = entry.value.split('\n');
                      return Card(
                        elevation: 4.0,
                        margin: const EdgeInsets.only(bottom: 16.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(_getIconForDetail(entry.key), color: reasonColor, size: 28),
                                  const SizedBox(width: 12.0),
                                  Expanded(
                                    child: Text(
                                      entry.key,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0,
                                        color: reasonColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24.0, thickness: 1.0),
                              ...lines.map((line) => Padding(
                                    padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4.0),
                                          child: Icon(Icons.arrow_right, color: Colors.blueGrey[300], size: 16),
                                        ),
                                        const SizedBox(width: 8.0),
                                        Expanded(
                                          child: Text(
                                            line,
                                            style: TextStyle(fontSize: 16.0, height: 1.4, color: Colors.blueGrey[800]),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                                  .toList(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
            : (widget.imagePath != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: SingleChildScrollView(
                        child: Card(
                          color: Colors.white,
                          elevation: 8.0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  mainText,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: reasonColor,
                                  ),
                                ),
                                const SizedBox(height: 16.0),
                                if (widget.segmentPredictions.isNotEmpty)
                                  ExpansionTile(
                                    title: Text('Check Results Here', style: TextStyle(color: reasonColor, fontWeight: FontWeight.bold)),
                                    onExpansionChanged: (bool expanded) {
                                      setState(() {
                                        _isExpanded = expanded;
                                      });
                                    },
                                    initiallyExpanded: _isExpanded,
                                    children: widget.segmentPredictions.map((prediction) => ListTile(title: Text(prediction))).toList(),
                                  ),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                                    child: Image.asset(
                                      widget.imagePath!,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _handleFeedback(true),
                                        icon: const Icon(Icons.check, color: Colors.white),
                                        label: const Text('Correct', style: TextStyle(color: Colors.white)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12.0),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16.0),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _handleFeedback(false),
                                        icon: const Icon(Icons.close, color: Colors.white),
                                        label: const Text('Incorrect', style: TextStyle(color: Colors.white)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12.0),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : const Center(
                    child: Text('No details to display.'),
                  )),
      ),
    );
  }
}
