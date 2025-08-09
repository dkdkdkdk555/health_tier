import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_app/model/cmu/reply/reply_write_request_dto.dart';
import 'package:my_app/model/cmu/reply/selected_reply_info.dart';
import 'package:my_app/providers/feed_providers.dart';
import 'package:my_app/providers/notifier_provider.dart';
import 'package:my_app/providers/reply_cud_providers.dart'; // replyCommentSupplyNotifierProvider 경로 확인

class ReplyBottomBar extends ConsumerStatefulWidget {
  final int cmuId;
  const ReplyBottomBar({
    required this.cmuId,
    super.key,
  });

  @override
  ConsumerState<ReplyBottomBar> createState() => _ReplyBottomBarState();
}

class _ReplyBottomBarState extends ConsumerState<ReplyBottomBar> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textEditingController = TextEditingController();

  double _barHeight = 106;
  bool _showSendButton = false;

  Color _textFieldBorderColor = const Color(0xFFDDDDDD);
  Color _sendButtonColor = const Color(0xFFCCCCCC);

  final GlobalKey _textFieldKey = GlobalKey();
  double _textFieldHeight = 37; // 기본 높이

  String _currentReplyTargetComment = ''; // 현재 답글 대상 댓글 내용 저장
  // 답글 대상 텍스트가 표시될 높이 (대략 한 줄 높이 + 패딩)
  final double _replyTargetHeight = 30.0; // 답글 대상 텍스트 영역 높이
  

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _textEditingController.addListener(_onTextChanged);

    // initState에서는 context가 완전히 빌드되지 않았으므로 didChangeDependencies에서 초기 comment 처리
    // 또는 `WidgetsBinding.instance.addPostFrameCallback` 사용
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant ReplyBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void _onReplyClicked(String comment, bool isUpdate){
    if(!isUpdate) {
      if (comment != _currentReplyTargetComment && comment.isNotEmpty) {
        _currentReplyTargetComment = _truncateComment(comment);
        // 새로운 답글 대상이 생겼을 때 키보드 올리기
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _focusNode.requestFocus();
          _updateBarHeight();
        });
      } else if (comment.isEmpty && _currentReplyTargetComment.isNotEmpty) {
        // comment가 비워졌을 때 답글 대상 제거
        _currentReplyTargetComment = '';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateBarHeight();
        });
      }
    } else {
      _textEditingController.text = comment;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
        _updateBarHeight();
      });
    }
  }


