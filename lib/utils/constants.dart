import 'package:flutter/foundation.dart';

class AppConstants {
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String movieNightBaseUrl =
      'https://movie-night-api.onrender.com';

  static const String tmdbApiKey =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI2NmFlNjFmMmU5MzY1MWJmOTQyZTRjYjljZjNhYTkxYyIsIm5iZiI6MTY0NTg0MTkwMC41ODcwMDAxLCJzdWIiOiI2MjE5OGRlY2NlNWQ4MjAwMWI0NTcyYmIiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.JIfaVmUup_cGcN1-wUPCb9WL_6mE_1PdbpEyzt7mmpM';

  // Default Values
  static const String defaultPosterPath = 'assets/images/default_poster.png';

  // Debug Printing
  static void debugPrint(String message) {
    if (kDebugMode) {
      print(message);
    }
  }

  // Base Spacing Unit
  static const double baseSpacingUnit = 8.0;
}
