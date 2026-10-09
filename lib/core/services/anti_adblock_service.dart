import 'dart:io';
import 'package:flutter/foundation.dart';

/// Represents a resilient, in-app student sponsor campaign that cannot be blocked by DNS/VPN ad blockers.
class SponsoredAdCampaign {
  final String sponsor;
  final String title;
  final String description;
  final String badgeText;
  final String ctaText;
  final String iconEmoji;

  const SponsoredAdCampaign({
    required this.sponsor,
    required this.title,
    required this.description,
    required this.badgeText,
    required this.ctaText,
    required this.iconEmoji,
  });
}

/// Anti-AdBlock Detection & Resilient Ad Engine Service
///
/// 1. Detects DNS/VPN/Host-based ad-blockers (e.g., AdGuard, Pi-hole, NextDNS, Private DNS sinkholes).
/// 2. Bypasses ad-blockers by serving embedded, resilient student partner campaigns that
///    run natively inside the Flutter UI engine and cannot be intercepted by network filters.
/// 3. Ensures the free tier consistently displays sponsored student ads and upgrade options.
class AntiAdBlockService extends ChangeNotifier {
  static final AntiAdBlockService instance = AntiAdBlockService._internal();
  AntiAdBlockService._internal() {
    _initDetection();
  }

  bool _isAdBlockerDetected = false;
  bool get isAdBlockerDetected => _isAdBlockerDetected;

  int _currentCampaignIndex = 0;
  int get currentCampaignIndex => _currentCampaignIndex;

  /// Curated, realistic student sponsor campaigns running natively in-app
  final List<SponsoredAdCampaign> campaigns = const [
    SponsoredAdCampaign(
      sponsor: 'Unstop & Internshala Partner',
      title: 'Verified College Internships & Stipends',
      description: 'Apply to verified tech & management internships offering ₹15,000–₹40,000/mo. Free for university students.',
      badgeText: 'STUDENT SPONSOR',
      ctaText: 'Explore Free',
      iconEmoji: '💼',
    ),
    SponsoredAdCampaign(
      sponsor: 'GeeksforGeeks & LeetCode Prep',
      title: 'Placement DSA & System Design Pass',
      description: 'Exclusive 60% student waiver on coding interview prep and campus recruitment tests.',
      badgeText: 'CAREER SPONSOR',
      ctaText: 'Claim Waiver',
      iconEmoji: '💻',
    ),
    SponsoredAdCampaign(
      sponsor: 'Amazon & Croma Campus Deals',
      title: 'Student Tech Deals: Up to 45% Off',
      description: 'Huge discounts on student laptops, iPads, calculators, and study accessories with valid college ID.',
      badgeText: 'TECH DEALS',
      ctaText: 'View Deals',
      iconEmoji: '🎧',
    ),
    SponsoredAdCampaign(
      sponsor: 'Student Utility Hub Official',
      title: 'Enjoy 100% Ad-Free Offline Studying',
      description: 'Permanently remove all banner ads across all calculators and tools for just ₹39 one-time.',
      badgeText: 'PRO STUDENT',
      ctaText: 'Remove for ₹39',
      iconEmoji: '👑',
    ),
  ];

  SponsoredAdCampaign get activeCampaign =>
      campaigns[_currentCampaignIndex % campaigns.length];

  void rotateCampaign() {
    _currentCampaignIndex = (_currentCampaignIndex + 1) % campaigns.length;
    notifyListeners();
  }

  /// Probes DNS resolutions to detect whether ad networks are being sinkholed or dropped
  Future<bool> checkAdBlocker() async {
    try {
      // 1. Check general network reachability to neutral DNS host
      final neutralHosts = await InternetAddress.lookup('dns.google')
          .timeout(const Duration(seconds: 2), onTimeout: () => []);

      if (neutralHosts.isEmpty) {
        // Device is completely offline — not an ad blocker
        _isAdBlockerDetected = false;
        notifyListeners();
        return false;
      }

      // 2. Probe standard ad network DNS resolution
      final adHosts = await InternetAddress.lookup('pagead2.googlesyndication.com')
          .timeout(const Duration(seconds: 2), onTimeout: () => []);

      if (adHosts.isEmpty) {
        // General internet is online, but ad network resolution was dropped/blocked
        _isAdBlockerDetected = true;
        notifyListeners();
        return true;
      }

      // Check if ad network is sinkholed to localhost/null (standard DNS blocker behavior)
      final isSinkholed = adHosts.any((addr) =>
          addr.address == '0.0.0.0' ||
          addr.address == '127.0.0.1' ||
          addr.address == '::' ||
          addr.address == '::1');

      _isAdBlockerDetected = isSinkholed;
      notifyListeners();
      return _isAdBlockerDetected;
    } catch (_) {
      return _isAdBlockerDetected;
    }
  }

  void _initDetection() {
    // Non-blocking background check on app launch
    Future.delayed(const Duration(seconds: 2), () {
      checkAdBlocker();
    });
  }
}
