import 'package:flutter/material.dart';

class CryReasonDetailsPage extends StatelessWidget {
  final String reason;
  final Map<String, String> details;

  const CryReasonDetailsPage({super.key, required this.reason, required this.details});

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

  @override
  Widget build(BuildContext context) {
    final Color reasonColor = _getColorForReason(reason);

    return Scaffold(
      appBar: AppBar(
        title: Text(reason, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: reasonColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.grey[100],
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: details.entries.length,
          itemBuilder: (context, index) {
            final entry = details.entries.elementAt(index);
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
    );
  }
}
