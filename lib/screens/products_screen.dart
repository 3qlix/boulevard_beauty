import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// استيراد النماذج والشاشات الضرورية فقط
import '../models/product.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  final String? categoryTitle;
  final List<Product> cartItems;
  final Function(Product) addToCart;
  final List<Product> favoriteItems;
  final Function(Product) toggleFavorite;

  const ProductsScreen({
    super.key,
    this.categoryTitle,
    required this.cartItems,
    required this.addToCart,
    required this.favoriteItems,
    required this.toggleFavorite,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  // متحكمات النصوص والتمرير
  final ScrollController _scrollController = ScrollController();

  // حالة التطبيق
  final bool _isLoading = false;

  // الألوان والثيمات - متطابقة مع الشاشة الرئيسية
  static const Color _primaryPurple = Color(0xFF6B166F);
  static const Color _lightPurple = Color(0xFF9C4A9F);

  // بيانات المنتجات
  final List<Product> _allProducts = [
    Product(
      id: '1',
      title: 'كريم مرطب يومي للبشرة الجافة',
      price: 25000.0,
      imagePath: 'assets/images/product1.png',
      description:
          'كريم مرطب غني بفيتامين E وزبدة الشيا لترطيب عميق يدوم 24 ساعة.',
      category: 'العناية بالبشرة',
      brand: 'SVR',
    ),
    Product(
      id: '2',
      title: 'سيروم فيتامين سي لتفتيح البشرة',
      price: 45000.0,
      imagePath: 'assets/images/product2.png',
      description:
          'سيروم قوي بتركيز عالٍ من فيتامين سي لتوحيد لون البشرة وتقليل البقع الداكنة.',
      category: 'العناية بالبشرة',
      brand: 'Cosmo',
    ),
    Product(
      id: '3',
      title: 'شامبو لتقوية الشعر ومنع التساقط',
      price: 30000.0,
      imagePath: 'assets/images/product3.png',
      description:
          'شامبو مغذٍ يقوي بصيلات الشعر ويقلل من تساقط الشعر، مناسب لجميع أنواع الشعر.',
      category: 'العناية بالشعر',
      brand: 'Nacomi',
    ),
    Product(
      id: '4',
      title: 'أحمر شفاه سائل ثابت - لون وردي طبيعي',
      price: 20000.0,
      imagePath: 'assets/images/product4.png',
      description:
          'أحمر شفاه سائل بتركيبة خفيفة ولون ثابت يدوم طويلاً، يمنح الشفاه ترطيباً.',
      category: 'المكياج',
      brand: 'Dermacol',
    ),
    Product(
      id: '5',
      title: 'عطر نسائي فواح - زهور الربيع',
      price: 60000.0,
      imagePath: 'assets/images/product5.png',
      description:
          'عطر نسائي بعبير الزهور المنعشة والفواكه، يدوم طويلاً ويمنحك إحساساً بالانتعاش.',
      category: 'العطور',
      brand: 'Yves Saint Laurent',
    ),
  ];

  // متغيرات الحالة
  List<Product> _displayedProducts = [];

  @override
  void initState() {
    super.initState();
    _filterProductsByCategory();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // تصفية المنتجات حسب الفئة
  void _filterProductsByCategory() {
    if (widget.categoryTitle != null && widget.categoryTitle!.isNotEmpty) {
      _displayedProducts = _allProducts
          .where((p) => p.category == widget.categoryTitle)
          .toList();
    } else {
      _displayedProducts = List.from(_allProducts);
    }
  }

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

  // إضافة منتج إلى السلة
  Future<void> _addToCart(Product product) async {
    // التحقق من حالة تسجيل الدخول يتم في الشاشة الرئيسية
    // هنا نضيف مباشرة
    widget.addToCart(product);

    final productCount =
        widget.cartItems.where((item) => item.id == product.id).length + 1;

    if (productCount > 1) {
      _showSnackBar('✅ «${product.title}» (${productCount}x) في السلة');
    } else {
      _showSnackBar('✅ تمت إضافة «${product.title}» إلى السلة');
    }

    HapticFeedback.lightImpact();
  }

  // فتح شاشة البحث

  // التنقل إلى تفاصيل المنتج
  void _navigateToProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          product: product,
          cartItems: widget.cartItems,
          addToCart: widget.addToCart,
          favoriteItems: widget.favoriteItems,
          toggleFavorite: widget.toggleFavorite,
        ),
      ),
    );
  }

  // الواجهة الرئيسية للتطبيق
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(_primaryPurple),
        ),
      );
    }

    return _buildProductsPage();
  }

  // بناء صفحة المنتجات
  Widget _buildProductsPage() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        color: Colors.grey.shade50,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              const SizedBox(height: 12),
              _buildControlsSection(),
              const SizedBox(height: 16),
              _buildProductsGrid(),
            ],
          ),
        ),
      ),
    );
  }

  // قسم أدوات التحكم (الترتيب والتصنيف)
  Widget _buildControlsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _primaryPurple.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    spreadRadius: 0,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () {
                    _showSnackBar('خيارات الترتيب قيد الإنشاء');
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sort_outlined,
                          color: _primaryPurple,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'الترتيب',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Almarai',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _primaryPurple.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    spreadRadius: 0,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () {
                    _showSnackBar('خيارات التصنيف قيد الإنشاء');
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.filter_list_outlined,
                          color: _primaryPurple,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'التصنيف',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Almarai',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // عرض المنتجات بشكل شبكي (عمودين)
  Widget _buildProductsGrid() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
          childAspectRatio: 0.62,
        ),
        itemCount: _displayedProducts.length,
        itemBuilder: (context, index) {
          final product = _displayedProducts[index];
          return _buildProductCard(product);
        },
      ),
    );
  }

  // كارت المنتج
  Widget _buildProductCard(Product product) {
    final bool isFavorite = widget.favoriteItems.any((e) => e.id == product.id);

    return GestureDetector(
      onTap: () => _navigateToProductDetail(product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              spreadRadius: 0,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة المنتج مع زر المفضلة
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  // حاوية الصورة
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          product.imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.image_not_supported,
                            color: Colors.grey.shade400,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // زر المفضلة
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => widget.toggleFavorite(product),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 0,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey.shade600,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // معلومات المنتج
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // اسم المنتج - ارتفاع ثابت
                    SizedBox(
                      height: 32,
                      child: Text(
                        product.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // الماركة
                    Text(
                      product.brand,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // السعر
                    Text(
                      '${product.price.toStringAsFixed(0)} د.ع',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),

                    // Spacer لدفع الزر للأسفل
                    const Spacer(),

                    // زر إضافة للسلة
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _addToCart(product),
                        borderRadius: BorderRadius.circular(16),
                        splashColor: Colors.white.withOpacity(0.3),
                        highlightColor: Colors.white.withOpacity(0.1),
                        child: Ink(
                          width: 110,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_primaryPurple, _lightPurple],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'ضيفيني لسلتج',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
