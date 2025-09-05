import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'order_details_screen.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final String orderNumber;
  final double totalAmount;
  final String phoneNumber;
  final String address;
  final VoidCallback onBackToShopping;

  const OrderConfirmationScreen({
    super.key,
    required this.orderNumber,
    required this.totalAmount,
    required this.phoneNumber,
    required this.address,
    required this.onBackToShopping,
  });

  // الألوان
  static const Color _primaryPurple = Color(0xFF6B166F);
  static const Color _lightPurple = Color(0xFF9C4A9F);
  static const Color _accentPurple = Color(0xFFE1BEE7);

  @override
  Widget build(BuildContext context) {
    // تأثير اهتزاز خفيف للتأكيد
    HapticFeedback.lightImpact();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: WillPopScope(
        onWillPop: () async {
          // منع الرجوع بالزر الخلفي
          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // أيقونة النجاح
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: _accentPurple.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: _primaryPurple,
                      size: 60,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // رسالة الشكر
                  const Text(
                    'شكراً على طلبج !',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _primaryPurple,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // رقم الطلب
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _accentPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'رقم طلبج هو $orderNumber',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: _primaryPurple,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // رسالة التأكيد
                  Text(
                    'تم تثبيت طلبج بنجاح',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'تگدرين همسه ترايعين تفاصيل طلبج من بروفايلج او من هنا',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // تفاصيل الطلب
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade200, width: 1),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          Icons.attach_money,
                          'السعر الكلي',
                          '${totalAmount.toStringAsFixed(0)} د.ع',
                        ),
                        const SizedBox(height: 15),
                        _buildDetailRow(
                          Icons.phone,
                          'رقم التواصل',
                          '+964 $phoneNumber',
                        ),
                        const SizedBox(height: 15),
                        _buildDetailRow(
                          Icons.location_on,
                          'عنوان التوصيل',
                          address,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // رسالة الشكر السفلية
                  Text(
                    'شكراً لثقتچ بينا وتمنى الچ تجربة تسوق ممتعة',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),

                  // الأزرار
                  Row(
                    children: [
                      // زر ارجعي للتسوق
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: _accentPurple.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextButton(
                            onPressed: onBackToShopping,
                            child: const Text(
                              'ارجعي للتسوق',
                              style: TextStyle(
                                color: _primaryPurple,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // زر متابعة حالة الطلب
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_primaryPurple, _lightPurple],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: _primaryPurple.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OrderDetailsScreen(
                                    orderNumber: orderNumber,
                                    totalAmount: totalAmount,
                                    phoneNumber: phoneNumber,
                                    address: address,
                                    onOrderCancelled: onBackToShopping,
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'متابعة حالة الطلب',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // بناء صف التفاصيل
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _accentPurple.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: _primaryPurple, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 2),
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
        ),
      ],
    );
  }
}
