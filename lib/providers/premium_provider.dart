import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../services/storage_service.dart';
import '../utils/safe_provider_base.dart';

class PremiumProvider extends SafeChangeNotifier {
  bool _isPremium = false;
  bool _isLoading = false;
  List<ProductDetails> _products = [];

  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;
  List<ProductDetails> get products => _products;

  // Premium feature flags
  bool get canUseMoodTracking => _isPremium;
  bool get canUseVoiceInput => _isPremium;
  bool get canUseAIInsights => _isPremium;
  bool get canUseCloudSync => _isPremium;
  bool get canUsePremiumThemes => _isPremium;
  bool get canUseRichEditor => _isPremium;
  bool get canExportPDF => _isPremium;
  bool get canLockEntries => _isPremium;

  static const String premiumProductId = 'premium_upgrade';
  static const String premiumMonthlyId = 'premium_monthly';

  PremiumProvider() {
    _loadPremiumStatus();
    _initializePurchases();
  }

  Future<void> _loadPremiumStatus() async {
    try {
      final settings = StorageService.getSettings();
      _isPremium = settings.isPremium;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading premium status: $e');
    }
  }

  Future<void> _initializePurchases() async {
    final bool available = await InAppPurchase.instance.isAvailable();
    if (!available) return;

    try {
      final ProductDetailsResponse response = await InAppPurchase.instance
          .queryProductDetails({premiumProductId, premiumMonthlyId});

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('Products not found: ${response.notFoundIDs}');
      }

      _products = response.productDetails;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing purchases: $e');
    }
  }

  Future<bool> purchasePremium({bool isMonthly = false}) async {
    if (_products.isEmpty) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final productId = isMonthly ? premiumMonthlyId : premiumProductId;
      final product = _products.firstWhere(
        (p) => p.id == productId,
        orElse: () => _products.first,
      );

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );
      final bool success = await InAppPurchase.instance.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (success) {
        await _activatePremium();
        return true;
      }
    } catch (e) {
      debugPrint('Error purchasing premium: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return false;
  }

  Future<void> _activatePremium() async {
    try {
      final settings = StorageService.getSettings();
      final updatedSettings = settings.copyWith(isPremium: true);
      await StorageService.saveSettings(updatedSettings);

      _isPremium = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error activating premium: $e');
    }
  }

  Future<void> restorePurchases() async {
    _isLoading = true;
    notifyListeners();

    try {
      await InAppPurchase.instance.restorePurchases();
      // Check if premium was restored
      final settings = StorageService.getSettings();
      _isPremium = settings.isPremium;
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // For development/testing purposes
  Future<void> activatePremiumForTesting() async {
    await _activatePremium();
  }

  Future<void> deactivatePremium() async {
    try {
      final settings = StorageService.getSettings();
      final updatedSettings = settings.copyWith(isPremium: false);
      await StorageService.saveSettings(updatedSettings);

      _isPremium = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error deactivating premium: $e');
    }
  }

  void showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Premium Feature'),
            content: const Text(
              'This feature is only available for premium users. Upgrade to unlock all premium features including mood tracking, AI insights, voice input, and more!',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showUpgradeBottomSheet(context);
                },
                child: const Text('Upgrade'),
              ),
            ],
          ),
    );
  }

  void _showUpgradeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder:
                (context, scrollController) => Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        '🌟 Upgrade to Premium',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          children: const [
                            _PremiumFeatureItem(
                              icon: '📊',
                              title: 'Mood Analytics',
                              description:
                                  'Track your mood with beautiful charts and insights',
                            ),
                            _PremiumFeatureItem(
                              icon: '🎤',
                              title: 'Voice Input',
                              description:
                                  'Speak your thoughts instead of typing',
                            ),
                            _PremiumFeatureItem(
                              icon: '🤖',
                              title: 'AI Insights',
                              description:
                                  'Get weekly summaries and personalized insights',
                            ),
                            _PremiumFeatureItem(
                              icon: '🎨',
                              title: 'Premium Themes',
                              description:
                                  'Beautiful animated backgrounds and custom fonts',
                            ),
                            _PremiumFeatureItem(
                              icon: '☁️',
                              title: 'Cloud Sync',
                              description: 'Access your journal from anywhere',
                            ),
                            _PremiumFeatureItem(
                              icon: '🔒',
                              title: 'Entry Lock',
                              description:
                                  'Lock individual entries for extra privacy',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed:
                                  _isLoading ? null : () => purchasePremium(),
                              child:
                                  _isLoading
                                      ? const CircularProgressIndicator()
                                      : const Text('Upgrade Now'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
          ),
    );
  }
}

class _PremiumFeatureItem extends StatelessWidget {
  final String icon;
  final String title;
  final String description;

  const _PremiumFeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
