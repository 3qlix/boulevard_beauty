import 'package:uuid/uuid.dart'; // لاستخدام مكتبة UUID لإنشاء معرفات فريدة

class AppUser {
  final String id; // رقم التعريف الفريد للمستخدم
  final String name; // الاسم الكامل للمستخدم
  final String phone; // رقم الهاتف (بدون +964)
  final String joinedDate; // تاريخ انضمام المستخدم
  String? imagePath; // مسار الصورة الشخصية (يمكن أن يكون فارغاً)
  bool isLoggedIn; // حالة تسجيل الدخول الحالية للمستخدم (للحساب الحالي)

  AppUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.joinedDate,
    this.imagePath, // أضف هذا هنا
    this.isLoggedIn = false, // القيمة الافتراضية هي غير مسجل دخول
  });

  // دالة مساعدة لإنشاء AppUser من بيانات JSON (من SharedPreferences)
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      joinedDate: json['joinedDate'],
      imagePath: json['imagePath'], // أضف هذا هنا
      isLoggedIn: json['isLoggedIn'] ?? false, // التأكد من قيمة افتراضية
    );
  }

  // دالة مساعدة لتحويل AppUser إلى بيانات JSON (للحفظ في SharedPreferences)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'joinedDate': joinedDate,
      'imagePath': imagePath, // أضف هذا هنا
      'isLoggedIn': isLoggedIn,
    };
  }

  // دالة مساعدة لإنشاء AppUser جديد (عند التسجيل لأول مرة)
  static AppUser createNewUser({
    required String name,
    required String phone,
    String? imagePath, // أضف هذا هنا
  }) {
    const uuid = Uuid();
    final newId = 'r${uuid.v4().substring(0, 7)}'; // إنشاء معرف فريد قصير
    final date = DateTime.now().toIso8601String().split('T')[0]; // تاريخ اليوم
    return AppUser(
      id: newId,
      name: name,
      phone: phone,
      joinedDate: date,
      imagePath: imagePath, // أضف هذا هنا
      isLoggedIn: true, // يعتبر مسجلاً للدخول فور التسجيل
    );
  }

  // دالة مساعدة لإنشاء نسخة من المستخدم مع تحديث بعض الخصائص
  AppUser copyWith({
    String? id,
    String? name,
    String? phone,
    String? joinedDate,
    String? imagePath, // أضف هذا هنا
    bool? isLoggedIn,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      joinedDate: joinedDate ?? this.joinedDate,
      imagePath: imagePath ?? this.imagePath, // أضف هذا هنا
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}
