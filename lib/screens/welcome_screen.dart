import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../widgets/custom_app_bar.dart';
import 'share_code_screen.dart';
import 'enter_code_screen.dart';
import '../services/device_id.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Movie Night'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Movie Night!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                final deviceId = await getDeviceId();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShareCodeScreen(deviceId: deviceId),
                  ),
                );
              },
              child: const Text('Create Session'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final deviceId = await getDeviceId();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EnterCodeScreen(deviceId: deviceId),
                  ),
                );
              },
              child: const Text('Join Session'),
            ),
          ],
        ),
      ),
    );
  }
}

extension on AndroidDeviceInfo {
  get androidId => null;
}
