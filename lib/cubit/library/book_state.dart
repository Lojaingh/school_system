// lib/cubit/library/book_state.dart

part of 'book_cubit.dart';

abstract class BookState {}

class BookInitial extends BookState {}

class BookLoading extends BookState {}

class BooksLoaded extends BookState {
  final List<Book> books;

  BooksLoaded(this.books);
}

class BookError extends BookState {
  final String message;

  BookError(this.message);
}
