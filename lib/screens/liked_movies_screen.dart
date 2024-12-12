import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../services/file_helper.dart';
import '../widgets/custom_app_bar.dart';
import '../utils/constants.dart';

class LikedMoviesScreen extends StatefulWidget {
  const LikedMoviesScreen({super.key});

  @override
  _LikedMoviesScreenState createState() => _LikedMoviesScreenState();
}

class _LikedMoviesScreenState extends State<LikedMoviesScreen> {
  List<Movie> _likedMovies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLikedMovies();
  }

  Future<void> _loadLikedMovies() async {
    final fileHelper = Provider.of<FileHelper>(context, listen: false);

    try {
      final movies = await fileHelper.getLikedMovies();
      setState(() {
        _likedMovies = movies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading liked movies: $e')),
      );
    }
  }

  Future<void> _removeMovie(Movie movie) async {
    final fileHelper = Provider.of<FileHelper>(context, listen: false);

    try {
      await fileHelper.removeLikedMovie(movie.id);
      setState(() {
        _likedMovies.removeWhere((m) => m.id == movie.id);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing movie: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Liked Movies'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _likedMovies.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No liked movies yet',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Go Back'),
                      )
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _likedMovies.length,
                  itemBuilder: (context, index) {
                    final movie = _likedMovies[index];
                    return Dismissible(
                      key: Key(movie.id.toString()),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _removeMovie(movie),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            movie.posterPath != null
                                ? 'https://image.tmdb.org/t/p/w92${movie.posterPath}'
                                : AppConstants.defaultPosterPath,
                            width: 50,
                            height: 75,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                AppConstants.defaultPosterPath,
                                width: 50,
                                height: 75,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                        title: Text(movie.title),
                        subtitle: Text(movie.releaseDate != null
                            ? 'Released: ${movie.releaseDate!.year}'
                            : 'Release year unknown'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeMovie(movie),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
