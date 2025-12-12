import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:my_app/util/screen_ratio.dart' show ScreenRatio;

enum AdType {
  nativeVideo, // 네이티브 광고 고급형 - 비디오만 보여줌
  banner, // 배너 광고
}

class AdmobAds extends StatefulWidget {
  final AdType adType;
  const AdmobAds({
    super.key,
    required this.adType
  });

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
 final String _adVideoUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1044960115'
      : 'ca-app-pub-3940256099942544/2521693316';

  @override
  void initState() {
    super.initState();
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: [
        'Simulator',   // iOS Simulator
        'EMULATOR',    // Android Emulator
      ])
    );
    loadVideoAd();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    _nativeAd = null;
    super.dispose();
  }

  /// Loads a native ad.
  void loadVideoAd() {
    _nativeAd = NativeAd(
        adUnitId: _adVideoUnitId,
        factoryId: 'onAIDietAnalyzeAds',
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            debugPrint('$NativeAd loaded.');
            setState(() {
              _nativeAdIsLoaded = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('NativeAd failed to load: $error');
            debugPrint('domain=${error.domain}, code=${error.code}, message=${error.message}');
            debugPrint('responseInfo=${error.responseInfo}');
            ad.dispose();
          },
          // Called when a click is recorded for a NativeAd.
          onAdClicked: (ad) {
          },
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
        nativeAdOptions: NativeAdOptions(
          videoOptions: VideoOptions(
            startMuted: true,
          ),
          shouldRequestMultipleImages: false,
          shouldReturnUrlsForImageAssets: true,
        ),
        nativeTemplateStyle: NativeTemplateStyle(
            templateType: TemplateType.medium,
            mainBackgroundColor: Colors.white,
            cornerRadius: 10.0,
            /* 설치하기 버튼 스타일 커스텀 */
            callToActionTextStyle: NativeTemplateTextStyle(
              textColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              style: NativeTemplateFontStyle.monospace,
              size: 1.0
            ),
            primaryTextStyle: NativeTemplateTextStyle(
              size: 1,
              textColor: Colors.transparent,
              backgroundColor: Colors.transparent,
            ),
            secondaryTextStyle: NativeTemplateTextStyle(
                backgroundColor: Colors.transparent,
                textColor: Colors.transparent,
                size: 1),
            tertiaryTextStyle: NativeTemplateTextStyle(
                backgroundColor: Colors.transparent,
                textColor: Colors.transparent,
                size: 1)))
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
    final htio = ScreenRatio(context).heightRatio;
    final wtio = ScreenRatio(context).widthRatio;
    
    return Container(
      constraints: BoxConstraints(
        minWidth: 90 * wtio, // minimum recommended width
        minHeight: 90 * htio, // minimum recommended height
        maxWidth: 300 * wtio,
        maxHeight: 250 * htio,
      ),
      padding: EdgeInsets.symmetric(horizontal: 10*wtio, vertical: 10*htio),
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