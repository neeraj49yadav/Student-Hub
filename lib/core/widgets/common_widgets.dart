import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../services/anti_adblock_service.dart';
import '../../features/premium/premium_screen.dart';

/// Interactive, rounded surface card with Material 3 depth & optional gradient
class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final Border? border;
  final Gradient? gradient;
  final double borderRadius;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.border,
    this.gradient,
    this.borderRadius = 18,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = color ?? (isDark ? AppColors.darkSurface : AppColors.lightSurface);

    return Container(
      decoration: BoxDecoration(
        color: gradient == null ? cardColor : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ??
            Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
              width: 1,
            ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

enum GooglePlayAdFormat {
  standardBanner,
  nativeCard,
  compactInline,
}

/// Google Play Console & Google AdMob Policy Compliant Ad Container
/// Complies with:
/// 1. Prominent "AD" / "SPONSORED" badge distinction.
/// 2. Separation from functional buttons to prevent accidental clicks.
/// 3. Zero intrusion during active study workflows (Pomodoro/typing).
/// 4. Complete suppression for Pro subscribers ($isPro == true).
class GooglePlayCompliantAdBanner extends StatelessWidget {
  final bool isPro;
  final GooglePlayAdFormat format;
  final String? customTag;
  final VoidCallback? onUpgradeTap;
  final StorageService? storage;

  const GooglePlayCompliantAdBanner({
    super.key,
    required this.isPro,
    this.format = GooglePlayAdFormat.standardBanner,
    this.customTag,
    this.onUpgradeTap,
    this.storage,
  });

  void _handleUpgrade(BuildContext context) {
    if (onUpgradeTap != null) {
      onUpgradeTap!();
      return;
    }
    final targetStorage = storage ?? StorageService.maybeInstance;
    if (targetStorage != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PremiumScreen(storage: targetStorage),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Plans & Upgrade • Student Pro ⭐'),
          content: const Text(
            'Support independent student app development and enjoy a 100% ad-free experience across all calculators and study tools for just ₹39 (one-time).',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Later'),
            ),
          ],
        ),
      );
    }
  }

  void _showAntiAdBlockDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.shield_outlined, color: AppColors.primary, size: 24),
            const SizedBox(width: 8),
            const Expanded(child: Text('Anti-AdBlock Shield Active')),
          ],
        ),
        content: const Text(
          'We detected an active Ad Blocker, DNS sinkhole, or Private DNS.\n\n'
          'Student Utility Hub is 100% free offline software supported by verified student sponsors. '
          'Our resilient in-app ad engine continues to display student partner campaigns in the free tier.\n\n'
          'To enjoy a 100% ad-free offline experience across the entire app, you can upgrade to the Remove Ads pass for ₹39.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Free with Ads'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _handleUpgrade(context);
            },
            child: const Text('Remove Ads (₹39)'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isPro) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final antiAdBlock = AntiAdBlockService.instance;
    final campaign = antiAdBlock.activeCampaign;
    final isBlocked = antiAdBlock.isAdBlockerDetected;

    if (format == GooglePlayAdFormat.nativeCard) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131D31) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isBlocked
                ? Colors.amber.shade700.withValues(alpha: 0.5)
                : (isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08)),
            width: isBlocked ? 1.5 : 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade700,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        campaign.badgeText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      campaign.sponsor,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isBlocked) ...[
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _showAntiAdBlockDialog(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: Colors.deepOrange.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.deepOrange.withValues(alpha: 0.4)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shield, size: 9, color: Colors.deepOrange),
                              SizedBox(width: 3),
                              Text(
                                'ANTI-ADBLOCK',
                                style: TextStyle(color: Colors.deepOrange, fontSize: 8.5, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                GestureDetector(
                  onTap: () => _handleUpgrade(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Remove Ads',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () => _handleUpgrade(context),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(campaign.iconEmoji, style: const TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            campaign.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            campaign.description,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Default Standard Compliant Banner (Safe margin, clearly labeled, anti-adblock resilient)
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131D31) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isBlocked
              ? Colors.amber.shade700.withValues(alpha: 0.4)
              : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.amber.shade700,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isBlocked ? 'AD • SHIELD' : 'AD',
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: isBlocked ? () => _showAntiAdBlockDialog(context) : () => _handleUpgrade(context),
              child: Text(
                customTag ?? '${campaign.iconEmoji} ${campaign.title} • ${campaign.sponsor}',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _handleUpgrade(context),
            child: Text(
              'Remove Ads',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Backwards compatibility alias for existing screens
class AdBannerPlaceholder extends StatelessWidget {
  final bool isPro;
  const AdBannerPlaceholder({super.key, required this.isPro});

  @override
  Widget build(BuildContext context) {
    return GooglePlayCompliantAdBanner(
      isPro: isPro,
      format: GooglePlayAdFormat.standardBanner,
    );
  }
}

/// Humanized, friendly motivational banner badge
class MotivationalPulseBadge extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color? accentColor;

  const MotivationalPulseBadge({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = accentColor ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable modal to cross-confirm any deletion with the user across the entire app
Future<bool> showConfirmDeleteDialog(
  BuildContext context, {
  required String title,
  required String message,
  String deleteLabel = 'Delete',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
          const SizedBox(width: 8),
          Expanded(child: Text(title)),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(deleteLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Reusable modal to prompt users when a feature is locked according to their current plan
Future<void> showFeatureLockedDialog(
  BuildContext context, {
  required String featureTitle,
  required String requiredPlanTitle,
  required String description,
  required StorageService storage,
  String planPrice = '₹89',
}) async {
  final isRemoveAds = storage.currentPlan == UserPlan.removeAds;
  final effectiveButtonLabel = isRemoveAds ? 'Extend Plan for +₹50' : 'Unlock for $planPrice';

  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lock_rounded, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              featureTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.shade700.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.amber.shade700.withValues(alpha: 0.4)),
            ),
            child: Text(
              'REQUIRES $requiredPlanTitle',
              style: TextStyle(
                color: Colors.amber.shade800,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          if (isRemoveAds) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.check_circle_outline, size: 16, color: AppColors.success),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '₹39 Already Credited! Pay only +₹50 to upgrade to Gold Plan 🥇.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Not Now'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(ctx);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PremiumScreen(storage: storage)),
            );
          },
          child: Text(effectiveButtonLabel),
        ),
      ],
    ),
  );
}

