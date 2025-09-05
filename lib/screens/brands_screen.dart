import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'search_screen.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';
import '../models/app_user.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class BrandsScreen extends StatefulWidget {
  final List<Product> cartItems;
  final Function(Product) addToCart;
  final List<Product> favoriteItems;
  final Function(Product) toggleFavorite;
  final String? initialSelectedBrand;

  const BrandsScreen({
    super.key,
    required this.cartItems,
    required this.addToCart,
    required this.favoriteItems,
    required this.toggleFavorite,
    this.initialSelectedBrand,
  });

  @override
  State<BrandsScreen> createState() => _BrandsScreenState();
}

class _BrandsScreenState extends State<BrandsScreen> {
  // ألوان الثيم
  static const Color _primaryPurple = Color(0xFF6B166F);
  static const Color _lightPurple = Color(0xFF9C4A9F);
  static const Color _accentPurple = Color(0xFFE1BEE7);

  static const LinearGradient _purpleGradient = LinearGradient(
    colors: [_primaryPurple, _lightPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // متغيرات الحالة
  String? _selectedBrand;
  bool _isLoggedIn = false;
  AppUser? _currentUser;

  // بيانات الماركات
  final List<Map<String, dynamic>> _brands = [
    {
      'name': 'SVR',
      'logo': 'assets/images/brand_a.png',
      'description': 'العناية الفرنسية المتخصصة بالبشرة',
      'productsCount': 25,
    },
    {
      'name': 'Cosmo',
      'logo': 'assets/images/brand_b.png',
      'description': 'منتجات كورية للعناية والجمال',
      'productsCount': 18,
    },
    {
      'name': 'Nacomi',
      'logo': 'assets/images/brand_c.png',
      'description': 'منتجات طبيعية وعضوية',
      'productsCount': 32,
    },
    {
      'name': 'Dermacol',
      'logo': 'assets/images/brand_d.png',
      'description': 'مكياج احترافي ثابت',
      'productsCount': 20,
    },
    {
      'name': 'ACM',
      'logo': 'assets/images/acm_logo.png',
      'description': 'حلول طبية للبشرة',
      'productsCount': 15,
    },
    {
      'name': 'Abib',
      'logo': 'assets/images/abib_logo.png',
      'description': 'العناية الكورية المبتكرة',
      'productsCount': 22,
    },
    {
      'name': 'UNDER TWENTY',
      'logo': 'assets/images/under20_logo.png',
      'description': 'للبشرة الشابة والحيوية',
      'productsCount': 28,
    },
    {
      'name': 'La Roche-Posay',
      'logo': 'assets/images/laroche_logo.png',
      'description': 'العناية الصيدلانية بالبشرة',
      'productsCount': 35,
    },
    {
      'name': 'Vichy',
      'logo': 'assets/images/vichy_logo.png',
      'description': 'قوة المياه الحرارية البركانية',
      'productsCount': 30,
    },
    {
      'name': 'Eucerin',
      'logo': 'assets/images/eucerin_logo.png',
      'description': 'علوم الجلد المتقدمة',
      'productsCount': 27,
    },
  ];

  // منتجات وهمية لكل ماركة
  final Map<String, List<Product>> _brandProducts = {
    'SVR': [
      Product(
        id: 'svr1',
        title: 'SVR سيروم فيتامين سي 20%',
        price: 45000.0,
        imagePath: 'assets/images/product1.png',
        description: 'سيروم مركز بفيتامين سي للتفتيح وتوحيد لون البشرة',
        category: 'العناية بالبشرة',
        brand: 'SVR',
      ),
      Product(
        id: 'svr2',
        title: 'SVR واقي شمس +SPF50',
        price: 35000.0,
        imagePath: 'assets/images/product2.png',
        description: 'حماية عالية من أشعة الشمس للبشرة الحساسة',
        category: 'العناية بالبشرة',
        brand: 'SVR',
      ),
      Product(
        id: 'svr3',
        title: 'SVR كريم ترطيب مكثف',
        price: 30000.0,
        imagePath: 'assets/images/product3.png',
        description: 'ترطيب عميق يدوم 48 ساعة',
        category: 'العناية بالبشرة',
        brand: 'SVR',
      ),
    ],
    'Cosmo': [
      Product(
        id: 'cos1',
        title: 'Cosmo ماسك الذهب للوجه',
        price: 25000.0,
        imagePath: 'assets/images/product4.png',
        description: 'ماسك بخلاصة الذهب لبشرة مشرقة',
        category: 'العناية بالبشرة',
        brand: 'Cosmo',
      ),
      Product(
        id: 'cos2',
        title: 'Cosmo تونر الأرز المخمر',
        price: 20000.0,
        imagePath: 'assets/images/product5.png',
        description: 'تونر كوري لتنظيف وتوازن البشرة',
        category: 'العناية بالبشرة',
        brand: 'Cosmo',
      ),
    ],
    'Nacomi': [
      Product(
        id: 'nac1',
        title: 'Nacomi زيت الأرغان العضوي',
        price: 40000.0,
        imagePath: 'assets/images/product1.png',
        description: 'زيت أرغان نقي 100% للشعر والبشرة',
        category: 'العناية بالشعر',
        brand: 'Nacomi',
      ),
      Product(
        id: 'nac2',
        title: 'Nacomi سكراب القهوة',
        price: 18000.0,
        imagePath: 'assets/images/product2.png',
        description: 'مقشر طبيعي بالقهوة وزيت جوز الهند',
        category: 'العناية بالجسم',
        brand: 'Nacomi',
      ),
    ],
    'Dermacol': [
      Product(
        id: 'der1',
        title: 'Dermacol فاونديشن كامل التغطية',
        price: 35000.0,
        imagePath: 'assets/images/product3.png',
        description: 'كريم أساس بتغطية كاملة يدوم 24 ساعة',
        category: 'المكياج',
        brand: 'Dermacol',
      ),
      Product(
        id: 'der2',
        title: 'Dermacol أحمر شفاه مطفي',
        price: 15000.0,
        imagePath: 'assets/images/product4.png',
        description: 'أحمر شفاه مطفي ثابت طويل الأمد',
        category: 'المكياج',
        brand: 'Dermacol',
      ),
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedBrand = widget.initialSelectedBrand;
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    _isLoggedIn = await AuthService.isLoggedIn();
    if (_isLoggedIn) {
      _currentUser = await AuthService.getCurrentUser();
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _buildAppTheme(),
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: _buildAppBar(),
        body: _selectedBrand == null
            ? _buildBrandsGrid()
            : _buildBrandProducts(),
      ),
    );
  }

  // ثيم التطبيق
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
      ),
    );
  }

  // شريط التطبيق العلوي المبسط
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text(
        _selectedBrand ?? 'تسوقي حسب الماركة',
        style: const TextStyle(
          color: _primaryPurple,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      // زر العودة على اليمين
      actions: [
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios, color: _primaryPurple),
          onPressed: () {
            // إذا كان في عرض منتجات الماركة، ارجع لقائمة الماركات
            if (_selectedBrand != null) {
              setState(() {
                _selectedBrand = null;
              });
            } else {
              // إذا كان في قائمة الماركات، ارجع للصفحة السابقة
              Navigator.pop(context);
            }
          },
        ),
      ],
      // أزرار البحث والواتساب على اليسار
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Image.asset(
              'assets/images/whatsapp_icon.png',
              height: 22,
              width: 22,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.chat_bubble_outline,
                color: Colors.green,
                size: 22,
              ),
            ),
            onPressed: _launchWhatsApp,
          ),
          IconButton(
            icon: const Icon(Icons.search, color: _primaryPurple, size: 22),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SearchScreen(
                    searchQuery: '',
                    cartItems: widget.cartItems,
                    addToCart: widget.addToCart,
                    favoriteItems: widget.favoriteItems,
                    toggleFavorite: widget.toggleFavorite,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      leadingWidth: 96,
    );
  }

  // شبكة الماركات
  Widget _buildBrandsGrid() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.85,
                crossAxisSpacing: 15,
                mainAxisSpacing: 20,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final brand = _brands[index];
                return _buildBrandCard(brand);
              }, childCount: _brands.length),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  // بطاقة الماركة
  Widget _buildBrandCard(Map<String, dynamic> brand) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBrand = brand['name'];
        });
      },
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(15),
                  child: Image.asset(
                    brand['logo'],
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.branding_watermark,
                      color: _primaryPurple.withOpacity(0.5),
                      size: 35,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            brand['name'],
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _primaryPurple,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // عرض منتجات الماركة المختارة
  Widget _buildBrandProducts() {
    final products = _brandProducts[_selectedBrand] ?? [];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            _buildSortAndFilterBar(),
            Expanded(
              child: products.isEmpty
                  ? _buildEmptyProductsView()
                  : _buildProductsGrid(products),
            ),
          ],
        ),
      ),
    );
  }

  // شريط أزرار الترتيب والتصنيف
  Widget _buildSortAndFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                _showSortOptions();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.swap_vert,
                      size: 20,
                      color: _primaryPurple,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'الترتيب',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () {
                _showFilterOptions();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.tune, size: 20, color: _primaryPurple),
                    const SizedBox(width: 6),
                    Text(
                      'التصنيف',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // شبكة المنتجات
  Widget _buildProductsGrid(List<Product> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 8,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(products[index]);
      },
    );
  }

  // بطاقة المنتج
  Widget _buildProductCard(Product product) {
    final isFavorite = widget.favoriteItems.any(
      (item) => item.id == product.id,
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
              favoriteItems: widget.favoriteItems,
              toggleFavorite: widget.toggleFavorite,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // صورة المنتج مع زر المفضلة
            Stack(
              children: [
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
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
                Positioned(
                  top: 6,
                  left: 6,
                  child: GestureDetector(
                    onTap: () {
                      widget.toggleFavorite(product);
                      setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite
                            ? const Color.fromARGB(255, 168, 46, 142)
                            : Colors.grey.shade400,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // معلومات المنتج
            Expanded(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        // اسم المنتج
                        SizedBox(
                          height: 28,
                          child: Text(
                            product.title,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // اسم الشركة
                        SizedBox(
                          height: 16,
                          child: Text(
                            product.brand,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // السعر
                        SizedBox(
                          height: 18,
                          child: Text(
                            '${product.price.toStringAsFixed(0)} د.ع',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    // زر الإضافة للسلة
                    Container(
                      width: double.infinity,
                      height: 30,
                      margin: const EdgeInsets.only(top: 4),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _handleAddToCart(product);
                          },
                          borderRadius: BorderRadius.circular(6),
                          splashColor: Colors.white.withOpacity(0.3),
                          highlightColor: Colors.white.withOpacity(0.1),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [_primaryPurple, _lightPurple],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Center(
                              child: Text(
                                'ضيفيني لسلتج',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
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

  // دالة التحقق من تسجيل الدخول قبل الإضافة للسلة
  void _handleAddToCart(Product product) {
    if (!_isLoggedIn) {
      _showLoginRequiredDialog();
      return;
    }

    widget.addToCart(product);

    // حساب عدد هذا المنتج في السلة
    final productCount = widget.cartItems
        .where((item) => item.id == product.id)
        .length;

    // عرض رسالة النجاح مع العدد
    if (productCount > 1) {
      _showSnackBar('✅ «${product.title}» (${productCount}x) في السلة');
    } else {
      _showSnackBar('✅ تمت إضافة «${product.title}» إلى السلة');
    }

    HapticFeedback.lightImpact();
  }

  // عرض رسالة تسجيل الدخول المطلوبة
  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // أيقونة
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _primaryPurple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    color: _primaryPurple,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                // العنوان
                const Text(
                  'تسجيل الدخول مطلوب',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // الرسالة
                Text(
                  'يتوجب عليك تسجيل الدخول للإضافة إلى السلة',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // الأزرار
                Row(
                  children: [
                    // زر إلغاء
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: Text(
                          'إلغاء',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // زر تسجيل الدخول
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // أغلق الرسالة
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          ).then((_) async {
                            // تحديث حالة تسجيل الدخول بعد العودة
                            await _checkLoginStatus();
                            if (mounted) {
                              setState(() {});
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryPurple,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'تسجيل الدخول',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // عرض حالة عدم وجود منتجات
  Widget _buildEmptyProductsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد منتجات متاحة حالياً',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // دوال مؤقتة لأزرار الترتيب والتصنيف
  void _showSortOptions() {
    _showSnackBar('خيارات الترتيب قيد التطوير');
  }

  void _showFilterOptions() {
    _showSnackBar('خيارات التصنيف قيد التطوير');
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

  // عرض رسالة
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
}
