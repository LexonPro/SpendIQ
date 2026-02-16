import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContributeScreen extends StatelessWidget {
  const ContributeScreen({super.key});

  final String upiId = "8004522805@pthdfc";

  Future<void> _pay() async {
    final Uri uri = Uri.parse(
      "upi://pay?pa=$upiId&pn=SpendIQ%20Developer&tn=Support%20SpendIQ&am=20&cu=INR",
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not launch UPI app");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Support SpendIQ")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "If this app helped you save money,\nconsider supporting with ₹20 ❤️",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: _pay,
              icon: const Icon(Icons.favorite),
              label: const Text("Donate ₹20 via UPI"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Thank you for supporting an independent student developer 🙏",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
