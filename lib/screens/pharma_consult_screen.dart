import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // تأكد من أن هذا المسار صحيح
import 'login_screen.dart'; // تأكد من أن هذا المسار صحيح

class PharmaConsultScreen extends StatefulWidget {
  const PharmaConsultScreen({super.key});

  @override
  State<PharmaConsultScreen> createState() => _PharmaConsultScreenState();
}

class _PharmaConsultScreenState extends State<PharmaConsultScreen> {
  final TextEditingController _consultationController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSending = false;

  @override
  void dispose() {
    _consultationController.dispose();
    super.dispose();
  }

  Future<void> _sendConsultation() async {
    final isLoggedIn = await AuthService.isLoggedIn();
    if (!mounted) return;

    if (!isLoggedIn) {
      _showLoginDialog();
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    // محاكاة إرسال الاستشارة
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isSending = false;
      _consultationController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          '✅ تم إرسال استشارتك بنجاح! سيتم الرد عليك قريبًا 💬',
          textAlign: TextAlign.center, // توسيط النص
        ),
        backgroundColor: const Color(0xFF8BC34A), // لون أخضر فاتح للنجاح
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ), // حواف دائرية
        margin: const EdgeInsets.all(10), // هوامش
      ),
    );
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ), // حواف دائرية
        title: const Text(
          'تسجيل الدخول مطلوب',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFE91E63),
          ), // لون وردي مميز
          textAlign: TextAlign.right,
        ),
        content: const Text(
          'يرجى تسجيل الدخول لإرسال استشارة صيدلانية.',
          style: TextStyle(fontSize: 16, color: Colors.black87),
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63), // لون زر تسجيل الدخول
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'تسجيل الدخول',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // لضمان دعم الاتجاه من اليمين لليسار
      child: Scaffold(
        // لون خلفية فاتح جداً ليتناسق مع الثيم العام
        backgroundColor: const Color(0xFFFBFBFB),
        appBar: AppBar(
          title: const Text(
            'الاستشارات الصيدلانية',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B008B), // لون بنفسجي داكن أنيق
              fontSize: 22, // حجم أكبر للعنوان
              // fontFamily: 'YourElegantFont', // يمكن إضافة خط مخصص هنا
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white, // لون AppBar أبيض نظيف
          elevation: 1.0, // ظل خفيف وأنيق
          iconTheme: const IconThemeData(
            color: Color(0xFF8B008B), // لون أيقونات الـ AppBar
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24), // زيادة المسافة الداخلية
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // أيقونة طبية بتصميم أنيق ولون مميز
                Icon(
                  Icons
                      .medical_services_outlined, // أيقونة أكثر نعومة واحترافية
                  size: 90, // حجم أكبر
                  color: const Color(0xFFE91E63), // لون وردي مميز
                ),
                const SizedBox(height: 25), // زيادة المسافة
                // نص توضيحي للاستشارة
                const Text(
                  'يمكنكِ كتابة استشارتكِ هنا وسيقوم فريقنا الطبي بالرد عليكِ في أقرب وقت ممكن.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.black54,
                    height: 1.5, // تباعد أسطر أفضل
                  ),
                ),
                const SizedBox(height: 30), // زيادة المسافة
                // حقل إدخال الاستشارة بتصميم أنيق
                TextFormField(
                  controller: _consultationController,
                  maxLines: 7, // زيادة عدد الأسطر الافتراضية
                  decoration: InputDecoration(
                    labelText: 'اكتبي استشارتكِ هنا...',
                    labelStyle: TextStyle(
                      color: Colors.grey.shade600,
                    ), // لون نص التسمية
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: Colors.white, // لون خلفية الحقل أبيض
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        15,
                      ), // حواف دائرية أكبر
                      borderSide: BorderSide.none, // إزالة الحدود الافتراضية
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ), // حدود رمادية فاتحة
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                        color: Color(0xFFE91E63),
                        width: 2,
                      ), // حدود وردية عند التركيز
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 1,
                      ), // حدود حمراء للخطأ
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ), // مسافة داخلية
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى كتابة الاستشارة قبل الإرسال';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30), // زيادة المسافة
                // زر "إرسال الاستشارة" بتصميم أنيق
                SizedBox(
                  width: double.infinity,
                  height: 55, // زيادة ارتفاع الزر
                  child: ElevatedButton.icon(
                    icon: _isSending
                        ? const SizedBox(
                            width: 25, // حجم أكبر لمؤشر التحميل
                            height: 25,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5, // سمك أكبر
                            ),
                          )
                        : const Icon(
                            Icons.send_outlined,
                            color: Colors.white,
                          ), // أيقونة إرسال أكثر نعومة
                    onPressed: _isSending ? null : _sendConsultation,
                    label: Text(
                      _isSending ? 'جارٍ الإرسال...' : 'إرسال الاستشارة',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ), // خط أكبر وأكثر بروزًا
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63), // لون وردي مميز
                      foregroundColor: Colors.white, // لون النص والأيقونة أبيض
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
