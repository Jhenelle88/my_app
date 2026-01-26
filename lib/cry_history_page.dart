import 'package:flutter/material.dart';

class CryHistoryPage extends StatelessWidget {
  const CryHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cry History'),
        backgroundColor: Colors.lightBlue[400],
      ),
      body: Center(
        child: Text('This is the Cry History page.'),
      ),
    );
  }
}
