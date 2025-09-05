import 'package:flutter/material.dart';

// استيراد النماذج والشاشات الضرورية فقط
import '../models/product.dart';
import 'products_screen.dart';
import 'login_screen.dart';

class CategoriesScreen extends StatefulWidget {
  final List<Product> cartItems;
  final Function(Product) addToCart;
  final List<Product> favoriteItems;
  final Function(Product) toggleFavorite;

  const CategoriesScreen({
    super.key,
    required this.cartItems,
    required this.addToCart,
    required this.favoriteItems,
    required this.toggleFavorite,
  });

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  // الألوان والثيمات
  static const Color _primaryPurple = Color(0xFF6B166F);
  static const Color _lightPurple = Color(0xFF9C4A9F);
  static const Color _accentPurple = Color(0xFFE1BEE7);

  static const LinearGradient _purpleGradient = LinearGradient(
    colors: [_primaryPurple, _lightPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // بيانات الأقسام
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'العناية بالبشرة',
      'image': 'assets/images/skincare.png',
      'icon': Icons.face_outlined,
      'color': const Color(0xFFE8F5E8),
    },
    {
      'name': 'العناية بالشعر',
      'image': 'assets/images/haircare.png',
      'icon': Icons.content_cut_outlined,
      'color': const Color(0xFFFFF3E0),
    },
    {
      'name': 'المكياج',
      'image': 'assets/images/makeup.png',
      'icon': Icons.brush_outlined,
      'color': const Color(0xFFFCE4EC),
    },
    {
      'name': 'العطور',
      'image': 'assets/images/perfumes.png',
      'icon': Icons.local_florist_outlined,
      'color': const Color(0xFFE3F2FD),
    },
    {
      'name': 'العناية بالجسم',
      'image': 'assets/images/bodycare.png',
      'icon': Icons.spa_outlined,
      'color': const Color(0xFFF3E5F5),
    },
    {
      'name': 'الأدوات',
      'image': 'assets/images/tools.png',
      'icon': Icons.build_outlined,
      'color': const Color(0xFFE0F2F1),
    },
  ];
  // عرض رسالة في أسفل الشاشة
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade400 : _primaryPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: isError ? 4 : 2),
        action: SnackBarAction(
          label: 'إغلاق',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // عرض حوار تسجيل الدخول المطلوب
  void _showLoginRequiredDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _accentPurple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.login_rounded, color: _primaryPurple),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _primaryPurple,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            height: 1.4,
          ),
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600),
            child: const Text('لاحقاً', style: TextStyle(fontSize: 16)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: _purpleGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'تسجيل الدخول',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // التنقل إلى قسم معين
  void _navigateToCategory(String categoryName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductsScreen(
          categoryTitle: categoryName,
          cartItems: widget.cartItems,
          addToCart: widget.addToCart,
          favoriteItems: widget.favoriteItems,
          toggleFavorite: widget.toggleFavorite,
        ),
      ),
    );
  }

  // بناء محتوى الأقسام
  Widget _buildCategoriesContent() {
    return Container(
      color: Colors.white,
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 0.85,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return GestureDetector(
            onTap: () {
              // الانتقال مباشرة للمنتجات
              _navigateToCategory(category['name']);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade100, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  children: [
                    // الصورة تملأ الجزء العلوي من البطاقة
                    Expanded(
                      flex: 3,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(color: Colors.grey.shade50),
                        child: Image.asset(
                          category['image'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: category['color'],
                                child: Icon(
                                  category['icon'],
                                  color: _primaryPurple.withOpacity(0.5),
                                  size: 50,
                                ),
                              ),
                        ),
                      ),
                    ),

                    // اسم القسم في الأسفل
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(
                              color: Colors.grey.shade100,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            category['name'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              fontFamily: 'Almarai',
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // دالة build الرئيسية
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: _buildCategoriesContent(),
    );
  }
}
