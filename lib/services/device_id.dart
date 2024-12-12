// In your app's main entry point or a dedicated utility class
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:uuid/uuid.dart';

Future<String> getDeviceId() async {
  final deviceInfo = DeviceInfoPlugin();
  String deviceId;

  if (kIsWeb) {
    // For web platform
    deviceId = await _generateUniqueId();
  } else {
    // For mobile platforms
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor ?? '';
    } else {
      deviceId = await _generateUniqueId();
    }
  }

  // Store the device ID in SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  if (deviceId.isNotEmpty) {
    await prefs.setString('deviceId', deviceId);
  } else {
    // Fallback to stored ID or generate new one if empty
    deviceId = prefs.getString('deviceId') ?? await _generateUniqueId();
    await prefs.setString('deviceId', deviceId);
  }
  return deviceId;
}

Future<String> _generateUniqueId() async {
  const uuid = Uuid();
  return uuid.v4();
}
