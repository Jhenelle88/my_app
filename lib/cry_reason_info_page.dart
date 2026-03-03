import 'package:flutter/material.dart';

class CryReasonInfoPage extends StatelessWidget {
  final String reason;
  final Map<String, String> details;
  final String imagePath;

  const CryReasonInfoPage({
    super.key,
    required this.reason,
    required this.details,
    required this.imagePath,
  });

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
        return Colors.blue[50]!;
      case 'Hunger':
        return Colors.green[50]!;
      case 'Pain':
        return Colors.orange[50]!;
      case 'Discomfort':
        return Colors.purple[50]!;
      default:
        return Colors.grey[100]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color reasonColor = _getColorForReason(reason);
    final Color backgroundColor = _getBackgroundColorForReason(reason);

    return Scaffold(
      appBar: AppBar(
        title: Text(reason, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor: reasonColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
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
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Baby is ${reason == 'Sleeping' ? 'Sleepy' : reason}!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: reasonColor,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Column(
                          children: details.entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(_getIconForDetail(entry.key), color: reasonColor, size: 22),
                                      const SizedBox(width: 8),
                                      Text(
                                        entry.key,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: reasonColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ...entry.value.split('\n').map((line) => Padding(
                                    padding: const EdgeInsets.only(left: 30.0, bottom: 4),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(Icons.arrow_right, color: Colors.blueGrey[300], size: 18),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            line,
                                            style: TextStyle(fontSize: 16, color: Colors.blueGrey[800], height: 1.4),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )).toList(),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24.0),
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.contain,
                            height: MediaQuery.of(context).size.height * 0.3,
                          ),
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
