import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_detail_screen.dart'; // تأكد من وجوده
// قد تحتاج لاستيراد Auth, AppUser, LoginScreen إذا كانت SearchScreen ستتفاعل مع تسجيل الدخول
// import '../services/auth_service.dart';
// import '../models/app_user.dart';
// import 'login_screen.dart';

class SearchScreen extends StatefulWidget {
  final String searchQuery;
  final List<Product> cartItems;
  final Function(Product) addToCart;
  final List<Product> favoriteItems; // إضافة هذا المعامل
  final Function(Product) toggleFavorite; // إضافة هذا المعامل

  const SearchScreen({
    super.key,
    required this.searchQuery,
    required this.cartItems,
    required this.addToCart,
    required this.favoriteItems, // مطلوب
    required this.toggleFavorite, // مطلوب
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _searchResults = [];
  // قائمة المنتجات الافتراضية (للتجربة)
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
    Product(
      id: '6',
      title: 'ماسكارا لتكثيف الرموش',
      price: 18000.0,
      imagePath: 'assets/images/product6.png',
      description:
          'ماسكارا تمنح رموشك كثافة وطولاً فائقين بتركيبة مقاومة للتلطخ.',
      category: 'المكياج',
      brand: 'BeYu',
    ),
    Product(
      id: '7',
      title: 'مجموعة بات آند بودي وركس 4 قطع',
      price: 50000.0,
      imagePath: 'assets/images/product7.png',
      description:
          'مجموعة متكاملة للعناية بالجسم تتضمن لوشن، جل استحمام، بخاخ جسم، وكريم يدين.',
      category: 'العناية بالجسم',
      brand: 'Bath & Body Works',
    ),
    Product(
      id: '8',
      title: 'شامبو ضد القمل للأطفال - 250 مل',
      price: 11000.0,
      imagePath: 'assets/images/product8.png',
      description:
          'شامبو فعال ولطيف على فروة رأس الأطفال للتخلص من القمل وبيوضه.',
      category: 'العناية بالشعر',
      brand: 'SUBRINA',
    ),
    Product(
      id: '9',
      title: 'بيبي ليس ملاقط شعر - 2 قطعة',
      price: 4000.0,
      imagePath: 'assets/images/product9.png',
      description:
          'ملاقط شعر عالية الجودة من بيبي ليس لتصفيف الشعر بسهولة ودقة.',
      category: 'الأدوات',
      brand: 'BaByliss',
    ),
  ];

  static const Color _purpleColor = Color(0xFF6B166F);

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
    _performSearch(widget.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = _allProducts.where((product) {
          return product.title.toLowerCase().contains(query.toLowerCase()) ||
              product.description.toLowerCase().contains(query.toLowerCase()) ||
              product.category.toLowerCase().contains(query.toLowerCase()) ||
              product.brand.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: _purpleColor,
          elevation: 0,
          title: TextField(
            controller: _searchController,
            onChanged: _performSearch,
            onSubmitted: _performSearch,
            decoration: InputDecoration(
              hintText: 'ابحثي عن منتجاتك هنا',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: _purpleColor, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 20.0,
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: _purpleColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _searchResults.isEmpty && _searchController.text.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'ابدئي البحث عن منتجاتك المفضلة.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontFamily: 'Almarai',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : _searchResults.isEmpty && _searchController.text.isNotEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sentiment_dissatisfied,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'عذراً، لا توجد نتائج لبحثك "${_searchController.text}".',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontFamily: 'Almarai',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'حاولي بكلمات مفتاحية أخرى.',
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
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final product = _searchResults[index];
                  return _buildProductCard(product);
                },
              ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    // التحقق مما إذا كان المنتج مفضلاً
    final bool isFavorite = widget.favoriteItems.any((e) => e.id == product.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(
              product: product,
              cartItems: widget.cartItems,
              addToCart: widget.addToCart,
              favoriteItems: widget.favoriteItems, // تمرير المفضلة
              toggleFavorite: widget.toggleFavorite, // تمرير دالة التبديل
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
              color: Color.fromARGB(
                (255 * 0.08).round(),
                0,
                0,
                0,
              ), // إصلاح withOpacity
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
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(
                          (255 * 0.8).round(),
                          255,
                          255,
                          255,
                        ), // إصلاح withOpacity
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : _purpleColor,
                        size: 20,
                      ),
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
