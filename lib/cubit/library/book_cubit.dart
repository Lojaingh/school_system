// lib/cubit/library/book_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/book_model.dart';
import '../../data/model/lending_model.dart';
import '../../data/repository/book_repository.dart';

part 'book_state.dart';

class BookCubit extends Cubit<BookState> {
  final BookRepository repository;

  BookCubit(this.repository) : super(BookInitial());

  // ── جلب جميع الكتب ──
  Future<void> loadBooks() async {
    try {
      emit(BookLoading());
      final books = await repository.getBooks();
      emit(BooksLoaded(books));
    } catch (e) {
      emit(BookError(e.toString()));
    }
  }

  // ── إضافة كتاب ──
  Future<void> addBook({
    required String title,
    required String summary,
    required String category,
    required int pages,
  }) async {
    try {
      emit(BookLoading());
      await repository.addBook(
        title: title,
        summary: summary,
        category: category,
        pages: pages,
      );
      await loadBooks();
    } catch (e) {
      emit(BookError(e.toString()));
    }
  }

  // ── تحديث كتاب ──
  Future<void> updateBook({
    required int id,
    String? title,
    String? summary,
    String? category,
    int? pages,
  }) async {
    try {
      emit(BookLoading());
      await repository.updateBook(
        id: id,
        title: title,
        summary: summary,
        category: category,
        pages: pages,
      );
      await loadBooks();
    } catch (e) {
      emit(BookError(e.toString()));
    }
  }

  // ── حذف كتاب ──
  Future<void> deleteBook(int id) async {
    try {
      emit(BookLoading());
      await repository.deleteBook(id);
      await loadBooks();
    } catch (e) {
      emit(BookError(e.toString()));
    }
  }

  // ── استعارة كتاب ──
  Future<void> lendBook(int bookId) async {
    try {
      emit(BookLoading());
      await repository.lendBook(bookId);
      await loadBooks();
    } catch (e) {
      emit(BookError(e.toString()));
    }
  }

  // ── إرجاع كتاب ──
  Future<void> returnBook(int lendingId) async {
    try {
      emit(BookLoading());
      await repository.returnBook(lendingId);
      await loadBooks();
    } catch (e) {
      emit(BookError(e.toString()));
    }
  }

  // ── جلب جميع الاستعارات ──
  Future<List<Lending>> getLendings() async {
    try {
      return await repository.getLendings();
    } catch (e) {
      print('❌ Error getting lendings: $e');
      return [];
    }
  }

  void refreshBooks() {
    loadBooks();
  }
}
