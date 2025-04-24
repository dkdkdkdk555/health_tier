import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_app/extension/screen_ratio_extension.dart';

class DocBodyWrite extends StatefulWidget {
  const DocBodyWrite({super.key});

  @override
  State<DocBodyWrite> createState() => _DocBodyWriteState();
}

class _DocBodyWriteState extends State<DocBodyWrite> {
  @override
  Widget build(BuildContext context) {
    final htio = ScreenRatio(context).heightRatio;
    final wtio = ScreenRatio(context).widthRatio;    

    final TextEditingController _weightEditor = TextEditingController();
    final TextEditingController _muscleEditor = TextEditingController();
    final TextEditingController _bodyFatEditor = TextEditingController();
    final TextEditingController _memoEditor = TextEditingController();

    final stampCollect = ['perfect', 'good', 'normal', 'bad', 'terrible'];
  
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
                           const Expanded(
                            flex: 15,
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: 
                                Text(
                                  '2025.03.06 (목)',
                                  style: TextStyle(
                                    color: Color(0xFF777777),
                                    fontSize: 13.7,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w500
                                  ),
                                ),
                            ),
                          ),
                          makeBorder(),
                          const Spacer(flex: 12),
                          inputArea('체중', 'kg', _weightEditor),
                          const Spacer(flex: 12),
                          inputArea('골격근', 'kg', _muscleEditor),
                          const Spacer(flex: 12),
                          inputArea('체지방률', '%', _bodyFatEditor),
                          const Spacer(flex: 12),
                          textArea(_memoEditor),
                          const Spacer(flex: 12),
                          buttonArea(),
                          const Spacer(flex: 16),
                          makeBorder(),
                          const Spacer(flex: 16),
                          const Expanded( // Text
                            flex: 9,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '당신의 하루를 평가해주세요.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color(0xFF777777),
                                      fontSize: 12,
                                      fontFamily: 'Pretendard',
                                  ),
                                )
                              ],
                            ),
                          ),
                          const Spacer(flex: 8),
                          setStampCollection(stampCollect),
                          const Spacer(flex: 20),
                          Expanded(
                            flex: 27,
                            child: Align(
                              alignment: Alignment.center,
                              child: FractionallySizedBox(
                                widthFactor: 1, // 부모(Row)의 width만큼 가로로 꽉 채움
                                child: GestureDetector(
                                  onTap: () {
                                    // 버튼 클릭 로직
                                  },
                                  child: Container(
                                    height: double.infinity, // 세로는 flex: 27 높이 채우기
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFF0D85E7),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        '확인',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontFamily: 'Pretendard',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
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

  Expanded setStampCollection(List<String> stampCollect) {
    return Expanded(
      flex: 31,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: stampCollect.map((stampName) {
          return SizedBox(
            width: 56.94, // 아이콘 크기 제한
            height: 56.94,
            child: SvgPicture.asset(
              'assets/icons/stamp_$stampName.svg',
              fit: BoxFit.contain,
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
          const Expanded(
            flex: 78,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '운동/음주',
                style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 14.5,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                    height: 0.09,
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
                  makeYnButton('운동 여부', 'assets/icons/work_out.svg'),
                  const SizedBox(width: 17),
                  makeYnButton('음주 여부', 'assets/icons/drink.svg'),
                ],
              ),
            )
          )
        ],
      ),
    );
  }

  GestureDetector makeYnButton(String text, String iconPath) {
    return GestureDetector(
      onTap: () {
      },
      child: Container(
          width: 89,
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Color(0xFF333333)),
          borderRadius: BorderRadius.circular(99),
          ),
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 4),
              child: Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 11,
                    fontFamily: 'Pretendard',
                    height: 0.12,
                ),
              ),
            ),
            Expanded(
              child: SvgPicture.asset(
                iconPath,
                colorFilter: const ColorFilter.mode(
                Color(0xFF333333),
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
          const Expanded(
            flex: 78,
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                '메모',
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 14.5,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  height: 3
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
              decoration: InputDecoration(
                hintText: '메모를 입력해주세요. (최대 100자)\n',
                hintStyle: const TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 13.5,
                  fontFamily: 'Pretendard',
                  height: 4,
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

  Widget inputArea(String text, String unit, TextEditingController _editor) {
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
                  style: const TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 14.5,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      height: 0.09,
                  ),
              )
            )
          ),
          Expanded(
            flex: 257,
            child: TextField(
              controller: _editor,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                suffixText: unit,
                suffixStyle: const TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 16,
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