import 'package:flutter/material.dart';
import 'package:fgsiz/data/product.dart';
import 'package:flutter_justify_text/justify_text.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleFullScreen(int index) {
    setState(() {
      _isFullScreen = !_isFullScreen;
      if (!_isFullScreen) {
        _currentPage = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали товара'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: _isFullScreen
          ? GestureDetector(
              onScaleUpdate: (details) {
                // Implement zoom functionality here
              },
              child: Stack(
                children: [
                  InteractiveViewer(
                    boundaryMargin: EdgeInsets.all(100.0),
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.asset(
                      widget.product.imageUrls[_currentPage],
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    top: 40,
                    left: 16,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _toggleFullScreen(_currentPage);
                      },
                    ),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 500,
                        child: Stack(
                          children: [
                            PageView.builder(
                              controller: _pageController,
                              itemCount: widget.product.imageUrls.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    _toggleFullScreen(index);
                                  },
                                  child: Image.asset(
                                    widget.product.imageUrls[index],
                                    fit: BoxFit.contain,
                                  ),
                                );
                              },
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPage = index;
                                });
                              },
                            ),
                            if (widget.product.imageUrls.length > 1)
                              Positioned.fill(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.arrow_back_ios),
                                      onPressed: () {
                                        if (_pageController.page! > 0) {
                                          _pageController.previousPage(
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.ease,
                                          );
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.arrow_forward_ios),
                                      onPressed: () {
                                        if (_pageController.page! < widget.product.imageUrls.length - 1) {
                                          _pageController.nextPage(
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
                      const SizedBox(height: 16.0),
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          fontFamily: 'Open Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      JustifyText(
                        widget.product.description,
                        textAlign: TextAlign.justify,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                if (_isFullScreen)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: GestureDetector(
                      onTap: () {
                        _toggleFullScreen(_currentPage);
                      },
                    ),
                  ),
              ],
            ),
    );
  }
}
