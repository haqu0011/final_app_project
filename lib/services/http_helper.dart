import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';
import '../utils/constants.dart';

class HttpHelper {
  // Base URL for Movie Night API
  static const String _baseUrl = 'https://movie-night-api.onrender.com';

  // Start a new session
  Future<Map<String, dynamic>> startSession(String deviceId) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/start-session?device_id=$deviceId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['data'];
      } else {
        throw Exception('Failed to start session: ${response.body}');
      }
    } catch (e) {
      AppConstants.debugPrint('Error starting session: $e');
      rethrow;
    }
  }

  // Join an existing session
  Future<Map<String, dynamic>> joinSession(
      {required String deviceId, required int code}) async {
    try {
      final response = await http.get(
          Uri.parse('$_baseUrl/join-session?device_id=$deviceId&code=$code'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['data'];
      } else {
        throw Exception('Failed to join session: ${response.body}');
      }
    } catch (e) {
      AppConstants.debugPrint('Error joining session: $e');
      rethrow;
    }
  }

  // Vote on a movie
  Future<Map<String, dynamic>> voteMovie(
      {required String sessionId,
      required int movieId,
      required bool vote}) async {
    try {
      AppConstants.debugPrint('Voting on movie: $movieId');
      AppConstants.debugPrint('Vote: $vote');
      AppConstants.debugPrint('Session ID: $sessionId');
      final response = await http.get(Uri.parse(
          '$_baseUrl/vote-movie?session_id=$sessionId&movie_id=$movieId&vote=$vote'));

      if (response.statusCode == 200) {
        AppConstants.debugPrint(
            'Voted on movie: $movieId, vote: $vote, session ID: $sessionId');
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['data'];
      } else {
        throw Exception('Failed to vote on movie: ${response.body}');
      }
    } catch (e) {
      AppConstants.debugPrint('Error voting on movie: $e');
      rethrow;
    }
  }

  // TMDB API Method for fetching movies
  Future<List<Movie>> fetchMovies({int page = 1}) async {
    try {
      final uri = Uri.parse(
        '${AppConstants.tmdbBaseUrl}/discover/movie?page=$page',
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${AppConstants.tmdbApiKey}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return (data['results'] as List)
            .map((movieJson) => Movie.fromJson(movieJson))
            .toList();
      } else {
        throw Exception('Failed to load movies: ${response.statusCode}');
      }
    } catch (e) {
      AppConstants.debugPrint('Error fetching movies: $e');
      rethrow;
    }
  }
}
