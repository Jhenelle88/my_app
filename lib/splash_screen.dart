import 'package:flutter/material.dart';
import 'package:my_app/main_menu.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/trans.png', // Using the provided logo
                height: 200,
              ),
              const SizedBox(height: 32),
              const Text(
                'Welcome to CRYCOM',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF03A9F4), // Light Blue
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your personal baby cry analyzer. Understand your baby\'s needs better.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF03A9F4), // Light Blue
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  elevation: 5,
                ),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => MainMenu(user: const {
                        'id': 1, // Dummy user ID
                        'fullName': 'User',
                        'email': 'user@example.com',
                        'imagePath': null,
                      }),
                    ),
                  );
                },
                child: const Text('Get Started', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
