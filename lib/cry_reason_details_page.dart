import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/database_helper.dart';

class CryReasonDetailsPage extends StatefulWidget {
  final String reason;
  final Map<String, String> details;
  final String? imagePath;
  final int userId;

  const CryReasonDetailsPage({super.key, required this.reason, required this.details, this.imagePath, required this.userId});

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
    final newRecord = {
      'userId': widget.userId,
      'time': time,
      'output': widget.reason,
      'accuracy': isCorrect ? 'True' : 'False',
    };
    await DatabaseHelper.instance.insertCryRecord(newRecord);

    // Navigate back or show a confirmation
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final Color reasonColor = _getColorForReason(widget.reason);
    final Color backgroundColor = _getBackgroundColorForReason(widget.reason);
    final String mainText = _getMainTextForReason(widget.reason);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reason, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: reasonColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: backgroundColor,
        child: widget.details.isNotEmpty
            ? ListView.builder(
                padding: const EdgeInsets.all(16.0),
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
              )
            : (widget.imagePath != null
                ? Center(
                    child: SingleChildScrollView(
                      child: Card(
                        color: Colors.white.withOpacity(0.8),
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                mainText,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: reasonColor,
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isExpanded = !_isExpanded;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _isExpanded ? 'Hide Results' : 'Check Results Here',
                                        style: const TextStyle(color: Colors.white, fontSize: 14),
                                      ),
                                      if (_isExpanded)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: List.generate(4, (index) => Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                                              child: Text('Segment ${index + 1}:', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                            )),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                                ),
                                child: Image.asset(
                                  widget.imagePath!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () => _handleFeedback(true),
                                    icon: const Icon(Icons.check, color: Colors.white),
                                    label: const Text('Correct', style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () => _handleFeedback(false),
                                    icon: const Icon(Icons.close, color: Colors.white),
                                    label: const Text('Incorrect', style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
