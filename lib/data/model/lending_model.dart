class LendingBook {
  final int id;
  final String title;
  final String category;
  final int pages;
  final String dueDate;
  final bool isOverdue;

  LendingBook({
    required this.id,
    required this.title,
    required this.category,
    required this.pages,
    required this.dueDate,
    required this.isOverdue,
  });

  factory LendingBook.fromJson(Map<String, dynamic> json) {
    return LendingBook(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      pages: json['pages'] is int
          ? json['pages']
          : int.tryParse(json['pages']?.toString() ?? '') ?? 0,
      dueDate: json['due_date'] ?? '',
      isOverdue: json['is_overdue'] ?? false,
    );
  }
}

class Lending {
  final int id;
  final String borrowDate;
  final String? returnDate;
  final bool isReturned;
  final LendingBook book;
  final int academicId;
  final String createdAt;

  Lending({
    required this.id,
    required this.borrowDate,
    this.returnDate,
    required this.isReturned,
    required this.book,
    required this.academicId,
    required this.createdAt,
  });

  factory Lending.fromJson(Map<String, dynamic> json) {
    return Lending(
      id: json['id'] ?? 0,
      borrowDate: json['borrow_date'] ?? '',
      returnDate: json['return_date'],
      isReturned: json['is_returned'] ?? false,
      book: LendingBook.fromJson(
        json['book'] ?? {},
      ),
      academicId: json['academic_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }

  bool get isActive => !isReturned && !book.isOverdue;

  bool get isReturnedStatus => isReturned;

  bool get isLate => !isReturned && book.isOverdue;
}
