import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/toast_notification.dart';
import 'login_screen.dart';

/// Halaman change password yang diakses via URL /change-password?token=xxx
/// Token didapat dari email reset password
class ChangePasswordScreen extends StatefulWidget {
  final String token;

  const ChangePasswordScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // State result (setelah submit)
  bool _isSubmitted = false;
  bool _isSuccess = false;
  String _resultMessage = '';

  // Animations
  late AnimationController _iconController;
  late Animation<double> _iconScale;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _iconScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _iconController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _playResultAnimation() {
    _iconController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _fadeController.forward();
    });
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.token.isEmpty) {
      ToastHelper.showError(
        context,
        'Token tidak ditemukan. Silakan request ulang link reset password.',
        title: 'Token Tidak Valid',
      );
      return;
    }

    try {
      final authProvider = context.read<AuthProvider>();
      final result = await authProvider.changePassword(
        widget.token,
        _newPasswordController.text,
        _confirmPasswordController.text,
      );

      if (!mounted) return;

      setState(() {
        _isSubmitted = true;
        _isSuccess = result['success'] == true;
        _resultMessage = result['message'] ?? '';
      });

      _playResultAnimation();

      if (_isSuccess) {
        ToastHelper.showSuccess(
          context,
          result['message'] ?? 'Password berhasil diubah!',
          title: 'Berhasil',
        );
      }
    } catch (e) {
      if (!mounted) return;
      ToastHelper.showError(
        context,
        'Terjadi kesalahan: ${e.toString()}',
        title: 'Error',
      );
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800;

    return Scaffold(
      body: Stack(
        children: [
          // Background circles
          Positioned(
            top: -100,
            right: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: (_isSubmitted && _isSuccess)
                    ? AppColors.income.withOpacity(0.10)
                    : AppColors.primaryAction.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            left: -80,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isWide ? 460 : double.infinity),
                child: _isSubmitted ? _buildResultState() : _buildFormState(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Form input password baru
  Widget _buildFormState() {
    // Cek token kosong
    if (widget.token.isEmpty) {
      return _buildTokenEmptyState();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),

        // Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primaryAction.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.lock_open_rounded,
            size: 40,
            color: AppColors.primaryAction,
          ),
        ),
        const SizedBox(height: 24),

        const Text(
          'Buat Password Baru',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Masukkan password baru untuk akun kamu. Minimal 8 karakter.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 36),

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
                      controller: _newPasswordController,
                      obscureText: _obscureNew,
                      decoration: InputDecoration(
                        labelText: 'Password Baru',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNew
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() => _obscureNew = !_obscureNew);
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password baru tidak boleh kosong';
                        }
                        if (value.length < 8) {
                          return 'Password minimal 8 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'Konfirmasi Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() => _obscureConfirm = !_obscureConfirm);
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Konfirmasi password tidak boleh kosong';
                        }
                        if (value != _newPasswordController.text) {
                          return 'Konfirmasi password tidak cocok';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),

                    // Submit Button
                    Consumer<AuthProvider>(
                      builder: (context, auth, child) {
                        return ElevatedButton(
                          onPressed: auth.isLoading ? null : _handleChangePassword,
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
                                  'Ubah Password',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 28),

        // Back to login
        GestureDetector(
          onTap: _navigateToLogin,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_back_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                'Kembali ke Halaman Login',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  /// State ketika token kosong
  Widget _buildTokenEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),

        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primaryAction.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Icon(
            Icons.link_off_rounded,
            size: 50,
            color: AppColors.primaryAction,
          ),
        ),
        const SizedBox(height: 32),

        const Text(
          'Token Tidak Ditemukan',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Link reset password tidak valid atau sudah kadaluarsa. Silakan request ulang dari halaman lupa password.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 36),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _navigateToLogin,
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
            label: const Text(
              'Kembali ke Login',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  /// Result state setelah submit (sukses atau gagal)
  Widget _buildResultState() {
    final resultColor = _isSuccess ? AppColors.income : AppColors.primaryAction;
    final resultIcon = _isSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),

        // Animated icon
        AnimatedBuilder(
          animation: _iconController,
          builder: (context, child) {
            return Transform.scale(
              scale: _iconScale.value,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: resultColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: resultColor.withOpacity(0.2),
                      blurRadius: 25,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  resultIcon,
                  size: 50,
                  color: resultColor,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),

        // Message with animation
        SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                Text(
                  _isSuccess
                      ? 'Password Berhasil Diubah! 🎉'
                      : 'Gagal Mengubah Password',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  _resultMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 36),

                // Glass card with action
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.6),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          if (_isSuccess) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.income.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: AppColors.income,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Password berhasil diubah. Silakan masuk dengan password baru kamu.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.income,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _navigateToLogin,
                                icon: const Icon(Icons.login_rounded, size: 20),
                                label: const Text(
                                  'Masuk ke GoCatat',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primaryAction.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    color: AppColors.primaryAction,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _resultMessage.isNotEmpty
                                          ? _resultMessage
                                          : 'Token mungkin sudah kadaluarsa. Silakan request ulang link reset password.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.primaryAction,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // Reset state agar bisa coba lagi
                                  setState(() {
                                    _isSubmitted = false;
                                    _isSuccess = false;
                                    _resultMessage = '';
                                  });
                                  _iconController.reset();
                                  _fadeController.reset();
                                },
                                icon: const Icon(Icons.refresh_rounded, size: 20),
                                label: const Text(
                                  'Coba Lagi',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _navigateToLogin,
                                icon: const Icon(Icons.arrow_back_rounded, size: 20),
                                label: const Text(
                                  'Kembali ke Login',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  foregroundColor: AppColors.primaryAction,
                                  side: const BorderSide(
                                    color: AppColors.primaryAction,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
