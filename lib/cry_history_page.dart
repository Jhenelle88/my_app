import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/database_helper.dart';

class CryHistoryPage extends StatefulWidget {
  final int userId;
  final DateTime initialDate;

  const CryHistoryPage({super.key, required this.userId, required this.initialDate});

  @override
  State<CryHistoryPage> createState() => _CryHistoryPageState();
}

class _CryHistoryPageState extends State<CryHistoryPage> {
  late Future<List<Map<String, dynamic>>> _historyFuture;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _historyFuture = DatabaseHelper.instance.getCryHistoryByDate(widget.userId, DateFormat.yMMMd().format(_selectedDate));
  }

  void _refreshHistory() {
    setState(() {
      _historyFuture = DatabaseHelper.instance.getCryHistoryByDate(widget.userId, DateFormat.yMMMd().format(_selectedDate));
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
        _refreshHistory();
      });
    }
  }

  void _changeDate(int days) {
    final newDate = _selectedDate.add(Duration(days: days));
    setState(() {
      _selectedDate = newDate;
      _refreshHistory();
    });
  }

  void _showSegmentsDialog(String? segmentsJson) {
    if (segmentsJson == null || segmentsJson.isEmpty || segmentsJson == '[]') {
       showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Segment Predictions'),
          content: const Text('No segment data available for this record.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
      return;
    }

    final segments = jsonDecode(segmentsJson) as List<dynamic>;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Segment Predictions'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: segments.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(segments[index].toString()));
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cry History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.lightBlue[400],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.lightBlue[50],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
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
                          isToday ? 'Today' : DateFormat.yMMMd().format(_selectedDate),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[700],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.calendar_today, color: Colors.lightBlue, size: 20),
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
          ),
          const Divider(),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _historyFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No cry history found for this date.'));
                }

                final records = snapshot.data!;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                    child: DataTable(
                      showCheckboxColumn: false, // Hides the checkbox column
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
                            DataCell(Text(record['accuracy'], style: TextStyle(color: record['accuracy'] == 'True' ? Colors.green : Colors.red, fontWeight: FontWeight.bold))),
                          ],
                          onSelectChanged: (selected) {
                            // Show dialog when any part of the row is tapped
                            _showSegmentsDialog(record['segments']);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
