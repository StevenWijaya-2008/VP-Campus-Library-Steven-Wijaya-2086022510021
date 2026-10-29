import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../models/loan.dart';
import '../models/repositories/book_repository.dart';

enum LoanStatus { onTime, overdue, missing }

class BorrowedBooksViewModel extends ChangeNotifier {
  final BookRepository _repository;

  BorrowedBooksViewModel(this._repository);

  List<Loan> get loans => _repository.getLoans();

  Book getBookById(String bookId) {
    return _repository.getBooks().firstWhere(
          (b) => b.id == bookId,
      orElse: () => Book(
        id: bookId,
        title: 'Buku Tidak Ditemukan',
        author: '-',
        replacementPrice: 0.0,
        isAvailable: false,
      ),
    );
  }

  DateTime _getSixMonthsThreshold(DateTime dueDate) {
    return DateTime(
      dueDate.year,
      dueDate.month + 6,
      dueDate.day,
      dueDate.hour,
      dueDate.minute,
      dueDate.second,
    );
  }

  void returnBook(String loanId) {
    final loanList = _repository.getLoans();
    final loanIndex = loanList.indexWhere((l) => l.id == loanId);

    if (loanIndex == -1) return;

    final loan = loanList[loanIndex];
    loan.returnDate = DateTime.now();

    _repository.updateBookAvailability(loan.bookId, true);

    notifyListeners();
  }

  LoanStatus getLoanStatus(Loan loan, {DateTime? checkDate}) {
    final effectiveDate = loan.returnDate ?? checkDate ?? DateTime.now();

    if (effectiveDate.isBefore(loan.dueDate) || effectiveDate.isAtSameMomentAs(loan.dueDate)) {
      return LoanStatus.onTime;
    }

    final sixMonthsThreshold = _getSixMonthsThreshold(loan.dueDate);

    if (effectiveDate.isAfter(sixMonthsThreshold) || effectiveDate.isAtSameMomentAs(sixMonthsThreshold)) {
      return LoanStatus.missing;
    }
    return LoanStatus.overdue;
  }

  double calculateFine(Loan loan, {DateTime? checkDate}) {
    final effectiveDate = loan.returnDate ?? checkDate ?? DateTime.now();

    if (effectiveDate.isBefore(loan.dueDate) || effectiveDate.isAtSameMomentAs(loan.dueDate)) {
      return 0.0;
    }

    final daysOverdue = effectiveDate.difference(loan.dueDate).inDays;

    if (daysOverdue <= 6) {
      return 0.0;
    }

    final sixMonthsThreshold = _getSixMonthsThreshold(loan.dueDate);
    if (effectiveDate.isAfter(sixMonthsThreshold) || effectiveDate.isAtSameMomentAs(sixMonthsThreshold)) {
      final book = getBookById(loan.bookId);
      return book.replacementPrice;
    }
    double totalFine = 0.0;

    for (int day = 7; day <= daysOverdue; day++) {
      int dayAfterGrace = day - 6;
      int currentWeek = ((dayAfterGrace - 1) ~/ 7) + 1;
      double dailyRate = currentWeek * 5000.0;
      totalFine += dailyRate;
    }

    return totalFine;
  }

  double calculateTotalFines() {
    double total = 0.0;
    for (final loan in loans) {
      total += calculateFine(loan);
    }
    return total;
  }
}