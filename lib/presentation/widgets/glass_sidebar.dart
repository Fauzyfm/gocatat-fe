import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'interactive_scale.dart';

/// Sidebar navigasi dengan efek glassmorphism + Toggle expand/collapse & hover effect
class GlassSidebar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isExpanded;
  final VoidCallback? onToggleExpand;

  const GlassSidebar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.isExpanded,
    this.onToggleExpand,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = isExpanded ? 250.0 : 76.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      width: width,
      height: double.infinity,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              border: Border(
                right: BorderSide(color: AppColors.textSecondary.withOpacity(0.15)),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Header Logo & Toggle Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: isExpanded
                          ? MainAxisAlignment.spaceBetween
                          : MainAxisAlignment.center,
                      children: [
                        if (isExpanded) ...[
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryAction.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet_rounded,
                                  color: AppColors.primaryAction,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'GoCatat',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (onToggleExpand != null)
                          InteractiveScale(
                            onTap: onToggleExpand,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.textSecondary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isExpanded
                                    ? Icons.menu_open_rounded
                                    : Icons.menu_rounded,
                                color: AppColors.textPrimary,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Nav Items
                  _buildNavItem(Icons.home_rounded, 'Dashboard', 0),
                  _buildNavItem(Icons.account_balance_wallet_rounded, 'Dompet', 1),
                  _buildNavItem(Icons.receipt_long_rounded, 'Transaksi', 2),
                  _buildNavItem(Icons.person_rounded, 'Profil', 3),

                  const Spacer(),
                  // Footer
                  if (isExpanded)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'v1.0.0',
                        style: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = currentIndex == index;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isExpanded ? 14 : 10,
        vertical: 4,
      ),
      child: InteractiveScale(
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: isExpanded ? 16 : 0,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primaryAction.withOpacity(0.14)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: isActive
                ? Border.all(color: AppColors.primaryAction.withOpacity(0.3))
                : null,
          ),
          child: Row(
            mainAxisAlignment:
                isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive ? AppColors.primaryAction : AppColors.textSecondary,
                size: 22,
              ),
              if (isExpanded) ...[
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? AppColors.primaryAction : AppColors.textPrimary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
