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
  static const AdRequest request = AdRequest( // 광고 요청 설정
    nonPersonalizedAds: false, // 사용자맞춤o
  );
  /* 
    네이티브 광고
  */
  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;
  // 테스트 네이티브 광고id -> 배포전 실제 광고id로 바꿀것
  final String _adVideoUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1044960115'
      : 'ca-app-pub-3940256099942544/2521693316';

  /*
    배너 광고
  */
  BannerAd? _bannerAd;
  bool _bannerAdIsLoaded = false;
  // 테스트 배너 광고id -> 배포전 실제 광고id로 바꿀것
  final String _adBannerUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/9214589741'
      : 'ca-app-pub-3940256099942544/2435281174';

  @override
  void initState() {
    super.initState();
    // 테스트 기기 설정
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: [
        'Simulator',   // iOS Simulator
        'EMULATOR',    // Android Emulator
      ])
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if(widget.adType == AdType.nativeVideo && _nativeAd == null) {
      loadNativeVideoAd();
    } else if(widget.adType == AdType.banner && _bannerAd == null) {
      _loadBannerAd(context);
    }
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    _nativeAd = null;
    _bannerAd?.dispose();
    _bannerAd = null;
    super.dispose();
  }

  // 네이티브 광고(비디오) 로드
  void loadNativeVideoAd() {
    _nativeAd = NativeAd(
        request: request,
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

  // 배너광고 로드
  void _loadBannerAd(BuildContext context) async {
    // 1. 화면 너비를 기반으로 반응형 사이즈 계산
    final AdSize? adaptiveSize = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      MediaQuery.of(context).size.width.truncate(),
    );

    if (adaptiveSize == null) {
      debugPrint('Failed to get anchored adaptive banner size.');
      return;
    }
  
    _bannerAd = BannerAd(
      adUnitId: _adBannerUnitId,
      request: request,
      size: adaptiveSize,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          // Called when an ad is successfully received.
          debugPrint("Ad was loaded.");
          setState(() {
            _bannerAdIsLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          // Called when an ad request failed.
          debugPrint("Ad failed to load with error: $err");
          ad.dispose();
        },
        // [START_EXCLUDE silent]
        // [START ad_events]
        onAdOpened: (Ad ad) {
          // Called when an ad opens an overlay that covers the screen.
          debugPrint("Ad was opened.");
        },
        onAdClosed: (Ad ad) {
          // Called when an ad removes an overlay that covers the screen.
          debugPrint("Ad was closed.");
        },
        onAdImpression: (Ad ad) {
          // Called when an impression occurs on the ad.
          debugPrint("Ad recorded an impression.");
        },
        onAdClicked: (Ad ad) {
          // Called when an a click event occurs on the ad.
          debugPrint("Ad was clicked.");
        },
        onAdWillDismissScreen: (Ad ad) {
          // iOS only. Called before dismissing a full screen view.
          debugPrint("Ad will be dismissed.");
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    Widget renderAdWidget;

    switch(widget.adType) {
      case AdType.nativeVideo:
        renderAdWidget = _nativeAdIsLoaded
        ? AdContainerSmall(nativeAd: _nativeAd)
        : const SizedBox.shrink();
      case AdType.banner:
        renderAdWidget = _bannerAdIsLoaded
        ? AdContainerBanner(bannerAd: _bannerAd)
        : const SizedBox.shrink();
    }

    return renderAdWidget;
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

class AdContainerBanner extends StatelessWidget {
  const AdContainerBanner({
    super.key,
    required BannerAd? bannerAd,
  }) : _bannerAd = bannerAd;

  final BannerAd? _bannerAd;

  @override
  Widget build(BuildContext context) {
    final htio = ScreenRatio(context).heightRatio;
    final wtio = ScreenRatio(context).widthRatio;
    final AdSize size = _bannerAd!.size;

    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: size.width.toDouble() * wtio, 
        height: size.height.toDouble() * htio, 
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}
