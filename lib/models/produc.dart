class Product {
  final String? id;
  final String name;
  final String description;
  final double price;
  final int stock;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
  });

  Map<String, dynamic> toMap() => {
    'name':        name,
    'description': description,
    'price':       price,
    'stock':       stock,
  };

  factory Product.fromMap(String id, Map<String, dynamic> map) => Product(
    id:          id,
    name:        map['name']        ?? '',
    description: map['description'] ?? '',
    price:       (map['price']      ?? 0).toDouble(),
    stock:       (map['stock']      ?? 0).toInt(),
  );
}