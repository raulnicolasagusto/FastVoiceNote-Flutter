import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // Real IDs provided by user
  static const String appId = 'ca-app-pub-1467750216848197~7377346348';
  static const String homeBannerId = 'ca-app-pub-1467750216848197/5130456958';
  static const String noteBannerId = 'ca-app-pub-1467750216848197/8878130272';
  static const String interstitialMuroId =
      'ca-app-pub-1467750216848197/3625803592';

  // Test IDs for development
  static const String testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';

  // Toggle this to use real IDs
  static const bool _useTestAds = kDebugMode;

  String get _homeBannerAdUnit => _useTestAds ? testBannerId : homeBannerId;
  String get _noteBannerAdUnit => _useTestAds ? testBannerId : noteBannerId;
  String get _interstitialAdUnit =>
      _useTestAds ? testInterstitialId : interstitialMuroId;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoaded = false;

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  // Banner Logic
  BannerAd createBannerAd(String adUnitType) {
    String adUnitId = adUnitType == 'home'
        ? _homeBannerAdUnit
        : _noteBannerAdUnit;

    return BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => debugPrint('Ad loaded: ${ad.adUnitId}'),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Ad failed to load: ${ad.adUnitId}, $error');
        },
      ),
    );
  }

  // Interstitial Logic
  Future<void> loadInterstitial() async {
    await InterstitialAd.load(
      adUnitId: _interstitialAdUnit,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          _setInterstitialCallbacks(ad);
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd failed to load: $error');
          _isInterstitialAdLoaded = false;
        },
      ),
    );
  }

  void _setInterstitialCallbacks(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isInterstitialAdLoaded = false;
        // Optionally reload
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isInterstitialAdLoaded = false;
      },
    );
  }

  bool showInterstitialIfReady() {
    if (_isInterstitialAdLoaded && _interstitialAd != null) {
      _interstitialAd!.show();
      return true;
    }
    debugPrint('Interstitial ad not ready yet.');
    return false;
  }

  // Open Tracker Logic
  static const String _openCountKey = 'app_open_count_ad_track';

  Future<bool> shouldShowInterstitialOnStartup() async {
    final prefs = await SharedPreferences.getInstance();
    int currentCount = prefs.getInt(_openCountKey) ?? 0;
    currentCount++;
    await prefs.setInt(_openCountKey, currentCount);

    debugPrint('App open count: $currentCount');

    debugPrint('App open count: $currentCount');

    // Show on 4th, 8th, 12th open, etc.
    return currentCount % 4 == 0;
  }
}
