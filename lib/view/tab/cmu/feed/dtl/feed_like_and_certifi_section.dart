import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_app/model/cmu/feed/certifi_user_dto.dart';
import 'package:my_app/model/cmu/feed/feed_detail.dart';
import 'package:my_app/util/user_prefs.dart';

class FeedLikeAndCertifiSection extends ConsumerStatefulWidget {
  const FeedLikeAndCertifiSection({
    super.key,
    required this.feed,
  });

  final FeedDetailDto feed;

  @override
  ConsumerState<FeedLikeAndCertifiSection> createState() => _FeedLikeAndCertifiSectionConsumerState();
}

class _FeedLikeAndCertifiSectionConsumerState extends ConsumerState<FeedLikeAndCertifiSection> {
  final int _myUserId = UserPrefs.myUserId ?? 16;

  // 로그인 이용자가 인증눌렀는지 여부 
  bool _isMyUserCertified = false;
  // 인증버튼 활성상태 여부
  bool _isCrtifiBtnActive = false;
  int certifiUserNum = 0;

  @override
  void initState() {
    super.initState();
    if(widget.feed.crtifiId !=0) {
      _checkIfMyUserIsCertified();
       _isCrtifiBtnActive = widget.feed.crtifiYn != 'Y';
       certifiUserNum = widget.feed.crtifiUsers?.length ?? 0;
    }
  }

   void _checkIfMyUserIsCertified() {
    if (widget.feed.crtifiUsers != null) {
      _isMyUserCertified = widget.feed.crtifiUsers!.any(
        (certifiUser) => certifiUser.userId == _myUserId,
      );
    } else {
      _isMyUserCertified = false; // 리스트가 null이면 인증되지 않은 것으로 간주
    }
  }
  
