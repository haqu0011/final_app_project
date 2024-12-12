import 'package:flutter/material.dart';
import 'package:movie_night/services/http_helper.dart';
import 'package:movie_night/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_app_bar.dart';
import 'welcome_screen.dart';
import 'movie_voting_screen.dart';

class EnterCodeScreen extends StatefulWidget {
  final String deviceId;
  const EnterCodeScreen({super.key, required this.deviceId});
  @override
  _EnterCodeScreenState createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends State<EnterCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _validateAndJoinSession() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final httpHelper = HttpHelper();
        final code = int.parse(_codeController.text);
        final response =
            await httpHelper.joinSession(deviceId: widget.deviceId, code: code);
        final message = response['message'];
        final sessionId = response['session_id'];

        AppConstants.debugPrint('Response: $response');

        // Save session details to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('session_id', sessionId);
        await prefs.setString('session_code', _codeController.text);

        AppConstants.debugPrint('Session joined: $message');

        // Navigate to MovieVotingScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                MovieVotingScreen(sessionCode: _codeController.text),
          ),
        );
      } catch (e) {
        AppConstants.debugPrint('Error joining session: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join session: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Enter Session Code'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Session Code',
                    hintText: 'Enter the 4-digit session code',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a session code';
                    }
                    if (value.length != 4 || int.tryParse(value) == null) {
                      return 'Please enter a valid 4-digit session code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _validateAndJoinSession,
                        child: const Text('Join Session'),
                      ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const WelcomeScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
