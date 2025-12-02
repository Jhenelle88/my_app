
import 'package:flutter/material.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4.0,
        backgroundColor: Colors.lightBlue[400],
        title: Row(
          children: [
            Image.asset(
              'assets/LOGO.png',
              height: 40,
            ),
            const SizedBox(width: 8),
            const Text(
              'CRYCOM',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Container(
          color: Colors.lightBlue[100],
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const SizedBox(height: 20),
              Text(
                'Frequently Asked Questions (FAQs)',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.lightBlue[800],
                    ),
              ),
              const SizedBox(height: 16),
              _buildFaqItem(
                '1. What is CRYCOM?',
                '''CRYCOM is an infant-care system that uses advanced hardware and software to analyze and interpret your baby’s cries. It identifies whether your baby is hungry, uncomfortable, in pain, or sleepy and provides real-time notifications to help parents respond promptly.''',
              ),
              _buildFaqItem(
                '2. How does CRYCOM recognize my baby’s cries?',
                '''CRYCOM uses directional microphones, signal processing, and edge-based deep learning to analyze the sound patterns of your baby’s cry. All processing is done offline on the device, ensuring privacy and security.''',
              ),
              _buildFaqItem(
                '3. Is my baby’s data safe?',
                '''Yes. CRYCOM performs all cry analysis offline, so your baby’s audio and data never leave the device, keeping your information completely private.''',
              ),
              _buildFaqItem(
                '4. Can I view past cry histories?',
                '''Absolutely. The CRYCOM app stores past cry data, allowing you to view records, analyze trends, and see bar graph visualizations of your baby’s crying patterns over time.''',
              ),
              _buildFaqItem(
                '5. Will I get real-time notifications?',
                '''Yes. CRYCOM sends instant notifications to your app, informing you why your baby may be crying so you can respond quickly and confidently.''',
              ),
              _buildFaqItem(
                '6. Do I need an internet connection to use CRYCOM?',
                '''No. CRYCOM works fully offline, thanks to edge-based processing. Internet access is not required for cry recognition or notifications.''',
              ),
              _buildFaqItem(
                '7. Can CRYCOM distinguish between multiple babies?',
                '''Currently, CRYCOM is designed for use with one baby at a time. Future updates may expand features for multiple infants.''',
              ),
              _buildFaqItem(
                '8. How do I set up CRYCOM?',
                '''Setup is simple: connect the hardware device near your baby, install the mobile app, and follow the on-screen instructions to pair and start monitoring.''',
              ),
              _buildFaqItem(
                '9. Is CRYCOM suitable for newborns and infants?',
                '''Yes. CRYCOM is designed specifically for babies aged 0–12 months, providing safe, non-intrusive monitoring during this critical stage of development.''',
              ),
              _buildFaqItem(
                '10. Can I rely solely on CRYCOM to take care of my baby?',
                '''CRYCOM is a support tool to help parents understand their baby’s needs faster. It is not a replacement for parental care, supervision, or medical advice.''',
              ),
              const SizedBox(height: 24),
              Text(
                'Tips & Troubleshooting',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.lightBlue[800],
                    ),
              ),
              const SizedBox(height: 16),
              _buildTipItem(
                'Device Placement:',
                'Place the CRYCOM device near your baby but out of reach. Avoid placing it near loud fans or air conditioners to reduce background noise.',
              ),
              _buildTipItem(
                'Battery & Charging:',
                'Ensure the device is charged or connected to power for continuous monitoring.',
              ),
              _buildTipItem(
                'App Notifications:',
                'Make sure your phone’s notifications are enabled for CRYCOM to receive instant alerts.',
              ),
              _buildTipItem(
                'Resetting the Device:',
                'If the device is not responding, unplug it, wait 10 seconds, and plug it back in.',
              ),
               _buildTipItem(
                'Analyzing Patterns:',
                'Check the app’s bar graph to identify trends and common causes of crying over time.',
              ),
              _buildTipItem(
                'Support:',
                'For additional help, refer to the user manual or contact CRYCOM support via the app.',
              ),
            ],
          )),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(answer),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String title, String content) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lightbulb_outline, color: Colors.lightBlue[800], size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(content),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
