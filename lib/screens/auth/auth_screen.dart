import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../home/home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _handleSubmit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final email = _emailController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showToast('لطفاً نام کاربری و رمز عبور را وارد کنید', isError: true);
      return;
    }

    if (!_isLogin && email.isEmpty) {
      _showToast('لطفاً آدرس ایمیل را وارد کنید', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final endpoint = _isLogin ? ApiEndpoints.login : ApiEndpoints.register;
      final body = <String, dynamic>{
        'username': username,
        'password': password,
      };
      if (!_isLogin) {
        body['email'] = email;
      }

      final res = await ApiClient.post(endpoint, body: body);

      if (res['success'] == true && res['token'] != null) {
        await ApiClient.setToken(res['token']);
        final userId = res['user']?['id'] ?? 0;
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomeScreen(currentUserId: userId)),
        );
      } else {
        _showToast(res['error'] ?? 'خطا در احراز هویت', isError: true);
      }
    } catch (e) {
      _showToast(e.toString().replaceAll('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.right),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // Ambient Glow Orb 1 (Top Right Purple)
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.brandPurple.withOpacity(0.18),
                ),
              ),
            ),

            // Ambient Glow Orb 2 (Bottom Left Blue)
            Positioned(
              bottom: -60,
              left: -60,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.brandBlue.withOpacity(0.18),
                ),
              ),
            ),

            // Main Content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 440),
                    decoration: BoxDecoration(
                      color: const Color(0xCC12121C),
                      borderRadius: BorderRadius.circular(36),
                      border: Border.all(color: const Color(0x40C084FC), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.65),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                        BoxShadow(
                          color: AppColors.brandPurple.withOpacity(0.12),
                          blurRadius: 35,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 34),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo with Glow
                        Container(
                          width: 78,
                          height: 78,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.primaryGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.brandPurple.withOpacity(0.4),
                                blurRadius: 25,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text('💜', style: TextStyle(fontSize: 36)),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Title with Gradient
                        ShaderMask(
                          shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                          child: const Text(
                            'لانگ‌دیستنس',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'روابط واقعی، فراتر از فاصله‌ها',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0x99FFFFFF),
                          ),
                        ),

                        const SizedBox(height: 26),

                        // Tab Switcher Pill
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.tabsHeaderBg,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: const Color(0x0DFFFFFF), width: 1),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildSegmentButton(
                                  title: 'ورود به حساب',
                                  isActive: _isLogin,
                                  onTap: () => setState(() => _isLogin = true),
                                ),
                              ),
                              Expanded(
                                child: _buildSegmentButton(
                                  title: 'ثبت‌نام جدید',
                                  isActive: !_isLogin,
                                  onTap: () => setState(() => _isLogin = false),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 22),

                        // Username Input
                        TextField(
                          controller: _usernameController,
                          textDirection: TextDirection.ltr,
                          decoration: InputDecoration(
                            hintText: 'نام کاربری (انگلیسی)',
                            prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.brandPurple, size: 20),
                            filled: true,
                            fillColor: const Color(0x0DFFFFFF),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        if (!_isLogin) ...[
                          const SizedBox(height: 14),
                          // Email Input
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textDirection: TextDirection.ltr,
                            decoration: InputDecoration(
                              hintText: 'ایمیل (example@gmail.com)',
                              prefixIcon: const Icon(Icons.email_outlined, color: AppColors.brandPurple, size: 20),
                              filled: true,
                              fillColor: const Color(0x0DFFFFFF),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(32),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 14),

                        // Password Input
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textDirection: TextDirection.ltr,
                          decoration: InputDecoration(
                            hintText: 'رمز عبور (حداقل ۴ کاراکتر)',
                            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.brandPurple, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: const Color(0x80FFFFFF),
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            filled: true,
                            fillColor: const Color(0x0DFFFFFF),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Glow Submit Button (.btn-glow)
                        Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.brandBlue.withOpacity(0.35),
                                blurRadius: 18,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : Text(
                                    _isLogin ? 'ورود به حساب' : 'عضویت در لانگ‌دیستنس',
                                    style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Switch Link
                        GestureDetector(
                          onTap: () => setState(() => _isLogin = !_isLogin),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 13, color: Color(0x80FFFFFF)),
                              children: [
                                TextSpan(text: _isLogin ? 'حساب کاربری نداری؟ ' : 'قبلاً حساب داشتی؟ '),
                                TextSpan(
                                  text: _isLogin ? 'ثبت‌نام کن' : 'وارد شو',
                                  style: const TextStyle(
                                    color: AppColors.brandPurple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentButton({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          gradient: isActive ? AppColors.tabActiveGradient : null,
          color: isActive ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: isActive ? AppColors.tabActiveBorder : Colors.transparent,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isActive ? AppColors.brandPurple : const Color(0x80FFFFFF),
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
