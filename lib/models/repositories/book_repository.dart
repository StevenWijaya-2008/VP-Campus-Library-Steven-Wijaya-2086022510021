import '../../models/book.dart';
import '../../models/loan.dart';
import '../services/book_service.dart';
import 'package:flutter/foundation.dart';

class BookRepository extends ChangeNotifier {
  final BookService _service;
  final List<Book> _books = [];
  final List<Loan> _loans = [];

  BookRepository(this._service);

  Future<void> fetchBooks() async {
    if (_books.isNotEmpty) return;
    final rawData = await _service.loadRawJson();
    final parsedBooks = rawData.map((json) => Book.fromJson(json)).toList();
    _books.clear();
    _books.addAll(parsedBooks);
    notifyListeners();
  }

  List<Book> getBooks() => _books;
  List<Loan> getLoans() => _loans;

  void addLoan(Loan loan) {
    _loans.add(loan);
    notifyListeners();
  }

  void updateBookAvailability(String bookId, bool isAvailable) {
    final index = _books.indexWhere((b) => b.id == bookId);
    if (index != -1){
      _books[index].isAvailable = isAvailable;
      notifyListeners();
    }
  }
}