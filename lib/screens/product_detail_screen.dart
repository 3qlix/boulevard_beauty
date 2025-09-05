import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

// استيراد النماذج والخدمات والشاشات
import '../models/product.dart';
import '../services/auth_service.dart';
import '../models/app_user.dart';
import 'favorites_screen.dart';
import 'login_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final List<Product> cartItems;
  final Function(Product) addToCart;
  final List<Product> favoriteItems;
  final Function(Product) toggleFavorite;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.cartItems,
    required this.addToCart,
    required this.favoriteItems,
    required this.toggleFavorite,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  // متحكمات الرسوم المتحركة
  late AnimationController _animationController;
  late AnimationController _imageAnimationController;
  late AnimationController _buttonAnimationController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _imageAnimation;
  late Animation<double> _buttonAnimation;

  // متحكم التمرير
  final ScrollController _scrollController = ScrollController();

  // حالة التطبيق
  bool _isLoggedIn = false;
  AppUser? _currentUser;
  bool _isLoading = false;
  bool _showAppBarBackground = false;
  int _quantity = 1;
  int _selectedImageIndex = 0;

  // الألوان والثيمات - متطابقة مع الشاشات الأخرى
  static const Color _primaryPurple = Color(0xFF6B166F);
  static const Color _lightPurple = Color(0xFF9C4A9F);
  static const Color _darkPurple = Color(0xFF4A0E4D);
  static const Color _accentPurple = Color(0xFFE1BEE7);

  // تدرج الألوان البنفسجية الراقية
  static const LinearGradient _purpleGradient = LinearGradient(
    colors: [_primaryPurple, _lightPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // صور المنتج الإضافية (للعرض)
  List<String> get _productImages => [
    widget.product.imagePath,
    widget.product.imagePath, // يمكن إضافة صور إضافية هنا
    widget.product.imagePath,
  ];

  // المنتجات المشابهة (مؤقتة)
  final List<Product> _relatedProducts = [
    Product(
      id: 'related_1',
      title: 'منتج مشابه 1',
      price: 22000.0,
      imagePath: 'assets/images/product2.png',
      description: 'منتج مشابه رائع',
      category: 'العناية بالبشرة',
      brand: 'Cosmo',
    ),
    Product(
      id: 'related_2',
      title: 'منتج مشابه 2',
      price: 28000.0,
      imagePath: 'assets/images/product3.png',
      description: 'منتج مشابه آخر',
      category: 'العناية بالبشرة',
      brand: 'SVR',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupScrollListener();
    _checkLoginStatus();
    _startAnimations();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _imageAnimationController.dispose();
    _buttonAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // تهيئة الرسوم المتحركة
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _imageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
      ),
    );

    _imageAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _imageAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _buttonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.bounceOut,
      ),
    );
  }

  // إعداد مستمع التمرير
  void _setupScrollListener() {
    _scrollController.addListener(() {
      final bool newShowBackground = _scrollController.offset >= 200.0;
      if (newShowBackground != _showAppBarBackground) {
        setState(() {
          _showAppBarBackground = newShowBackground;
        });
      }
    });
  }

  // بدء الرسوم المتحركة
  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _animationController.forward();
        _imageAnimationController.forward();
      }
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _buttonAnimationController.forward();
      }
    });
  }

  // فحص حالة تسجيل الدخول
  Future<void> _checkLoginStatus() async {
    try {
      _isLoggedIn = await AuthService.isLoggedIn();
      if (_isLoggedIn) {
        _currentUser = await AuthService.getCurrentUser();
      }
    } catch (e) {
      debugPrint('خطأ في فحص حالة تسجيل الدخول: $e');
      _isLoggedIn = false;
      _currentUser = null;
    }
  }

  // دالة مساعدة لإنشاء الألوان مع الشفافية
  Color _withAlpha(Color color, double alpha) {
    return color.withValues(alpha: alpha);
  }

  // التحقق من حالة المنتج
  bool get _isFavorite =>
      widget.favoriteItems.any((e) => e.id == widget.product.id);
  bool get _isInCart => widget.cartItems.any((e) => e.id == widget.product.id);

  // إضافة للمفضلة مع تأثير بصري
  void _toggleFavoriteWithAnimation() {
    HapticFeedback.lightImpact();

    // رسم متحرك للقلب
    _buttonAnimationController.reset();
    _buttonAnimationController.forward();

    setState(() {
      widget.toggleFavorite(widget.product);
    });

    _showSnackBar(
      _isFavorite
          ? 'تمت إضافة المنتج إلى المفضلة ❤️'
          : 'تمت إزالة المنتج من المفضلة',
      isSuccess: _isFavorite,
    );
  }

  // إضافة للسلة مع تحقق من تسجيل الدخول
  Future<void> _addToCartWithValidation() async {
    if (!_isLoggedIn) {
      _showLoginRequiredDialog();
      return;
    }

    if (_isInCart) {
      _showSnackBar('المنتج موجود بالفعل في السلة!', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // محاكاة تأخير إضافة المنتج
    await Future.delayed(const Duration(milliseconds: 800));

    HapticFeedback.mediumImpact();

    // إضافة المنتج بالكمية المحددة
    for (int i = 0; i < _quantity; i++) {
      widget.addToCart(widget.product);
    }

    setState(() {
      _isLoading = false;
    });

    _showSnackBar('✅ تمت إضافة «${widget.product.title}» إلى السلة');

    // رسم متحرك للزر
    _buttonAnimationController.reset();
    _buttonAnimationController.forward();
  }

  // تغيير الكمية
  void _updateQuantity(int newQuantity) {
    if (newQuantity >= 1 && newQuantity <= 10) {
      setState(() {
        _quantity = newQuantity;
      });
      HapticFeedback.selectionClick();
    }
  }

  // تغيير الصورة المحددة
  void _selectImage(int index) {
    if (index != _selectedImageIndex) {
      setState(() {
        _selectedImageIndex = index;
      });

      _imageAnimationController.reset();
      _imageAnimationController.forward();
      HapticFeedback.selectionClick();
    }
  }

  // عرض حوار تسجيل الدخول المطلوب
  void _showLoginRequiredDialog() {
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
                color: _withAlpha(_accentPurple, 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.login_rounded, color: _primaryPurple),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'تسجيل الدخول مطلوب',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _primaryPurple,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'يجب تسجيل الدخول لإضافة المنتجات إلى السلة',
          style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.4),
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
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );

                if (result == true) {
                  await _checkLoginStatus();
                  if (mounted) setState(() {});
                }
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

  // عرض رسالة في أسفل الشاشة
  void _showSnackBar(
    String message, {
    bool isError = false,
    bool isSuccess = false,
  }) {
    if (!mounted) return;

    Color backgroundColor;
    IconData icon;

    if (isError) {
      backgroundColor = Colors.red.shade400;
      icon = Icons.error_outline;
    } else if (isSuccess) {
      backgroundColor = Colors.green.shade400;
      icon = Icons.check_circle_outline;
    } else {
      backgroundColor = _primaryPurple;
      icon = Icons.check_circle_outline;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
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
        backgroundColor: backgroundColor,
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

  // فتح واتساب
  Future<void> _launchWhatsApp() async {
    const url = 'https://wa.me/9647831934249';
    try {
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        _showSnackBar('تعذّر فتح واتساب', isError: true);
      }
    } catch (e) {
      _showSnackBar('تعذّر فتح واتساب', isError: true);
    }
  }

  // مشاركة المنتج
  void _shareProduct() {
    HapticFeedback.mediumImpact();
    _showSnackBar('ميزة المشاركة قيد التطوير');
  }

  // التنقل إلى شاشة المفضلة
  void _navigateToFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FavoritesScreen(
          favoriteProducts: widget.favoriteItems,
          cartItems: widget.cartItems,
          addToCart: widget.addToCart,
          toggleFavorite: widget.toggleFavorite,
        ),
      ),
    );
  }

  // الواجهة الرئيسية
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _buildAppTheme(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.grey.shade50,
          extendBodyBehindAppBar: true,
          appBar: _buildAnimatedAppBar(),
          body: _buildBody(),
        ),
      ),
    );
  }

  // تطبيق الثيم
  ThemeData _buildAppTheme() {
    return ThemeData(
      primarySwatch: Colors.purple,
      primaryColor: _primaryPurple,
      fontFamily: 'Almarai',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: _primaryPurple,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
    );
  }

  // شريط التطبيق المتحرك
  PreferredSizeWidget _buildAnimatedAppBar() {
    return AppBar(
      backgroundColor: _showAppBarBackground
          ? Colors.white
          : Colors.transparent,
      foregroundColor: _showAppBarBackground ? _primaryPurple : Colors.white,
      elevation: _showAppBarBackground ? 2 : 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _showAppBarBackground
              ? _withAlpha(_accentPurple, 0.1)
              : _withAlpha(Colors.black, 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
          tooltip: 'رجوع',
        ),
      ),
      title: AnimatedOpacity(
        opacity: _showAppBarBackground ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Text(
          widget.product.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Almarai',
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _showAppBarBackground
                ? _withAlpha(_accentPurple, 0.1)
                : _withAlpha(Colors.black, 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ScaleTransition(
            scale: _buttonAnimation,
            child: IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite
                    ? Colors.red
                    : (_showAppBarBackground ? _primaryPurple : Colors.white),
              ),
              onPressed: _toggleFavoriteWithAnimation,
              tooltip: _isFavorite ? 'إزالة من المفضلة' : 'إضافة للمفضلة',
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _showAppBarBackground
                ? _withAlpha(_accentPurple, 0.1)
                : _withAlpha(Colors.black, 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(
              Icons.share_outlined,
              color: _showAppBarBackground ? _primaryPurple : Colors.white,
            ),
            onPressed: _shareProduct,
            tooltip: 'مشاركة',
          ),
        ),
        Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.green.withValues(
              alpha: _showAppBarBackground ? 0.1 : 0.3,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Image.asset(
              'assets/images/whatsapp_icon.png',
              height: 24,
              width: 24,
              color: _showAppBarBackground ? Colors.green : Colors.white,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.chat_bubble_outline,
                color: _showAppBarBackground ? Colors.green : Colors.white,
              ),
            ),
            onPressed: _launchWhatsApp,
            tooltip: 'تواصل عبر واتساب',
          ),
        ),
      ],
    );
  }

  // بناء الجسم الرئيسي
  Widget _buildBody() {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // صور المنتج
        SliverToBoxAdapter(child: _buildProductImageSection()),

        // معلومات المنتج
        SliverToBoxAdapter(child: _buildProductInfoSection()),

        // خيارات المنتج
        SliverToBoxAdapter(child: _buildProductOptionsSection()),

        // الوصف التفصيلي
        SliverToBoxAdapter(child: _buildDetailedDescriptionSection()),

        // معلومات إضافية
        SliverToBoxAdapter(child: _buildAdditionalInfoSection()),

        // المنتجات المشابهة
        SliverToBoxAdapter(child: _buildRelatedProductsSection()),

        // مساحة إضافية في الأسفل
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  // قسم صور المنتج
  Widget _buildProductImageSection() {
    return SizedBox(
      height: 400,
      child: Stack(
        children: [
          // الصورة الرئيسية
          AnimatedBuilder(
            animation: _imageAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.9 + (_imageAnimation.value * 0.1),
                child: Container(
                  margin: EdgeInsets.only(
                    top: 100 + (20 * (1 - _imageAnimation.value)),
                    left: 20,
                    right: 20,
                    bottom: 20,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        spreadRadius: 2,
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      _productImages[_selectedImageIndex],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported_outlined,
                              size: 60,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'فشل تحميل الصورة',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // شارات المنتج
          Positioned(
            top: 120,
            left: 40,
            child: Column(
              children: [
                _buildProductBadge('جديد', Colors.green),
                const SizedBox(height: 8),
                _buildProductBadge('كمية محدودة', Colors.red),
              ],
            ),
          ),

          // مؤشر الصور (إذا كان هناك أكثر من صورة)
          if (_productImages.length > 1)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: _buildImageIndicator(),
            ),
        ],
      ),
    );
  }

  // شارة المنتج
  Widget _buildProductBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.8)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          fontFamily: 'Almarai',
        ),
      ),
    );
  }

  // مؤشر الصور
  Widget _buildImageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_productImages.length, (index) {
        return GestureDetector(
          onTap: () => _selectImage(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: index == _selectedImageIndex ? 12 : 8,
            height: index == _selectedImageIndex ? 12 : 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: index == _selectedImageIndex
                  ? _primaryPurple
                  : Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
        );
      }),
    );
  }

  // قسم معلومات المنتج
  Widget _buildProductInfoSection() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    spreadRadius: 1,
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // الماركة
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _withAlpha(_accentPurple, 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _withAlpha(_primaryPurple, 0.2),
                      ),
                    ),
                    child: Text(
                      widget.product.brand,
                      style: TextStyle(
                        color: _primaryPurple,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Almarai',
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // عنوان المنتج
                  Text(
                    widget.product.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      height: 1.3,
                      fontFamily: 'Almarai',
                    ),
                  ),

                  const SizedBox(height: 12),

                  // تقييم المنتج (وهمي)
                  Row(
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < 4 ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 18,
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '4.2',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(127 تقييم)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // السعر
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.product.price.toStringAsFixed(0)} د.ع',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: _primaryPurple,
                              fontFamily: 'Almarai',
                            ),
                          ),
                          if (widget.product.price > 20000) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${(widget.product.price * 1.2).toStringAsFixed(0)} د.ع',
                              style: TextStyle(
                                fontSize: 16,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey.shade500,
                                fontFamily: 'Almarai',
                              ),
                            ),
                          ],
                        ],
                      ),

                      // حالة المنتج
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.green, Colors.greenAccent],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.3),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'متاح',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // الوصف المختصر
                  Text(
                    widget.product.description,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                      height: 1.5,
                      fontFamily: 'Almarai',
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // قسم خيارات المنتج
  Widget _buildProductOptionsSection() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 0.5),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // عنوان القسم
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: _purpleGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.tune_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'خيارات المنتج',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          fontFamily: 'Almarai',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // اختيار الكمية
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'الكمية:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          fontFamily: 'Almarai',
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _buildQuantityButton(
                              Icons.remove,
                              () => _updateQuantity(_quantity - 1),
                              enabled: _quantity > 1,
                            ),
                            Container(
                              width: 50,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                '$_quantity',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Almarai',
                                ),
                              ),
                            ),
                            _buildQuantityButton(
                              Icons.add,
                              () => _updateQuantity(_quantity + 1),
                              enabled: _quantity < 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // معلومات الشحن
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _withAlpha(_accentPurple, 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _withAlpha(_primaryPurple, 0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_shipping_outlined,
                          color: _primaryPurple,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'شحن مجاني',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'للطلبات فوق 50,000 د.ع',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // زر تغيير الكمية
  Widget _buildQuantityButton(
    IconData icon,
    VoidCallback onPressed, {
    bool enabled = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: enabled
                ? _withAlpha(_primaryPurple, 0.1)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: enabled ? _primaryPurple : Colors.grey.shade400,
            size: 18,
          ),
        ),
      ),
    );
  }

  // قسم الوصف التفصيلي
  Widget _buildDetailedDescriptionSection() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 0.3),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // عنوان القسم
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: _purpleGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.description_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'وصف المنتج',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          fontFamily: 'Almarai',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // الوصف المفصل
                  Text(
                    widget.product.description,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                      height: 1.6,
                      fontFamily: 'Almarai',
                    ),
                  ),

                  const SizedBox(height: 20),

                  // المميزات
                  Column(
                    children: [
                      _buildFeatureItem(
                        Icons.verified_outlined,
                        'منتج أصلي 100%',
                        'مضمون الجودة والأصالة',
                      ),
                      _buildFeatureItem(
                        Icons.eco_outlined,
                        'آمن على البشرة',
                        'مختبر ومعتمد طبياً',
                      ),
                      _buildFeatureItem(
                        Icons.stars_outlined,
                        'جودة عالية',
                        'من أفضل الماركات العالمية',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // عنصر المميزة
  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _withAlpha(_accentPurple, 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _withAlpha(_primaryPurple, 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _primaryPurple, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // قسم المعلومات الإضافية
  Widget _buildAdditionalInfoSection() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 0.2),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // تبويب المعلومات
                  DefaultTabController(
                    length: 3,
                    child: Column(
                      children: [
                        TabBar(
                          labelColor: _primaryPurple,
                          unselectedLabelColor: Colors.grey.shade600,
                          indicatorColor: _primaryPurple,
                          indicatorWeight: 3,
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            fontFamily: 'Almarai',
                          ),
                          tabs: const [
                            Tab(text: 'المكونات'),
                            Tab(text: 'طريقة الاستخدام'),
                            Tab(text: 'معلومات'),
                          ],
                        ),
                        Container(
                          height: 200,
                          padding: const EdgeInsets.all(20),
                          child: TabBarView(
                            children: [
                              _buildIngredientsTab(),
                              _buildUsageTab(),
                              _buildInfoTab(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // تبويب المكونات
  Widget _buildIngredientsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المكونات الفعالة:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _primaryPurple,
            ),
          ),
          const SizedBox(height: 12),
          _buildIngredientItem('فيتامين E', 'مضاد للأكسدة وترطيب عميق'),
          _buildIngredientItem('زبدة الشيا', 'تغذية وحماية البشرة'),
          _buildIngredientItem('حمض الهيالورونيك', 'ترطيب مكثف'),
          _buildIngredientItem('خلاصة الصبار', 'تهدئة وتلطيف'),
        ],
      ),
    );
  }

  // عنصر المكون
  Widget _buildIngredientItem(String name, String benefit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, left: 8),
            decoration: BoxDecoration(
              color: _primaryPurple,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontFamily: 'Almarai',
                ),
                children: [
                  TextSpan(
                    text: '$name: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  TextSpan(text: benefit),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // تبويب طريقة الاستخدام
  Widget _buildUsageTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'طريقة الاستخدام:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _primaryPurple,
            ),
          ),
          const SizedBox(height: 12),
          _buildUsageStep('1', 'نظفي البشرة جيداً بالماء الفاتر'),
          _buildUsageStep('2', 'ضعي كمية صغيرة من المنتج على راحة اليد'),
          _buildUsageStep('3', 'وزعي المنتج بلطف على الوجه والرقبة'),
          _buildUsageStep('4', 'دلكي بحركات دائرية لطيفة'),
          _buildUsageStep('5', 'اتركي المنتج ليتشرب في البشرة'),
        ],
      ),
    );
  }

  // خطوة الاستخدام
  Widget _buildUsageStep(String number, String step) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              gradient: _purpleGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              step,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // تبويب المعلومات
  Widget _buildInfoTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildInfoRow('الماركة', widget.product.brand),
          _buildInfoRow('الفئة', widget.product.category),
          _buildInfoRow('بلد المنشأ', 'فرنسا'),
          _buildInfoRow('الحجم', '50 مل'),
          _buildInfoRow('تاريخ الانتهاء', '12/2026'),
          _buildInfoRow('رقم التشغيلة', 'LOT2024001'),
        ],
      ),
    );
  }

  // صف المعلومات
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // قسم المنتجات المشابهة
  Widget _buildRelatedProductsSection() {
    if (_relatedProducts.isEmpty) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 0.1),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // عنوان القسم
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: _purpleGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.recommend_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'منتجات مشابهة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            fontFamily: 'Almarai',
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _withAlpha(_accentPurple, 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _withAlpha(_primaryPurple, 0.2),
                          ),
                        ),
                        child: Text(
                          'عرض الكل',
                          style: TextStyle(
                            color: _primaryPurple,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // قائمة المنتجات المشابهة
                SizedBox(
                  height: 280,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _relatedProducts.length,
                    itemBuilder: (context, index) {
                      final product = _relatedProducts[index];
                      return Container(
                        width: 160,
                        margin: const EdgeInsets.only(left: 12),
                        child: _buildRelatedProductCard(product),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // كارت المنتج المشابه
  Widget _buildRelatedProductCard(Product product) {
    final bool isFavorite = widget.favoriteItems.any((e) => e.id == product.id);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => Navigator.push(
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
          ),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة المنتج
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Image.asset(
                        product.imagePath,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade100,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey.shade400,
                            size: 40,
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
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite
                                ? Colors.red
                                : Colors.grey.shade600,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // الماركة
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _withAlpha(_accentPurple, 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.brand,
                          style: TextStyle(
                            color: _primaryPurple,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // العنوان
                      Text(
                        product.title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const Spacer(),

                      // السعر وزر الإضافة
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${product.price.toStringAsFixed(0)} د.ع',
                              style: TextStyle(
                                color: _primaryPurple,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => widget.addToCart(product),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                gradient: _purpleGradient,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: _primaryPurple.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.add_shopping_cart,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // الشريط السفلي للإجراءات
  Widget _buildBottomActionBar() {
    return Container(
      padding: EdgeInsets.only(
        top: 16,
        bottom: 16 + MediaQuery.of(context).padding.bottom,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // زر المفضلة
            AnimatedBuilder(
              animation: _buttonAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.9 + (_buttonAnimation.value * 0.1),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _isFavorite
                          ? Colors.red.withValues(alpha: 0.1)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isFavorite
                            ? Colors.red.withValues(alpha: 0.3)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: _toggleFavoriteWithAnimation,
                        borderRadius: BorderRadius.circular(16),
                        child: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite
                              ? Colors.red
                              : Colors.grey.shade600,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(width: 16),

            // زر الإضافة للسلة
            Expanded(
              child: AnimatedBuilder(
                animation: _buttonAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.95 + (_buttonAnimation.value * 0.05),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: _isInCart
                            ? const LinearGradient(
                                colors: [Colors.green, Colors.greenAccent],
                              )
                            : _purpleGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (_isInCart ? Colors.green : _primaryPurple)
                                .withValues(alpha: 0.3),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: _isLoading ? null : _addToCartWithValidation,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isLoading)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                else ...[
                                  Icon(
                                    _isInCart
                                        ? Icons.check
                                        : Icons.add_shopping_cart,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _isInCart ? 'في السلة' : 'أضيفي إلى السلة',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Almarai',
                                    ),
                                  ),
                                  if (_quantity > 1) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '×$_quantity',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
