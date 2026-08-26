import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'email_sent_screen.dart';

/// Halaman verifikasi email yang menangkap token dari URL
/// URL: /verify?token=xxx
class VerifyEmailScreen extends StatefulWidget {
  final String token;

  const VerifyEmailScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  bool _isSuccess = false;
  String _message = '';

  late AnimationController _iconController;
  late Animation<double> _iconScale;
  late Animation<double> _iconRotation;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Icon animation (bounce + scale)
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _iconScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: Curves.elasticOut,
      ),
    );
    _iconRotation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: Curves.easeOut,
      ),
    );

    // Fade in content
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

    // Auto-verify when screen loads
    _verifyEmail();
  }

  @override
  void dispose() {
    _iconController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _verifyEmail() async {
    if (widget.token.isEmpty) {
      setState(() {
        _isLoading = false;
        _isSuccess = false;
        _message = 'Token verifikasi tidak ditemukan.';
      });
      _playResultAnimation();
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final result = await authProvider.verifyEmail(widget.token);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _isSuccess = result['success'] == true;
      _message = result['message'] ?? '';
    });

    _playResultAnimation();
  }

  void _playResultAnimation() {
    _iconController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _fadeController.forward();
    });
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
          // Background decorative circles
          Positioned(
            top: -100,
            right: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: _isSuccess
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
                child: _isLoading ? _buildLoadingState() : _buildResultState(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Loading spinner
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primaryAction.withOpacity(0.08),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Center(
            child: SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(
                strokeWidth: 3.5,
                color: AppColors.primaryAction,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Memverifikasi Email...',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Mohon tunggu sebentar, kami sedang memproses verifikasi email kamu.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildResultState() {
    final resultColor =
        _isSuccess ? AppColors.income : AppColors.primaryAction;
    final resultIcon = _isSuccess
        ? Icons.verified_rounded
        : Icons.error_outline_rounded;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),

        // Animated result icon
        AnimatedBuilder(
          animation: _iconController,
          builder: (context, child) {
            return Transform.scale(
              scale: _iconScale.value,
              child: Transform.rotate(
                angle: _iconRotation.value,
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
              ),
            );
          },
        ),
        const SizedBox(height: 32),

        // Title & message with slide/fade animation
        SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                Text(
                  _isSuccess
                      ? 'Email Berhasil Diverifikasi! 🎉'
                      : 'Verifikasi Gagal',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  _message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 36),

                // Glass card with action buttons
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
                            // Pesan sukses tambahan
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
                                      'Akun kamu sudah aktif. Silakan masuk untuk mulai mencatat keuanganmu.',
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
                            // Login button
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                          ] else ...[
                            // Pesan error
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
                                      'Token mungkin sudah kadaluarsa atau tidak valid. Silakan coba kirim ulang email verifikasi.',
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
                            // Login button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _navigateToLogin,
                                icon: const Icon(Icons.arrow_back_rounded, size: 20),
                                label: const Text(
                                  'Kembali ke Login',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
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
