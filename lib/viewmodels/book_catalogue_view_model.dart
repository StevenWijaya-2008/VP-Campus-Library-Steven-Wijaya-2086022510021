import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../models/loan.dart';
import '../models/repositories/book_repository.dart';

class BookCatalogueViewModel extends ChangeNotifier {
  final BookRepository _repository;
  bool _isLoading = false;

  BookCatalogueViewModel(this._repository) {
    _repository.addListener(notifyListeners);
  }

  List<Book> get books => _repository.getBooks();
  bool get isLoading => _isLoading;

  Future<void> loadBooks() async {
    _isLoading = true;
    notifyListeners();

    await _repository.fetchBooks();

    _isLoading = false;
    notifyListeners();
  }

  bool borrowBook({required String bookId, required String studentId}) {
    final bookList = _repository.getBooks();
    final bookIndex = bookList.indexWhere((b) => b.id == bookId);

    if (bookIndex == -1 || !bookList[bookIndex].isAvailable) {
      return false;
    }

    final now = DateTime.now();
    final dueDate = now.add(const Duration(days: 14));

    final newLoan = Loan(
      id: 'L${DateTime.now().millisecondsSinceEpoch}',
      bookId: bookId,
      studentId: studentId,
      borrowDate: now,
      dueDate: dueDate,
    );

    _repository.addLoan(newLoan);
    _repository.updateBookAvailability(bookId, false);

    notifyListeners();
    return true;
  }

  void refresh() {
    notifyListeners();
  }
}