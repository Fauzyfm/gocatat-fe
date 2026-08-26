import 'dart:ui';
import 'package:flutter/material.dart';

/// Toast notification modern dengan tampilan Glassmorphism dan warna tematik.
/// Mendukung eksekusi via ScaffoldMessenger global key maupun BuildContext.
class ToastHelper {
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// Tampilkan notifikasi Berhasil (Hijau)
  static void showSuccess(BuildContext? context, String message, {String? title}) {
    _show(
      context: context,
      message: message,
      title: title ?? 'Berhasil',
      backgroundColor: const Color(0xFF10B981),
      icon: Icons.check_circle_rounded,
    );
  }

  /// Tampilkan notifikasi Error (Merah / Coral)
  static void showError(BuildContext? context, String message, {String? title}) {
    _show(
      context: context,
      message: message.isNotEmpty ? message : 'Terjadi kesalahan.',
      title: title ?? 'Gagal',
      backgroundColor: const Color(0xFFEF4444),
      icon: Icons.error_rounded,
    );
  }

  /// Tampilkan notifikasi Peringatan (Kuning / Oranye)
  static void showWarning(BuildContext? context, String message, {String? title}) {
    _show(
      context: context,
      message: message,
      title: title ?? 'Perhatian',
      backgroundColor: const Color(0xFFF59E0B),
      icon: Icons.warning_rounded,
    );
  }

  /// Tampilkan notifikasi Info (Biru)
  static void showInfo(BuildContext? context, String message, {String? title}) {
    _show(
      context: context,
      message: message,
      title: title ?? 'Info',
      backgroundColor: const Color(0xFF3B82F6),
      icon: Icons.info_rounded,
    );
  }

  static void _show({
    required BuildContext? context,
    required String message,
    required String title,
    required Color backgroundColor,
    required IconData icon,
  }) {
    final messenger = (context != null && context.mounted)
        ? ScaffoldMessenger.maybeOf(context) ?? messengerKey.currentState
        : messengerKey.currentState;

    if (messenger == null) return;

    messenger.removeCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        duration: const Duration(seconds: 4),
        padding: EdgeInsets.zero,
        content: _ToastCard(
          title: title,
          message: message,
          backgroundColor: backgroundColor,
          icon: icon,
          onDismiss: () => messenger.hideCurrentSnackBar(),
        ),
      ),
    );
  }
}

class _ToastCard extends StatelessWidget {
  final String title;
  final String message;
  final Color backgroundColor;
  final IconData icon;
  final VoidCallback onDismiss;

  const _ToastCard({
    required this.title,
    required this.message,
    required this.backgroundColor,
    required this.icon,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF222831).withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: backgroundColor.withValues(alpha: 0.4),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: backgroundColor.withValues(alpha: 0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: backgroundColor.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: backgroundColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: backgroundColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          message,
                          style: const TextStyle(
                            color: Color(0xFFE2E8F0),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onDismiss,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF94A3B8),
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
