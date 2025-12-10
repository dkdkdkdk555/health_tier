import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdmobAds extends StatefulWidget {
  const AdmobAds({super.key});

  @override
  State<AdmobAds> createState() => _AdmobAdsState();
}

class _AdmobAdsState extends State<AdmobAds> {
  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;
  static const AdRequest request = AdRequest(
    nonPersonalizedAds: false,
  );

  // 테스트광고id -> 배포전 실제 광고id로 바꿀것
 final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/2247696110'
      : 'ca-app-pub-3940256099942544/3986624511';

  @override
  void initState() {
    super.initState();
    MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: [
          'Simulator',   // iOS Simulator
          'EMULATOR',    // Android Emulator
        ]));
    loadAd();
  }

  @override
  void dispose() {
    super.dispose();
    _nativeAd?.dispose();
  }

  /// Loads a native ad.
  void loadAd() {
    _nativeAd = NativeAd(
        adUnitId: _adUnitId,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            debugPrint('$NativeAd loaded.');
            setState(() {
              _nativeAdIsLoaded = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            // Dispose the ad here to free resources.
            debugPrint('$NativeAd failed to load: $error');
            ad.dispose();
          },
          // Called when a click is recorded for a NativeAd.
          onAdClicked: (ad) {},
          // Called when an impression occurs on the ad.
          onAdImpression: (ad) {},
          // Called when an ad removes an overlay that covers the screen.
          onAdClosed: (ad) {},
          // Called when an ad opens an overlay that covers the screen.
          onAdOpened: (ad) {},
          // For iOS only. Called before dismissing a full screen view
          onAdWillDismissScreen: (ad) {},
          // Called when an ad receives revenue value.
          onPaidEvent: (ad, valueMicros, precision, currencyCode) {},
        ),
        request: const AdRequest(),
        // Styling
        nativeTemplateStyle: NativeTemplateStyle(
            // Required: Choose a template.
            templateType: TemplateType.medium,
            // Optional: Customize the ad's style.
            mainBackgroundColor: Colors.purple,
            cornerRadius: 10.0,
            callToActionTextStyle: NativeTemplateTextStyle(
                textColor: Colors.cyan,
                backgroundColor: Colors.red,
                style: NativeTemplateFontStyle.monospace,
                size: 16.0),
            primaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.red,
                backgroundColor: Colors.cyan,
                style: NativeTemplateFontStyle.italic,
                size: 16.0),
            secondaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.green,
                backgroundColor: Colors.black,
                style: NativeTemplateFontStyle.bold,
                size: 16.0),
            tertiaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.brown,
                backgroundColor: Colors.amber,
                style: NativeTemplateFontStyle.normal,
                size: 16.0)))
      ..load();
  }

  @override
  Widget build(BuildContext context) {
    return _nativeAdIsLoaded
        ? AdContainerSmall(nativeAd: _nativeAd)
        : const SizedBox(
            height: 320,
            child: Center(child: CircularProgressIndicator()),
          );
  }
}

class AdContainerSmall extends StatelessWidget {
  const AdContainerSmall({
    super.key,
    required NativeAd? nativeAd,
  }) : _nativeAd = nativeAd;

  final NativeAd? _nativeAd;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 90, // minimum recommended width
        minHeight: 90, // minimum recommended height
        maxWidth: 500,
        maxHeight: 500,
      ),
      child: AdWidget(ad: _nativeAd!),
    );
  }
}

class AdContainerMedium extends StatelessWidget {
  const AdContainerMedium({
    super.key,
    required NativeAd? nativeAd,
  }) : _nativeAd = nativeAd;

  final NativeAd? _nativeAd;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 320, // minimum recommended width
        minHeight: 320, // minimum recommended height
        maxWidth: 400,
        maxHeight: 400,
      ),
      child: AdWidget(ad: _nativeAd!),
    );
  }
}