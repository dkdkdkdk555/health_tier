import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_app/model/cmu/feed/certifi_user_dto.dart';
import 'package:my_app/model/cmu/feed/like_and_crtifi_accept_request_dto.dart';
import 'package:my_app/model/cmu/feed/feed_detail.dart';
import 'package:my_app/providers/feed_cud_providers.dart';
import 'package:my_app/providers/feed_providers.dart';
import 'package:my_app/util/dialog_utils.dart' show showAppDialog;
import 'package:my_app/util/error_message_utils.dart';
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
  final int? _myUserId = UserPrefs.myUserId;

  bool _isMyUserCertified = false;
  bool _isCertifiBtnActive = false;
  int _certifiUserNum = 0;

  // 버튼이 눌리고 있는지를 나타내는 상태
  bool _isCertifyButtonPressedState = false; 

  @override
  void initState() {
    super.initState();
    _updateCertifiState();
  }

  // feed가 업데이트될 때마다 상태를 동기화하기 위해 didUpdateWidget 오버라이드
  @override
  void didUpdateWidget(covariant FeedLikeAndCertifiSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.feed != oldWidget.feed) {
      _updateCertifiState();
    }
  }

  void _updateCertifiState() {
    if (widget.feed.crtifiId != 0) {
      _checkIfMyUserIsCertified();
      _isCertifiBtnActive = widget.feed.crtifiYn != 'Y';
      _certifiUserNum = widget.feed.crtifiUsers?.length ?? 0;
    }
  }

  void _checkIfMyUserIsCertified() {
    _isMyUserCertified = widget.feed.crtifiUsers?.any(
          (certifiUser) => certifiUser.userId == _myUserId,
        ) ??
        false;
  }

  // 인증 버튼 클릭 핸들러
  Future<void> _onCertifyButtonPressed() async {

    if (!_isCertifiBtnActive || _isMyUserCertified) {
      return;
    }

    try {
    await showAppDialog(
      context, 
      message: '인증 처리는 취소가 불가능합니다.\n계속 진행하시겠습니까?',
      confirmText: '확인',
      cancelText: '취소',
      onConfirm: () async {
        try {
          final feedCudService = ref.read(feedCudServiceProvider).value; // notifier를 통해 인스턴스 접근
          final response = await feedCudService!.acceptCertification(
            dto: LikeAndCrtifiRequestDto(
              userId: _myUserId ?? 0,
              feedId: widget.feed.id,
              feedWriterUserId: widget.feed.userId
            ),
          );
          
          if(response == 'success') {
            // 성공적으로 인증 요청을 보냈다면, feedDetailProvider를 무효화하여 데이터를 새로고침합니다.
            ref.invalidate(feedDetailProvider(widget.feed.id));
          }
        } catch (e) {
          if(!mounted)return;
          // 에러 처리: 사용자에게 메시지를 보여주거나 로깅
          showAppMessage(context, message: "인증처리 중에 오류가 발생하였습니다.");
        }
      },
      onCancel: () {
        return;
      },
    );
    } catch (e) {
      if (mounted) {
        showAppMessage(context);
      }
    } 
  }

  // 좋아요 버튼 클릭 핸들러 (새로 추가)
  Future<void> _onLikeButtonPressed() async {

    final feedCudService = ref.read(feedCudServiceProvider).value;
    if (feedCudService == null) return;
    
    try {
      if (widget.feed.isLiked == false) {
        // 좋아요가 아닌 상태에서 누르면 좋아요 요청
        final response = await feedCudService.likeFeed(
          LikeAndCrtifiRequestDto(
            userId: _myUserId ?? 0,
            feedId: widget.feed.id,
            feedWriterUserId: widget.feed.userId,
          ),
        );
        if(response == 'success') {
           // 성공적으로 요청을 보냈다면, feedDetailProvider를 무효화하여 데이터를 새로고침합니다.
          ref.invalidate(feedDetailProvider(widget.feed.id));
        }
      } else if (widget.feed.isLiked == true) {
        // 좋아요 상태에서 누르면 좋아요 취소 요청
        final response = await feedCudService.cancelFeedLike(
          LikeAndCrtifiRequestDto(
            userId: _myUserId ?? 0,
            feedId: widget.feed.id,
            feedWriterUserId: widget.feed.userId,
          ),
        );
        if(response == 'success') {
           // 성공적으로 요청을 보냈다면, feedDetailProvider를 무효화하여 데이터를 새로고침합니다.
          ref.invalidate(feedDetailProvider(widget.feed.id));
        }
      }
    } catch (e) {
      if (mounted) {
        showAppMessage(context);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final List<Widget> certifiedUserAvatars =
        _certifiUserNum > 0 && widget.feed.crtifiId != 0
            ? _makeCertifiedUserProfileList(widget.feed.crtifiUsers!)
            : [];

    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildActionButton(
                iconPath: widget.feed.isLiked! ? 'assets/icons/liked.svg' : 'assets/icons/like.svg',
                text: '좋아요',
                backgroundColor: Colors.white,
                borderColor: const Color(0xFFDDDDDD),
                textColor: const Color(0xFF333333),
                iconColor: null,
                onTap: _onLikeButtonPressed, 
              ),
              if (widget.feed.crtifiId != 0 && widget.feed.crtifiYn != '')
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: _buildActionButton(
                    iconPath: 'assets/icons/check.svg',
                    text: '인증합니다',
                    backgroundColor: _isMyUserCertified ? const Color(0xFFFFE6D7) : (_isCertifyButtonPressedState ? const Color(0xFFE0E0E0) : (_isCertifiBtnActive ? Colors.white : const Color(0x33333333))),
                    borderColor: _isMyUserCertified ? const Color(0xFFFFE6D7) : const Color(0xFFDDDDDD),
                    textColor: _isMyUserCertified ? const Color(0xFFE56413) : (_isCertifiBtnActive ? const Color(0xFF333333) : const Color(0xFF666666)),
                    iconColor: _isMyUserCertified ? const Color(0xFFE56413) : (_isCertifiBtnActive ? const Color(0xFF777777) : const Color(0xFF666666)),
                    onTap: _onCertifyButtonPressed, 
                    onTapDown: (details) {
                      if (_isCertifiBtnActive && !_isMyUserCertified) {
                        setState(() {
                          _isCertifyButtonPressedState = true;
                        });
                      }
                    },
                    onTapUp: (details) {
                      if (_isCertifiBtnActive && !_isMyUserCertified) {
                        setState(() {
                          _isCertifyButtonPressedState = false;
                        });
                      }
                    },
                    onTapCancel: () {
                      if (_isCertifiBtnActive && !_isMyUserCertified) {
                        setState(() {
                          _isCertifyButtonPressedState = false;
                        });
                      }
                    },
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${widget.feed.likeCnt}명이 좋아합니다',
                  style: _commonTextStyle,
                ),
                if (widget.feed.crtifiId != 0 && _certifiUserNum > 0) ...[
                  const Text(
                    ' · ',
                    style: _commonTextStyle,
                  ),
                  // 인증 사용자 아바타 영역 (클릭 가능)
                  GestureDetector(
                    onTapDown: (TapDownDetails details) {
                       if (widget.feed.crtifiUsers != null) _showCertifiedUsersMenu(context, widget.feed.crtifiUsers!, details.globalPosition);
                    },
                    child: SizedBox(
                      width: 10.0 * (_certifiUserNum > 1 ? certifiedUserAvatars.length - 1 : 0) + 16,
                      height: 16,
                      child: Stack(
                        children: certifiedUserAvatars.reversed.toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4,),
                  Text(
                    '$_certifiUserNum명이 인증합니다',
                    style: _commonTextStyle,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const TextStyle _commonTextStyle = TextStyle(
    color: Color(0xFF333333),
    fontSize: 14,
    fontFamily: 'Pretendard',
    fontWeight: FontWeight.w400,
    height: 1.50,
  );

  Widget _buildActionButton({
    required String iconPath,
    required String text,
    required Color backgroundColor,
    required Color borderColor,
    required Color textColor,
    Color? iconColor,
    VoidCallback? onTap,
    GestureTapDownCallback? onTapDown,
    GestureTapUpCallback? onTapUp,
    GestureTapCancelCallback? onTapCancel,
  }) {
    return GestureDetector(
      onTap: onTap,
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onTapCancel: onTapCancel,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: ShapeDecoration(
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: _isMyUserCertified && text == '인증합니다' ? 0 : 1,
              color: borderColor,
            ),
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: SvgPicture.asset(
                iconPath,
                width: 16,
                height: 16,
                fit: BoxFit.cover,
                colorFilter: iconColor != null ? ColorFilter.mode(iconColor, BlendMode.srcIn) : null,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 사용자 프로필 아바타 위젯을 생성합니다. (팝업에서도 사용 가능하도록 분리)
  Widget _buildUserProfileAvatar(String? imgPath, double profileSize) {
    // 기본 아바타 크기
    double avatarSize = profileSize; // 팝업에서는 조금 더 크게 표시

    Widget userImageWidget;
    if (imgPath != null && imgPath.startsWith('http')) {
      userImageWidget = Container(
        width: avatarSize,
        height: avatarSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(imgPath),
            fit: BoxFit.cover,
            onError: (exception, stackTrace) {
              debugPrint('Error loading image: $imgPath, Exception: $exception');
            },
          ),
        ),
      );
    } else {
      userImageWidget = Container(
        width: avatarSize,
        height: avatarSize,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(
          'assets/widgets/default_user_profile.svg',
          width: avatarSize,
          height: avatarSize,
          fit: BoxFit.cover,
        ),
      );
    }
    return userImageWidget;
  }

  List<Widget> _makeCertifiedUserProfileList(List<CertifiUserDto> crtifiUsers) {
    final List<Widget> certifiedUserAvatars = [];
    if (crtifiUsers.isNotEmpty) {
      final displayCount = _certifiUserNum > 5 ? 5 : _certifiUserNum;

      for (int i = 0; i < displayCount; i++) {
        final user = crtifiUsers[i];
        final double offset = i * 10.0;

        certifiedUserAvatars.add(
          Positioned(
            left: offset,
            top: 0,
            child: _buildUserProfileAvatar(user.imgPath, 16), // 재사용 가능한 함수 호출
          ),
        );
      }
    }
    return certifiedUserAvatars;
  }

  /// 팝업(다이얼로그)을 띄워 인증 사용자 목록을 보여줍니다.
  void _showCertifiedUsersMenu(BuildContext context, List<CertifiUserDto> users, Offset position) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        overlay.size.width - position.dx,
        overlay.size.height - position.dy,
      ),
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      items: users.map((user) {
        return PopupMenuItem(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          enabled: false, // 클릭 안 되게 (단순 표시용)
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildUserProfileAvatar(user.imgPath, 24),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 80),
                child: Text(
                  user.nickname.length > 6
                      ? '${user.nickname.substring(0, 6)}..'
                      : user.nickname,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Pretendard',
                    color: Colors.black,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}