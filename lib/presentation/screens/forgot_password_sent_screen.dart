import 'dart:async';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/toast_notification.dart';
import 'login_screen.dart';

/// Halaman konfirmasi email reset password telah dikirim.
/// Menampilkan countdown 5 menit untuk resend.
class ForgotPasswordSentScreen extends StatefulWidget {
  final String email;

  const ForgotPasswordSentScreen({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<ForgotPasswordSentScreen> createState() => _ForgotPasswordSentScreenState();
}

class _ForgotPasswordSentScreenState extends State<ForgotPasswordSentScreen>
    with TickerProviderStateMixin {
  static const int _cooldownSeconds = 300; // 5 menit

  Timer? _timer;
  int _remainingSeconds = 0;
  bool _canResend = false;
  bool _isResending = false;

  // Animasi ikon
  late AnimationController _iconController;
  late Animation<double> _iconBounce;
  late Animation<double> _iconGlow;

  // Animasi pulse timer
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Icon bounce animation
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _iconBounce = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeInOut),
    );
    _iconGlow = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeInOut),
    );
    _iconController.repeat(reverse: true);

    // Pulse animation for timer
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Mulai countdown langsung (email sudah dikirim dari halaman sebelumnya)
    _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _iconController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startCooldown() {
    setState(() {
      _remainingSeconds = _cooldownSeconds;
      _canResend = false;
    });
    _pulseController.repeat(reverse: true);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _canResend = true;
          timer.cancel();
          _pulseController.stop();
          _pulseController.reset();
        }
      });
    });
  }

  String get _formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get _timerProgress {
    if (_remainingSeconds <= 0) return 0;
    return _remainingSeconds / _cooldownSeconds;
  }

  Future<void> _handleResend() async {
    if (!_canResend || _isResending) return;

    setState(() => _isResending = true);

    final authProvider = context.read<AuthProvider>();
    final result = await authProvider.requestChangePassword(widget.email);

    if (!mounted) return;

    setState(() => _isResending = false);

    if (result['success'] == true) {
      ToastHelper.showSuccess(
          context, result['message'] ?? 'Email reset password berhasil dikirim ulang!');
      _startCooldown();
    } else {
      ToastHelper.showError(
          context, result['message'] ?? 'Gagal mengirim ulang email reset password.');
    }
  }

  Future<void> _openGmail() async {
    final uri = Uri.parse('https://mail.google.com');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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
          // Background decorative circles
          Positioned(
            top: -100,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                color: AppColors.primaryAction.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -140,
            right: -100,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.3,
            right: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryAction.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isWide ? 480 : double.infinity),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),

                    // Animated icon
                    AnimatedBuilder(
                      animation: _iconController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _iconBounce.value),
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.primaryAction.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryAction
                                      .withOpacity(_iconGlow.value * 0.3),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.mark_email_unread_rounded,
                              size: 50,
                              color: AppColors.primaryAction,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // Title
                    const Text(
                      'Cek Email Kamu! 📩',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // Subtitle
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Kami telah mengirim link untuk mengatur ulang password ke email ',
                          ),
                          TextSpan(
                            text: widget.email,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const TextSpan(
                            text: '. Klik link tersebut untuk membuat password baru.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Glass Card with Timer & Actions
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
                              // Countdown timer
                              if (!_canResend) ...[
                                _buildCountdownTimer(),
                                const SizedBox(height: 8),
                                Text(
                                  'Kirim ulang dalam',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formattedTime,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],

                              // Resend button
                              SizedBox(
                                width: double.infinity,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  child: ElevatedButton.icon(
                                    onPressed: _canResend && !_isResending
                                        ? _handleResend
                                        : null,
                                    icon: _isResending
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Icon(
                                            _canResend
                                                ? Icons.send_rounded
                                                : Icons.timer_outlined,
                                            size: 20,
                                          ),
                                    label: Text(
                                      _isResending
                                          ? 'Mengirim...'
                                          : _canResend
                                              ? 'Kirim Ulang Link Reset'
                                              : 'Tunggu $_formattedTime',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      backgroundColor: _canResend
                                          ? AppColors.primaryAction
                                          : AppColors.textSecondary.withOpacity(0.4),
                                      disabledBackgroundColor:
                                          AppColors.textSecondary.withOpacity(0.3),
                                      disabledForegroundColor:
                                          AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Open Gmail button
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: _openGmail,
                                  icon: const Icon(
                                    Icons.open_in_new_rounded,
                                    size: 18,
                                    color: AppColors.primaryAction,
                                  ),
                                  label: const Text(
                                    'Buka Gmail',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryAction,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Countdown timer dengan circular progress indicator
  Widget _buildCountdownTimer() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background ring
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 6,
                    backgroundColor: Colors.transparent,
                    color: AppColors.textSecondary.withOpacity(0.15),
                  ),
                ),
                // Progress ring
                SizedBox(
                  width: 120,
                  height: 120,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: _timerProgress, end: _timerProgress),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, value, child) {
                      return CustomPaint(
                        painter: _GradientCircularProgressPainter(
                          progress: value,
                          strokeWidth: 6,
                          gradientColors: const [
                            AppColors.primaryAction,
                            Color(0xFFFF8A65),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Center icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryAction.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.hourglass_top_rounded,
                    color: AppColors.primaryAction,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Custom painter for gradient circular progress
class _GradientCircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final List<Color> gradientColors;

  _GradientCircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: 3 * math.pi / 2,
      colors: gradientColors,
    );

    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _GradientCircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
