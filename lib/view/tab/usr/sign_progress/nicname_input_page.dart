import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/providers/usr_auth_providers.dart';
import 'package:my_app/util/error_message_utils.dart' show showAppMessage;
import 'package:my_app/util/spinner_utils.dart' show AppLoadingIndicator;

class NicknameInputPage extends ConsumerStatefulWidget { // StatefulWidget 대신 ConsumerStatefulWidget 사용
  const NicknameInputPage({super.key});

  @override
  ConsumerState<NicknameInputPage> createState() => _NicknameInputPageState(); // State도 ConsumerState로 변경
}

class _NicknameInputPageState extends ConsumerState<NicknameInputPage> {
  final TextEditingController _nicknameController = TextEditingController();
  String _lastCheckedNickname = ''; // 마지막으로 중복 검사한 닉네임
  bool _showDuplicateWarning = false; // 닉네임 중복 경고 표시 여부
  bool _isCheckingNickname = false; // 닉네임 중복 검사 API 호출 중인지 여부

   final int _maxLength = 14; // 최대 글자 수 제한
   bool _showLengthWarning = false;  // 글자 수  제한 경고 표시 여부


  @override
  void initState() {
    super.initState();
    // TextField 텍스트 변경을 감지하는 리스너 추가
    _nicknameController.addListener(_onNicknameChanged);
  }

  @override
  void dispose() {
    // 리스너 해제 및 컨트롤러 해제
    _nicknameController.removeListener(_onNicknameChanged);
    _nicknameController.dispose();
    super.dispose();
  }

   // TextField 텍스트 변경 시 호출될 리스너 메서드
  void _onNicknameChanged() {
    final currentText = _nicknameController.text.trim();
    bool isTooLong = currentText.length > _maxLength;

    // 1. 글자수 경고 처리
    if (isTooLong != _showLengthWarning) {
      setState(() {
        _showLengthWarning = isTooLong; // 글자수 초과 시 경고 표시
      });
    }

    // 2. 중복 경고 처리
    // 현재 입력된 닉네임이 마지막으로 검사했던 닉네임과 다르면 중복 경고 숨김
    if (currentText != _lastCheckedNickname) {
      if (_showDuplicateWarning) {
        setState(() {
          _showDuplicateWarning = false;
        });
      }
    }
  }

  void _submitNickname(BuildContext context) async {
    final nickname = _nicknameController.text.trim();

    // 닉네임이 비어있는 경우
    if (nickname.isEmpty) {
      showAppMessage(context, message: '닉네임을 입력해주세요');
      return;
    }

    if (nickname.length > _maxLength) {
      // 닉네임이 16자를 초과하면 경고를 표시하고 API 호출을 중단합니다.
      // 이미 _onNicknameChanged에서 _showLengthWarning이 true로 설정되었을 것입니다.
      showAppMessage(context, message: '닉네임은 최대 $_maxLength자까지 입력 가능합니다.');
      return;
    }

    // 이미 검사 중인 경우 중복 호출 방지
    if (_isCheckingNickname) {
      return;
    }

    // 검사 시작 전 상태 업데이트
    setState(() {
      _isCheckingNickname = true; // 로딩 상태 시작
      _showDuplicateWarning = false; // 새로운 검사를 시작하므로 이전 경고 숨김
    });

    try {
      // isUserNicknameDupliateProvider를 통해 닉네임 중복 검사 API 호출
      // .future를 사용하여 FutureProvider의 실제 Future를 await합니다.
      final isDuplicate = await ref.read(isUserNicknameDupliateProvider(nickname).future);

      // 검사 결과에 따라 상태 업데이트
      setState(() {
        _lastCheckedNickname = nickname; // 마지막으로 검사한 닉네임 저장
        _showDuplicateWarning = isDuplicate; // 중복 여부에 따라 경고 표시
      });

      if (isDuplicate) {
        debugPrint('입력한 닉네임 "$nickname"은(는) 이미 사용 중입니다.');
        // 경고 메시지는 TextField의 errorText로 표시되므로 별도의 스낵바는 생략
      } else {
        debugPrint('입력한 닉네임 "$nickname"은(는) 사용 가능합니다.');
        // 닉네임 사용 가능 시 다음 단계로 이동
        if(!context.mounted)return;
        Navigator.pop(context, nickname); // 또는 다음 화면으로 이동
      }
    } catch (e) {
      // API 호출 중 오류 발생 시 처리
      debugPrint('닉네임 중복 검사 중 오류 발생: $e');
      // 오류 발생 시 경고 숨김
      setState(() {
        _showDuplicateWarning = false;
      });
    } finally {
      // 검사 종료 후 로딩 상태 해제
      setState(() {
        _isCheckingNickname = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 현재 표시할 에러 메시지 결정
    String? errorText;
    if (_showLengthWarning) {
      errorText = '닉네임은 $_maxLength자까지만 입력 가능합니다.';
    } else if (_showDuplicateWarning) {
      errorText = '이미 사용 중인 닉네임입니다.';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('닉네임 설정'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              '사용하실 닉네임을 입력해주세요',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nicknameController,
              maxLength: _maxLength, 
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF2b2b2b),
                hintText: '닉네임 입력 (최대 $_maxLength자)',
                counterText: '',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                // ✅ 닉네임 중복 경고 메시지 표시
                errorText: errorText,
                errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 14), // 경고 메시지 스타일
              ),
            ),
            // ✅ 닉네임 검사 중일 때 로딩 인디케이터 표시
            if (_isCheckingNickname)
              const Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: AppLoadingIndicator(),
              )
            else
              const SizedBox(height: 10), // 로딩 인디케이터가 없을 때도 적절한 간격 유지
            
            const SizedBox(height: 10), // 기존 SizedBox(height: 20)를 두 개의 10으로 분리

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  /*
                    onPressed는 VoidCallback 을 리턴받아야하는데
                    onPressed: _submitNickname() 형식으로 하면 void 를 리턴받기 때문에 컴파일 오류가 남
                    그래서 () {

                    } 을 해줘야 이게 voidCallback임 그 안에 함수 실행하는 코드를 둬야 함!
                  */
                  _submitNickname(context);
                }, // 버튼 클릭 시 닉네임 검사 및 처리
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '확인',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}