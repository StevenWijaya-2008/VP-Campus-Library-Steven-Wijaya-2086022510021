import 'package:flutter/material.dart';
import '../viewmodels/borrowed_books_view_model.dart';

class BorrowedBooksScreen extends StatelessWidget {
  final BorrowedBooksViewModel viewModel;

  const BorrowedBooksScreen({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        final totalFine = viewModel.calculateTotalFines();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Daftar Peminjaman'),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card.filled(
                  color: totalFine > 0 ? colorScheme.errorContainer : colorScheme.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.payments_outlined,
                          size: 36,
                          color: totalFine > 0 ? colorScheme.onErrorContainer : colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Denda Terakumulasi',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: totalFine > 0 ? colorScheme.onErrorContainer : colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rp ${totalFine.toStringAsFixed(0)}',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: totalFine > 0 ? colorScheme.onErrorContainer : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Expanded(
                child: viewModel.loans.isEmpty
                    ? const Center(child: Text('Belum ada transaksi peminjaman.'))
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: viewModel.loans.length,
                  itemBuilder: (context, index) {
                    final loan = viewModel.loans[index];

                    final book = viewModel.getBookById(loan.bookId);
                    final status = viewModel.getLoanStatus(loan);
                    final fine = viewModel.calculateFine(loan);

                    return Card.outlined(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    book.title,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                _buildStatusBadge(context, status),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Peminjam (NIM): ${loan.studentId}', style: Theme.of(context).textTheme.bodyMedium),
                            Text('Jatuh Tempo: ${_formatDate(loan.dueDate)}', style: Theme.of(context).textTheme.bodySmall),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Denda Buku Ini:',
                                      style: Theme.of(context).textTheme.labelSmall,
                                    ),
                                    Text(
                                      'Rp ${fine.toStringAsFixed(0)}',
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        color: fine > 0 ? colorScheme.error : colorScheme.onSurface,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                OutlinedButton.icon(
                                  onPressed: loan.isReturned
                                      ? null
                                      : () => viewModel.returnBook(loan.id),
                                  icon: const Icon(Icons.assignment_return, size: 18),
                                  label: Text(loan.isReturned ? 'Dikembalikan' : 'Kembalikan'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(BuildContext context, LoanStatus status) {
    final colorScheme = Theme.of(context).colorScheme;

    String label;
    Color color;

    switch (status) {
      case LoanStatus.onTime:
        label = 'ON TIME';
        color = Colors.green;
        break;
      case LoanStatus.overdue:
        label = 'OVERDUE';
        color = colorScheme.error;
        break;
      case LoanStatus.missing:
        label = 'MISSING';
        color = colorScheme.tertiary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}