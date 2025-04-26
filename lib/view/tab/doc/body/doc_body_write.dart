import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:my_app/extension/screen_ratio_extension.dart';
import 'package:my_app/model/doc_detail_model.dart';
import 'package:my_app/providers/db_providers.dart';
import 'package:flutter/services.dart';
import 'package:my_app/extension/limit_value_formatter.dart';
import 'package:my_app/util/saving_success_dialog.dart';

class DocBodyWrite extends ConsumerStatefulWidget {
  const DocBodyWrite({
    super.key,
    required this.focusDay,
    required this.onSaved,
  });

  final DateTime focusDay;
  final VoidCallback onSaved; // 입력or수정 완료시 콜백 호출

  @override
  ConsumerState<DocBodyWrite> createState() => _DocBodyWriteState();
}

var htio = 0.0;
var wtio = 0.0;

class _DocBodyWriteState extends ConsumerState<DocBodyWrite> {

  late DateTime focusedDay;

  late TextEditingController weightEditor;
  late TextEditingController muscleEditor;
  late TextEditingController bodyFatEditor;
  late TextEditingController memoEditor;

  // bool initialized = false;
  bool wkoutYn = false;
  bool drunkYn = false;
  String selectedStamp = '';
  late int docId;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    focusedDay = widget.focusDay;

    weightEditor = TextEditingController();
    muscleEditor = TextEditingController();
    bodyFatEditor = TextEditingController();
    memoEditor = TextEditingController();

