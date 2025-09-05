import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderNumber;
  final double totalAmount;
  final String phoneNumber;
  final String address;
  final VoidCallback onOrderCancelled;

  const OrderDetailsScreen({
    super.key,
    required this.orderNumber,
    required this.totalAmount,
    required this.phoneNumber,
    required this.address,
    required this.onOrderCancelled,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  // الألوان
  static const Color _primaryPurple = Color(0xFF6B166F);
  static const Color _lightPurple = Color(0xFF9C4A9F);
  static const Color _accentPurple = Color(0xFFE1BEE7);

  // دالة مساعدة للألوان مع الشفافية
  Color withAlpha(Color color, double opacity) {
    return Color.fromRGBO(color.red, color.green, color.blue, opacity);
  }

  // البيانات المؤقتة
  final String _customerName = 'الاسم: محمد أحمد';
  final String _country = 'البلد: العراق';
  final String _governorate = 'المحافظة: بغداد';
  final String _addressDetails = 'التفاصيل: الكرادة، شارع 62';
  final int _quantity = 2;
  final String _paymentMethod = 'نقدي';
  late double _deliveryFee;
  late double _total;

  @override
  void initState() {
    super.initState();
    _calculatePrices();
  }

  void _calculatePrices() {
    // حساب الأسعار
    _deliveryFee = widget.totalAmount >= 50000 ? 0.0 : 5000.0;
    _total = widget.totalAmount;
  }

  // إلغاء الطلب
  void _cancelOrder() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'رسالة',
          style: TextStyle(
            color: _primaryPurple,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'هل تريدين إلغاء الطلب؟',
          style: TextStyle(fontSize: 16, color: Colors.black87),
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(
                    foregroundColor: _primaryPurple,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: withAlpha(_primaryPurple, 0.3)),
                    ),
                  ),
                  child: const Text('إلغاء', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_primaryPurple, _lightPurple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _confirmCancellation();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'تأكيد',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // تأكيد الإلغاء
  void _confirmCancellation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'رسالة',
          style: TextStyle(
            color: _primaryPurple,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'تم إلغاء الطلب.',
          style: TextStyle(fontSize: 16, color: Colors.black87),
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: Container(
              width: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryPurple, _lightPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  widget.onOrderCancelled();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'حسناً',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
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
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildAddressSection(),
              const SizedBox(height: 16),
              _buildInvoiceSection(),
              const SizedBox(height: 16),
              _buildContactSection(),
              const SizedBox(height: 30),
              _buildCancelButton(),
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
      title: Text(
        'الطلب ${widget.orderNumber}',
        style: const TextStyle(
          color: _primaryPurple,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  // قسم تفاصيل العنوان
  Widget _buildAddressSection() {
    return Container(
      width: double.infinity,
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
                'تفاصيل العنوان',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _primaryPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAddressRow(_customerName),
          const SizedBox(height: 8),
          _buildAddressRow(_country),
          const SizedBox(height: 8),
          _buildAddressRow(_governorate),
          const SizedBox(height: 8),
          _buildAddressRow(_addressDetails),
          const SizedBox(height: 8),
          _buildAddressRow('رقم التواصل: +964 ${widget.phoneNumber}'),
        ],
      ),
    );
  }

  // صف في العنوان
  Widget _buildAddressRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 28),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade700,
          height: 1.5,
        ),
      ),
    );
  }

  // قسم تفاصيل الفاتورة
  Widget _buildInvoiceSection() {
    return Container(
      width: double.infinity,
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
          _buildInvoiceRow('الكمية:', _quantity.toString()),
          const SizedBox(height: 8),
          _buildInvoiceRow('طريقة الدفع:', _paymentMethod),
          const SizedBox(height: 8),
          _buildInvoiceRow(
            'كلفة التوصيل:',
            '${_deliveryFee.toStringAsFixed(0)} د.ع',
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          _buildInvoiceRow(
            'السعر الكلي:',
            '${widget.totalAmount.toStringAsFixed(0)} د.ع',
            isBold: true,
          ),
        ],
      ),
    );
  }

  // صف في الفاتورة
  Widget _buildInvoiceRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isBold ? _primaryPurple : Colors.black87,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // قسم التواصل
  Widget _buildContactSection() {
    return Container(
      width: double.infinity,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/contact_support.png',
                width: 80,
                height: 80,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: withAlpha(_accentPurple, 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.phone_in_talk,
                        color: _primaryPurple,
                        size: 30,
                      ),
                      const SizedBox(height: 4),
                      Icon(Icons.message, color: _primaryPurple, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'تواصلي ويانا',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _primaryPurple,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'عندچ استفسار او تحتاجين مساعدة، تواصلي ويا',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          Text(
            'فريقنا',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // زر إلغاء الطلب
  Widget _buildCancelButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: withAlpha(_accentPurple, 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: withAlpha(_primaryPurple, 0.3), width: 1),
      ),
      child: TextButton(
        onPressed: _cancelOrder,
        child: const Text(
          'إلغاء الطلب',
          style: TextStyle(
            color: _primaryPurple,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
