import 'package:flutter/material.dart';
import 'package:fgsiz/data/products_data.dart';
import 'package:image/image.dart' as img;
import 'package:fgsiz/data/product.dart';
import 'package:fgsiz/screens/product_details_screen.dart';
class SpiroBrandScreen extends StatelessWidget {
  const SpiroBrandScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('СПИРО'),
        backgroundColor: Colors.blue, // Синий цвет для СПИРО
      ),
      body: FutureBuilder<Map<String, List<dynamic>>>(
        future: loadBrands(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final spiroLines = snapshot.data!['spiro'];
            return ListView.builder(
              itemCount: spiroLines.length,
              itemBuilder: (context, index) {
                final line = spiroLines[index];
                return Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(line['lineName']),
                        subtitle: Text(line['description']),
                      ),
                      // Список товаров линейки
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(), // Отключаем прокрутку внутреннего ListView
                        itemCount: line['products'].length,
                        itemBuilder: (context, productIndex) {
                          final productName = line['products'][productIndex]['productName'];
                          // Найдите product по productName в products.json
                          final product = products.firstWhere((p) => p.name == productName, orElse: () => Product(name: 'Неизвестный товар', imageUrls: [], description: '', designations: [], standard: ''));
                          return ListTile(
                            title: Text(productName),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailsScreen(product: product),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('Ошибка: ${snapshot.error}');
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}