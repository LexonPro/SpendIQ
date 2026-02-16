import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About SpendIQ")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "SpendIQ – Smart Expense Tracker",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              "SpendIQ is a simple and powerful expense tracking app designed "
              "for students and individuals to manage daily spending, track "
              "monthly balance, and build better financial habits.\n\n"
              "Built with focus on clean design, speed, and privacy.",
            ),
            SizedBox(height: 20),
            Text(
              "Developed by Shikhar Maurya\n"
              "Independent Student Developer, India\n"
              "© 2026 All Rights Reserved",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 20),
            Text(
              "GitHub: https://github.com/LexonPro",
              style: TextStyle(color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
