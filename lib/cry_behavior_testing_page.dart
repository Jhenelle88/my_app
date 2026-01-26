import 'package:flutter/material.dart';
import 'package:my_app/cry_reason_details_page.dart';

class CryBehaviorTestingPage extends StatefulWidget {
  final int userId;

  const CryBehaviorTestingPage({super.key, required this.userId});

  @override
  State<CryBehaviorTestingPage> createState() => _CryBehaviorTestingPageState();
}

class _CryBehaviorTestingPageState extends State<CryBehaviorTestingPage> {
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
          child: _buildReasonForCrySection(),
        ),
      ),
    );
  }

  Widget _buildReasonForCrySection() {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            _buildReasonButton('Sleeping', Icons.nightlight_round, Colors.blue, 'assets/sleeping.png'),
            _buildReasonButton('Hunger', Icons.restaurant_menu, Colors.green, 'assets/hunger.png'),
            _buildReasonButton('Pain', Icons.healing, Colors.orange, 'assets/pain.png'),
            _buildReasonButton('Discomfort', Icons.thermostat, Colors.purple, 'assets/discomfort.png'),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonButton(String reason, IconData icon, Color color, String imagePath) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () => _showReasonDetails(reason, imagePath),
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12.0),
              Text(
                reason,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.blueGrey[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
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
