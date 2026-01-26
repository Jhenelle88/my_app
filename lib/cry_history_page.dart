import 'package:flutter/material.dart';
import 'package:my_app/database_helper.dart';

class CryHistoryPage extends StatefulWidget {
  final int userId;

  const CryHistoryPage({super.key, required this.userId});

  @override
  State<CryHistoryPage> createState() => _CryHistoryPageState();
}

class _CryHistoryPageState extends State<CryHistoryPage> {
  late Future<List<Map<String, dynamic>>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = DatabaseHelper.instance.getCryHistory(widget.userId);
  }

  Future<void> _clearHistory() async {
    // This is a placeholder for the actual implementation of clearing the history
    // For now, it will just refresh the state.
    setState(() {
      _historyFuture = DatabaseHelper.instance.getCryHistory(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cry History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.lightBlue[400],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _clearHistory,
            tooltip: 'Clear History',
          ),
        ],
      ),
      backgroundColor: Colors.lightBlue[50],
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No cry history found.'));
          }

          final records = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: DataTable(
                  columnSpacing: 38.0,
                  columns: const <DataColumn>[
                    DataColumn(
                      label: Text(
                        'Time',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Output',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Accuracy',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey),
                      ),
                    ),
                  ],
                  rows: records.map((record) {
                    return DataRow(
                      cells: <DataCell>[
                        DataCell(Text(record['time'])),
                        DataCell(Text(record['output'])),
                        DataCell(Text(record['accuracy'], style: TextStyle(color: record['accuracy'] == 'True' ? Colors.green : Colors.red))),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
