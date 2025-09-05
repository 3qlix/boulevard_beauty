class Product {
  final String id;
  final String title;
  final double price;
  final String imagePath;
  final String description;
  final String category;
  final String brand;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.imagePath,
    required this.description,
    required this.category,
    required this.brand,
  });

  // Factory constructor لإنشاء Product من JSON (Map)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(), // التأكد من التحويل لـ double
      imagePath: json['imagePath'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      brand: json['brand'] as String,
    );
  }

  // دالة لتحويل Product إلى JSON (Map)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'imagePath': imagePath,
      'description': description,
      'category': category,
      'brand': brand,
    };
  }

  // لتمكين المقارنة بين المنتجات (مهم لـ .any() و .removeWhere())
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
