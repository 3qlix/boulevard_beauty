import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_detail_screen.dart';
// import 'cart_screen.dart'; // تم إزالة هذا الاستيراد لأنه غير مستخدم مباشرة هنا

class FavoritesScreen extends StatefulWidget {
  final List<Product> favoriteProducts;
  final List<Product> cartItems;
  final Function(Product) addToCart;
  final Function(Product) toggleFavorite;

  const FavoritesScreen({
    super.key,
    required this.favoriteProducts,
    required this.cartItems,
    required this.addToCart,
    required this.toggleFavorite,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  static const Color _purpleColor = Color(0xFF6B166F);
  static const Color _lightGreyColor = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _lightGreyColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: _purpleColor,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'المفضلة',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Almarai',
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: _purpleColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: widget.favoriteProducts.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'لا توجد منتجات في المفضلة بعد.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontFamily: 'Almarai',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'اضغط على أيقونة القلب في المنتجات لإضافتها هنا.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                        fontFamily: 'Almarai',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(15),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.65,
                ),
                itemCount: widget.favoriteProducts.length,
                itemBuilder: (context, index) {
                  final product = widget.favoriteProducts[index];
                  return _buildProductCard(product);
                },
              ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final bool isFavorite = widget.favoriteProducts.any(
      (e) => e.id == product.id,
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(
              product: product,
              cartItems: widget.cartItems,
              addToCart: widget.addToCart,
              favoriteItems: widget.favoriteProducts,
              toggleFavorite: widget.toggleFavorite,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB((255 * 0.08).round(), 0, 0, 0),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: Image.asset(
                    product.imagePath,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150,
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 50,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'كمية محدودة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Almarai',
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      widget.toggleFavorite(product);
                    },
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? _purpleColor : Colors.white,
                      size: 24,
                      shadows: isFavorite
                          ? null
                          : [
                              Shadow(
                                color: Color.fromARGB(
                                  (255 * 0.5).round(),
                                  0,
                                  0,
                                  0,
                                ),
                                blurRadius: 4,
                                offset: const Offset(1, 1),
                              ),
                            ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black87,
                      fontFamily: 'Almarai',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.brand,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      fontFamily: 'Almarai',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product.price.toStringAsFixed(0)} د.ع',
                        style: const TextStyle(
                          color: _purpleColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'Almarai',
                        ),
                      ),
                      GestureDetector(
                        onTap: () => widget.addToCart(product),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _purpleColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.add_shopping_cart,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
