class Book {
  final String id;
  final String title;
  final String author;
  final double replacementPrice;
  bool isAvailable;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.replacementPrice,
    this.isAvailable = true,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      replacementPrice: (json['replacementPrice'] as num).toDouble(),
      isAvailable: json['isAvailable'] ?? true,
    );
  }
}