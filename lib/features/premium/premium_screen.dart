import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/services/storage_service.dart';

class PremiumScreen extends StatelessWidget {
  final StorageService storage;
  const PremiumScreen({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final plan = storage.currentPlan;
    final isRemoveAdsActive = plan == UserPlan.removeAds;
    final isProStudentActive = plan == UserPlan.proStudent;
    final isLifetimeActive = plan == UserPlan.lifetimeUltimate;

    String heroTitle;
    String heroSubtitle;
    if (isLifetimeActive) {
      heroTitle = 'Diamond Member Active! 💎';
      heroSubtitle = 'All V1, V2, and V3 updates unlocked forever.';
    } else if (isProStudentActive) {
      heroTitle = 'Gold Plan Member 🥇';
      heroSubtitle = 'All premium features unlocked: Ad-Free, Unlimited Semesters & Custom Themes.';
    } else if (isRemoveAdsActive) {
      heroTitle = 'Silver Plan Active 🥈';
      heroSubtitle = 'Zero ads active. Upgrade anytime to Gold by adding just +₹50.';
    } else {
      heroTitle = 'Unlock Student Utility Hub ⭐';
      heroSubtitle = 'Choose your student plan. One-time payment, lifetime access.';
    }

    // Pricing & extension calculations:
    final String silverPrice = '₹39';
    final String silverOriginalPrice = '₹49';
    final bool silverEnabled = plan == UserPlan.free;
    final String silverButtonText = isRemoveAdsActive
        ? 'Current Plan 🥈'
        : (isProStudentActive || isLifetimeActive ? 'Included in Gold 🥇' : 'Get Silver Plan for ₹39');

    // Gold Plan: Base ₹89
    // If user has Silver (₹39), extension cost is ₹89 - ₹39 = ₹50!
    final String goldPrice = isRemoveAdsActive ? '₹50' : '₹89';
    final String goldOriginalPrice = isRemoveAdsActive ? '₹89' : '₹99';
    final String? goldPriceSuffix = isRemoveAdsActive ? ' (Upgrade)' : null;
    final String? goldCustomBadge = isRemoveAdsActive ? 'SAVE ₹39 • EXTEND FOR ₹50' : null;
    final bool goldEnabled = !isProStudentActive && !isLifetimeActive;
    final String goldButtonText = isProStudentActive
        ? 'Current Plan 🥇'
        : (isLifetimeActive
            ? 'Included in Diamond 💎'
            : (isRemoveAdsActive ? 'Upgrade to Gold for +₹50' : 'Get Gold Plan for ₹89'));

    // Diamond Plan: Base ₹149 (Coming Soon)
    const String diamondPrice = '₹149';
    const String diamondButtonText = 'Coming Soon';

    return Scaffold(
      appBar: AppBar(title: const Text('Plans & Upgrades ⭐')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pro Hero Card
            CustomCard(
              gradient: LinearGradient(
                colors: isProStudentActive
                    ? [const Color(0xFFF59E0B), const Color(0xFFD97706)]
                    : (isRemoveAdsActive
                        ? [const Color(0xFF64748B), const Color(0xFF475569)]
                        : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Column(
                children: [
                  Icon(
                    isLifetimeActive
                        ? Icons.diamond_outlined
                        : (isProStudentActive
                            ? Icons.workspace_premium
                            : (isRemoveAdsActive ? Icons.shield_rounded : Icons.stars_rounded)),
                    size: 56,
                    color: isProStudentActive ? Colors.white : Colors.amberAccent,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    heroTitle,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    heroSubtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Silver Plan Card (₹39)
            _buildTierCard(
              context,
              title: 'Silver Plan 🥈',
              price: silverPrice,
              originalPrice: silverOriginalPrice,
              subtitle: '100% distraction-free offline studying.',
              badgeColor: const Color(0xFF94A3B8),
              cardAccentColor: const Color(0xFF64748B),
              features: [
                'Zero Banner Ads',
                'Zero Interstitial Ads',
                'Capped at 4 semesters',
                'Super-fast load times',
              ],
              buttonText: silverButtonText,
              isPopular: false,
              isEnabled: silverEnabled,
              isDark: isDark,
              onTap: () => _activatePlan(context, UserPlan.removeAds, 'Silver Plan 🥈 (₹39)'),
            ),
            const SizedBox(height: 14),

            // Gold Plan Card (₹89)
            _buildTierCard(
              context,
              title: 'Gold Plan 🥇',
              price: goldPrice,
              priceSuffix: goldPriceSuffix,
              originalPrice: goldOriginalPrice,
              subtitle: isRemoveAdsActive
                  ? 'Add ₹50 to your Silver plan to unlock all Gold privileges.'
                  : 'Most popular for college & semester tracking.',
              customBadge: goldCustomBadge,
              badgeColor: const Color(0xFFF59E0B),
              cardAccentColor: const Color(0xFFF59E0B),
              features: [
                'All Silver Ad-Free Benefits',
                'Unlimited Saved Semesters',
                'Advanced Attendance Predictions',
                '7 Exclusive Gold Themes (AMOLED, Sunset, Lavender...)',
                'Export Academic PDF Reports',
              ],
              buttonText: goldButtonText,
              isPopular: !isRemoveAdsActive,
              isEnabled: goldEnabled,
              isDark: isDark,
              onTap: () => _activatePlan(
                context,
                UserPlan.proStudent,
                isRemoveAdsActive ? 'Gold Plan 🥇 (Upgraded for +₹50)' : 'Gold Plan 🥇 (₹89)',
              ),
            ),
            const SizedBox(height: 14),

            // Diamond Plan Card (₹149 - Coming Soon)
            _buildTierCard(
              context,
              title: 'Diamond Plan 💎',
              price: diamondPrice,
              subtitle: 'Unlock everything + all future V2 & V3 updates.',
              badgeColor: const Color(0xFF06B6D4),
              cardAccentColor: const Color(0xFF06B6D4),
              features: [
                'Everything in Gold Plan',
                'AI-Powered Study Assistant',
                'Future Cloud Backup & Sync',
                'Priority Developer Support',
              ],
              buttonText: diamondButtonText,
              isPopular: false,
              isUpcoming: true,
              isEnabled: false,
              isDark: isDark,
              onTap: null,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTierCard(
    BuildContext context, {
    required String title,
    required String price,
    String? priceSuffix,
    String? originalPrice,
    required String subtitle,
    String? customBadge,
    Color? badgeColor,
    Color? cardAccentColor,
    required List<String> features,
    required bool isPopular,
    bool isUpcoming = false,
    bool isEnabled = true,
    required bool isDark,
    String? buttonText,
    required VoidCallback? onTap,
  }) {
    final accent = cardAccentColor ?? AppColors.primary;
    return CustomCard(
      border: isPopular
          ? Border.all(color: accent, width: 2)
          : (customBadge != null
              ? Border.all(color: accent, width: 1.8)
              : (isUpcoming
                  ? Border.all(color: accent.withValues(alpha: 0.6), width: 1.5)
                  : Border.all(color: accent.withValues(alpha: 0.4), width: 1.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              if (customBadge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [badgeColor ?? const Color(0xFF10B981), (badgeColor ?? const Color(0xFF059669)).withValues(alpha: 0.8)],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        customBadge,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                )
              else if (isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('MOST POPULAR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                )
              else if (isUpcoming)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.rocket_launch, size: 11, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'COMING SOON',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.6),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              _buildPriceWidget(price, accent),
              if (priceSuffix != null) ...[
                const SizedBox(width: 4),
                Text(
                  priceSuffix,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success),
                ),
              ],
              if (originalPrice != null) ...[
                const SizedBox(width: 8),
                _buildOriginalPriceWidget(
                  originalPrice,
                  isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: accent, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(f, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 14),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isUpcoming ? Colors.grey.shade700 : accent,
              foregroundColor: Colors.white,
            ),
            onPressed: isEnabled ? onTap : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isUpcoming) ...[
                  const Icon(Icons.rocket_launch, size: 16),
                  const SizedBox(width: 8),
                ],
                Text(buttonText ?? 'Get $title for $price'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceWidget(String price, Color color) {
    if (price.startsWith('₹')) {
      final amount = price.substring(1);
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            '₹',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w400,
              color: color,
            ),
          ),
          const SizedBox(width: 1),
          Text(
            amount,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      );
    }
    return Text(
      price,
      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: color),
    );
  }

  Widget _buildOriginalPriceWidget(String originalPrice, Color color) {
    if (originalPrice.startsWith('₹')) {
      final amount = originalPrice.substring(1);
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            '₹',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              decoration: TextDecoration.lineThrough,
              color: color,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.lineThrough,
              color: color,
            ),
          ),
        ],
      );
    }
    return Text(
      originalPrice,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        decoration: TextDecoration.lineThrough,
        color: color,
      ),
    );
  }

  void _activatePlan(BuildContext context, UserPlan plan, String planName) {
    storage.setUserPlan(plan);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 Congratulations! $planName successfully unlocked.'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
