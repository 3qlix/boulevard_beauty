import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_user.dart';

/// خدمة إدارة المصادقة والمستخدمين
/// تدير تسجيل الدخول والخروج وحفظ بيانات المستخدمين
class AuthService {
  // مفاتيح التخزين
  static const String _registeredUsersKey = 'registered_users';
  static const String _currentUserIdKey = 'current_user_id';
  static const String _appVersionKey = 'app_version';
  static const String _lastLoginKey = 'last_login';

  // معلومات النسخة للتحقق من التوافق
  static const String _currentAppVersion = '1.0.0';

  /// جلب قائمة جميع المستخدمين المسجلين
  static Future<List<AppUser>> _getRegisteredUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // التحقق من توافق النسخة
      await _checkVersionCompatibility(prefs);

      final List<String> userJsonList =
          prefs.getStringList(_registeredUsersKey) ?? [];

      if (userJsonList.isEmpty) {
        developer.log('No registered users found', name: 'AuthService');
        return [];
      }

      final users = <AppUser>[];
      for (final jsonString in userJsonList) {
        try {
          final user = AppUser.fromJson(jsonDecode(jsonString));
          users.add(user);
        } catch (e) {
          developer.log('Error parsing user data: $e', name: 'AuthService');
          // تخطي البيانات التالفة وعدم إيقاف العملية
        }
      }