    // 초기 데이터 주입
    final searchDay = DateFormat('yyyy-MM-dd').format(focusedDay);
    ref.read(selectHtDayDoc(searchDay).future).then((doc) {
      if (doc != null && doc.id != -1) {
        setState(() {
          docId = doc.id;
          weightEditor.text = doc.weight.toString();
          muscleEditor.text = doc.muscle.toString();
          bodyFatEditor.text = doc.fat.toString();
          memoEditor.text = doc.memo ?? '';
          drunkYn = doc.drunYn == 1;
          wkoutYn = doc.workYn == 1;
          selectedStamp = doc.stamp ?? '';
          // initialized = true;
        });
      } else {
        docId = -1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    htio = ScreenRatio(context).heightRatio;
    wtio = ScreenRatio(context).widthRatio;    

    final displayDay = DateFormat('yyyy.MM.dd (E)', 'ko').format(focusedDay);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(47)),
        border: Border(
          left: BorderSide(width: 2 * wtio ,color: const Color(0xFFEEEEEE)),
          top: BorderSide(width: 2 * wtio, color: const Color(0xFFEEEEEE)),
          right: BorderSide(width: 2 * wtio, color: const Color(0xFFEEEEEE)),
          bottom: const BorderSide(color: Color(0xFFEEEEEE)),
        ),
      ),
      child: Column(
        children: [
          const Spacer(flex:2),
          Expanded(
            flex:1,
            child: Container(
              width: 40 * wtio,
              height: 4 * htio,
              decoration: ShapeDecoration(
                color: const Color(0xFFE6E6E6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                ),
              ),
            )
          ),
          const Spacer(flex:4),
          Expanded(
            flex: 180,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Row(
                children: [
                  const Spacer(flex:4),
                  Expanded(
                    flex: 67,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            flex: 15,
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: 
                                Text(
                                  displayDay,
                                  style: TextStyle(
                                    color: const Color(0xFF777777),
                                    fontSize: 13.7 * htio,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w500
                                  ),
                                ),
                            ),
                          ),
                          makeBorder(),
                          const Spacer(flex: 12),
                          inputArea('체중', 'kg', weightEditor),
                          const Spacer(flex: 12),
                          inputArea('골격근', 'kg', muscleEditor),
                          const Spacer(flex: 12),
                          inputArea('체지방률', '%', bodyFatEditor),
                          const Spacer(flex: 12),
                          textArea(memoEditor),
                          const Spacer(flex: 12),
                          buttonArea(),
                          const Spacer(flex: 16),
                          makeBorder(),
                          const Spacer(flex: 16),
                          const InfoText(flex: 9),
                          const Spacer(flex: 8),
                          setStampCollection(),
                          const Spacer(flex: 20),
                          requestBtn(),
                          const Spacer(flex: 18),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(flex:4),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Expanded requestBtn() {
    return Expanded(
      flex: 27,
      child: Align(
        alignment: Alignment.center,
        child: FractionallySizedBox(
          widthFactor: 1, // 부모(Row)의 width만큼 가로로 꽉 채움
          child: GestureDetector(
            onTapDown: (_) {
              setState(() {
                _isPressed = true;
              });
            },
            onTapUp: (_) {
              setState(() {
                _isPressed = false;
              });
            },
            onTapCancel: () {
              setState(() {
                _isPressed = false;
              });
            },
            onTap: () async {

              final day = DateFormat('yyyy-MM-dd').format(focusedDay);
              final weight = double.tryParse(weightEditor.text) ?? 0;
              final muscle = double.tryParse(muscleEditor.text) ?? 0;
              final fat = double.tryParse(bodyFatEditor.text) ?? 0;
              final memo = memoEditor.text;

              try {
                if (docId == -1) {
                  await insertHtDayDoc(
                    ref: ref,
                    doc: DocDayDetail(id: -1, day: day, weight: weight, muscle: muscle,
                          fat: fat, memo: memo, workYn: wkoutYn ? 1 : 0, drunYn: drunkYn ? 1 : 0, stamp: selectedStamp)
                  );
                } else {
                  await updateHtDayDoc(
                    ref: ref,
                    doc: DocDayDetail(id: docId, day: day, weight: weight, muscle: muscle,
                          fat: fat, memo: memo, workYn: wkoutYn ? 1 : 0, drunYn: drunkYn ? 1 : 0, stamp: selectedStamp)
                  );
                }

                // 저장 성공 시 메시지
                if (mounted) {
                  
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) {
                      return const SuccessAfterLoadingDialog();
                    },
                  );
                  
                  widget.onSaved();
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop(); // 로딩 닫기

                  showDialog( // 실패 시
                    context: context,
                    builder: (_) => AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          Text('저장 중 오류 발생/n$e'),
                        ],
                      ),
                    ),
                  );
                }
              } 
          },
          child: AnimatedContainer(
            height: double.infinity, // 세로는 flex: 27 높이 채우기
            duration: const Duration(milliseconds: 300), // 300ms 부드럽게 변화
            curve: Curves.easeInOut, // 자연스러운 곡선 사용
            decoration: ShapeDecoration(
              color:  _isPressed 
                ? const Color.fromARGB(255, 81, 172, 230) // 눌렀을 때 더 연한 색 (원래색보다 밝은 블루)
                : const Color(0xFF0D85E7), // 기본 색
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Center(
              child: Text(
                  '확인',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16 * htio,
                    fontFamily: 'Pretendard',
                  ),
                ),
            ),
          ),
          ),
        ),
      ),
    );
  }

