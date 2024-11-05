import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:fgsiz/data/product.dart';

List<Product> products = [];

Future<void> loadProducts() async {
  final String response = await rootBundle.loadString('assets/products.json');
  final data = json.decode(response) as List<dynamic>;
  products = data.map((item) => Product(
    name: item['name'],
    imageUrls: List<String>.from(item['imageUrls']),
    description: item['description'],
    designations: List<String>.from(item['designations']),
    standard: item['standard'],
  )).toList();
}
