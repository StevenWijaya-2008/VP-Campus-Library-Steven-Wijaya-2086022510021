import 'dart:convert';
import 'package:flutter/services.dart';

class BookService {
  Future<List<Map<String, dynamic>>> loadRawJson() async {
    final String jsonString = await rootBundle.loadString('books.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }
}