@override
void dispose() {
  _focusNode.removeListener(_onFocusChange);
  _textEditingController.removeListener(_onTextChanged);
  _focusNode.dispose();
  _textEditingController.dispose();

  super.dispose();
}

  void _onFocusChange() {
    setState(() {
      if (_focusNode.hasFocus) {
        _showSendButton = true;
        _updateBarHeight();
      } else {
        _currentReplyTargetComment = '';
        ref.read(replySupplyNotifierProvider).disposeReplyState();
        if (_textEditingController.text.isEmpty && _currentReplyTargetComment.isEmpty) {
          // 텍스트도 비어있고 답글 대상도 없을 때만 바 숨김
          _barHeight = 106;
          _showSendButton = false;
        }
      }
    });
  }

  void _onTextChanged() {
    _updateColorsBasedOnText(_textEditingController.text.isNotEmpty);
    _updateTextFieldHeight(); // 텍스트 내용 변경 시 TextField 높이 업데이트
  }

  void _updateColorsBasedOnText(bool hasText) {
    setState(() {
      if (hasText) {
        _textFieldBorderColor = const Color(0xFF0D86E7);
        _sendButtonColor = const Color(0xFF0D86E7);
      } else {
        _textFieldBorderColor = const Color(0xFFDDDDDD);
        _sendButtonColor = const Color(0xFFCCCCCC);
      }
    });
  }

  void _updateTextFieldHeight() {
    // 다음 프레임에 렌더링된 TextField의 실제 높이를 측정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _textFieldKey.currentContext;
      if (context == null) return; // context가 null이면 함수 종료

      final RenderBox box = context.findRenderObject() as RenderBox;
      final newHeight = box.size.height;

      if (newHeight != _textFieldHeight) {
        setState(() {
          _textFieldHeight = newHeight;
          _updateBarHeight(); // TextField 높이 변경 시 바 높이도 업데이트
        });
      }
    });
  }

  // 전체 바 높이를 업데이트하는 로직
  void _updateBarHeight() {
    // 프로필 이미지, 텍스트 필드, 버튼의 고정/가변 높이와 패딩을 종합적으로 고려
    double calculatedBarHeight = 0;

    // 상단 여백 (프로필과 텍스트 필드 시작 위치)
    calculatedBarHeight += 23;

    // 답글 대상 표시 영역 높이 (있다면 추가)
    if (_currentReplyTargetComment.isNotEmpty) {
      calculatedBarHeight += _replyTargetHeight;
      calculatedBarHeight += 10; // 답글 대상과 TextField 사이 간격
    }

    // TextField의 현재 높이 (minHeight: 37, maxHeight: 120)
    calculatedBarHeight += _textFieldHeight;

    // TextField 아래쪽과 전송 버튼 사이의 여백 (또는 바닥 패딩)
    // 현재 레이아웃에서 전송 버튼의 top 위치에 따라 계산이 달라집니다.
    // 텍스트필드와 전송 버튼이 같은 레벨에 위치하고, 텍스트 필드가 늘어나는 만큼 버튼이 아래로 밀려나야 한다면
    // 텍스트 필드 아래에 추가 공간 + 버튼 높이 + 하단 패딩을 고려해야 합니다.
    // 여기서는 전송 버튼이 TextField 아래쪽에 위치한다고 가정하고 계산합니다.
    calculatedBarHeight += 15; // TextField 아래와 전송 버튼 사이의 최소 여백
    calculatedBarHeight += 31; // 전송 버튼의 높이
    calculatedBarHeight += 10; // 바닥 패딩 (Stack의 바닥에서 여유 공간)

    setState(() {
      _barHeight = calculatedBarHeight;
    });
  }

  // 댓글 내용 자르기 (최대 22글자 + ...)
  String _truncateComment(String comment) {
    if (comment.length > 22) {
      return '${comment.substring(0, 22)}...';
    }
    return comment;
  }

  Future<void> sendComment(int cmuId, WidgetRef ref) async {
    String commentText = _textEditingController.text.trim();
    if (commentText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('댓글을 입력해주세요')),
      );
      return;
    }
    
    // sendComment 함수가 호출될 때마다 최신 상태를 직접 읽어옵니다.
    final currentIsUpdate = ref.read(replySupplyNotifierProvider.select((notifier) => notifier.isUpdate));
    final currentReplyId = ref.read(replySupplyNotifierProvider.select((notifier) => notifier.selectedReplyId));
    final isReReply = ref.read(replySupplyNotifierProvider.select((notifier) => notifier.isReReply));

    if(isReReply){
      final nickNameTag =  '@${ref.read(replySupplyNotifierProvider.select((notifier) => notifier.nickname))}';
      debugPrint(nickNameTag);
      commentText = '$nickNameTag $commentText';
    }

    debugPrint(commentText);

    final dto = currentIsUpdate ? 
      ReplyWriteRequestDto(
        id: currentReplyId,
        cmuId: cmuId,
        ctnt: commentText,
      ):
      ReplyWriteRequestDto(
        cmuId: cmuId,
        ctnt: commentText,
        parentReplyId: currentReplyId == 0 ? null : currentReplyId,
      );

    try {
      final service = await ref.read(replyCudServiceProvider.future);
      final resultMessage = currentIsUpdate ? await service.updateReply(dto) : await service.writeReply(dto);

      // 성공 시 입력 초기화 및 댓글 목록 갱신
      _textEditingController.clear();
      _currentReplyTargetComment = '';
      _showSendButton = false;
      ref.read(replySupplyNotifierProvider).disposeReplyState();

      ref.invalidate(replyPaginationProvider(cmuId));
      ref.invalidate(feedDetailProvider(cmuId));

      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resultMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      _updateBarHeight();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;


    ref.listen<SelectedReplyInfo?>(
      replySupplyNotifierProvider.select((n) => n.pickReply),
      (previous, next) {
        final String replyComment = next?.comment ?? '';
        final bool isUpdate = next?.isUpdate ?? false;

        _onReplyClicked(replyComment, isUpdate);
      },
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      height: _barHeight + keyboardHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            width: 1,
            color: Color(0xFFEEEEEE),
          ),
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 20,
            top: 23,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 사용자 프로필 이미지
                Column(
                  children: [
                    Padding(
                      padding: _currentReplyTargetComment.isNotEmpty
                          ? EdgeInsets.only(top: _replyTargetHeight + 10,) // 답글 대상이 있으면 그만큼 아래로
                          : EdgeInsets.zero,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          'assets/widgets/default_user_profile.svg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: _textFieldHeight - 37, // 37 = 텍스트 필드 기본 높이, 프로필의 위치가 텍스트필드와 수평을 유지해야함.,
                    )
                  ],
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 답글 대상 댓글 표시 영역
                    if (_currentReplyTargetComment.isNotEmpty)
                      Container(
                        height: _replyTargetHeight,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _currentReplyTargetComment,
                              style: const TextStyle(
                                color: Color(0xFF555555),
                                fontSize: 12,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _currentReplyTargetComment = '';
                                  ref.read(replySupplyNotifierProvider).disposeReplyState();
                                  _barHeight = 116;
                                });
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Color(0xFF888888),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // 댓글 입력 필드
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: 37,
                        maxHeight: 120, // 텍스트 14px, height 1.5면 1줄 21px + 패딩 16 = 37px
                                         // 120px면 대략 4~5줄 정도 가능
                      ),
                      child: Container(
                        key: _textFieldKey,
                        width: 303,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1,
                              color: _textFieldBorderColor,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row( // 아이콘과 텍스트 필드를 위한 Row
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_currentReplyTargetComment.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(right: 4.0, top: 2.0), // 아이콘과 텍스트 필드 사이 간격
                                child: Icon(
                                  Icons.subdirectory_arrow_right_sharp,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            Expanded( // TextField가 남은 공간을 모두 차지하도록
                              child: TextField(
                                focusNode: _focusNode,
                                controller: _textEditingController,
                                onChanged: (_) => _updateTextFieldHeight(),
                                keyboardType: TextInputType.multiline,
                                maxLength: 250,
                                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                buildCounter: (
                                  BuildContext context, {
                                  required int currentLength,
                                  required bool isFocused,
                                  required int? maxLength,
                                }) {
                                  return null;
                                },
                                maxLines: null,
                                minLines: 1,
                                expands: false,
                                decoration: const InputDecoration(
                                  hintText: '댓글 달기',
                                  border: InputBorder.none,
                                  isCollapsed: true,
                                  contentPadding: EdgeInsets.zero,
                                  hintStyle: TextStyle(
                                    color: Color(0xFF999999),
                                    fontSize: 14,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w400,
                                    height: 1.50,
                                  ),
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF000000),
                                  fontSize: 14,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w400,
                                  height: 1.50,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 전송 버튼
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            right: 20,
            // 버튼 top 위치 재조정: bottom으로부터 계산하는 것이 더 쉬움
            // bottom: keyboardHeight + (_currentReplyTargetComment.isNotEmpty ? 16 : 22), // 답글 대상 유무에 따라 조정
            top: 30 + _textFieldHeight + (_currentReplyTargetComment.isEmpty ? 0 : _replyTargetHeight + 10),
            // Note: 이 'bottom' 값은 실제 레이아웃에 맞춰 세부 조정 필요합니다.
            child: AnimatedOpacity(
              opacity: _showSendButton ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: IgnorePointer(
                ignoring: !_showSendButton,
                child: GestureDetector(
                  onTap: () async {
                      await sendComment(widget.cmuId, ref);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: ShapeDecoration(
                      color: _sendButtonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    child: const Text(
                      '전송',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        height: 1.50,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}