import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// استيراد النماذج والشاشات الضرورية
import '../models/product.dart';
import 'products_screen.dart';
import 'login_screen.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final List<Product> cartItems;
  final bool isLoggedIn;
  final List<Product> favoriteItems;
  final Function(Product) toggleFavorite;
  final Function(Product) addToCart;
  final VoidCallback? onCartUpdated; // للتحديث التلقائي

  const CartScreen({
    super.key,
    required this.cartItems,
    required this.isLoggedIn,
    required this.favoriteItems,
    required this.toggleFavorite,
    required this.addToCart,
    this.onCartUpdated,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // الألوان الأساسية
  static const Color _primaryPurple = Color(0xFF6B166F);
  static const Color _lightPurple = Color(0xFF9C4A9F);
  static const Color _accentPurple = Color(0xFFE1BEE7);

  // تدرج الألوان البنفسجية
  static const LinearGradient _purpleGradient = LinearGradient(
    colors: [_primaryPurple, _lightPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // الحد الأدنى للتوصيل المجاني
  final double _freeDeliveryThreshold = 50000.0;

  // متغيرات الحالة
  Map<String, int> _productQuantities = {};

  @override
  void initState() {
    super.initState();
    _initializeQuantities();
  }

  @override
  void didUpdateWidget(CartScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // تحديث الكميات عند تغيير السلة
    if (oldWidget.cartItems.length != widget.cartItems.length) {
      _initializeQuantities();
    }
  }

  // تهيئة كميات المنتجات
  void _initializeQuantities() {
    _productQuantities.clear();
    for (var product in widget.cartItems) {
      _productQuantities[product.id] =
          (_productQuantities[product.id] ?? 0) + 1;
    }
  }

  // حساب المجموع الكلي
  double get _totalAmount {
    double total = 0.0;
    for (var item in widget.cartItems) {
      total += item.price;
    }
    return total;
  }

  // حساب العدد الكلي للمنتجات
  int get _totalQuantity {
    return widget.cartItems.length;
  }

  // حساب تكلفة التوصيل
  double get _deliveryFee {
    if (_totalAmount >= _freeDeliveryThreshold) {
      return 0.0;
    }
    return 5000.0;
  }

  // زيادة كمية المنتج
  void _increaseQuantity(Product product) {
    setState(() {
      widget.cartItems.add(product);
      _productQuantities[product.id] =
          (_productQuantities[product.id] ?? 0) + 1;
    });
    _saveCartToPrefs();
    widget.onCartUpdated?.call(); // تحديث الشاشة الرئيسية
    HapticFeedback.lightImpact();
  }

  // تقليل كمية المنتج
  void _decreaseQuantity(Product product) {
    if ((_productQuantities[product.id] ?? 0) > 1) {
      setState(() {
        int index = widget.cartItems.indexWhere(
          (item) => item.id == product.id,
        );
        if (index != -1) {
          widget.cartItems.removeAt(index);
          _productQuantities[product.id] =
              (_productQuantities[product.id]! - 1);
        }
      });
      _saveCartToPrefs();
      widget.onCartUpdated?.call(); // تحديث الشاشة الرئيسية
      HapticFeedback.lightImpact();
    }
  }

  // إزالة منتج من السلة
  void _removeItem(Product product) {
    setState(() {
      widget.cartItems.removeWhere((item) => item.id == product.id);
      _productQuantities.remove(product.id);
    });
    _saveCartToPrefs();
    widget.onCartUpdated?.call(); // تحديث الشاشة الرئيسية
    _showSnackBar('تمت إزالة "${product.title}" من السلة');
    HapticFeedback.mediumImpact();
  }

  // إفراغ السلة بالكامل
  void _clearCart() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // زر الإغلاق
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(ctx),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),

              // العنوان
              Text(
                'هل إنتي متأكدة من حذف المنتجات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primaryPurple,
                  fontFamily: 'Almarai',
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'من سلتج',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primaryPurple,
                  fontFamily: 'Almarai',
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // زر نعم
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      widget.cartItems.clear();
                      _productQuantities.clear();
                    });
                    _saveCartToPrefs();
                    widget.onCartUpdated?.call(); // تحديث الشاشة الرئيسية
                    Navigator.pop(ctx);
                    _showSnackBar('تم إفراغ السلة بنجاح!');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'نعم',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'Almarai',
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // زر لا
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _primaryPurple, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'لا',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _primaryPurple,
                      fontFamily: 'Almarai',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // حفظ السلة في التفضيلات
  Future<void> _saveCartToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = widget.cartItems
          .map((product) => jsonEncode(product.toJson()))
          .toList();
      await prefs.setStringList('cart', cartData);
    } catch (e) {
      debugPrint('خطأ في حفظ السلة: $e');
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
      ),
    );
  }

  // التنقل إلى المنتجات
  void _navigateToProducts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductsScreen(
          categoryTitle: '',
          cartItems: widget.cartItems,
          addToCart: widget.addToCart,
          favoriteItems: widget.favoriteItems,
          toggleFavorite: widget.toggleFavorite,
        ),
      ),
    ).then((_) {
      setState(() {
        _initializeQuantities();
      });
      widget.onCartUpdated?.call();
    });
  }

  // التنقل لتسجيل الدخول
  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    ).then((result) {
      if (result == true) {
        setState(() {});
        widget.onCartUpdated?.call();
      }
    });
  }

  // التنقل إلى شاشة تثبيت الطلب
  void _navigateToCheckout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          cartItems: widget.cartItems,
          totalAmount: _totalAmount,
          deliveryFee: _deliveryFee,
          onOrderConfirmed: () {
            setState(() {
              widget.cartItems.clear();
              _productQuantities.clear();
            });
            _saveCartToPrefs();
            widget.onCartUpdated?.call();
          },
        ),
      ),
    );
  }

  // الحصول على عدد المنتجات الفريدة
  int _getUniqueProductsCount() {
    return _productQuantities.keys.length;
  }

  // الحصول على قائمة المنتجات الفريدة
  List<Product> _getUniqueProducts() {
    final uniqueProducts = <Product>[];
    final addedIds = <String>{};

    for (var product in widget.cartItems) {
      if (!addedIds.contains(product.id)) {
        uniqueProducts.add(product);
        addedIds.add(product.id);
      }
    }

    return uniqueProducts;
  }

  // واجهة عندما يكون المستخدم غير مسجل الدخول
  Widget _buildLoginRequiredView() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // متابعة التسوق في الأعلى
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: GestureDetector(
              onTap: _navigateToProducts,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'متابعة التسوق',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _primaryPurple,
                      fontFamily: 'Almarai',
                    ),
                  ),
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: _accentPurple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.shopping_bag,
                      color: _primaryPurple,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // الصورة الرئيسية
          Container(
            height: 250,
            width: 250,
            decoration: BoxDecoration(
              color: _accentPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.lock_outline, color: _primaryPurple, size: 100),
          ),

          const SizedBox(height: 40),

          Text(
            'ما تگدرين تضيفين للسلة حتى تسوين',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade700,
              fontFamily: 'Almarai',
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            'تسجيل دخول',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade700,
              fontFamily: 'Almarai',
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _navigateToLogin,
              borderRadius: BorderRadius.circular(16),
              splashColor: Colors.white.withOpacity(0.3),
              highlightColor: Colors.white.withOpacity(0.1),
              child: Ink(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  gradient: _purpleGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryPurple.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  'تسجيل الدخول',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }

  // واجهة السلة الفارغة للمستخدم المسجل
  Widget _buildEmptyCartView() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: GestureDetector(
              onTap: _navigateToProducts,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'متابعة التسوق',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _primaryPurple,
                      fontFamily: 'Almarai',
                    ),
                  ),
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: _accentPurple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.shopping_bag,
                      color: _primaryPurple,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          Icon(Icons.shopping_cart_outlined, color: _primaryPurple, size: 120),

          const SizedBox(height: 40),

          Text(
            'سلتج فارغة!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _primaryPurple,
              fontFamily: 'Almarai',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'تسوقي هسه وابدي رحلة العناية بنفسج',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontFamily: 'Almarai',
            ),
            textAlign: TextAlign.center,
          ),

          const Spacer(),
        ],
      ),
    );
  }

  // بناء بطاقة المنتج في السلة
  Widget _buildCartItemCard(Product product, int quantity) {
    final totalPrice = product.price * quantity;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // الصف الأول: العنوان وزر الإغلاق
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    product.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                      fontFamily: 'Almarai',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.grey.shade500,
                    size: 22,
                  ),
                  onPressed: () => _removeItem(product),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // الصف الثاني: الماركة
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                product.brand,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontFamily: 'Almarai',
                ),
              ),
            ),

            const SizedBox(height: 12),

            // الصف الثالث: الصورة والمعلومات
            Row(
              children: [
                // صورة المنتج
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
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

                const SizedBox(width: 16),

                // معلومات السعر والكمية
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'سعر القطعة: ${product.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          fontFamily: 'Almarai',
                        ),
                      ),

                      const SizedBox(height: 16),

                      // أزرار تغيير الكمية
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 20),
                                  onPressed: quantity > 1
                                      ? () => _decreaseQuantity(product)
                                      : null,
                                  color: _primaryPurple,
                                  disabledColor: Colors.grey.shade400,
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    quantity.toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _primaryPurple,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 20),
                                  onPressed: () => _increaseQuantity(product),
                                  color: _primaryPurple,
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // الإجمالي
                      Text(
                        'الإجمالي: ${totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _primaryPurple,
                          fontFamily: 'Almarai',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // واجهة السلة عند وجود منتجات
  Widget _buildCartWithItemsView() {
    final double remainingForFreeDelivery =
        _freeDeliveryThreshold - _totalAmount;
    final uniqueProducts = _getUniqueProducts();

    return Column(
      children: [
        // الهيدر
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              GestureDetector(
                onTap: _clearCart,
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      color: Colors.grey.shade600,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'إفراغ السلة',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 16,
                        fontFamily: 'Almarai',
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'متابعة التسوق',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primaryPurple,
                  fontFamily: 'Almarai',
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _navigateToProducts,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _accentPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.shopping_bag,
                    color: _primaryPurple,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),

        // قائمة المنتجات
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: uniqueProducts.length,
            itemBuilder: (context, index) {
              final product = uniqueProducts[index];
              final quantity = _productQuantities[product.id] ?? 1;
              return _buildCartItemCard(product, quantity);
            },
          ),
        ),

        // شريط التقدم للتوصيل المجاني
        if (remainingForFreeDelivery > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'باقي ${remainingForFreeDelivery.toStringAsFixed(0)} للحصول على توصيل مجاني',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _primaryPurple,
                      fontFamily: 'Almarai',
                    ),
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: (_totalAmount / _freeDeliveryThreshold).clamp(
                      0.0,
                      1.0,
                    ),
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(_primaryPurple),
                    borderRadius: BorderRadius.circular(10),
                    minHeight: 6,
                  ),
                ],
              ),
            ),
          ),

        // ملخص الطلب
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الكمية: $_totalQuantity',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      fontFamily: 'Almarai',
                    ),
                  ),
                  Text(
                    'المجموع: ${_totalAmount.toStringAsFixed(0)} د.ع',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _primaryPurple,
                      fontFamily: 'Almarai',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _navigateToCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'المتابعة لتثبيت الطلب',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Almarai',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(color: Colors.grey.shade50, child: _buildContent()),
    );
  }

  Widget _buildContent() {
    if (!widget.isLoggedIn) {
      return _buildLoginRequiredView();
    }

    if (widget.cartItems.isEmpty) {
      return _buildEmptyCartView();
    }

    return _buildCartWithItemsView();
  }
}
