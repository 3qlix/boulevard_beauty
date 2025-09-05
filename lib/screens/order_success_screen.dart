import 'package:flutter/material.dart';
import 'home_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // لون خلفية فاتح جداً ليتناسق مع الثيم العام
      backgroundColor: const Color(0xFFFBFBFB), // نفس لون خلفية الشاشات الأخرى
      // لا نحتاج لـ AppBar في شاشة نجاح الطلب عادةً، يمكن إزالته أو جعله شفافًا
      // إذا أردت إزالته تمامًا، تأكد من أنك تستخدم زر العودة إلى الرئيسية بشكل واضح
      appBar: AppBar(
        backgroundColor: Colors.transparent, // خلفية شفافة
        elevation: 0, // إزالة الظل تمامًا
        automaticallyImplyLeading: false, // إزالة زر الرجوع التلقائي
      ),
      body: Directionality(
        textDirection: TextDirection.rtl, // لضمان دعم الاتجاه من اليمين لليسار
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // أيقونة النجاح بلون مميز وحجم أكبر
                Icon(
                  Icons.check_circle_outline, // أيقونة أكثر نعومة
                  color: const Color(
                    0xFF8BC34A,
                  ), // لون أخضر فاتح للنجاح (أكثر بهجة)
                  size: 120, // حجم أكبر
                ),
                const SizedBox(height: 30), // زيادة المسافة
                // نص التأكيد بتصميم أنيق
                const Text(
                  'تم تنفيذ طلبك بنجاح! 🎉', // إضافة إيموجي لإحساس بالاحتفال
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28, // حجم خط أكبر
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B008B), // لون بنفسجي داكن أنيق
                    // fontFamily: 'YourElegantFont', // يمكن إضافة خط مخصص هنا
                  ),
                ),
                const SizedBox(height: 16),
                // نص الشكر بتصميم مريح
                const Text(
                  'شكراً لاختياركِ متجرنا الجميل! سيتم تجهيز طلبك بعناية وسنوافيكِ بالتفاصيل قريباً.', // نص أكثر تفصيلاً
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17, // حجم أكبر قليلاً
                    color: Colors.black54, // لون رمادي داكن
                    height: 1.5, // تباعد أسطر أفضل
                  ),
                ),
                const SizedBox(height: 50), // مسافة أكبر قبل الزر
                // زر "العودة إلى الرئيسية" بتصميم أنيق
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.home_outlined,
                      color: Colors.white,
                    ), // أيقونة منزل أكثر نعومة
                    label: const Text(
                      'العودة إلى الرئيسية',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ), // خط أكبر وأكثر بروزًا
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63), // لون وردي مميز
                      foregroundColor: Colors.white, // لون النص والأيقونة أبيض
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                      ), // زيادة المسافة الداخلية
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          30,
                        ), // حواف دائرية أكبر
                      ),
                      elevation: 5, // ظل للزر
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
