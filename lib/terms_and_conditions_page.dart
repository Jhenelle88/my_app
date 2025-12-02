
import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CRYCOM Terms and Conditions',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Effective Date: November 27, 2025',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('1. Acceptance of Terms'),
              _buildSectionContent(
                  'By accessing or using CRYCOM, you confirm that you have read, understood, and agreed to these Terms and Conditions. If you do not agree, please do not use the Service.'),
              _buildSectionTitle('2. Use of the Service'),
              _buildSectionContent(
                  'CRYCOM is designed for monitoring and analyzing infant cries for babies aged 0–12 months. The Service is intended for personal, non-commercial use by parents or caregivers.'),
              const SizedBox(height: 16),
              _buildSectionContent('You agree not to:'),
              const SizedBox(height: 8),
              _buildBulletPoint('Use the Service for any illegal purpose.'),
              _buildBulletPoint(
                  'Attempt to reverse engineer, tamper with, or modify the hardware or software.'),
              _buildBulletPoint(
                  'Share the Service or its data with unauthorized users.'),
              _buildSectionTitle('3. Privacy and Data'),
              _buildSectionContent(
                  'CRYCOM processes audio data offline, keeping your baby’s information private and secure. We do not store, share, or transmit your baby’s audio recordings outside the device. By using the Service, you consent to the collection and processing of cry data for analysis purposes solely on your device.'),
              _buildSectionTitle('4. Notifications and Monitoring'),
              _buildSectionContent(
                  'CRYCOM provides real-time notifications about your baby’s cry patterns. These alerts are intended as a support tool and not a substitute for parental care, supervision, or medical advice. Users are responsible for their baby’s well-being and for responding appropriately.'),
              _buildSectionTitle('5. Limitations of Liability'),
              _buildSectionContent(
                  'CRYCOM is provided “as is” and “as available.” We are not liable for:'),
              const SizedBox(height: 8),
              _buildBulletPoint(
                  'Any direct, indirect, or incidental damages resulting from the use of the Service.'),
              _buildBulletPoint(
                  'Misinterpretation of cry data or delayed response to alerts.'),
              _buildBulletPoint('Loss of data or device malfunction.'),
              const SizedBox(height: 16),
               _buildSectionContent('Parents and caregivers are responsible for ensuring safe use of the hardware and app.'),
              _buildSectionTitle('6. Intellectual Property'),
              _buildSectionContent(
                  'All content, software, and designs related to CRYCOM are the property of the developers. Users may not copy, distribute, or reproduce the Service without written permission.'),
              _buildSectionTitle('7. Modifications to Terms'),
              _buildSectionContent(
                  'We may update these Terms and Conditions from time to time. Continued use of the Service constitutes your acceptance of the updated terms.'),
              _buildSectionTitle('8. Governing Law'),
              _buildSectionContent(
                  'These Terms and Conditions are governed by and construed under the laws of [Insert Country/Region], without regard to conflict of laws principles.'),
              _buildSectionTitle('9. Contact Us'),
              _buildSectionContent(
                  'For questions, concerns, or support, please contact:'),
               const SizedBox(height: 8),
              _buildSectionContent('Email: crycom@gmail.com'),
              _buildSectionContent('Contact Number: 09567667607'),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  'By using CRYCOM, you acknowledge that you have read, understood, and agreed to these Terms and Conditions.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.lightBlue[800],
        ),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[850],
        height: 1.5,
      ),
    );
  }
  
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[850],
              height: 1.5,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[850],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
