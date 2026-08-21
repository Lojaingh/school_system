// lib/data/repository/book_repository.dart
import '../model/book_model.dart';
import '../model/lending_model.dart';
import '../services/book_service.dart';

class BookRepository {
  final BookService bookService;

  BookRepository(this.bookService);
  Future<List<Book>> getBooks() async {
    try {
      final response = await bookService.getBooks();

      if (response.statusCode == 200) {
        final data = response.data['data'] as List? ?? [];

        return data
            .map(
              (json) => Book.fromJson(
                Map<String, dynamic>.from(json),
              ),
            )
            .toList();
      }

      throw Exception(
        'Failed to load books: ${response.statusCode}',
      );
    } catch (e) {
      print('❌ Error fetching books: $e');
      rethrow;
    }
  }

  Future<Book> getBook(int id) async {
    try {
      final response = await bookService.getBook(id);

      if (response.statusCode == 200) {
        final data = response.data['data'];

        return Book.fromJson(
          Map<String, dynamic>.from(data),
        );
      }

      throw Exception(
        'Failed to load book: ${response.statusCode}',
      );
    } catch (e) {
      print('❌ Error fetching book: $e');
      rethrow;
    }
  }

  Future<Book> addBook({
    required String title,
    required String summary,
    required String category,
    required int pages,
  }) async {
    try {
      final response = await bookService.addBook(
        title: title,
        summary: summary,
        category: category,
        pages: pages,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];

        return Book.fromJson(
          Map<String, dynamic>.from(data),
        );
      }

      throw Exception(
        'Failed to add book: ${response.statusCode}',
      );
    } catch (e) {
      print('❌ Error adding book: $e');
      rethrow;
    }
  }

  Future<Book> updateBook({
    required int id,
    String? title,
    String? summary,
    String? category,
    int? pages,
  }) async {
    try {
      final response = await bookService.updateBook(
        id: id,
        title: title,
        summary: summary,
        category: category,
        pages: pages,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];

        return Book.fromJson(
          Map<String, dynamic>.from(data),
        );
      }

      throw Exception(
        'Failed to update book: ${response.statusCode}',
      );
    } catch (e) {
      print('❌ Error updating book: $e');
      rethrow;
    }
  }

  Future<void> deleteBook(int id) async {
    try {
      final response = await bookService.deleteBook(id);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to delete book: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error deleting book: $e');
      rethrow;
    }
  }

  Future<Lending> lendBook(int bookId) async {
    try {
      final response = await bookService.lendBook(bookId);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];

        return Lending.fromJson(
          Map<String, dynamic>.from(data),
        );
      }

      throw Exception(
        'Failed to lend book: ${response.statusCode}',
      );
    } catch (e) {
      print('❌ Error lending book: $e');
      rethrow;
    }
  }

  Future<void> returnBook(int lendingId) async {
    try {
      final response = await bookService.returnBook(lendingId);

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to return book: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error returning book: $e');
      rethrow;
    }
  }

  Future<List<Lending>> getLendings() async {
    try {
      final response = await bookService.getLendings();

      if (response.statusCode == 200) {
        final data = response.data['data'] as List? ?? [];

        return data
            .map(
              (json) => Lending.fromJson(
                Map<String, dynamic>.from(json),
              ),
            )
            .toList();
      }

      throw Exception(
        'Failed to load lendings: ${response.statusCode}',
      );
    } catch (e) {
      print('❌ Error fetching lendings: $e');
      rethrow;
    }
  }

  Future<List<Lending>> getMyLendings() async {
    try {
      final response = await bookService.getMyLendings();

      if (response.statusCode == 200) {
        final data = response.data['data'] as List? ?? [];

        return data
            .map(
              (json) => Lending.fromJson(
                Map<String, dynamic>.from(json),
              ),
            )
            .toList();
      }

      throw Exception(
        'Failed to load my lendings: ${response.statusCode}',
      );
    } catch (e) {
      print('❌ Error fetching my lendings: $e');
      rethrow;
    }
  }
}
