import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _showEmailForm = false;
  bool _isRegisterMode = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF7C3AED), // Purple
              Color(0xFFDB2777), // Pink
              Color(0xFFF97316), // Orange
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    48,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 10),

                  // Logo/Icon với animation shimmer effect
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                        BoxShadow(
                          color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                          blurRadius: 40,
                          spreadRadius: -10,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
                      ).createShader(bounds),
                      child: const Icon(
                        Icons.checkroom,
                        size: 45,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // App name
                  const Text(
                    'AI Personal Stylist',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Stylist cá nhân thông minh\ngiúp bạn phối đồ mỗi ngày',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // Features - ẩn khi mở form email
                  if (!_showEmailForm) ...[
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        _buildFeature(Icons.camera_alt, 'Số hóa tủ đồ bằng AI'),
                        const SizedBox(height: 10),
                        _buildFeature(
                          Icons.auto_awesome,
                          'Gợi ý outfit thông minh',
                        ),
                        const SizedBox(height: 10),
                        _buildFeature(Icons.palette, 'Chấm điểm hợp màu'),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Login buttons
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      if (auth.isLoading) {
                        return const CircularProgressIndicator(
                          color: Colors.white,
                        );
                      }

                      // Show email form
                      if (_showEmailForm) {
                        return _buildEmailForm(auth);
                      }

                      return Column(
                        children: [
                          // Email/Password Sign In
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  setState(() => _showEmailForm = true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppTheme.textPrimary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: const Icon(Icons.email_outlined),
                              label: const Text(
                                'Đăng nhập với Email',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Google Sign In
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _signInWithGoogle(auth),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: Image.network(
                                'https://www.google.com/favicon.ico',
                                width: 24,
                                height: 24,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.g_mobiledata),
                              ),
                              label: const Text(
                                'Đăng nhập với Google',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Anonymous/Demo login
                          TextButton(
                            onPressed: () => _signInAnonymously(auth),
                            child: Text(
                              'Dùng thử không cần đăng nhập',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _signInWithGoogle(AuthProvider auth) async {
    final success = await auth.signInWithGoogle();
    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (auth.errorMessage != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(auth.errorMessage!)));
    }
  }

  Future<void> _signInAnonymously(AuthProvider auth) async {
    final success = await auth.signInAnonymously();
    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (auth.errorMessage != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(auth.errorMessage!)));
    }
  }

  Widget _buildEmailForm(AuthProvider auth) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                IconButton(
                  onPressed: () => setState(() {
                    _showEmailForm = false;
                    _isRegisterMode = false;
                    _emailController.clear();
                    _passwordController.clear();
                  }),
                  icon: const Icon(Icons.arrow_back),
                ),
                Expanded(
                  child: Text(
                    _isRegisterMode ? 'Đăng ký' : 'Đăng nhập',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48), // Balance
              ],
            ),

            const SizedBox(height: 20),

            // Email field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập email';
                }
                if (!value.contains('@')) {
                  return 'Email không hợp lệ';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Password field
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Mật khẩu',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mật khẩu';
                }
                if (value.length < 6) {
                  return 'Mật khẩu tối thiểu 6 ký tự';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _submitEmailForm(auth),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _isRegisterMode ? 'Đăng ký' : 'Đăng nhập',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Toggle mode
            TextButton(
              onPressed: () =>
                  setState(() => _isRegisterMode = !_isRegisterMode),
              child: Text(
                _isRegisterMode
                    ? 'Đã có tài khoản? Đăng nhập'
                    : 'Chưa có tài khoản? Đăng ký',
                style: const TextStyle(color: AppTheme.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitEmailForm(AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    bool success;
    if (_isRegisterMode) {
      success = await auth.registerWithEmail(email, password);
    } else {
      success = await auth.signInWithEmail(email, password);
    }

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (auth.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage!),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
}