      developer.log(
        'Loaded ${users.length} registered users',
        name: 'AuthService',
      );
      return users;
    } catch (e) {
      developer.log('Error getting registered users: $e', name: 'AuthService');
      return [];
    }
  }

  /// حفظ قائمة المستخدمين المسجلين
  static Future<bool> _saveRegisteredUsers(List<AppUser> users) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> userJsonList = users
          .map((user) => jsonEncode(user.toJson()))
          .toList();

      final success = await prefs.setStringList(
        _registeredUsersKey,
        userJsonList,
      );

      if (success) {
        developer.log(
          'Saved ${users.length} users successfully',
          name: 'AuthService',
        );
        // حفظ وقت آخر تحديث
        await prefs.setString(_lastLoginKey, DateTime.now().toIso8601String());
      } else {
        developer.log('Failed to save users', name: 'AuthService');
      }

      return success;
    } catch (e) {
      developer.log('Error saving registered users: $e', name: 'AuthService');
      return false;
    }
  }

  /// التحقق من توافق النسخة وتنظيف البيانات القديمة
  static Future<void> _checkVersionCompatibility(
    SharedPreferences prefs,
  ) async {
    try {
      final savedVersion = prefs.getString(_appVersionKey);

      if (savedVersion != _currentAppVersion) {
        developer.log(
          'App version updated from $savedVersion to $_currentAppVersion',
          name: 'AuthService',
        );

        // تنظيف البيانات القديمة عند تحديث التطبيق
        await _cleanupLegacyData(prefs);

        // حفظ النسخة الجديدة
        await prefs.setString(_appVersionKey, _currentAppVersion);
      }
    } catch (e) {
      developer.log(
        'Error checking version compatibility: $e',
        name: 'AuthService',
      );
    }
  }

  /// تنظيف البيانات القديمة
  static Future<void> _cleanupLegacyData(SharedPreferences prefs) async {
    try {
      // حذف البيانات القديمة التي لا تُستخدم بعد الآن
      final keysToRemove = ['userName', 'userPhone', 'userId', 'joinedDate'];

      for (final key in keysToRemove) {
        if (prefs.containsKey(key)) {
          await prefs.remove(key);
          developer.log('Removed legacy key: $key', name: 'AuthService');
        }
      }
    } catch (e) {
      developer.log('Error cleaning up legacy data: $e', name: 'AuthService');
    }
  }

  /// الحصول على المستخدم الحالي المسجل للدخول
  static Future<AppUser?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? currentUserId = prefs.getString(_currentUserIdKey);

      if (currentUserId == null || currentUserId.isEmpty) {
        developer.log('No current user ID found', name: 'AuthService');
        return null;
      }

      final List<AppUser> registeredUsers = await _getRegisteredUsers();
      final user = registeredUsers.firstWhereOrNull(
        (user) => user.id == currentUserId,
      );

      if (user != null) {
        developer.log('Current user found: ${user.name}', name: 'AuthService');
      } else {
        developer.log(
          'Current user not found in registered users',
          name: 'AuthService',
        );
        // تنظيف ID المستخدم الحالي إذا لم يعد موجوداً
        await prefs.remove(_currentUserIdKey);
      }

      return user;
    } catch (e) {
      developer.log('Error getting current user: $e', name: 'AuthService');
      return null;
    }
  }

  /// التحقق من تسجيل الدخول
  static Future<bool> isLoggedIn() async {
    try {
      final AppUser? currentUser = await getCurrentUser();
      final isLoggedIn = currentUser != null && currentUser.isLoggedIn;

      developer.log('User logged in status: $isLoggedIn', name: 'AuthService');
      return isLoggedIn;
    } catch (e) {
      developer.log('Error checking login status: $e', name: 'AuthService');
      return false;
    }
  }

  /// تسجيل مستخدم جديد أو تسجيل دخول مستخدم موجود
  static Future<AuthResult> registerAndLoginUser({
    required String name,
    required String phone,
    String? imagePath,
  }) async {
    try {
      // التحقق من صحة البيانات
      if (name.trim().isEmpty) {
        return AuthResult.failure('الاسم مطلوب');
      }

      if (phone.trim().isEmpty || !_isValidPhone(phone)) {
        return AuthResult.failure('رقم الهاتف غير صحيح');
      }

      final List<AppUser> registeredUsers = await _getRegisteredUsers();
      AppUser? existingUser = registeredUsers.firstWhereOrNull(
        (user) => user.phone == phone,
      );

      if (existingUser != null) {
        // تحديث المستخدم الموجود
        final updatedUser = existingUser.copyWith(
          isLoggedIn: true,
          name: name.trim(),
          imagePath: imagePath,
        );

        final index = registeredUsers.indexOf(existingUser);
        registeredUsers[index] = updatedUser;

        final saveSuccess = await _saveRegisteredUsers(registeredUsers);
        if (!saveSuccess) {
          return AuthResult.failure('فشل في حفظ البيانات');
        }

        await _setCurrentUser(updatedUser.id);
        developer.log(
          'Existing user logged in: ${updatedUser.name}',
          name: 'AuthService',
        );
        return AuthResult.success(updatedUser, 'تم تسجيل الدخول بنجاح');
      } else {
        // إنشاء مستخدم جديد
        final newUser = AppUser.createNewUser(
          name: name.trim(),
          phone: phone.trim(),
          imagePath: imagePath,
        );

        registeredUsers.add(newUser);

        final saveSuccess = await _saveRegisteredUsers(registeredUsers);
        if (!saveSuccess) {
          return AuthResult.failure('فشل في إنشاء الحساب');
        }

        await _setCurrentUser(newUser.id);
        developer.log(
          'New user registered: ${newUser.name}',
          name: 'AuthService',
        );
        return AuthResult.success(newUser, 'تم إنشاء الحساب بنجاح');
      }
    } catch (e) {
      developer.log('Error in registerAndLoginUser: $e', name: 'AuthService');
      return AuthResult.failure('حدث خطأ غير متوقع');
    }
  }

  /// تسجيل دخول مستخدم موجود
  static Future<AuthResult> loginUser(String phone) async {
    try {
      if (phone.trim().isEmpty || !_isValidPhone(phone)) {
        return AuthResult.failure('رقم الهاتف غير صحيح');
      }

      final List<AppUser> registeredUsers = await _getRegisteredUsers();
      AppUser? userToLogin = registeredUsers.firstWhereOrNull(
        (user) => user.phone == phone.trim(),
      );

      if (userToLogin == null) {
        return AuthResult.failure('المستخدم غير موجود');
      }

      final updatedUser = userToLogin.copyWith(isLoggedIn: true);
      final index = registeredUsers.indexOf(userToLogin);
      registeredUsers[index] = updatedUser;

      final saveSuccess = await _saveRegisteredUsers(registeredUsers);
      if (!saveSuccess) {
        return AuthResult.failure('فشل في تسجيل الدخول');
      }

      await _setCurrentUser(updatedUser.id);
      developer.log('User logged in: ${updatedUser.name}', name: 'AuthService');
      return AuthResult.success(updatedUser, 'تم تسجيل الدخول بنجاح');
    } catch (e) {
      developer.log('Error in loginUser: $e', name: 'AuthService');
      return AuthResult.failure('حدث خطأ في تسجيل الدخول');
    }
  }

  /// تحديث بيانات المستخدم الحالي
  static Future<AuthResult> updateCurrentUser({
    String? name,
    String? phone,
    String? imagePath,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? currentUserId = prefs.getString(_currentUserIdKey);

      if (currentUserId == null || currentUserId.isEmpty) {
        return AuthResult.failure('لا يوجد مستخدم مسجل دخول');
      }

      final List<AppUser> registeredUsers = await _getRegisteredUsers();
      final int index = registeredUsers.indexWhere(
        (user) => user.id == currentUserId,
      );

      if (index == -1) {
        return AuthResult.failure('المستخدم غير موجود');
      }

      // التحقق من صحة البيانات الجديدة
      if (name != null && name.trim().isEmpty) {
        return AuthResult.failure('الاسم لا يمكن أن يكون فارغاً');
      }

      if (phone != null && !_isValidPhone(phone)) {
        return AuthResult.failure('رقم الهاتف غير صحيح');
      }

      AppUser currentUser = registeredUsers[index];
      final updatedUser = currentUser.copyWith(
        name: name?.trim(),
        phone: phone?.trim(),
        imagePath: imagePath,
      );

      registeredUsers[index] = updatedUser;

      final saveSuccess = await _saveRegisteredUsers(registeredUsers);
      if (!saveSuccess) {
        return AuthResult.failure('فشل في حفظ التحديثات');
      }

      developer.log(
        'User data updated: ${updatedUser.name}',
        name: 'AuthService',
      );
      return AuthResult.success(updatedUser, 'تم تحديث البيانات بنجاح');
    } catch (e) {
      developer.log('Error updating user: $e', name: 'AuthService');
      return AuthResult.failure('حدث خطأ في التحديث');
    }
  }

  /// تسجيل الخروج
  static Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? currentUserId = prefs.getString(_currentUserIdKey);

      if (currentUserId != null && currentUserId.isNotEmpty) {
        final List<AppUser> registeredUsers = await _getRegisteredUsers();
        final int index = registeredUsers.indexWhere(
          (user) => user.id == currentUserId,
        );

        if (index != -1) {
          final updatedUser = registeredUsers[index].copyWith(
            isLoggedIn: false,
          );
          registeredUsers[index] = updatedUser;
          await _saveRegisteredUsers(registeredUsers);
        }
      }

      // مسح بيانات الجلسة الحالية
      final success = await prefs.remove(_currentUserIdKey);

      // تنظيف البيانات القديمة
      await _cleanupLegacyData(prefs);

      developer.log('User logged out successfully', name: 'AuthService');
      return success;
    } catch (e) {
      developer.log('Error during logout: $e', name: 'AuthService');
      return false;
    }
  }

  /// التحقق من تسجيل رقم الهاتف
  static Future<bool> isPhoneRegistered(String phone) async {
    try {
      if (phone.trim().isEmpty) return false;

      final List<AppUser> registeredUsers = await _getRegisteredUsers();
      return registeredUsers.any((user) => user.phone == phone.trim());
    } catch (e) {
      developer.log(
        'Error checking phone registration: $e',
        name: 'AuthService',
      );
      return false;
    }
  }

  /// الحصول على إحصائيات المستخدمين
  static Future<UserStats> getUserStats() async {
    try {
      final users = await _getRegisteredUsers();
      final loggedInUsers = users.where((user) => user.isLoggedIn).length;

      return UserStats(
        totalUsers: users.length,
        loggedInUsers: loggedInUsers,
        lastUpdate: DateTime.now(),
      );
    } catch (e) {
      developer.log('Error getting user stats: $e', name: 'AuthService');
      return UserStats(
        totalUsers: 0,
        loggedInUsers: 0,
        lastUpdate: DateTime.now(),
      );
    }
  }

  // الدوال المساعدة الخاصة

  /// تعيين المستخدم الحالي
  static Future<bool> _setCurrentUser(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_currentUserIdKey, userId);
    } catch (e) {
      developer.log('Error setting current user: $e', name: 'AuthService');
      return false;
    }
  }

  /// التحقق من صحة رقم الهاتف
  static bool _isValidPhone(String phone) {
    if (phone.trim().isEmpty) return false;

    // نمط رقم الهاتف العراقي (مع أو بدون +964)
    final phoneRegex = RegExp(r'^(\+964|964|0)?[0-9]{10}$');
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[^\d+]'), ''));
  }
}

// نماذج مساعدة

/// نتيجة عمليات المصادقة
class AuthResult {
  final bool isSuccess;
  final String message;
  final AppUser? user;

  const AuthResult._({
    required this.isSuccess,
    required this.message,
    this.user,
  });

  factory AuthResult.success(AppUser user, String message) {
    return AuthResult._(isSuccess: true, message: message, user: user);
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(isSuccess: false, message: message);
  }
}

/// إحصائيات المستخدمين
class UserStats {
  final int totalUsers;
  final int loggedInUsers;
  final DateTime lastUpdate;

  const UserStats({
    required this.totalUsers,
    required this.loggedInUsers,
    required this.lastUpdate,
  });
}

// Extensions مساعدة

/// إضافة دوال مساعدة للقوائم
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}
