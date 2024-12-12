import 'package:equatable/equatable.dart';
import 'package:movie_night/utils/constants.dart';

class Movie extends Equatable {
  final int id;
  final String title;
  final String? posterPath;
  final String? overview;
  final DateTime? releaseDate;

  const Movie({
    required this.id,
    required this.title,
    this.posterPath,
    this.overview,
    this.releaseDate,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      posterPath: json['poster_path'],
      overview: json['overview'],
      releaseDate: json['release_date'] != null
          ? DateTime.parse(json['release_date'])
          : null,
    );
  }

  String get displayPosterPath => posterPath ?? AppConstants.defaultPosterPath;

  @override
  List<Object?> get props => [id, title, posterPath, overview, releaseDate];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'poster_path': posterPath,
        'overview': overview,
        'release_date': releaseDate?.toIso8601String(),
      };
}
