import 'package:flutter/material.dart';

class SessionProvider extends ChangeNotifier {
  String? _sessionId;
  String? _sessionCode;

  String? get sessionId => _sessionId;
  String? get sessionCode => _sessionCode;

  void updateSession({required String sessionId, required String sessionCode}) {
    _sessionId = sessionId;
    _sessionCode = sessionCode;
    notifyListeners(); // Notify widgets listening to this provider
  }
}
