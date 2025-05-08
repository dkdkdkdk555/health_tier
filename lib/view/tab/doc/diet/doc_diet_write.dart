import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter, LengthLimitingTextInputFormatter;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:my_app/extension/limit_value_formatter.dart' show LimitValueFormatter;
import 'package:my_app/extension/screen_ratio_extension.dart';
import 'package:my_app/model/diet/diet_input_data.dart' show DietInputData;
import 'package:my_app/model/diet/doc_diet_model.dart';
import 'package:my_app/providers/db_providers.dart';
import 'package:my_app/util/hoverable_icon.dart';
import 'package:my_app/util/saving_success_dialog.dart';


class DocDietWrite extends ConsumerStatefulWidget {
  const DocDietWrite({
    super.key,
    required this.focusDay,
    required this.onSaved,
  });
  final DateTime focusDay;
  final VoidCallback onSaved; // 입력or수정 완료시 콜백 호출

  @override
  ConsumerState<DocDietWrite> createState() => _DocDietWriteState();
}

var htio = 0.0;
var wtio = 0.0;


class _DocDietWriteState extends ConsumerState<DocDietWrite> {
  late DateTime focusedDay;

  bool _isPressed = false;

  List<DietInputData> inputList = [DietInputData.def()];


  @override
  void initState() {
    super.initState();

    focusedDay = widget.focusDay;

    final searchDay = DateFormat('yyyy-MM-dd').format(focusedDay);
    ref.read(selectDietDayDoc(searchDay).future).then((dietList) {
      if (inputList.length == 1 && inputList.first.isEmpty && dietList.isNotEmpty) {
        setState(() {
          inputList = dietList.map((e) {
            final dto = DietInputData.def();
            dto.id = e.id;
            dto.mealType.text = e.title ?? '';
            dto.dietText.text = e.diet ?? '';
            dto.calorie.text = e.formattedCalorie;
            dto.protein.text = e.formattedProtein;
            return dto;
          }).toList();
        });
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
                        makeBorder(),//여기 밑으로 flex 342
                        Expanded(
                          flex: 297,
                          child: SingleChildScrollView(
                            child: Column(
                            children: [
                              ...List.generate(inputList.length, (index) {
                                final input = inputList[index];
                                return Column(
                                  children: [
                                    // 식사유형
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: TextField(
                                            controller: input.mealType,
                                            inputFormatters: [
                                              LengthLimitingTextInputFormatter(12), // 최대 100자 제한
                                            ],
                                            decoration: getInputDecoration('식사 유형'),
                                            onChanged: (value) {
                                              input.mealType.text = value;
                                              input.isUpdate = true;
                                            }
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: HoverableIcon(
                                            icon: Icons.remove_circle_outline,
                                            originColor: Colors.grey,
                                            changedColor: Colors.red,
                                            onTap: () async {
                                              final deleteId = input.id; // DayDietModel의 id
                                              if (deleteId != -1) {
                                                await deleteHtDietDoc(ref: ref, id: deleteId);
                                              }
                                              setState(() {
                                                inputList.removeAt(index);
                                              });

                                              widget.onSaved();
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 6 * htio),
                                
                                    // 식단내용 + 칼로리/단백질
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // 식단내용
                                        Expanded(
                                          flex: 8,
                                          child: SizedBox(
                                            height: 100*htio,
                                            child: TextField(
                                              controller: input.dietText,
                                              textAlignVertical: TextAlignVertical.top,
                                              expands: true,
                                              maxLines: null,
                                              keyboardType: TextInputType.multiline,
                                              textInputAction: TextInputAction.newline,
                                              inputFormatters: [
                                                LengthLimitingTextInputFormatter(150), // 최대 100자 제한
                                              ],
                                              style: TextStyle(
                                                fontSize: 13.5 * htio,
                                                fontFamily: 'Pretendard',
                                                height: 1.2 * htio
                                              ),
                                              decoration: getInputDecoration('식단을 입력해주세요.\n(최대 150자)'),
                                              onChanged: (value) {
                                                input.dietText.text = value;
                                                input.isUpdate = true;
                                              }
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 7),
                                
                                        // 칼로리 + 단백질
                                        Expanded(
                                          flex: 4,
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 48,
                                                child: TextField(
                                                  controller: input.calorie,
                                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                  decoration: getInputDecoration('칼로리'),
                                                  inputFormatters: [
                                                    LimitValueFormatter(max: 9999.9),
                                                    FilteringTextInputFormatter.allow(RegExp(r'^(\d{0,4})(\.\d?)?$')),
                                                  ],
                                                  onChanged: (value) {
                                                    input.calorie.text = value;
                                                    input.isUpdate = true;
                                                  }
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              SizedBox(
                                                height: 48,
                                                child: TextField(
                                                  controller: input.protein,
                                                  decoration: getInputDecoration('단백질'),
                                                  inputFormatters: [
                                                    LimitValueFormatter(max: 999.9),
                                                    FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}(\.\d{0,})?$')),
                                                  ],
                                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                  onChanged: (value) {
                                                    input.protein.text = value;
                                                    input.isUpdate = true;
                                                  }
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    makeBorder(),
                                    const SizedBox(height: 16),
                                  ],
                                );
                              }),

                              // 하단 고정 추가 버튼
                              Align(
                                alignment: Alignment.center,
                                child: TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      inputList.add(DietInputData.def());
                                    });
                                  },
                                  icon: const Icon(Icons.add_circle_outline),
                                  label: const Text('식단 추가'),
                                ),
                              ),
                            ],
                            ),
                          ),
                        ),
                        requestBtn(),
                        const Spacer(flex: 18),
                      ]
                    )
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

  InputDecoration getInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 14 * htio,
        fontWeight: FontWeight.w400,
        fontFamily: 'Pretendard',
        color: const Color(0xFF999999),
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
        borderSide: BorderSide(
          color: const Color(0xFF0D86E7),
          width: 1.5 * wtio,
        ),
      ),
      suffixText: hint == '칼로리' ? 'kcal' : (hint == '단백질' ? 'g' : ''),
      suffixStyle: hint == '칼로리' || hint == '단백질' 
                ? TextStyle(
                  color: const Color(0xFF999999),
                  fontSize: 14 * htio,
                  fontFamily: 'Pretendard',
                ) 
                : null,
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
              final String day = DateFormat('yyyy-MM-dd').format(focusedDay);

              final insertList = <DayDietModel>[];
              final updateList = <DayDietModel>[];

              try {

                for (final input in inputList) {
                  debugPrint('엠티::: ${input.isEmpty}');
                  debugPrint('수정여부::: ${input.isUpdate}');
                  if(input.isEmpty) {
                    
                    continue;
                  }
                  final title = input.mealType.text;
                  final diet = input.dietText.text;
                  final calorie = double.tryParse(input.calorie.text);
                  final protein = double.tryParse(input.protein.text);

                  final model = DayDietModel(
                    id: input.id,
                    day: day,
                    title: title,
                    diet: diet,
                    calorie: calorie,
                    protein: protein,
                  );

                  if (input.id != -1) {
                    if(input.isUpdate) updateList.add(model);
                  } else {
                    insertList.add(model);
                  }
                }

                if (insertList.isNotEmpty) {
                  await insertHtDietDoc(ref: ref, list: insertList);
                }

                if (updateList.isNotEmpty) {
                  await updateHtDietDoc(ref: ref, list: updateList);
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

              } catch(e) {
                if (mounted) {
                  Navigator.of(context).pop(); // 로딩 닫기

                  showDialog( // 실패 시
                    context: context,
                    builder: (_) => const AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error, color: Colors.red, size: 48),
                          SizedBox(height: 16),
                          Text('저장 중 오류 발생/n'),
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

  Container makeBorder() {
    return Container(
      height: 1,
      decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
    );
  }
}