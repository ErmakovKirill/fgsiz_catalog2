import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fgsiz/data/products_data.dart';
import 'package:image/image.dart' as img;
import 'package:fgsiz/data/product.dart';
import 'package:fgsiz/screens/product_details_screen.dart';
import 'package:fgsiz/screens/splash_screen.dart';
import 'package:flutter/services.dart';
//import 'package:url_launcher/url_launcher.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadProducts();
  runApp(const MyApp());
}

Set<String> _getUniqueTags() {
  final allTags = products.expand((product) => product.designations).toSet();
  return allTags;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'КИМРА',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
      routes: {

        '/home': (context) => const MyHomePage(title: 'Каталог товаров'),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _searchQuery = '';
  List<String> _selectedTags = [];
  String? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _filterProducts();
    return Scaffold(
      backgroundColor: const Color(0xFFe3e2e2),
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFFe3e2e2),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox( // Добавлено SizedBox для управления высотой поиска
              height: 48, // Устанавливаем высоту поиска
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Поиск',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return _buildProductCard(product);
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.blue,
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Фильтры', style: TextStyle(color: Colors.white)),
            ),
            const Divider(),

            ExpansionTile(
              title: const Text('Теги', style: TextStyle(color: Colors.white)),
              children: <Widget>[
                for (final tag in _getUniqueTags())
                  CheckboxListTile(
                    title: Text(tag, style: TextStyle(color: Colors.white)),
                    value: _selectedTags.contains(tag),
                    onChanged: (bool? value) {
                      Navigator.pop(context);

                      setState(() {
                        if (value != null) {
                          if (value) {
                            _selectedTags.add(tag);
                          } else {
                            _selectedTags.remove(tag);
                          }
                        }
                      });
                    },
                  ),
              ],
            ),
            const Spacer(), // Добавляем Spacer для размещения текста внизу

            // Padding( // Добавляем отступы вокруг текста
            //   padding: const EdgeInsets.all(16.0),
            //   child: InkWell( // InkWell для обработки нажатий
            //     onTap: () async {
            //       final url = Uri.parse('https://fgsiz.ru/'); // Замени на свой URL
            //       if (await canLaunchUrl(url)) {
            //         await launchUrl(url);
            //       } else {
            //         // Обработка ошибки, если URL не может быть открыт
            //         ScaffoldMessenger.of(context).showSnackBar(
            //           const SnackBar(content: Text('Не удалось открыть URL')),
            //         );
            //       }
            //     },
            //     child: const Center( // Центрируем текст
            //       child: Text(
            //         'Наш сайт',
            //         style: TextStyle(color: Colors.white),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  List<Product> _filterProducts() {
    var filtered = products;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) =>
      product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_selectedTags.isNotEmpty) {
      filtered = filtered
          .where((product) =>
          product.designations.any((tag) => _selectedTags.contains(tag)))
          .toList();
    }

    return filtered;
  }

  Future<bool> _isVerticalImage(String imageUrl) async {
    final ByteData data = await rootBundle.load(imageUrl);
    final Uint8List bytes = data.buffer.asUint8List();
    final image = img.decodeImage(bytes);
    return image!.height > image.width;
  }


  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ProductDetailsScreen(product: product))
        );
      },
      child: Card(
        elevation: 2.0,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 200,
                child: FutureBuilder<List<bool>>(
                  future: Future.wait(product.imageUrls.map(_isVerticalImage)),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final verticalImages = product.imageUrls
                          .asMap()
                          .entries
                          .where((entry) => snapshot.data![entry.key])
                          .map((entry) => entry.value)
                          .toList();
                      final horizontalImages = product.imageUrls
                          .where((imageUrl) =>
                      !verticalImages.contains(imageUrl))
                          .toList();

                      if (verticalImages.isNotEmpty) {
                        return _buildVerticalImages(verticalImages);
                      } else if (horizontalImages.isNotEmpty) {
                        return _buildHorizontalImages(horizontalImages);
                      } else {
                        return const Center(child: Text('Нет изображений'));
                      }
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Ошибка: ${snapshot.error}'));
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
              const SizedBox(height: 10.0),
              Text(
                product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              const SizedBox(height: 5.0),
              Text(product.standard),
              const SizedBox(height: 5.0),
              Text(
                product.description.length > 100
                    ? '${product.description.substring(0, 100)}...'
                    : product.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalImages(List<String> imageUrls) {
    return PageView.builder(
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return Image.asset(
          imageUrls[index],
          fit: BoxFit
              .contain, // Сжимаем изображение, чтобы оно поместилось в контейнер
        );
      },
    );
  }


  Widget _buildVerticalImages(List<String> verticalImages) {
    if (verticalImages.length >= 2) {
      return Row(
        children: [
          for (final imageUrl in verticalImages.take(2))
            Expanded(
              child: Image.asset(
                imageUrl,
                fit: BoxFit.contain, //
              ),
            ),
        ],
      );
    } else if (verticalImages.isNotEmpty) {
      return Center( // Добавлено Center
        child: Image.asset(
          verticalImages[0],
          fit: BoxFit.contain,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
