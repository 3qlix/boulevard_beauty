import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import 'order_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Product> cartItems;
  final double totalAmount;
  final double deliveryFee;
  final VoidCallback onOrderConfirmed;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.totalAmount,
    required this.deliveryFee,
    required this.onOrderConfirmed,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // الألوان
  static const Color _primaryPurple = Color(0xFF6B166F);
  static const Color _lightPurple = Color(0xFF9C4A9F);
  static const Color _accentPurple = Color(0xFFE1BEE7);

  // دالة مساعدة للألوان مع الشفافية
  Color withAlpha(Color color, double opacity) {
    return Color.fromRGBO(color.red, color.green, color.blue, opacity);
  }

  // المتحكمات
  final TextEditingController _notesController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // البيانات
  AppUser? _currentUser;
  String _userAddress = '';
  String _userPhone = '';
  bool _showAllProducts = false;
  String _paymentMethod = 'cash'; // نقدي عند الاستلام
  static int _orderCounter = 0; // عداد الطلبات

  // حساب الكميات
  final Map<String, int> _productQuantities = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _calculateQuantities();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // تحميل بيانات المستخدم
  Future<void> _loadUserData() async {
    try {
      _currentUser = await AuthService.getCurrentUser();
      if (_currentUser != null) {
        setState(() {
          _userPhone = _currentUser!.phone;
          // يمكن تحميل العنوان من شاشة العناوين
          _userAddress = 'بغداد، الكرادة'; // عنوان مؤقت
        });
      }
    } catch (e) {
      debugPrint('خطأ في تحميل بيانات المستخدم: $e');
    }
  }

  // حساب كميات المنتجات
  void _calculateQuantities() {
    _productQuantities.clear();
    for (var product in widget.cartItems) {
      _productQuantities[product.id] =
          (_productQuantities[product.id] ?? 0) + 1;
    }
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

  // تأكيد الطلب
  void _confirmOrder() {
    _orderCounter++;
    final orderNumber = _orderCounter.toString();

    // الانتقال لشاشة تأكيد الطلب
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OrderConfirmationScreen(
          orderNumber: orderNumber,
          totalAmount: widget.totalAmount + widget.deliveryFee,
          phoneNumber: _userPhone,
          address: _userAddress,
          onBackToShopping: () {
            widget.onOrderConfirmed();
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              _buildDeliveryTimeNotice(),
              _buildProductsList(),
              _buildAddressSection(),
              _buildInvoiceDetails(),
              _buildPaymentMethod(),
              _buildContactNumber(),
              _buildNotesSection(),
              _buildPoliciesLinks(),
              _buildPrivacyNote(),
              _buildConfirmButton(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // شريط العنوان
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_forward_ios, color: _primaryPurple),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'خطوة واحدة لتثبيت الطلب',
        style: TextStyle(
          color: _primaryPurple,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  // إشعار وقت التوصيل
  Widget _buildDeliveryTimeNotice() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: withAlpha(_accentPurple, 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: withAlpha(_primaryPurple, 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, color: _primaryPurple, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'الوقت المتوقع لوصول طلبج: بغداد والبصرة يومين عمل وباقي المحافظات 3 أيام عمل',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // قائمة المنتجات
  Widget _buildProductsList() {
    final uniqueProducts = _getUniqueProducts();
    final productsToShow = _showAllProducts
        ? uniqueProducts
        : uniqueProducts.take(2).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: withAlpha(Colors.black, 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ...productsToShow.map((product) => _buildProductItem(product)),
          if (uniqueProducts.length > 2)
            TextButton(
              onPressed: () {
                setState(() {
                  _showAllProducts = !_showAllProducts;
                });
              },
              child: Text(
                _showAllProducts ? 'إخفاء المنتجات' : 'عرض المنتجات',
                style: const TextStyle(color: _primaryPurple),
              ),
            ),
        ],
      ),
    );
  }

  // عنصر المنتج
  Widget _buildProductItem(Product product) {
    final quantity = _productQuantities[product.id] ?? 1;
    final totalPrice = product.price * quantity;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              product.imagePath,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 60,
                height: 60,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product.brand,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'سعر القطعة: ${product.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      'الكمية: $quantity',
                      style: const TextStyle(
                        fontSize: 12,
                        color: _primaryPurple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'الإجمالي: ${totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _primaryPurple,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // قسم العنوان
  Widget _buildAddressSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: withAlpha(Colors.black, 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: _primaryPurple, size: 20),
              const SizedBox(width: 8),
              const Text(
                'عنوان التوصيل',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _primaryPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _userAddress.isNotEmpty ? _userAddress : 'لم يتم تحديد عنوان',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {
              // الانتقال لشاشة العناوين
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('شاشة العناوين قيد الإنشاء')),
              );
            },
            icon: const Icon(Icons.add, color: _primaryPurple, size: 18),
            label: const Text(
              'إضافة عنوان آخر',
              style: TextStyle(color: _primaryPurple),
            ),
          ),
        ],
      ),
    );
  }

  // تفاصيل الفاتورة
  Widget _buildInvoiceDetails() {
    final total = widget.totalAmount + widget.deliveryFee;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: withAlpha(Colors.black, 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_outlined, color: _primaryPurple, size: 20),
              const SizedBox(width: 8),
              const Text(
                'تفاصيل الفاتورة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _primaryPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInvoiceRow(
            'السعر',
            '${widget.totalAmount.toStringAsFixed(0)} د.ع',
          ),
          const SizedBox(height: 8),
          _buildInvoiceRow(
            'كلفة التوصيل',
            '${widget.deliveryFee.toStringAsFixed(0)} د.ع',
          ),
          const Divider(height: 20),
          _buildInvoiceRow(
            'السعر الكلي',
            '${total.toStringAsFixed(0)} د.ع',
            isBold: true,
          ),
        ],
      ),
    );
  }

  // صف في الفاتورة
  Widget _buildInvoiceRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isBold ? _primaryPurple : Colors.black87,
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // طريقة الدفع
  Widget _buildPaymentMethod() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: withAlpha(Colors.black, 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: _primaryPurple,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'طريقة الدفع',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _primaryPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                  style: BorderStyle.solid,
                ),
              ),
            ),
          ),
          RadioListTile<String>(
            value: 'cash',
            groupValue: _paymentMethod,
            onChanged: (value) {
              setState(() {
                _paymentMethod = value!;
              });
            },
            title: Row(
              children: [
                Icon(Icons.money, color: Colors.grey.shade600, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'الدفع نقداً عند الاستلام',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            subtitle: const Text(
              'الدفع نقدا عند استلام الطلب',
              style: TextStyle(fontSize: 12),
            ),
            activeColor: _primaryPurple,
            dense: true,
          ),
        ],
      ),
    );
  }

  // رقم التواصل
  Widget _buildContactNumber() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: withAlpha(Colors.black, 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'رقم التواصل عند التوصيل',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _primaryPurple,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              _userPhone.isNotEmpty ? '+964 $_userPhone' : 'لم يتم تحديد رقم',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // قسم الملاحظات
  Widget _buildNotesSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: withAlpha(Colors.black, 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ملاحظات',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _primaryPurple,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'عندچ ملاحظة تگوليها النا ؟',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _primaryPurple),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // روابط السياسات
  Widget _buildPoliciesLinks() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('شاشة سياسة التبديل قيد الإنشاء')),
              );
            },
            child: const Text(
              'شوكت أگدر أبدل او أرجع المنتج ؟',
              style: TextStyle(
                color: _primaryPurple,
                fontSize: 14,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('شاشة ضمان المنتجات قيد الإنشاء')),
              );
            },
            child: const Text(
              'ضمان منتجاتنا',
              style: TextStyle(
                color: _primaryPurple,
                fontSize: 14,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ملاحظة الخصوصية
  Widget _buildPrivacyNote() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: withAlpha(_accentPurple, 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'راح نحتفظ بمعلوماتچ بسرية تامة ومراح نشاركها مع احد',
        style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
        textAlign: TextAlign.center,
      ),
    );
  }

  // زر تأكيد الطلب
  Widget _buildConfirmButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _confirmOrder,
          borderRadius: BorderRadius.circular(16),
          splashColor: withAlpha(Colors.white, 0.3),
          highlightColor: withAlpha(Colors.white, 0.1),
          child: Ink(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_primaryPurple, _lightPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: withAlpha(_primaryPurple, 0.3),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Text(
              'تأكيد الطلب',
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
    );
  }
}
