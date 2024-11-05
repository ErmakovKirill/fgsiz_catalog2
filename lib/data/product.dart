class Product {
  final String name;
  final List<String> imageUrls;
  final String description;
  final List<String> designations;
  final String standard; // Новое поле для стандарта изделия

  Product({
    required this.name,
    required this.imageUrls,
    required this.description,
    required this.designations,
    required this.standard, // Добавь standard в конструктор
  });
}