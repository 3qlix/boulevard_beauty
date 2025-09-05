import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel_slider;

// استيراد النماذج والخدمات والشاشات
import '../models/product.dart';
import '../services/auth_service.dart';
import '../models/app_user.dart';
import 'categories_screen.dart';
import 'products_screen.dart';
import 'cart_screen.dart';
import 'login_screen.dart';
import 'pharma_consult_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';
import 'product_detail_screen.dart';
import 'favorites_screen.dart';
import 'brands_screen.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // متحكمات النصوص والتمرير
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // متحكم الرسوم المتحركة للانتقالات السلسة
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // حالة التطبيق
  final List<Product> _cartItems = [];
  final List<Product> _favoriteItems = [];
  bool _isLoggedIn = false;
  AppUser? _currentUser;
  bool _isLoading = true;
  int _currentIndex = 4;
  bool _showAppBarSearchIcon = false;

  // الألوان والثيمات
  static const Color _primaryPurple = Color(0xFF6B166F);
  static const Color _lightPurple = Color(0xFF9C4A9F);
  static const Color _accentPurple = Color(0xFFE1BEE7);

  // تدرج الألوان البنفسجية الراقية
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

  // المنتجات المميزة (تم تحسين البيانات)
  final List<Product> _featuredProductsList = [
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

  // صور البانرات المنظمة حسب الأقسام
  final Map<String, List<String>> _bannerSections = {
    'main': ['assets/images/banner1.png', 'assets/images/banner2.png'],
    'right': [
      'assets/images/banner3.png',
      'assets/images/banner4.png',
      'assets/images/banner5.png',
      'assets/images/banner6.png',
    ],
    'left': [
      'assets/images/banner7.png',
      'assets/images/banner8.png',
      'assets/images/banner9.png',
      'assets/images/banner10.png',
    ],
  };

  // الماركات
  final List<Map<String, String>> _brands = [
    {'name': 'SVR', 'image': 'assets/images/brand_a.png'},
    {'name': 'Cosmo', 'image': 'assets/images/brand_b.png'},
    {'name': 'Nacomi', 'image': 'assets/images/brand_c.png'},
    {'name': 'Dermacol', 'image': 'assets/images/brand_d.png'},
  ];

  // فئات المشاكل
  final List<Map<String, dynamic>> _problemCategories = [
    {
      'name': 'مشاكل البشرة',
      'image': 'assets/images/skin_problems.png', // ضع صورتك هنا
    },
    {
      'name': 'مشاكل الجسم',
      'image': 'assets/images/body_problems.png', // ضع صورتك هنا
    },
    {
      'name': 'مشاكل الشعر',
      'image': 'assets/images/hair_problems.png', // ضع صورتك هنا
    },
    {
      'name': 'مشاكل أخرى',
      'image': 'assets/images/other_problems.png', // ضع صورتك هنا
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _setupAnimations();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // تهيئة التطبيق
  void _initializeApp() {
    _bootstrap();
  }

  // إعداد الرسوم المتحركة
  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  // إعداد مستمع التمرير
  void _setupScrollListener() {
    _scrollController.addListener(() {
      final bool newShowAppBarSearchIcon = _scrollController.offset >= 80.0;
      if (newShowAppBarSearchIcon != _showAppBarSearchIcon) {
        setState(() {
          _showAppBarSearchIcon = newShowAppBarSearchIcon;
        });
      }
    });
  }

  // تحميل البيانات الأساسية
  Future<void> _bootstrap({bool showLoading = true}) async {
    try {
      // عرض مؤشر التحميل فقط إذا طُلب ذلك
      if (showLoading && mounted) {
        setState(() => _isLoading = true);
      }

      await Future.wait([
        _loadCartFromPrefs(),
        _loadFavoritesFromPrefs(),
        _checkLoginStatus(),
      ]);
    } catch (e) {
      debugPrint('خطأ في تحميل البيانات: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _silentRefresh() async {
    // تحديث صامت بدون إظهار أي مؤشرات تحميل
    await _bootstrap(showLoading: false);

    // يمكنك إضافة تحديثات إضافية هنا مثل:
    // - جلب منتجات جديدة
    // - تحديث العروض
    // - تحديث الأسعار

    if (mounted) {
      // إعادة بناء الواجهة بسلاسة
      setState(() {
        // فقط لإعادة البناء
      });
    }
  }

  // تحميل السلة من التفضيلات المحفوظة
  Future<void> _loadCartFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getStringList('cart') ?? [];

      _cartItems.clear();
      for (final item in cartData) {
        try {
          final product = Product.fromJson(jsonDecode(item));
          _cartItems.add(product);
        } catch (e) {
          debugPrint('خطأ في تحليل منتج السلة: $e');
        }
      }
    } catch (e) {
      debugPrint('خطأ في تحميل السلة: $e');
    }
  }

  // حفظ السلة في التفضيلات
  Future<void> _saveCartToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = _cartItems
          .map((product) => jsonEncode(product.toJson()))
          .toList();
      await prefs.setStringList('cart', cartData);
    } catch (e) {
      debugPrint('خطأ في حفظ السلة: $e');
    }
  }

  // تحميل المفضلة من التفضيلات المحفوظة
  Future<void> _loadFavoritesFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesData = prefs.getStringList('favorites') ?? [];

      _favoriteItems.clear();
      for (final item in favoritesData) {
        try {
          final product = Product.fromJson(jsonDecode(item));
          _favoriteItems.add(product);
        } catch (e) {
          debugPrint('خطأ في تحليل منتج المفضلة: $e');
        }
      }
    } catch (e) {
      debugPrint('خطأ في تحميل المفضلة: $e');
    }
  }

  // حفظ المفضلة في التفضيلات
  Future<void> _saveFavoritesToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesData = _favoriteItems
          .map((product) => jsonEncode(product.toJson()))
          .toList();
      await prefs.setStringList('favorites', favoritesData);
    } catch (e) {
      debugPrint('خطأ في حفظ المفضلة: $e');
    }
  }

  // فحص حالة تسجيل الدخول
  Future<void> _checkLoginStatus() async {
    try {
      _isLoggedIn = await AuthService.isLoggedIn();
      if (_isLoggedIn) {
        _currentUser = await AuthService.getCurrentUser();
      } else {
        _currentUser = null;
      }
    } catch (e) {
      debugPrint('خطأ في فحص حالة تسجيل الدخول: $e');
      _isLoggedIn = false;
      _currentUser = null;
    }
  }

  // إضافة منتج إلى السلة مع التحقق المحسن
  Future<void> _addToCart(Product product) async {
    // التحقق من تسجيل الدخول أولاً
    if (!_isLoggedIn) {
      _showLoginRequiredDialog(
        'للإضافة إلى السلة',
        'يجب تسجيل الدخول أولاً لإضافة المنتجات للسلة 🌸',
      );
      return;
    }

    // إضافة المنتج للسلة (بدون التحقق من الوجود المسبق)
    setState(() {
      _cartItems.add(product);
    });

    // حفظ السلة
    await _saveCartToPrefs();

    // حساب عدد هذا المنتج في السلة
    final productCount = _cartItems
        .where((item) => item.id == product.id)
        .length;

    // عرض رسالة النجاح مع العدد
    if (productCount > 1) {
      _showSnackBar('✅ «${product.title}» (${productCount}x) في السلة');
    } else {
      _showSnackBar('✅ تمت إضافة «${product.title}» إلى السلة');
    }

    // 🟢 التحديث الفوري للشريط السفلي
    _instantRefresh();

    // إضافة تأثير اهتزاز خفيف للتأكيد (اختياري)
    HapticFeedback.lightImpact();
  }

  // تبديل حالة المفضلة
  Future<void> _toggleFavoriteStatus(Product product) async {
    // التحقق من تسجيل الدخول أولاً
    if (!_isLoggedIn) {
      _showLoginRequiredDialog(
        'لإضافة للمفضلة',
        'يجب تسجيل الدخول أولاً لإضافة المنتجات للمفضلة 🌸',
      );
      return;
    }

    // التحقق من حالة المفضلة الحالية
    final isCurrentlyFavorite = _favoriteItems.any(
      (item) => item.id == product.id,
    );

    // تبديل الحالة
    setState(() {
      if (isCurrentlyFavorite) {
        _favoriteItems.removeWhere((item) => item.id == product.id);
      } else {
        _favoriteItems.add(product);
      }
    });

    // حفظ المفضلة
    await _saveFavoritesToPrefs();

    // عرض الرسالة المناسبة
    final message = isCurrentlyFavorite
        ? 'تمت إزالة «${product.title}» من المفضلة'
        : 'تمت إضافة «${product.title}» إلى المفضلة ❤️';

    _showSnackBar(message);

    // 🟢 التحديث الفوري للشريط السفلي والواجهة
    _instantRefresh();
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
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );

                if (result == true) {
                  // إعادة تحميل البيانات بعد تسجيل الدخول
                  await _checkLoginStatus();
                  await _loadCartFromPrefs();
                  await _loadFavoritesFromPrefs();

                  if (mounted) {
                    setState(() {});
                    // 🟢 التحديث الفوري بعد تسجيل الدخول
                    _instantRefresh();
                  }
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

  // فتح وسائل التواصل الاجتماعي
  Future<void> _launchSocialMedia(String url) async {
    try {
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        _showSnackBar('تعذّر فتح الرابط', isError: true);
      }
    } catch (e) {
      _showSnackBar('تعذّر فتح الرابط', isError: true);
    }
  }

  // الواجهة الرئيسية للتطبيق
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    return Theme(
      data: _buildAppTheme(),
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: _currentIndex == 4
            ? null
            : _buildMainAppBar(), // ← السطر الجديد
        body: IndexedStack(index: _currentIndex, children: _buildScreens()),
        endDrawer: _buildModernDrawer(),
        bottomNavigationBar: _buildModernBottomNavBar(),
      ),
    );
  }

  // دالة جديدة للشريط العلوي الموحد
  PreferredSizeWidget _buildMainAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: _primaryPurple,
      elevation: 0.5,
      centerTitle: true,
      automaticallyImplyLeading: false,

      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          gradient: _purpleGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _primaryPurple.withOpacity(0.2),
              spreadRadius: 0,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: const Text(
          'Boulevard',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'GreatVibes',
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // ✅ صحيح: القائمة في actions (ستظهر على اليسار في RTL)
      actions: [
        Builder(
          builder: (BuildContext innerContext) {
            return Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _accentPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.menu_rounded,
                  color: _primaryPurple,
                  size: 20,
                ),
                onPressed: () => Scaffold.of(innerContext).openEndDrawer(),
                tooltip: 'القائمة',
              ),
            );
          },
        ),
      ],

      // ✅ صحيح: البحث والواتساب في leading (سيظهران على اليمين في RTL)
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// زر الواتساب (أولاً)
          Container(
            decoration: BoxDecoration(
              color: _accentPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: Image.asset(
                'assets/images/whatsapp_icon.png',
                height: 20,
                width: 20,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              onPressed: _launchWhatsApp,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              padding: EdgeInsets.zero,
            ),
          ),

          const SizedBox(width: 4),

          /// زر البحث (ثانياً)
          Container(
            decoration: BoxDecoration(
              color: _accentPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.search, color: _primaryPurple, size: 20),
              onPressed: _openSearchScreen,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
      leadingWidth: 100, // إعطاء مساحة كافية للزرين
    );
  }

  // شاشة التحميل المحسنة
  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: _purpleGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _primaryPurple.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Boulevard',
              style: TextStyle(
                fontSize: 28,
                fontFamily: 'GreatVibes',
                color: _primaryPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_primaryPurple),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'جاري التحميل...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // تطبيق الثيم المحسن
  ThemeData _buildAppTheme() {
    return ThemeData(
      primarySwatch: Colors.purple,
      primaryColor: _primaryPurple,
      fontFamily: 'Almarai',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: _primaryPurple,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: _primaryPurple,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryPurple,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      cardTheme: CardThemeData(
        // تم تغيير CardTheme إلى CardThemeData
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),
    );
  }

  // بناء الشاشات
  List<Widget> _buildScreens() {
    return [
      ProfileScreen(
        isLoggedIn: _isLoggedIn,
        cartItems: _cartItems,
        addToCart: _addToCart,
        favoriteItems: _favoriteItems,
        toggleFavorite: _toggleFavoriteStatus,
      ),
      CartScreen(
        cartItems: _cartItems,
        isLoggedIn: _isLoggedIn,
        favoriteItems: _favoriteItems,
        toggleFavorite: _toggleFavoriteStatus,
        addToCart: _addToCart,
      ),
      CategoriesScreen(
        cartItems: _cartItems,
        addToCart: _addToCart,
        favoriteItems: _favoriteItems,
        toggleFavorite: _toggleFavoriteStatus,
      ),
      ProductsScreen(
        categoryTitle: '',
        cartItems: _cartItems,
        addToCart: _addToCart,
        favoriteItems: _favoriteItems,
        toggleFavorite: _toggleFavoriteStatus,
      ),
      _buildHomePage(),
    ];
  }

  // شريط التنقل السفلي المحسن
  Widget _buildModernBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCustomNavItem(
                icon: _buildUserIcon(),
                label: 'حسابي',
                isSelected: _currentIndex == 0,
                onTap: () {
                  if (_currentIndex != 0) {
                    _handleBottomNavTap(0);
                  }
                },
              ),

              _buildCustomNavItem(
                icon: _buildCartIcon(),
                label: 'السلة',
                badge: _cartItems.length,
                isSelected: _currentIndex == 1,
                onTap: () {
                  if (_currentIndex != 1) {
                    _handleBottomNavTap(1);
                  }
                },
              ),

              _buildCustomNavItem(
                icon: _buildCategoriesIcon(),
                label: 'الأقسام',
                isSelected: _currentIndex == 2,
                onTap: () {
                  if (_currentIndex != 2) {
                    _handleBottomNavTap(2);
                  }
                },
              ),

              _buildCustomNavItem(
                icon: _buildProductsIcon(),
                label: 'المنتجات',
                isSelected: _currentIndex == 3,
                onTap: () {
                  if (_currentIndex != 3) {
                    _handleBottomNavTap(3);
                  }
                },
              ),

              _buildCustomNavItem(
                icon: _buildHomeIcon(),
                label: 'الرئيسية',
                isSelected: _currentIndex == 4,
                onTap: () {
                  if (_currentIndex != 4) {
                    _handleBottomNavTap(4);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // بناء عنصر شريط التنقل
  Widget _buildCustomNavItem({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
    int badge = 0,
    bool isSelected = false,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // تغيير لون الأيقونة حسب التحديد
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    isSelected ? _primaryPurple : Colors.grey.shade700,
                    BlendMode.srcIn,
                  ),
                  child: icon,
                ),
                if (badge > 0)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _primaryPurple, // اللون البنفسجي السائد
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        badge.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? _primaryPurple : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // أيقونة حسابي
  Widget _buildUserIcon() {
    return CustomPaint(size: const Size(24, 24), painter: UserIconPainter());
  }

  // أيقونة السلة
  Widget _buildCartIcon() {
    return CustomPaint(size: const Size(24, 24), painter: CartIconPainter());
  }

  // أيقونة الأقسام
  Widget _buildCategoriesIcon() {
    return CustomPaint(
      size: const Size(24, 24),
      painter: CategoriesIconPainter(),
    );
  }

  // أيقونة المنتجات
  Widget _buildProductsIcon() {
    return CustomPaint(
      size: const Size(24, 24),
      painter: ShoppingBagIconPainter(),
    );
  }

  // أيقونة الرئيسية
  Widget _buildHomeIcon() {
    return CustomPaint(size: const Size(24, 24), painter: HomeIconPainter());
  }

  // التعامل مع نقرات شريط التنقل
  Future<void> _handleBottomNavTap(int index) async {
    // فحص تسجيل الدخول للملف الشخصي
    if (index == 0) {
      final bool loggedIn = await AuthService.isLoggedIn();
      if (!loggedIn) {
        _showLoginRequiredDialog(
          'الملف الشخصي',
          'يجب تسجيل الدخول لعرض الحساب 🌸',
        );
        return;
      }
    }

    // تحديث الفهرس الحالي
    setState(() => _currentIndex = index);

    // 🟢 التحديث التلقائي الصامت والفوري عند التنقل
    _instantRefresh();
  }

  // أضف هذه الدالة الجديدة للتحديث الفوري:
  void _instantRefresh() {
    if (mounted) {
      setState(() {
        // التحديث يحدث فوراً وبصمت
        // يمكن إضافة أي تحديثات هنا مثل:
        // - تحديث عدد المنتجات في السلة
        // - تحديث المفضلة
        // - تحديث حالة تسجيل الدخول
      });
    }
  }

  // بناء الـ Drawer المحسن
  Widget _buildModernDrawer() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            _buildDrawerHeader(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerSection('الخدمات', [
                    _buildDrawerItem(
                      'الاستشارة المجانية',
                      Icons.medical_services_outlined,
                      () => _navigateToConsultation(),
                      hasNotification: true,
                    ),
                  ]),

                  _buildDrawerSection('التسوق', [
                    _buildExpandableDrawerItem(
                      'تسوقي حسب المشكلة',
                      Icons.category_outlined,
                      [
                        {
                          'title': 'مشاكل البشرة',
                          'onTap': () => _showComingSoon('مشاكل البشرة'),
                        },
                        {
                          'title': 'مشاكل الجسم',
                          'onTap': () => _showComingSoon('مشاكل الجسم'),
                        },
                        {
                          'title': 'مشاكل الشعر',
                          'onTap': () => _showComingSoon('مشاكل الشعر'),
                        },
                        {
                          'title': 'مشاكل أخرى',
                          'onTap': () => _showComingSoon('مشاكل أخرى'),
                        },
                      ],
                    ),

                    _buildDrawerItem(
                      'تسوقي حسب الماركة',
                      Icons.branding_watermark_outlined,
                      () {
                        Navigator.pop(context);
                        _navigateToBrandsScreen();
                      },
                    ),
                  ]),

                  _buildDrawerSection('المحتوى', [
                    _buildDrawerItem(
                      'دليل الروتينات',
                      Icons.book_outlined,
                      () => _showComingSoon('دليل الروتينات'),
                      isNew: true,
                    ),
                    _buildDrawerItem(
                      'العروض',
                      Icons.local_offer_outlined,
                      () => _showComingSoon('العروض'),
                      hasNotification: true,
                    ),
                    _buildDrawerItem(
                      'المقالات',
                      Icons.article_outlined,
                      () => _showComingSoon('المقالات'),
                    ),
                  ]),

                  _buildDrawerSection('الحساب', [
                    _buildDrawerItem(
                      'المفضلة',
                      Icons.favorite_outline,
                      () => _navigateToFavorites(),
                      badge: _favoriteItems.isNotEmpty
                          ? _favoriteItems.length.toString()
                          : null,
                    ),
                    _buildDrawerItem(
                      'الإشعارات',
                      Icons.notifications_outlined,
                      () => _showComingSoon('الإشعارات'),
                    ),
                  ]),

                  _buildDrawerSection('المساعدة', [
                    _buildDrawerItem(
                      'سياسة التبديل',
                      Icons.cached_outlined,
                      () => _showComingSoon('سياسة التبديل'),
                    ),
                    _buildDrawerItem(
                      'ضمان المنتجات',
                      Icons.security_outlined,
                      () => _showComingSoon('ضمان المنتجات'),
                    ),
                    _buildDrawerItem(
                      'من نحن!',
                      Icons.info_outline,
                      () => _showComingSoon('من نحن!'),
                    ),
                  ]),
                ],
              ),
            ),
            _buildDrawerFooter(),
          ],
        ),
      ),
    );
  }

  // رأس الـ Drawer المحسن
  Widget _buildDrawerHeader() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        gradient: _purpleGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GestureDetector(
            onTap: _handleDrawerHeaderTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildUserAvatar(),
                    const SizedBox(width: 12),
                    Expanded(child: _buildUserInfo()),
                  ],
                ),
                const Spacer(),
                if (!_isLoggedIn) _buildLoginPrompt(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // صورة المستخدم
  Widget _buildUserAvatar() {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child:
            _isLoggedIn &&
                _currentUser?.imagePath != null &&
                _currentUser!.imagePath!.isNotEmpty
            ? Image.file(
                File(_currentUser!.imagePath!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildDefaultAvatar(),
              )
            : _buildDefaultAvatar(),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: Icon(
        _isLoggedIn ? Icons.person : Icons.person_outline,
        color: _primaryPurple,
        size: 28,
      ),
    );
  }

  // معلومات المستخدم
  Widget _buildUserInfo() {
    if (_isLoggedIn && _currentUser != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _currentUser!.name,
            style: const TextStyle(
              fontSize: 17, // ← كان 20
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3), // ← كان 4
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ), // ← كان 8, 2
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10), // ← كان 12
            ),
            child: Text(
              '+964 ${_currentUser!.phone}',
              style: const TextStyle(
                fontSize: 12, // ← كان 14
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    } else {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'نورتينا ',
            style: TextStyle(
              fontSize: 17, // ← كان 20
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 3), // ← كان 4
          Text(
            'انضمي إلى عائلة بوليڤارد',
            style: TextStyle(fontSize: 12, color: Colors.white70), // ← كان 14
          ),
        ],
      );
    }
  }

  // دعوة تسجيل الدخول
  Widget _buildLoginPrompt() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: const Text(
        'سجلي ويانة هسة',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // التعامل مع نقرة رأس الـ Drawer
  void _handleDrawerHeaderTap() {
    Navigator.pop(context);
    if (_isLoggedIn && _currentUser != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProfileScreen(
            isLoggedIn: true,
            cartItems: _cartItems,
            addToCart: _addToCart,
            favoriteItems: _favoriteItems,
            toggleFavorite: _toggleFavoriteStatus,
          ),
        ),
      ).then((_) {
        // 🟢 التحديث التلقائي بعد العودة
        _silentRefresh();
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      ).then((_) async {
        await _checkLoginStatus();
        if (mounted) {
          setState(() {});
          // 🟢 التحديث التلقائي بعد تسجيل الدخول
          _silentRefresh();
        }
      });
    }
  }

  // بناء قسم في الـ Drawer
  Widget _buildDrawerSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            6,
          ), // ← كان 20, 16, 20, 8
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12, // ← كان 14
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...items,
        const SizedBox(height: 6), // ← كان 8
      ],
    );
  }

  // بناء عنصر في الـ Drawer
  Widget _buildDrawerItem(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool hasNotification = false,
    bool isNew = false,
    String? badge,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 1,
      ), // ← كان 12, 2
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ), // ← كان 12
      child: ListTile(
        dense: true, // ← إضافة dense لتقليل الارتفاع
        leading: Container(
          padding: const EdgeInsets.all(6), // ← كان 8
          decoration: BoxDecoration(
            color: _accentPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8), // ← كان 10
          ),
          child: Icon(icon, color: _primaryPurple, size: 18), // ← كان 20
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13, // ← كان 15
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            if (hasNotification)
              Container(
                width: 6, // ← كان 8
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(3), // ← كان 4
                ),
              ),
            if (isNew)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 1,
                ), // ← كان 6, 2
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(6), // ← كان 8
                ),
                child: const Text(
                  'جديد',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9, // ← كان 10
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 1,
                ), // ← كان 6, 2
                decoration: BoxDecoration(
                  color: _primaryPurple,
                  borderRadius: BorderRadius.circular(8), // ← كان 10
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10, // ← كان 11
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 12, // ← كان 14
          color: Colors.grey.shade400,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ), // ← كان 12
        hoverColor: _accentPurple.withOpacity(0.05),
      ),
    );
  }

  // بناء عنصر قابل للتوسيع في الـ Drawer
  Widget _buildExpandableDrawerItem(
    String title,
    IconData icon,
    List<Map<String, dynamic>> subItems,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 1,
      ), // ← كان 12, 2
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ), // ← كان 12
      child: ExpansionTile(
        dense: true, // ← إضافة dense
        leading: Container(
          padding: const EdgeInsets.all(6), // ← كان 8
          decoration: BoxDecoration(
            color: _accentPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8), // ← كان 10
          ),
          child: Icon(icon, color: _primaryPurple, size: 18), // ← كان 20
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 13, // ← كان 15
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        tilePadding: const EdgeInsets.symmetric(horizontal: 14), // ← كان 16
        childrenPadding: const EdgeInsets.only(
          right: 35,
          bottom: 6,
        ), // ← كان 40, 8
        iconColor: _primaryPurple,
        collapsedIconColor: Colors.grey.shade400,
        children: subItems.map((item) {
          return ListTile(
            dense: true, // ← إضافة dense
            title: Text(
              item['title'],
              style: TextStyle(
                fontSize: 12, // ← كان 14
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w400,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              item['onTap']();
            },
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 10, // ← كان 12
              color: Colors.grey.shade400,
            ),
          );
        }).toList(),
      ),
    );
  }

  // ذيل الـ Drawer
  Widget _buildDrawerFooter() {
    return Container(
      padding: const EdgeInsets.all(16), // ← كان 20
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialButton(
                'assets/images/instagram_icon.png',
                'انستجرام',
                () => _launchSocialMedia(
                  'https://www.instagram.com/blv.iq?igsh=MzNlNGNkZWQ4Mg==',
                ),
              ),
              const SizedBox(width: 16), // ← كان 20
              _buildSocialButton(
                'assets/images/tiktok_icon.png',
                'تيك توك',
                () => _launchSocialMedia(
                  'https://www.tiktok.com/@blv.iq?_t=ZS-8yA4LCvJGXV&_r=1',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10), // ← كان 12
          Text(
            'Boulevard v1.0.0',
            style: TextStyle(
              fontSize: 11, // ← كان 12
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // زر وسائل التواصل الاجتماعي
  Widget _buildSocialButton(
    String imagePath,
    String tooltip,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10), // ← كان 12
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), // ← كان 0.05
            spreadRadius: 0, // ← كان 1
            blurRadius: 3, // ← كان 4
            offset: const Offset(0, 1), // ← كان 0, 2
          ),
        ],
      ),
      child: IconButton(
        icon: Image.asset(
          imagePath,
          height: 24, // ← كان 28
          width: 24,
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.link, color: _primaryPurple, size: 24), // ← كان 28
        ),
        onPressed: onPressed,
        tooltip: tooltip,
        padding: const EdgeInsets.all(6), // ← كان 8
      ),
    );
  }

  // دوال التنقل
  void _navigateToConsultation() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PharmaConsultScreen()),
    ).then((_) {
      // 🟢 التحديث التلقائي بعد العودة
      _silentRefresh();
    });
  }

  void _navigateToFavorites() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FavoritesScreen(
          favoriteProducts: _favoriteItems,
          cartItems: _cartItems,
          addToCart: _addToCart,
          toggleFavorite: _toggleFavoriteStatus,
        ),
      ),
    ).then((_) {
      // 🟢 التحديث التلقائي بعد العودة من المفضلة
      _silentRefresh();
    });
  }

  void _showComingSoon(String feature) {
    Navigator.pop(context);
    _showSnackBar('شاشة $feature قيد الإنشاء');
  }

  // التنقل إلى شاشة الماركات
  void _navigateToBrandsScreen({String? selectedBrand}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BrandsScreen(
          cartItems: _cartItems,
          addToCart: _addToCart,
          favoriteItems: _favoriteItems,
          toggleFavorite: _toggleFavoriteStatus,
          initialSelectedBrand: selectedBrand, // ← تمرير الماركة المختارة
        ),
      ),
    ).then((_) {
      // التحديث التلقائي بعد العودة
      _silentRefresh();
    });
  }

  // بناء الصفحة الرئيسية المحسنة
  Widget _buildHomePage() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // إضافة SliverAppBar فقط للصفحة الرئيسية
          if (_currentIndex == 4) _buildModernAppBar(),
          _buildSearchBar(),
          SliverList(
            delegate: SliverChildListDelegate([
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    const SizedBox(height: 12), // ← كان 20
                    _buildCategoriesSection(),
                    const SizedBox(height: 20), // ← كان 32
                    _buildMainBanner(),
                    const SizedBox(height: 16), // ← كان 24
                    _buildSecondaryBanners(),
                    const SizedBox(height: 20), // ← كان 32
                    _buildBrandsSection(),
                    const SizedBox(height: 16), // ← كان 24
                    _buildMiddleBanner(),
                    const SizedBox(height: 20), // ← كان 32
                    _buildProblemCategoriesSection(),
                    const SizedBox(height: 20), // ← كان 32
                    _buildFeaturedProductsSection(),
                    const SizedBox(height: 20), // ← كان 32
                    _buildNewArrivalsSection(),
                    const SizedBox(height: 20), // ← كان 32
                    _buildHandPickedSection(),
                    const SizedBox(height: 20), // ← كان 32
                    _buildBackInStockSection(),
                    const SizedBox(height: 24), // ← كان 40
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  // شريط التطبيق المحسن
  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: 80.0, // ← كان 120 أصبح 80
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      foregroundColor: _primaryPurple,
      elevation: 0.0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ), // ← كان 16, 8
          decoration: BoxDecoration(
            gradient: _purpleGradient,
            borderRadius: BorderRadius.circular(16), // ← كان 20
            boxShadow: [
              BoxShadow(
                color: _primaryPurple.withOpacity(0.2), // ← كان 0.3
                spreadRadius: 0,
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: const Text(
            'Boulevard',
            style: TextStyle(
              fontSize: 18, // ← كان 24 أصبح 18
              fontFamily: 'GreatVibes',
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      leading: Builder(
        builder: (BuildContext innerContext) {
          return Container(
            margin: const EdgeInsets.all(6), // ← كان 8
            decoration: BoxDecoration(
              color: _accentPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10), // ← كان 12
            ),
            child: IconButton(
              icon: const Icon(
                Icons.menu_rounded,
                color: _primaryPurple,
                size: 20,
              ), // ← حجم أصغر
              onPressed: () => Scaffold.of(innerContext).openEndDrawer(),
              tooltip: 'القائمة',
            ),
          );
        },
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _accentPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.search,
              color: _primaryPurple,
              size: 20,
            ), // ← حجم أصغر
            onPressed: () => _openSearchScreen(),
            tooltip: 'بحث',
          ),
        ),
        Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _accentPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: Image.asset(
              'assets/images/whatsapp_icon.png',
              height: 20, // ← كان 24
              width: 20,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.chat_bubble_outline,
                color: Colors.green,
                size: 20,
              ),
            ),
            onPressed: _launchWhatsApp,
            tooltip: 'تواصل عبر واتساب',
          ),
        ),
      ],
    );
  }

  // شريط البحث
  Widget _buildSearchBar() {
    return SliverPersistentHeader(
      delegate: _ModernSearchBarDelegate(
        minHeight: 0.0,
        maxHeight: 50.0,
        onSearchSubmitted: _openSearchScreen,
        purpleColor: _primaryPurple,
      ),
      pinned: true,
    );
  }

  // فتح شاشة البحث
  void _openSearchScreen([String? query]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchScreen(
          searchQuery: query ?? '',
          cartItems: _cartItems,
          addToCart: _addToCart,
          favoriteItems: _favoriteItems,
          toggleFavorite: _toggleFavoriteStatus,
        ),
      ),
    ).then((_) {
      // 🟢 التحديث التلقائي بعد العودة من البحث
      _silentRefresh();
    });
  }

  // قسم الأقسام المحسن
  Widget _buildCategoriesSection() {
    return Column(
      children: [
        SizedBox(
          height: 95, // ← كان 120 أصبح 95
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12), // ← كان 16
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return Container(
                width: 75, // ← كان 90 أصبح 75
                margin: const EdgeInsets.only(left: 8), // ← كان 12
                child: GestureDetector(
                  onTap: () => _navigateToCategory(category['name']),
                  child: Column(
                    children: [
                      Container(
                        width: 55, // ← كان 70 أصبح 55
                        height: 55,
                        decoration: BoxDecoration(
                          color: category['color'],
                          borderRadius: BorderRadius.circular(16), // ← كان 20
                          boxShadow: [
                            BoxShadow(
                              color: _primaryPurple.withOpacity(0.08),
                              spreadRadius: 0,
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            category['image'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              category['icon'],
                              color: _primaryPurple,
                              size: 24, // ← كان 30
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6), // ← كان 8
                      Text(
                        category['name'],
                        style: const TextStyle(
                          fontSize: 11, // ← كان 12
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // التنقل إلى قسم معين
  void _navigateToCategory(String categoryName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductsScreen(
          categoryTitle: categoryName,
          cartItems: _cartItems,
          addToCart: _addToCart,
          favoriteItems: _favoriteItems,
          toggleFavorite: _toggleFavoriteStatus,
        ),
      ),
    ).then((_) {
      // 🟢 التحديث التلقائي بعد العودة من شاشة القسم
      _silentRefresh();
    });
  }

  // البانر الرئيسي
  Widget _buildMainBanner() {
    return _buildCarouselBanner(
      images: _bannerSections['main']!,
      aspectRatio: 2.5,
      autoPlay: true,
      showDots: false,
    );
  }

  // البانرات الثانوية
  Widget _buildSecondaryBanners() {
    return Row(
      children: [
        Expanded(
          child: _buildCarouselBanner(
            images: _bannerSections['right']!,
            aspectRatio: 1.2,
            autoPlay: true,
            margin: const EdgeInsets.only(right: 16, left: 8),
          ),
        ),
        Expanded(
          child: _buildCarouselBanner(
            images: _bannerSections['left']!,
            aspectRatio: 1.2,
            autoPlay: true,
            margin: const EdgeInsets.only(left: 16, right: 8),
          ),
        ),
      ],
    );
  }

  // بانر الكاروسيل المحسن
  Widget _buildCarouselBanner({
    required List<String> images,
    double aspectRatio = 2.0,
    bool autoPlay = true,
    bool showDots = false,
    EdgeInsets? margin,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: carousel_slider.CarouselSlider(
              options: carousel_slider.CarouselOptions(
                height: MediaQuery.of(context).size.width / aspectRatio,
                aspectRatio: aspectRatio,
                viewportFraction: 1.0,
                initialPage: 0,
                enableInfiniteScroll: images.length > 1,
                reverse: false,
                autoPlay: autoPlay && images.length > 1,
                autoPlayInterval: const Duration(seconds: 4),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: false,
                scrollDirection: Axis.horizontal,
              ),
              items: images.map((item) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          item,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey.shade200,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey.shade400,
                                      size: 40,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'فشل تحميل الصورة',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // قسم الماركات
  Widget _buildBrandsSection() {
    return Column(
      children: [
        _buildSectionHeader(
          'ماركاتنا', // ← تغيير العنوان
          // حذف icon
          showViewAll: true,
          onViewAllTap: () => _navigateToBrandsScreen(),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _brands.length,
            itemBuilder: (context, index) {
              final brand = _brands[index];
              return Container(
                width: 80,
                margin: const EdgeInsets.only(left: 12),
                child: GestureDetector(
                  onTap: () =>
                      _navigateToBrandsScreen(selectedBrand: brand['name']),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              brand['image']!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.branding_watermark,
                                    color: _primaryPurple,
                                    size: 25,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          brand['name']!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // البانر الأوسط
  Widget _buildMiddleBanner() {
    return GestureDetector(
      onTap: () =>
          _showComingSoon('العروض'), // ← الانتقال لشاشة العروض عند الضغط
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16), // مع التعديل السابع
        height: 120, // مع التعديل السابع
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _primaryPurple.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'assets/images/offers_banner.png', // ← الصورة الثابتة من اختيارك
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) => Container(
              color: _accentPurple.withOpacity(
                0.1,
              ), // ← خلفية بسيطة في حالة الخطأ
              child: Icon(
                Icons.image_not_supported,
                color: _primaryPurple,
                size: 40,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // قسم مشاكل العناية
  Widget _buildProblemCategoriesSection() {
    return Column(
      children: [
        _buildSectionHeader(
          'تسوقي حسب مشكلتج', // ← تغيير العنوان
          // حذف icon
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2, // تعديل النسبة
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _problemCategories.length,
          itemBuilder: (context, index) {
            final problem = _problemCategories[index];
            return GestureDetector(
              onTap: () => _showComingSoon(problem['name']),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // الصورة تملأ المربع
                      Image.asset(
                        problem['image'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: _accentPurple.withOpacity(0.2),
                          child: Icon(
                            Icons.image_not_supported,
                            color: _primaryPurple,
                            size: 40,
                          ),
                        ),
                      ),
                      // خلفية شفافة للنص
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Text(
                            problem['name'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
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
      ],
    );
  }

  // قسم المنتجات المميزة
  Widget _buildFeaturedProductsSection() {
    return Column(
      children: [
        _buildSectionHeader(
          'المنتجات الأكثر مبيعاً',
          showViewAll: true,
          onViewAllTap: () => _showComingSoon('المنتجات الأكثر مبيعاً'),
        ),
        const SizedBox(height: 16),
        _buildProductsList(_featuredProductsList),
      ],
    );
  }

  // قسم الوصول الجديد
  Widget _buildNewArrivalsSection() {
    return Column(
      children: [
        _buildSectionHeader(
          'وصلنا هسة', // ← تغيير العنوان وحذف الرمز
          // حذف icon
          showViewAll: true,
          onViewAllTap: () => _showComingSoon('وصلنا هسة'),
        ),
        const SizedBox(height: 16),
        _buildProductsList(_featuredProductsList),
      ],
    );
  }

  // قسم المختارات بعناية
  Widget _buildHandPickedSection() {
    return Column(
      children: [
        _buildSectionHeader(
          'اختاريناهه الج بعناية',
          showViewAll: true,
          onViewAllTap: () => _showComingSoon('اختاريناهه الج بعناية'),
        ),
        const SizedBox(height: 16),
        _buildProductsList(_featuredProductsList),
      ],
    );
  }

  // قسم العودة للمخزون
  Widget _buildBackInStockSection() {
    return Column(
      children: [
        _buildSectionHeader(
          'رجع توفر',
          showViewAll: true,
          onViewAllTap: () => _showComingSoon('رجع توفر'),
        ),
        const SizedBox(height: 16),
        _buildProductsList(_featuredProductsList),
      ],
    );
  }

  // رأس القسم المحسن
  Widget _buildSectionHeader(
    String title, {
    IconData? icon,
    bool showViewAll = false,
    VoidCallback? onViewAllTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0), // ← كان 20
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(6), // ← كان 8
              decoration: BoxDecoration(
                gradient: _purpleGradient,
                borderRadius: BorderRadius.circular(8), // ← كان 10
              ),
              child: Icon(icon, color: Colors.white, size: 14), // ← كان 18
            ),
            const SizedBox(width: 8), // ← كان 12
          ],
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15, // ← كان 18
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontFamily: 'Almarai',
              ),
            ),
          ),
          if (showViewAll)
            GestureDetector(
              onTap: onViewAllTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10, // ← كان 12
                  vertical: 4, // ← كان 6
                ),
                decoration: BoxDecoration(
                  color: _accentPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16), // ← كان 20
                  border: Border.all(color: _primaryPurple.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'عرض الكل',
                      style: TextStyle(
                        color: _primaryPurple,
                        fontSize: 12, // ← كان 14
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: _primaryPurple,
                      size: 10, // ← كان 12
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // قائمة المنتجات المحسنة
  Widget _buildProductsList(List<Product> products) {
    return SizedBox(
      height: 320,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];

          return Container(
            width: 160,
            margin: const EdgeInsets.only(left: 12),
            child: GestureDetector(
              onTap: () => _navigateToProductDetail(product),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // صورة المنتج بخلفية بيضاء
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 0.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          spreadRadius: 0,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Image.asset(
                            product.imagePath,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.image_not_supported,
                              color: Colors.grey.shade400,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // معلومات المنتج - باستخدام Expanded للتوزيع المتساوي
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // اسم المنتج - ارتفاع ثابت
                          SizedBox(
                            height: 32, // ← ارتفاع ثابت لسطرين
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

                          // زر إضافة للسلة - مثبت في الأسفل مع تأثير الضغط
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _addToCart(product),
                              borderRadius: BorderRadius.circular(16),
                              splashColor: Colors.white.withOpacity(0.3),
                              highlightColor: Colors.white.withOpacity(0.1),
                              child: Ink(
                                width: 110,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
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
        },
      ),
    );
  }

  // التنقل إلى تفاصيل المنتج
  void _navigateToProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          product: product,
          cartItems: _cartItems,
          addToCart: _addToCart,
          favoriteItems: _favoriteItems,
          toggleFavorite: _toggleFavoriteStatus,
        ),
      ),
    ).then((_) {
      // 🟢 التحديث التلقائي بعد العودة من تفاصيل المنتج
      _silentRefresh();
    });
  }
}

// فئة مخصصة لشريط البحث
class _ModernSearchBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final VoidCallback
  onSearchSubmitted; // ← تغيير من دالة تأخذ String إلى VoidCallback
  final Color purpleColor;

  _ModernSearchBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.onSearchSubmitted,
    required this.purpleColor,
  });

  @override
  double get minExtent => 0;

  @override
  double get maxExtent => 50.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final opacity = 1.0 - (shrinkOffset / maxHeight).clamp(0.0, 1.0);

    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Opacity(
        opacity: opacity,
        child: GestureDetector(
          // ← تغليف كامل الشريط بـ GestureDetector
          onTap: onSearchSubmitted, // ← استدعاء الدالة عند الضغط
          child: Container(
            height: 38,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: purpleColor.withOpacity(
                  0.3,
                ), // ← تغيير من Colors.grey.shade200 إلى البنفسجي
                width: 1.5,
              ), // ← زيادة العرض قليلاً من 1 إلى 1.5),
              boxShadow: [
                BoxShadow(
                  color: purpleColor.withOpacity(0.08),
                  spreadRadius: 0,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    child: Icon(Icons.search, color: purpleColor, size: 18),
                  ),
                  Expanded(
                    child: Text(
                      'شنو بخاطرج اليوم ؟',
                      style: TextStyle(
                        color: purpleColor.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_ModernSearchBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        purpleColor != oldDelegate.purpleColor;
  }
}

// امتداد مساعد للحاويات المزينة
extension ContainerDecoration on Widget {
  Widget decorated({
    Gradient? gradient,
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
    Border? border,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: borderRadius,
        boxShadow: boxShadow,
        border: border,
      ),
      child: this,
    );
  }
}

// رسامات الأيقونات المخصصة
class UserIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // رأس
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.3),
      size.width * 0.18,
      paint,
    );

    // جسم
    final path = Path();
    path.moveTo(size.width * 0.15, size.height * 0.85);
    path.quadraticBezierTo(
      size.width * 0.15,
      size.height * 0.65,
      size.width * 0.35,
      size.height * 0.65,
    );
    path.lineTo(size.width * 0.65, size.height * 0.65);
    path.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.65,
      size.width * 0.85,
      size.height * 0.85,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CartIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    // عربة التسوق
    path.moveTo(size.width * 0.1, size.height * 0.2);
    path.lineTo(size.width * 0.25, size.height * 0.2);
    path.lineTo(size.width * 0.35, size.height * 0.55);
    path.lineTo(size.width * 0.8, size.height * 0.55);
    path.lineTo(size.width * 0.9, size.height * 0.25);
    path.lineTo(size.width * 0.95, size.height * 0.1);

    // عجلات
    canvas.drawCircle(
      Offset(size.width * 0.4, size.height * 0.75),
      size.width * 0.05,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.75),
      size.width * 0.05,
      paint,
    );

    // خطوط داخلية
    canvas.drawLine(
      Offset(size.width * 0.45, size.height * 0.3),
      Offset(size.width * 0.45, size.height * 0.45),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.6, size.height * 0.3),
      Offset(size.width * 0.6, size.height * 0.45),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.75, size.height * 0.3),
      Offset(size.width * 0.75, size.height * 0.45),
      paint,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CategoriesIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // مربعات الأقسام
    final squareSize = size.width * 0.35;
    final spacing = size.width * 0.1;

    // مربع علوي أيسر
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, squareSize, squareSize),
        const Radius.circular(3),
      ),
      paint,
    );

    // مربع علوي أيمن
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(squareSize + spacing, 0, squareSize, squareSize),
        const Radius.circular(3),
      ),
      paint,
    );

    // مربع سفلي أيسر
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, squareSize + spacing, squareSize, squareSize),
        const Radius.circular(3),
      ),
      paint,
    );

    // مربع سفلي أيمن
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          squareSize + spacing,
          squareSize + spacing,
          squareSize,
          squareSize,
        ),
        const Radius.circular(3),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ShoppingBagIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    // جسم الحقيبة
    path.moveTo(size.width * 0.2, size.height * 0.35);
    path.lineTo(size.width * 0.2, size.height * 0.85);
    path.lineTo(size.width * 0.8, size.height * 0.85);
    path.lineTo(size.width * 0.8, size.height * 0.35);
    path.close();

    // مقبض الحقيبة
    path.moveTo(size.width * 0.35, size.height * 0.35);
    path.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.15,
      size.width * 0.5,
      size.height * 0.15,
    );
    path.quadraticBezierTo(
      size.width * 0.65,
      size.height * 0.15,
      size.width * 0.65,
      size.height * 0.35,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HomeIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    // السقف
    path.moveTo(size.width * 0.1, size.height * 0.45);
    path.lineTo(size.width * 0.5, size.height * 0.1);
    path.lineTo(size.width * 0.9, size.height * 0.45);

    // الجدران
    path.moveTo(size.width * 0.15, size.height * 0.4);
    path.lineTo(size.width * 0.15, size.height * 0.85);
    path.lineTo(size.width * 0.85, size.height * 0.85);
    path.lineTo(size.width * 0.85, size.height * 0.4);

    // الباب
    path.moveTo(size.width * 0.4, size.height * 0.85);
    path.lineTo(size.width * 0.4, size.height * 0.6);
    path.lineTo(size.width * 0.6, size.height * 0.6);
    path.lineTo(size.width * 0.6, size.height * 0.85);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
