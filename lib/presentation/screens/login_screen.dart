import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/toast_notification.dart';
import 'register_screen.dart';
import 'email_sent_screen.dart';
import 'forgot_password_screen.dart';
import '../app_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  /// State untuk menampilkan banner "belum diverifikasi"
  bool _showVerificationBanner = false;
  String _unverifiedEmail = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    // Reset verification banner saat login baru
    setState(() => _showVerificationBanner = false);

    try {
      final authProvider = context.read<AuthProvider>();
      final result = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        ToastHelper.showSuccess(
          context,
          result['message'] ?? 'Login berhasil! Selamat datang 👋',
          title: 'Login Berhasil',
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AppShell()),
        );
      } else if (result['needsVerification'] == true) {
        // Email belum diverifikasi → tampilkan banner & toast warning
        final errorMsg = result['message'] ?? authProvider.errorMessage;
        ToastHelper.showWarning(
          context,
          errorMsg.isNotEmpty
              ? errorMsg
              : 'Akun Anda belum diverifikasi. Silakan cek email Anda atau kirim ulang.',
          title: 'Akun Belum Terverifikasi',
        );

        setState(() {
          _showVerificationBanner = true;
          _unverifiedEmail = result['email'] ?? _emailController.text.trim();
        });
      } else {
        // Error biasa (salah password, user tidak terdaftar, server down, dll)
        final errorMsg = result['message'] ?? authProvider.errorMessage;
        ToastHelper.showError(
          context,
          errorMsg.isNotEmpty
              ? errorMsg
              : 'Email atau password salah. Silakan periksa kembali.',
          title: 'Gagal Masuk',
        );
      }
    } catch (e) {
      if (!mounted) return;
      ToastHelper.showError(
        context,
        'Terjadi kesalahan saat memproses login: ${e.toString()}',
        title: 'Error',
      );
    }
  }

  void _navigateToResendVerification() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EmailSentScreen(
          email: _unverifiedEmail,
          fromLogin: true,
        ),
      ),
    );
  }

  /// Handle Google OAuth login — redirect ke BE endpoint
  Future<void> _handleGoogleLogin() async {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api/v1';
    final googleLoginUrl = '$baseUrl/auth/google/login';

    final uri = Uri.parse(googleLoginUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ToastHelper.showError(
          context,
          'Tidak dapat membuka halaman login Google.',
          title: 'Error',
        );
      }
    } catch (e) {
      if (!mounted) return;
      ToastHelper.showError(
        context,
        'Gagal membuka Google Login: ${e.toString()}',
        title: 'Error',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient circles
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                color: AppColors.primaryAction.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isWide ? 440 : double.infinity),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    // Logo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primaryAction.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 40,
                        color: AppColors.primaryAction,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'GoCatat',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Masuk untuk melanjutkan pencatatan keuanganmu',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Verification Banner (muncul saat login gagal karena belum verifikasi)
                    if (_showVerificationBanner) _buildVerificationBanner(),

                    const SizedBox(height: 8),

                    // Glass Form Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.6),
                              width: 1.5,
                            ),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(Icons.email_outlined),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Email tidak boleh kosong';
                                    }
                                    if (!value.contains('@')) {
                                      return 'Format email tidak valid';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                      ),
                                      onPressed: () {
                                        setState(() => _obscurePassword = !_obscurePassword);
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password tidak boleh kosong';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),

                                // Lupa Password link
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                                      );
                                    },
                                    child: const Text(
                                      'Lupa Password?',
                                      style: TextStyle(
                                        color: AppColors.primaryAction,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Login Button
                                Consumer<AuthProvider>(
                                  builder: (context, auth, child) {
                                    return ElevatedButton(
                                      onPressed: auth.isLoading ? null : _handleLogin,
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 18),
                                      ),
                                      child: auth.isLoading
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text(
                                              'Masuk',
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                            ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 20),

                                // Divider "atau"
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: AppColors.textSecondary.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        'atau',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: AppColors.textSecondary.withValues(alpha: 0.3),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                // Google OAuth Login Button
                                OutlinedButton.icon(
                                  onPressed: _handleGoogleLogin,
                                  icon: Image.network(
                                    'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                                    width: 20,
                                    height: 20,
                                    errorBuilder: (context, error, stackTrace) => const Icon(
                                      Icons.g_mobiledata_rounded,
                                      size: 24,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  label: const Text(
                                    'Masuk dengan Google',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    side: BorderSide(
                                      color: AppColors.textSecondary.withValues(alpha: 0.3),
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Belum punya akun? ',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const RegisterScreen()),
                            );
                          },
                          child: const Text(
                            'Daftar Sekarang',
                            style: TextStyle(
                              color: AppColors.primaryAction,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Banner notifikasi yang muncul saat login gagal karena email belum diverifikasi
  Widget _buildVerificationBanner() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryAction.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryAction.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryAction.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_rounded,
                    color: AppColors.primaryAction,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Email Belum Diverifikasi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Akun kamu sudah terdaftar, silakan verifikasi email terlebih dahulu.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                // Close button
                GestureDetector(
                  onTap: () => setState(() => _showVerificationBanner = false),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Resend verification button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _navigateToResendVerification,
                icon: const Icon(Icons.send_rounded, size: 16),
                label: const Text(
                  'Kirim Ulang Email Verifikasi',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: AppColors.primaryAction,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
