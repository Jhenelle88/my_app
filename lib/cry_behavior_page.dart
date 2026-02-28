import 'package:flutter/material.dart';
import 'package:my_app/cry_reason_details_page.dart';

class CryBehaviorPage extends StatelessWidget {
  final int userId;

  const CryBehaviorPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cry Behavior', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.lightBlue[400],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.lightBlue[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _buildReasonForCrySection(context),
      ),
    );
  }

  Widget _buildReasonForCrySection(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          childAspectRatio: 1.1,
          children: [
            _buildReasonButton(context, 'Sleeping', Icons.nightlight_round, Colors.blue),
            _buildReasonButton(context, 'Hunger', Icons.restaurant_menu, Colors.green),
            _buildReasonButton(context, 'Pain', Icons.healing, Colors.orange),
            _buildReasonButton(context, 'Discomfort', Icons.thermostat, Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonButton(BuildContext context, String reason, IconData icon, Color color) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () => _showReasonDetails(context, reason),
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 26, color: color),
              const SizedBox(height: 2.0),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    reason,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blueGrey[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReasonDetails(BuildContext context, String reason) {
    Map<String, String> details;
    switch (reason) {
      case 'Sleeping':
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
        details = {};
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CryReasonDetailsPage(
          reason: reason,
          details: details,
          userId: userId,
        ),
      ),
    );
  }
}
