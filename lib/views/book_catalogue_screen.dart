import 'package:flutter/material.dart';
import '../viewmodels/book_catalogue_view_model.dart';
import '../viewmodels/borrowed_books_view_model.dart';
import '../models/repositories/book_repository.dart';
import 'borrowed_books_screen.dart';

class BookCatalogueScreen extends StatefulWidget {
  final BookCatalogueViewModel viewModel;
  final BookRepository repository;

  const BookCatalogueScreen({
    super.key,
    required this.viewModel,
    required this.repository,
  });

  @override
  State<BookCatalogueScreen> createState() => _BookCatalogueScreenState();
}

class _BookCatalogueScreenState extends State<BookCatalogueScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadBooks();
  }

  void _showBorrowDialog(BuildContext context, String bookId, String bookTitle) {
    final studentIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Pinjam Buku'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Judul: $bookTitle', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            TextField(
              controller: studentIdController,
              decoration: const InputDecoration(
                labelText: 'NIM / Student ID',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              final studentId = studentIdController.text.trim();
              if (studentId.isNotEmpty) {
                final success = widget.viewModel.borrowBook(
                  bookId: bookId,
                  studentId: studentId,
                );

                Navigator.pop(ctx);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Buku berhasil dipinjam!'
                          : 'Gagal meminjam buku.',
                    ),
                  ),
                );
              }
            },
            child: const Text('Pinjam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Katalog Perpustakaan'),
            centerTitle: false,
            actions: [
              IconButton.filledTonal(
                icon: const Icon(Icons.bookmark_outlined),
                tooltip: 'Buku Dipinjam',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BorrowedBooksScreen(
                        viewModel: BorrowedBooksViewModel(widget.repository),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: widget.viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : widget.viewModel.books.isEmpty
              ? const Center(child: Text('Tidak ada buku tersedia.'))
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: widget.viewModel.books.length,
            itemBuilder: (context, index) {
              final book = widget.viewModel.books[index];

              return Card.outlined(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: colorScheme.primaryContainer,
                        child: Icon(Icons.menu_book, color: colorScheme.onPrimaryContainer),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Penulis: ${book.author}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 6),
                            Chip(
                              visualDensity: VisualDensity.compact,
                              labelStyle: const TextStyle(fontSize: 12),
                              label: Text(book.isAvailable ? 'Tersedia' : 'Dipinjam'),
                              avatar: Icon(
                                book.isAvailable ? Icons.check_circle : Icons.cancel,
                                size: 16,
                                color: book.isAvailable ? colorScheme.primary : colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: book.isAvailable
                            ? () => _showBorrowDialog(context, book.id, book.title)
                            : null,
                        child: const Text('Pinjam'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}