  Expanded setStampCollection() {
    final stampCollect = ['perfect', 'good', 'normal', 'bad', 'terrible'];

    return Expanded(
      flex: 31,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: stampCollect.map((stampName) {
          final isSelected = stampName == selectedStamp;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedStamp = stampName;
              });
            },
            child: SizedBox(
              width: 56.94 * wtio,
              height: 56.94 * htio,
              child: SvgPicture.asset(
                isSelected
                    ? 'assets/icons/stamp_100_$stampName.svg'
                    : 'assets/icons/stamp_$stampName.svg',
                fit: BoxFit.contain,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }



  Container makeBorder() {
    return Container(
      height: 1,
      decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
    );
  }

  Expanded buttonArea() {
    return Expanded(
      flex: 17,
      child: Row(
        children: [
          Expanded(
            flex: 78,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '운동/음주',
                style: TextStyle(
                    color: const Color(0xFF333333),
                    fontSize: 14.5 * htio,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                    height: 0.09 * htio,
                ),
              )
            )
          ),
          Expanded(
            flex: 257,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  makeYnButton('운동 여부', 'assets/icons/work_out.svg', wkoutYn, () {
                    setState(() {
                      wkoutYn = !wkoutYn;
                    });
                  }),
                  const SizedBox(width: 17),
                  makeYnButton('음주 여부', 'assets/icons/drink.svg', drunkYn, () {
                    setState(() {
                      drunkYn = !drunkYn;
                    });
                  }),
                ],
              ),
            )
          )
        ],
      ),
    );
  }

  GestureDetector makeYnButton(String text, String iconPath, bool yn, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          width: 89 * wtio,
          height: 34 * htio,
          padding: EdgeInsets.symmetric(horizontal: 12 * wtio, vertical: 8 * htio),
          decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: yn == true ? const Color(0xFF333333) : const Color(0xFFAAAAAA),),
          borderRadius: BorderRadius.circular(99),
          ),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                  text,
                  style: TextStyle(
                    color: yn == true ? const Color(0xFF333333) : const Color(0xFFAAAAAA),
                    fontSize: 11 * htio,
                    fontFamily: 'Pretendard',
                    height: 0.12 * htio,
                ),
              ),
            ),
            Expanded(
              child: SvgPicture.asset(
                iconPath,
                colorFilter: ColorFilter.mode(
                  yn == true ? const Color(0xFF333333) : const Color(0xFFAAAAAA),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        )
      ),
    );
  }

  Expanded textArea(TextEditingController editor) {
    return Expanded(
      flex: 48,
      child: Row(
        children: [
          Expanded(
            flex: 78,
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                '메모',
                style: TextStyle(
                  color: const Color(0xFF333333),
                  fontSize: 14.5 * htio,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  height: 3 * htio
                ),
              ),
            ),
          ),
          Expanded(
            flex: 257,
            child: TextField(
              controller: editor,
              maxLines: null, // 여러 줄
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              expands: true, // 남은 공간 전체 사용 -> 이거 해야 height flex:48 다 차지함
              inputFormatters: [
                LengthLimitingTextInputFormatter(100), // 최대 100자 제한
              ],
              style: TextStyle(
                fontSize: 12.5 * htio,
                fontFamily: 'Pretendard',
                height: 1.2 * htio
              ),
              decoration: InputDecoration(
                hintText: '메모를 입력해주세요. (최대 100자)\n',
                hintStyle: TextStyle(
                  color: const Color(0xFF999999),
                  fontSize: 13.5 * htio,
                  fontFamily: 'Pretendard',
                  height: 4 * htio,
                ),
                contentPadding: const EdgeInsets.all(12), // 여백 추가
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFFDDDDDD),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF0D86E7),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget inputArea(String text, String unit, TextEditingController editor) {
    return Expanded(
      flex: 24,
      child: Row(
        children:[
          Expanded(
            flex: 78,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  text,
                  style: TextStyle(
                      color: const Color(0xFF333333),
                      fontSize: 14.5 * htio,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      height: 0.09 * htio,
                  ),
              )
            )
          ),
          Expanded(
            flex: 257,
            child: TextField(
              controller: editor,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.right, 
              inputFormatters: [
                LimitValueFormatter(max: 999.9),
                FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}(\.\d{0,})?$')),
              ],
              decoration: InputDecoration(
                suffixText: unit,
                suffixStyle: TextStyle(
                  color: const Color(0xFF999999),
                  fontSize: 16 * htio,
                  fontFamily: 'Pretendard',
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFFDDDDDD),
                    width: 1,
                  )
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF0D86E7), // 클릭 시 파란색 테두리
                    width: 1.5,
                  ),
                ),
              ),
            ),
          )
        ]
      ),
    );
  }
}

class InfoText extends StatelessWidget {
  const InfoText({
    super.key,
    required this.flex
  });

  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded( // Text
      flex: flex,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '당신의 하루를 평가해주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: const Color(0xFF777777),
                fontSize: 12 * htio,
                fontFamily: 'Pretendard',
            ),
          )
        ],
      ),
    );
  }
}