  @override
  Widget build(BuildContext context) {
    List<Widget> certifiedUserAvatars = [];
    if(certifiUserNum > 0 && widget.feed.crtifiId != 0) {  
      certifiedUserAvatars = makeCertifiedUserProfileList(widget.feed.crtifiUsers!);
    }
    return SizedBox(
        width: double.infinity,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
                Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                        width: 1,
                                        color: Color(0xFFDDDDDD),
                                    ),
                                    borderRadius: BorderRadius.circular(99),
                                ),
                            ),
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 10,
                                children: [
                                    Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 2,
                                        children: [
                                            SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: SvgPicture.asset(
                                                widget.feed.isLiked! ? 'assets/icons/liked.svg' : 'assets/icons/like.svg',
                                                width: 16,
                                                height: 16,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const Text(
                                                '좋아요',
                                                style: TextStyle(
                                                    color: Color(0xFF333333),
                                                    fontSize: 12,
                                                    fontFamily: 'Pretendard',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.50,
                                                ),
                                            ),
                                        ],
                                    ),
                                ],
                            ),
                        ),
                        if(widget.feed.crtifiId != 0 && widget.feed.crtifiYn != '')
                          Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: ShapeDecoration(
                                  color:  _isMyUserCertified ? const Color(0xFFFFE6D7) : _isCrtifiBtnActive ?Colors.white : const Color(0x33333333),
                                  shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: _isMyUserCertified ? 0 : 1,
                                        color: _isMyUserCertified ? const Color(0xFFFFE6D7) : const Color(0xFFDDDDDD),
                                      ),
                                      borderRadius: BorderRadius.circular(99),
                                  ),
                              ),
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 10,
                                  children: [
                                      Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          spacing: 2,
                                          children: [
                                              SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: SvgPicture.asset(
                                                  'assets/icons/check.svg',
                                                  width: 16,
                                                  height: 16,
                                                  fit: BoxFit.cover,
                                                  colorFilter: ColorFilter.mode(
                                                    _isMyUserCertified ? const Color(0xFFE56413) : const Color(0xFF777777),
                                                    BlendMode.srcIn,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                  '인증합니다',
                                                  style: TextStyle(
                                                      color: _isMyUserCertified ? const Color(0xFFE56413) : const Color(0xFF333333),
                                                      fontSize: 12,
                                                      fontFamily: 'Pretendard',
                                                      fontWeight: FontWeight.w400,
                                                      height: 1.50,
                                                  ),
                                              ),
                                          ],
                                      ),
                                  ],
                              ),
                          ),
                    ],
                ),
                SizedBox(
                    width: double.infinity,
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 4,
                        children: [
                            
                            Text(
                                '${widget.feed.likeCnt}명이 좋아합니다',
                                style: const TextStyle(
                                    color: Color(0xFF333333),
                                    fontSize: 14,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w400,
                                    height: 1.50,
                                ),
                            ),
                            if(widget.feed.crtifiId != 0 && certifiUserNum > 0)...[
                              const Text(
                                  '·',
                                  style: TextStyle(
                                      color: Color(0xFF333333),
                                      fontSize: 14,
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w400,
                                      height: 1.50,
                                  ),
                              ),
                              SizedBox(
                                width: 10.0 * (certifiedUserAvatars.length - 1 < 0 ? 0 : certifiedUserAvatars.length - 1) + 16, // 겹치는 offset + 마지막 아바타 너비
                                height: 16,
                                child: Stack(
                                  children: certifiedUserAvatars.reversed.toList(), // Stack은 마지막에 추가된 위젯이 맨 위에 그려지므로 reversed
                                ),
                              ),
                              Text(
                                  certifiUserNum!=0 ? '$certifiUserNum명이 인증합니다' : '',
                                  style: const TextStyle(
                                      color: Color(0xFF333333),
                                      fontSize: 14,
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w400,
                                      height: 1.50,
                                  ),
                              ),
                            ]
                        ],
                    ),
                ),
            ],
        )
    );
  }


  List<Widget> makeCertifiedUserProfileList(List<CertifiUserDto> crtifiUsers){
    // certifiedUsers를 기반으로 Positioned 위젯 리스트 생성
    List<Widget> certifiedUserAvatars = [];
    if (crtifiUsers.isNotEmpty) {
      // 최대 3개까지만 표시하도록 제한 (원하는 개수로 조절 가능)
      final displayCount = certifiUserNum > 5 ? 5 : certifiUserNum;

      // 리스트를 역순으로 순회하여 왼쪽으로 겹쳐지도록 배치
      for (int i = 0; i < displayCount; i++) {
        final user = crtifiUsers[i];
        final double offset = (displayCount - 1 - i) * 10.0; // 겹치는 정도 조절
        
        // ImageProvider를 동적으로 결정 (네트워크 이미지 vs. SVG asset)
        Widget userImageWidget;
        if (user.imgPath!.startsWith('http')) { // URL인 경우
          userImageWidget = Image.network(
            user.imgPath!,
            width: 16,
            height: 16,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => SvgPicture.asset(
              'assets/widgets/default_user_profile.svg', // 에러 발생 시 기본 SVG
              width: 16,
              height: 16,
              fit: BoxFit.cover,
            ),
          );
        } else {
          userImageWidget = SvgPicture.asset(
            'assets/widgets/default_user_profile.svg',
            width: 16,
            height: 16,
            fit: BoxFit.cover,
          );
        }

        certifiedUserAvatars.add(
          Positioned(
            left: offset,
            top: 0,
            child: Container(
              width: 16, // 아바타 너비
              height: 16, // 아바타 높이
              decoration: ShapeDecoration(
                shape: const OvalBorder(
                  side: BorderSide(
                    width: 1,
                    strokeAlign: BorderSide.strokeAlignOutside,
                    color: Colors.white,
                  ),
                ),
                image: user.imgPath!.startsWith('http')
                    ? DecorationImage( // 네트워크 이미지일 경우
                        image: NetworkImage(user.imgPath!),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                           debugPrint('Error loading image: ${user.imgPath}');
                        },
                      )
                    : null, // SVG 또는 기타 asset은 Container의 child로 처리
              ),
              child: user.imgPath!.startsWith('http') ? null : userImageWidget, // 네트워크 이미지가 아니면 child로 설정
            ),
          ),
        );
      }
    }

    return certifiedUserAvatars;
  }
}