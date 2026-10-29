import 'package:flutter/material.dart';

// Import sesuaikan dengan lokasi folder proyek Anda
import 'models/services/book_service.dart';
import 'models/repositories/book_repository.dart';
import 'viewmodels/book_catalogue_view_model.dart';
import 'views/book_catalogue_screen.dart';

void main() {
  // Memastikan binding Flutter siap sebelum membaca assets JSON
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Data Layer (Single Source of Truth)
  final bookService = BookService();
  final bookRepository = BookRepository(bookService);

  // 2. Inisialisasi ViewModel untuk Screen 1
  final catalogueViewModel = BookCatalogueViewModel(bookRepository);

  runApp(MyApp(
    viewModel: catalogueViewModel,
    repository: bookRepository,
  ));
}

class MyApp extends StatelessWidget {
  final BookCatalogueViewModel viewModel;
  final BookRepository repository;

  const MyApp({
    super.key,
    required this.viewModel,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistem Perpustakaan',
      debugShowCheckedModeBanner: false,
      // Tampilan Material 3 Wajib
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
      ),
      home: BookCatalogueScreen(
        viewModel: viewModel,
        repository: repository,
      ),
    );
  }
}