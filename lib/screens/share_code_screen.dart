import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/http_helper.dart';
import '../widgets/custom_app_bar.dart';
import 'welcome_screen.dart';

class ShareCodeScreen extends StatefulWidget {
  final String deviceId;

  const ShareCodeScreen({super.key, required this.deviceId});

  @override
  _ShareCodeScreenState createState() => _ShareCodeScreenState();
}

class _ShareCodeScreenState extends State<ShareCodeScreen> {
  String? _sessionCode;
  String? _sessionId;
  final HttpHelper _httpHelper = HttpHelper();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _generateSessionCode();
  }

  Future<void> _generateSessionCode() async {
    try {
      // Call the startSession method with the device ID
      final sessionData = await _httpHelper.startSession(widget.deviceId);
      setState(() {
        _sessionCode = sessionData['code'].toString();
        _sessionId = sessionData['session_id'];
        _isLoading = false;
      });

      // Save session details to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('session_id', _sessionId!);
      await prefs.setString('session_code', _sessionCode!);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating session: $e')),
      );
    }
  }

  void _copyToClipboard() {
    if (_sessionCode != null) {
      Clipboard.setData(ClipboardData(text: _sessionCode!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session code copied to clipboard')),
      );
    }
  }

  void _navigateBack() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Share Session Code'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Your Session Code:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : Text(
                    _sessionCode ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _sessionCode != null ? _copyToClipboard : null,
              child: const Text('Copy Code'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _navigateBack,
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}
