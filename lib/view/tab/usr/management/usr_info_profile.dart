import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:my_app/model/usr/user/usr_simple_dto.dart';
import 'package:my_app/providers/user_cud_providers.dart';
import 'package:my_app/util/error_message_utils.dart';
import 'package:my_app/util/screen_ratio.dart' show ScreenRatio;
import 'package:my_app/view/tab/usr/sign_progress/nicname_input_page.dart';
import 'package:path/path.dart' as path show basename;

// ignore: must_be_immutable
class UsrInfoProfile extends ConsumerWidget {
  final UserSimpleDto userInfo;
  UsrInfoProfile({
    super.key,
    required this.userInfo,
  
  });
  var htio = 0.0;
  var wtio = 0.0;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    htio = ScreenRatio(context).heightRatio;
    wtio = ScreenRatio(context).widthRatio;

    return Column(
      children: [
        Container(
            height: 1 * htio,
            decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
        ),
        Container(
          padding: EdgeInsets.only(left: 20 * wtio, right: 20 * wtio, top: 25 * htio, bottom: 26 * htio),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: 80 * wtio,
                    height: 80 * wtio,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: userInfo.imgPath == null
                      ? SvgPicture.asset(
                          'assets/widgets/default_user_profile.svg',
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          userInfo.imgPath!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return SvgPicture.asset(
                              'assets/widgets/default_user_profile.svg',
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                    ),
                  ),
                  // 우측 하단 카메라 아이콘
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                          _showProfileImageOptions(context, ref); 
                      },
                      child: Container(
                        width: 28 * wtio,
                        height: 28 * htio,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1 * wtio,
                          ),
                        ),
                        child: Icon(
                          Icons.camera,
                          color: Colors.grey.shade600,
                          size: 20 * wtio,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // 연동 sns + 닉네임
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16 * wtio, vertical: 10 * htio),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userInfo.snsType != null ? '${userInfo.snsType!.displayName} 계정 연결 중' : '',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14 * htio,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          height: 1.5 * htio,
                        ),
                      ),
                      SizedBox(height: 4 * htio),
                      Row(
                        spacing: 6 * wtio,
                        children: [
                          Text(
                            userInfo.nickname,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20 * htio,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.bold,
                              height: 1.6 * htio,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              try {
                                final nickname = await context.push<String>('/usr/nicknameInput');

                                if(nickname == null || nickname == '') return;

                                final service = await ref.read(userCudServiceProvider.future);
                                final response = await service.updateNickname(nickname);
                                if(response == 'success'){
                                  if(!context.mounted) return;
                                  ref.invalidate(usrSimpleInfoProvider);
                                  showAppMessage(context, message: '닉네임이 수정되었습니다.');
                                }
                              }catch(e) {
                                if(!context.mounted) return;
                                showAppMessage(context, message: '닉네임이 수정에 실패하였습니다.', type: AppMessageType.dialog);
                              }
                            },
                            child: SizedBox(
                              width: 18 * wtio,
                              height: 18 * htio,
                              child: SvgPicture.asset(
                                'assets/icons/reply/update_feed.svg',
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                  Colors.grey.shade900,        // 적용할 색
                                  BlendMode.srcIn,    // 원래 svg 색을 덮어씀
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        Container(
            height: 8 * htio,
            decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
        ),
      ],
    );
  }

    // 프로필 이미지 옵션 바텀 시트를 보여주는 함수
  void _showProfileImageOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)), // 둥근 모서리
      ),
      builder: (BuildContext bc) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20 * wtio, vertical: 20 * htio),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Material( // 탭 애니메이션을 위해 Material 위젯 사용
                color: Colors.white, // 하얀색 배경
                shape:  const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22)), // 둥근 모서리 유지
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15), // 탭 효과도 둥글게
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickImage(context, ref, ImageSource.gallery);
                  },
                  child: Container(
                    height: 55 * htio, // 세로 폭
                    alignment: Alignment.center,
                    child: Text(
                      '갤러리에서 선택',
                      style: TextStyle(
                        fontSize: 16 * htio,
                        color:Colors.grey.shade900,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 0.5 * htio), // 마진 역할을 하는 간격
              Material(
                color: Colors.white,
                shape:  const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)), // 둥근 모서리 유지
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15), // 탭 효과도 둥글게
                  onTap: () async {
                    Navigator.pop(context);
                     await _deleteProfileImage(context, ref);
                  },
                  child: Container(
                    height: 55 * htio, // 세로 폭
                    alignment: Alignment.center,
                    child: Text(
                      '프로필 이미지 삭제',
                      style: TextStyle(
                        fontSize: 16 * htio,
                        color:Colors.red,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }


  // 갤러리에서 이미지 선택 및 업로드 함수
  Future<void> _pickImage(BuildContext context, WidgetRef ref, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      // 로딩 상태 시작 (로딩 프로바이더가 있다고 가정)
      try {
        final String? mimeType = lookupMimeType(pickedFile.path);
        MediaType? contentType;
        if (mimeType != null) {
          final List<String> parts = mimeType.split('/');
          if (parts.length == 2) {
            contentType = MediaType(parts[0], parts[1]);
          }
        }
        MultipartFile multipartFile = MultipartFile.fromFileSync(
            pickedFile.path,
            filename: path.basename(pickedFile.path),
            contentType: contentType, // 추론된 MediaType을 넘겨줍니다.
        );

        final service = await ref.read(userCudServiceProvider.future);
        final response = await service.createOrUpdateProfileImage(imageFile: multipartFile);

        // 성공 시 메시지 표시 및 UI 업데이트
        if (context.mounted && response=='success') {
          showAppMessage(context, message: '프로필 이미지가 업로드되었습니다.');
          ref.invalidate(usrSimpleInfoProvider); // 사용자 정보 프로바이더 새로고침
        }
      } catch (e) {
        // 에러 메시지 표시
        if (context.mounted) {
          showAppMessage(context, message: '이미지 업로드에 실패하였습니다.');
        }
      } finally {
      }
    }
  }

  // 프로필 이미지 삭제 함수
  Future<void> _deleteProfileImage(BuildContext context, WidgetRef ref) async {
    try {
      final service = await ref.read(userCudServiceProvider.future);
      final response = await service.deleteProfileImage();
      // 성공 시 메시지 표시 및 UI 업데이트
      if (context.mounted && response == 'success') {
        showAppMessage(context, message: '프로필 이미지가 삭제되었습니다.');
        ref.invalidate(usrSimpleInfoProvider); // 사용자 정보 프로바이더 새로고침
      }
    } catch (e) {
      // 에러 메시지 표시
      if (context.mounted) {
        showAppMessage(context, message: '프로필 이미지 삭제에 실패하였습니다.');
      }
    } finally {
    }
  }
}
