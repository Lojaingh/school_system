// lib/data/model/book_model.dart
class Book {
  final int id;
  final String title;
  final String summary;
  final String category;
  final int pages;
  final bool isAvailable;
  final int academicId;
  final String createdAt;

  Book({
    required this.id,
    required this.title,
    required this.summary,
    required this.category,
    required this.pages,
    required this.isAvailable,
    required this.academicId,
    required this.createdAt,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      category: json['category'] ?? '',
      pages: json['pages'] is int
          ? json['pages']
          : int.tryParse(json['pages']?.toString() ?? '') ?? 0,
      isAvailable: json['is_available'] ?? false,
      academicId: json['academic_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'summary': summary,
      'category': category,
      'pages': pages,
    };
  }
}
