import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:fgsiz/data/product.dart';

List<Product> products = [];

Future<void> loadProducts() async {
  final String response = await rootBundle.loadString('assets/products.json');
  final data = json.decode(response) as List<dynamic>;
  products = await Future.wait(data.map((item) async {
    // Приведение к List<String>
    final imageUrls = List<String>.from(item['imageUrls']); // <-- Исправление здесь
    return Product(
      name: item['name'] as String,
      imageUrls: imageUrls.map((imageUrl) => 'assets/images/$imageUrl').toList(), // Изменено
      description: await _loadDescription(item['description'] as String), // Изменено
      designations: List<String>.from(item['designations']), // Изменено
      standard: item['standard'] as String, // Изменено
    );
  }).toList());
}

Future<String> _loadDescription(String filename) async {
  final String response = await rootBundle.loadString('assets/descriptions/$filename.txt');
  return response;
}