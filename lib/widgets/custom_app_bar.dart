import 'package:flutter/material.dart';
import '../screens/liked_movies_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showLikedMoviesAction;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showLikedMoviesAction = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: showLikedMoviesAction
          ? [
              IconButton(
                icon: const Icon(Icons.favorite),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LikedMoviesScreen()));
                },
              )
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
