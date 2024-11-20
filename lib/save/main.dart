import 'package:flutter/material.dart';
import 'package:fgsiz/data/products_data.dart';
import 'package:image/image.dart' as img;
import 'package:fgsiz/data/product.dart';
import 'package:fgsiz/screens/product_details_screen.dart';
import 'package:fgsiz/screens/splash_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

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
  const MyApp({super.key});

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
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _searchQuery = '';
  final List<String> _selectedTags = [];
  String? _selectedFilter;

  Future<Uint8List?> _compressImage(Uint8List imageData) async {
    try {
      final result = await FlutterImageCompress.compressWithList(
        imageData,
        minWidth: 200,
        minHeight: 200,
        quality: 60,
        format: CompressFormat.jpeg,
      );
      return result;
    } catch (e) {
      return null;
    }
  }

  Future<bool> _isVerticalImage(String imageUrl) async {
    final ByteData data = await rootBundle.load(imageUrl);
    final Uint8List bytes = data.buffer.asUint8List();

    final compressedBytes = await _compressImage(bytes);

    if (compressedBytes == null) {
      return false;
    }

    final image = img.decodeImage(compressedBytes);
    if (image == null) return false;

    return image.height > image.width;
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _filterProducts();
    final orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      backgroundColor: const Color(0xFFe3e2e2),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 18, // Уменьшаем размер шрифта заголовка
          ),
        ),
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
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0, vertical: 3.0),
            child: SizedBox(
              height: 48,
              child: TextField(
                onChanged: (value) {
                  setState(() { // Добавляем setState сюда
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
            child: GridView.builder( // Используем GridView.builder
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: (orientation == Orientation.portrait) ? 1 : 2, // 1 колонка в портретной ориентации, 2 - в ландшафтной
                childAspectRatio: (orientation == Orientation.portrait) ? 1 : 1.3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return _buildProductCard(product);
              },
              padding: const EdgeInsets.all(10),

            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.blue,
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Center( // Центрируем текст "Фильтры"
                child: Text(
                  'Фильтры',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const Divider(color: Colors.white),
            Theme(
              data: Theme.of(context).copyWith(
                unselectedWidgetColor: Colors.white,
              ),
              child: ExpansionTile(
                title: const Text('Теги', style: TextStyle(color: Colors.white)),
                children: [
                  SizedBox(
                    height: 400, // Увеличиваем высоту SizedBox
                    child: ListView(
                      children: [
                        for (final tag in _getUniqueTags().toList()..sort())
                          CheckboxListTile(
                            title: Text(tag, style: TextStyle(color: Colors.white)),
                            checkColor: Colors.blue,
                            value: _selectedTags.contains(tag),
                            activeColor: Colors.white,
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Product> _filterProducts() {
    final lowerCaseQuery = _searchQuery.toLowerCase();
    final queryWords = lowerCaseQuery.split(' '); // Разбиваем запрос на слова

    // Начальная фильтрация по поисковому запросу (если есть)
    var filtered = _searchQuery.isEmpty
        ? products
        : products.where((product) {
      final lowerCaseName = product.name.toLowerCase();
      final lowerCaseDescription = product.description.toLowerCase();
      return queryWords.every((word) => lowerCaseName.contains(word) || lowerCaseDescription.contains(word));
    }).toList();


    // Фильтрация по выбранному фильтру (если есть)
    if (_selectedFilter != null && _selectedFilter!.isNotEmpty) {
      filtered = filtered.where((product) {
        return product.designations.any((tag) => tag == _selectedFilter);
      }).toList();
    }

    // Фильтрация по выбранным тегам (если есть)
    if (_selectedTags.isNotEmpty) {
      filtered = filtered.where((product) {
        return product.designations.any((tag) => _selectedTags.contains(tag));
      }).toList();
    }

    return filtered;
  }



  Widget _buildProductCard(Product product) {
    int currentImageIndex = 0;
    final pageController = PageController();

    // Определяем цвет рамки
    Color borderColor = Colors.transparent;
    if (product.designations.contains('FFP1')) {
      borderColor = Colors.yellow;
    } else if (product.designations.contains('FFP2')) {
      borderColor = Colors.green;
    } else if (product.designations.contains('FFP3')) {
      borderColor = Colors.red;
    }
    final orientation = MediaQuery.of(context).orientation;
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProductDetailsScreen(product: product)
            )
        );
      },
      child: Card(
        elevation: 2.0,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: borderColor,
            width: 2.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Растягиваем по горизонтали
            children: [
              SizedBox(
                height: (orientation == Orientation.portrait) ? 200 : 150, // Высота изображения в зависимости от ориентации
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: pageController,
                      itemCount: product.imageUrls.length,
                      itemBuilder: (context, index) {
                        return _buildProductImage(product.imageUrls, index);
                      },
                      onPageChanged: (index) {
                        setState(() {
                          currentImageIndex = index;
                        });
                      },
                    ),
                    if (product.imageUrls.length > 1)
                      Positioned.fill(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios),
                              onPressed: () {
                                if (pageController.page! > 0) {
                                  pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.ease,
                                  );
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward_ios),
                              onPressed: () {
                                if (pageController.page! < product.imageUrls.length - 1) {
                                  pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.ease,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10.0),
              Expanded( // Используем Expanded для названия
                child: Text(
                  product.name,
                  style: const TextStyle(
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              const SizedBox(height: 5.0),
              Text(
                product.standard,
                style: const TextStyle(
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: (orientation == Orientation.portrait) ? 2 : 1, // Ограничиваем количество строк в зависимости от ориентации
              ),
              const SizedBox(height: 5.0),
              Expanded( // Используем Expanded для описания
                child: Text(
                  product.description,
                  overflow: TextOverflow.ellipsis,
                  maxLines: (orientation == Orientation.portrait) ? 3 : 2,  // Ограничиваем количество строк в зависимости от ориентации
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(List<String> imageUrls, int index) {
    if (imageUrls.isEmpty) return const SizedBox();
    return FutureBuilder<bool>(
      future: _isVerticalImage(imageUrls[index]),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage(imageUrls[index]),
                fit: BoxFit.contain,
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Ошибка: ${snapshot.error}'));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildHorizontalImages(List<String> imageUrls, int currentIndex) {
    final pageController = PageController(initialPage: currentIndex);

    return PageView.builder(
      controller: pageController,
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return Image.asset(imageUrls[index], fit: BoxFit.contain);
      },
    );
  }

  Widget _buildVerticalImages(List<String> imageUrls) {
    if (imageUrls.length >= 2) {
      return Row(
        children: [
          for (final imageUrl in imageUrls.take(2))
            Expanded(
              child: Image.asset(imageUrl, fit: BoxFit.contain),
            ),
        ],
      );
    } else if (imageUrls.isNotEmpty) {
      return Center(
        child: Image.asset(imageUrls.first, fit: BoxFit.contain),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
