import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/LOGO.png',
                      height: 100,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.child_care,
                          size: 100,
                          color: Colors.lightBlue[400],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'CRYCOM',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlue[800],
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Smart care starts with knowing why.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[700],
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                'About CRYCOM',
                '''CRYCOM is an innovative infant-care system designed to help parents understand their baby’s needs with clarity and confidence. Using directional microphones, advanced signal processing, and edge-based deep learning, CRYCOM classifies infant cries into four key categories—hunger, discomfort, pain, or sleepiness—all while keeping your data safe through secure offline processing.\n\nMore than just an app, CRYCOM is a fully integrated hardware and software ecosystem. The hardware intelligently listens and analyzes your baby’s cry, while the mobile app presents the results through a clean and intuitive interface. Parents can easily view past cry histories, check detailed records and bar graph trends, and receive real-time notifications explaining why their baby may be crying.\n\nDesigned with modern families in mind, CRYCOM provides smarter monitoring, faster awareness, and peace of mind, helping you respond to your child’s needs with understanding and care.''',
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                'Mission',
                '''Our mission is to empower parents through smart, reliable, and privacy-preserving technology that accurately identifies and interprets infant cries. We aim to support timely infant care by providing insights, notifications, and clear data that help parents respond with confidence and understanding.''',
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                'Vision',
                '''Our vision is to become a trusted companion in modern infant care—combining intelligent hardware, secure offline processing, and intuitive software to create a safer, more informed environment for families. We envision a future where every parent has access to technology that brings clarity, comfort, and peace of mind.''',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.lightBlue[700],
              ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              content,
              textAlign: TextAlign.justify,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
