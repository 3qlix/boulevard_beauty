import 'package:flutter/material.dart';
import 'dart:io';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../models/product.dart';
import 'favorites_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool isLoggedIn;
  final List<Product> cartItems;
  final Function(Product) addToCart;
  final List<Product> favoriteItems;
  final Function(Product) toggleFavorite;

  const ProfileScreen({
    super.key,
    required this.isLoggedIn,
    required this.cartItems,
    required this.addToCart,
    required this.favoriteItems,
    required this.toggleFavorite,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color _purpleColor = Color(0xFF6B166F);
  static const Color _lightGreyColor = Color(0xFFF5F5F5);

  AppUser? _currentUser;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (widget.isLoggedIn) {
      _currentUser = await AuthService.getCurrentUser();
    } else {
      _currentUser = null;
    }
    if (mounted) {
      setState(() {
        _isLoadingUser = false;
      });
    }
  }

  void _logout() async {
    await AuthService.logout();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم تسجيل الخروج بنجاح!')));
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  Widget _buildLoggedInView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB((255 * 0.08).round(), 0, 0, 0),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: _purpleColor.withAlpha(50),
                      backgroundImage:
                          (_currentUser?.imagePath != null &&
                              _currentUser!.imagePath!.isNotEmpty)
                          ? FileImage(File(_currentUser!.imagePath!))
                                as ImageProvider<Object>?
                          : null,
                      child:
                          (_currentUser?.imagePath == null ||
                              _currentUser!.imagePath!.isEmpty)
                          ? const Icon(
                              Icons.person,
                              color: _purpleColor,
                              size: 50,
                            )
                          : null,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مرحباً ${_currentUser?.name ?? 'زائر'}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: _purpleColor,
                              fontFamily: 'Almarai',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            Icons.person_outline,
                            'الرقم التعريفي:',
                            _currentUser?.id ?? 'N/A',
                          ),
                          _buildInfoRow(
                            Icons.phone_outlined,
                            'رقم التواصل:',
                            '+964 ${_currentUser?.phone ?? 'N/A'}',
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'شاشة تعديل الملف الشخصي قيد الإنشاء',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit, color: Colors.grey),
                              label: const Text(
                                'تعديل الملف الشخصي',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.grey),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('وظيفة المشاركة قيد الإنشاء'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildOptionTile(Icons.location_on_outlined, 'عناوين التوصيل', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('شاشة عناوين التوصيل قيد الإنشاء')),
            );
          }),
          _buildOptionTile(Icons.notifications_outlined, 'إشعاراتج', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('شاشة إشعاراتج قيد الإنشاء')),
            );
          }),
          _buildOptionTile(Icons.shopping_bag_outlined, 'طلباتج', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('شاشة طلباتج قيد الإنشاء')),
            );
          }),
          _buildOptionTile(Icons.card_giftcard_outlined, 'وندر زون', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('شاشة وندر زون قيد الإنشاء')),
            );
          }),
          const Divider(height: 30, thickness: 1, color: Colors.grey),
          _buildOptionTile(Icons.favorite_outline, 'المفضلة', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FavoritesScreen(
                  favoriteProducts: widget.favoriteItems,
                  cartItems: widget.cartItems,
                  addToCart: widget.addToCart,
                  toggleFavorite: widget.toggleFavorite,
                ),
              ),
            );
          }),
          _buildOptionTile(
            Icons.notifications_active_outlined,
            'كولولي من يتوفر',
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('شاشة كولولي من يتوفر قيد الإنشاء'),
                ),
              );
            },
          ),
          _buildOptionTile(Icons.cached_outlined, 'اكدر ابدل؟', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('شاشة اكدر ابدل؟ قيد الإنشاء')),
            );
          }),
          _buildOptionTile(
            Icons.account_balance_wallet_outlined,
            'المحفظة',
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('شاشة المحفظة قيد الإنشاء')),
              );
            },
          ),
          _buildOptionTile(Icons.discount_outlined, 'كوداتج', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('شاشة كوداتج قيد الإنشاء')),
            );
          }),
          const Divider(height: 30, thickness: 1, color: Colors.grey),
          _buildOptionTile(
            Icons.logout,
            'تسجيل الخروج',
            _logout,
            isLogout: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontFamily: 'Almarai',
            ),
          ),
          const SizedBox(width: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              fontFamily: 'Almarai',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Icon(
          icon,
          color: isLogout ? Colors.red : _purpleColor,
          size: 28,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isLogout ? Colors.red : Colors.black87,
            fontFamily: 'Almarai',
          ),
        ),
        trailing: isLogout
            ? null
            : const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLoggedOutView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off_outlined,
              size: 100,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            Text(
              'تسجيل الدخول مطلوب',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _purpleColor,
                fontFamily: 'Almarai',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'يرجى تسجيل الدخول لعرض ملفك الشخصي وإدارة إعدادات حسابك.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontFamily: 'Almarai',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _purpleColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              child: const Text(
                'تسجيل الدخول',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        color: _lightGreyColor,
        child: _isLoadingUser
            ? const Center(
                child: CircularProgressIndicator(color: _purpleColor),
              )
            : (widget.isLoggedIn
                  ? _buildLoggedInView()
                  : _buildLoggedOutView()),
      ),
    );
  }
}
