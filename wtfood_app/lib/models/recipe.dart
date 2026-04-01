class Recipe {
  final String id;
  final String title;
  final String imageUrl;
  final String prepTime;
  final String difficulty;
  final String author;
  final int likes;

  const Recipe({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.prepTime,
    required this.difficulty,
    this.author = 'Chef WTFood',
    this.likes = 0,
  });
}
