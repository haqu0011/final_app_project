import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';
import '../services/http_helper.dart';
// import '../services/file_helper.dart';
import '../widgets/custom_app_bar.dart';
import '../utils/constants.dart';

class MovieVotingScreen extends StatefulWidget {
  final String sessionCode;

  const MovieVotingScreen({super.key, required this.sessionCode});

  @override
  _MovieVotingScreenState createState() => _MovieVotingScreenState();
}

class _MovieVotingScreenState extends State<MovieVotingScreen> {
  List<Movie> _movies = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _sessionId;

  @override
  void initState() {
    super.initState();
    _fetchInitialMovies();
    _loadSessionId();
  }

  Future<void> _loadSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sessionId = prefs.getString('session_id');
    });
  }

  Future<void> _fetchInitialMovies() async {
    try {
      final httpHelper = Provider.of<HttpHelper>(context, listen: false);
      final movies = await httpHelper.fetchMovies();

      setState(() {
        _movies = movies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading movies: $e')),
      );
    }
  }

  Future<void> _loadMoreMovies() async {
    try {
      final httpHelper = Provider.of<HttpHelper>(context, listen: false);
      final moreMovies =
          await httpHelper.fetchMovies(page: _movies.length ~/ 20 + 1);

      setState(() {
        _movies.addAll(moreMovies);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading more movies: $e')),
      );
    }
  }

  Future<void> _handleVote(bool isLiked) async {
    final httpHelper = HttpHelper();
    // final fileHelper = FileHelper();

    // Retrieve the actual session ID, not the code
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_id');
    AppConstants.debugPrint('Session ID: $sessionId');

    if (sessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active session found')),
      );
      return;
    }

    try {
      // Submit vote using the session ID
      final voteResult = await httpHelper.voteMovie(
          sessionId: sessionId,
          movieId: _movies[_currentIndex].id,
          vote: isLiked);

      //log the result
      AppConstants.debugPrint('Vote result: $voteResult');

      // Check for match
      if (voteResult['match'] == true) {
        final matchedMovieId = voteResult['movie_id'] as int;
        final matchedMovie =
            _movies.firstWhere((movie) => movie.id == matchedMovieId);

        // Show match dialog
        if (!mounted) return;
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('It\'s a Match! 🎉'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('You and your partner both liked:'),
                  const SizedBox(height: 8),
                  Text(
                    matchedMovie.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (matchedMovie.releaseDate != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Released: ${matchedMovie.releaseDate!.year}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        return; // Exit the method after showing dialog
      }

      // // If movie is liked, save to liked movies
      // if (isLiked) {
      //   await fileHelper.addLikedMovie(_movies[_currentIndex]);
      // }

      // Move to next movie
      _moveToNextMovie();
    } catch (e) {
      AppConstants.debugPrint('Error submitting vote: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting vote: $e')),
      );
    }
  }

  void _moveToNextMovie() {
    setState(() {
      _currentIndex++;

      // If we're near the end of the list, load more movies
      if (_currentIndex >= _movies.length - 3) {
        _loadMoreMovies();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Movie Night',
        showLikedMoviesAction: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _movies.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No movies available',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchInitialMovies,
                        child: const Text('Retry'),
                      )
                    ],
                  ),
                )
              : _currentIndex < _movies.length
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                _movies[_currentIndex].posterPath != null
                                    ? 'https://image.tmdb.org/t/p/w500${_movies[_currentIndex].posterPath}'
                                    : AppConstants.defaultPosterPath,
                                height: 400,
                                width: 300,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    AppConstants.defaultPosterPath,
                                    height: 400,
                                    width: 300,
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _movies[_currentIndex].title,
                              style: Theme.of(context).textTheme.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _movies[_currentIndex].releaseDate != null
                                  ? 'Released: ${_movies[_currentIndex].releaseDate!.year}'
                                  : '',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Text('Movie ID: ${_movies[_currentIndex].id}'),
                            if (_sessionId != null) ...[
                              const SizedBox(height: 4),
                              Text('Session ID: $_sessionId'),
                            ],
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () => _handleVote(false),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 32, vertical: 12),
                                  ),
                                  child: const Text('Nope'),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: () => _handleVote(true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 32, vertical: 12),
                                  ),
                                  child: const Text('Yes'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : _buildEndOfMoviesView(),
    );
  }

  Widget _buildEndOfMoviesView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'No more movies to vote on!',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchInitialMovies,
            child: const Text('Load More Movies'),
          )
        ],
      ),
    );
  }
}
