import 'dart:io' show File;

import 'package:dio/dio.dart' show DioException;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter, LengthLimitingTextInputFormatter;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource, XFile;
import 'package:intl/intl.dart';
import 'package:my_app/extension/limit_value_formatter.dart' show LimitValueFormatter;
import 'package:my_app/model/diet/diet_input_data.dart' show DietInputData;
import 'package:my_app/model/diet/doc_diet_model.dart';
import 'package:my_app/providers/db_providers.dart';
import 'package:my_app/providers/feed_cud_providers.dart';
import 'package:my_app/providers/usr_auth_providers.dart' show jwtTokenVerificationProvider;
import 'package:my_app/service/doc_api_service.dart';
import 'package:my_app/util/dialog_utils.dart';
import 'package:my_app/util/error_message_utils.dart' show AppMessageType, showAppMessage;
import 'package:my_app/util/hoverable_icon.dart';
import 'package:my_app/util/loading_dialog.dart' show showAiAnalysisLoadingDialog;
import 'package:my_app/util/saving_success_dialog.dart';
import 'package:my_app/util/screen_ratio.dart' show ScreenRatio;
import 'package:my_app/util/spinner_utils.dart';

class DocDietWrite extends ConsumerStatefulWidget {
  const DocDietWrite({
    super.key,
    required this.focusDay,
    required this.onSaved,
  });
  final DateTime focusDay;
  final VoidCallback onSaved;

  @override
  ConsumerState<DocDietWrite> createState() => _DocDietWriteState();
}

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

  // =========================================================================
  // 1. AI 이미지 분석용 바텀 시트 호출 메서드 추가
  // =========================================================================
  void _showImageSourcePicker(int index, DocApiService? docApiService) {
    FocusScope.of(context).unfocus(); // 혹시 모를 키보드 내리기

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 시트 높이 조절 가능
      backgroundColor: Colors.transparent, // 배경 투명 처리
      builder: (BuildContext context) {
        final wtio = ScreenRatio(context).widthRatio;
        final htio = ScreenRatio(context).heightRatio;

        final ImagePicker picker = ImagePicker();

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(22 * wtio),
              topRight: Radius.circular(22 * wtio),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20 * htio,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // 타이틀: AI 식사 이미지 분석 기능
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20 * wtio, vertical: 8 * htio),
                child: Text(
                  'AI 식단 영양성분 분석',
                  style: TextStyle(
                    fontSize: 17 * htio,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Pretendard',
                    color: const Color(0xFF333333),
                  ),
                ),
              ),
              Divider(height: 1 * htio, color: const Color(0xFFEEEEEE)),
              
              // 갤러리 선택 버튼
              _buildImageSourceItem(
                context,
                icon: Icons.photo_library_outlined,
                label: '갤러리',
                onTap: () async {
                  Navigator.pop(context); // 시트 닫기
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    debugPrint('식단 $index - 갤러리 이미지 경로: ${image.path}');
                    await analyzeRequest(image, docApiService, index);
                  }
                },
              ),

              // 카메라 선택 버튼
              _buildImageSourceItem(
                context,
                icon: Icons.camera_alt_outlined,
                label: '카메라',
                onTap: () async {
                  Navigator.pop(context); // 시트 닫기
                  final XFile? image = await picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    debugPrint('식단 $index - 카메라 이미지 경로: ${image.path}');
                    await analyzeRequest(image, docApiService, index);
                  }
                },
              ),
              SizedBox(height: 10 * htio),
            ],
          ),
        );
      },
    );
  }

   analyzeRequest(XFile image, DocApiService? docApiService, int index) async{
      if (docApiService == null) {
        // DocApiService가 null인 경우 (초기화 중이거나 에러 발생)
        showAppMessage(context, 
          message: '서비스 초기화 중입니다. 잠시 후 다시 시도해주세요.', 
          type: AppMessageType.dialog
        );
        return; // 널 값 오류 방지
      }

      showAiAnalysisLoadingDialog(context);

      try {
        final imageFile = File(image.path);
        // ! 대신 ?를 사용하여 널이 아님을 보장했으므로, 널 체크 연산자 제거
        final s = await docApiService.analyzeImage(imageFile); 
        
        // UI 업데이트
        if (mounted) {
          if(s == null) {
            return;
          }
          Navigator.of(context, rootNavigator: true).pop(); 
          setState(() {
            final input = inputList[index];
            input.mealType.text = s.foodName;
            input.dietText.text = s.description + (s.sugar!=0 ? ', 총 당류(g) : ${s.sugar}' : '');
            if(s.calories != 0) input.calorie.text = s.calories.toStringAsFixed(1);
            if(s.protein != 0)  input.protein.text = s.protein.toStringAsFixed(1);
            input.isUpdate = true;
          });
        }
      }on DioException catch (e) {
        if(mounted) {
          Navigator.of(context, rootNavigator: true).pop(); // 실패 시 닫기
          if(e.response?.statusCode == 423) {
            showAppMessage(context, message: e.response?.data['message'] ?? '오늘 무료 분석 횟수를 초과했습니다.', type: AppMessageType.dialog);
          }
        }
      } catch(e) {
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop(); // 실패 시 닫기
        }
        debugPrint('식단 분석 API 호출 에러: $e');
      }
    }

  // 바텀 시트의 각 항목을 구성하는 위젯
  Widget _buildImageSourceItem(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    final wtio = ScreenRatio(context).widthRatio;
    final htio = ScreenRatio(context).heightRatio;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20 * wtio, vertical: 15 * htio),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 24 * htio, color: const Color(0xFF333333)),
            SizedBox(width: 15 * wtio),
            Text(
              label,
              style: TextStyle(
                fontSize: 16 * htio,
                fontFamily: 'Pretendard',
                color: const Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    final htio = ScreenRatio(context).heightRatio;
    final wtio = ScreenRatio(context).widthRatio;
    final displayDay = DateFormat('yyyy.MM.dd (E)', 'ko').format(focusedDay);

     final docApiService = ref.watch(docApiServiceProvider).value;

    return GestureDetector(
       behavior: HitTestBehavior.opaque, // 빈 영역도 터치 가능
      onTap: () {
        FocusScope.of(context).unfocus(); // 키보드 내리기
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(47 * wtio)),
          border: Border.all(width: 2 * wtio, color: const Color(0xFFEEEEEE)),
        ),
        child: Column(
          children: [
            SizedBox(height: 12 * htio), // spacer 대체
            Container(
              width: 40 * wtio,
              height: 4 * htio,
              decoration: ShapeDecoration(
                color: const Color(0xFFE6E6E6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100 * wtio),
                ),
              ),
            ),
            SizedBox(height: 20 * htio), // spacer 대체
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16 * wtio)
                  .copyWith(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  children: [
                    // 날짜 표시
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        displayDay,
                        style: TextStyle(
                          color: const Color(0xFF777777),
                          fontSize: 13.7 * htio,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 8 * htio),
                    makeBorder(),
                    SizedBox(height: 16 * htio),
      
                    // 입력 리스트
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ...List.generate(inputList.length, (index) {
                              final input = inputList[index];
                              return Padding(
                                padding: EdgeInsets.only(bottom: 16 * htio),
                                child: Column(
                                  children: [
                                    // 식사유형
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: SizedBox(
                                            height: 48 * htio,
                                            child: TextField(
                                              controller: input.mealType,
                                              inputFormatters: [
                                                LengthLimitingTextInputFormatter(12),
                                              ],
                                              style: TextStyle(
                                                fontSize: 13.5 * htio,
                                                fontFamily: 'Pretendard',
                                              ),
                                              decoration: getInputDecoration('식사 유형', htio, wtio),
                                              onChanged: (value) {
                                                input.isUpdate = true;
                                              },
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12 * wtio),
                                        GestureDetector(
                                          onTap: () async{
                                            final response = await ref.read(jwtTokenVerificationProvider.future);
                                            if(response.isValid) {
                                              _showImageSourcePicker(index, docApiService);
                                            } else {
                                              if(!context.mounted)return;
                                              showAppMessage(context,title: '로그인이 필요해요', message: '로그인이 필요한 기능입니다. 로그인 후 이용해주세요.', type: AppMessageType.dialog, loginRequest: true);
                                            }
                                          },
                                          child: SvgPicture.asset(
                                            'assets/widgets/gemini_icon.svg',
                                            fit: BoxFit.cover,
                                            width: 28 * wtio,
                                            height: 28 * htio,
                                          ),
                                        ),
                                        SizedBox(width: 12 * wtio),
                                        HoverableIcon(
                                          icon: Icons.remove_circle_outline,
                                          originColor: Colors.grey,
                                          changedColor: Colors.red,
                                          onTap: () {
                                            showAppDialog(context, message: '목록에서 바로 삭제됩니다.\n삭제하시겠습니까?', confirmText: '확인',
                                              onConfirm: () async {
                                                final deleteId = input.id;
                                                if (deleteId != -1) {
                                                  await deleteHtDietDoc(ref: ref, id: deleteId);
                                                }
                                                setState(() {
                                                  inputList.removeAt(index);
                                                });
                                                widget.onSaved();
                                              },
                                              cancelText: '취소',
                                              onCancel: (){
                                                return;
                                              }
                                            );
                                          },
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
                                          child: Container(
                                            constraints: BoxConstraints(
                                              minHeight: 102 * htio, // 기본 높이
                                              maxHeight: double.infinity,
                                            ),
                                            child: TextField(
                                              controller: input.dietText,
                                              keyboardType: TextInputType.multiline,
                                              minLines: 1,     // 최소 1줄
                                              maxLines: 10,  // 내용에 따라 무제한 확장
                                              style: TextStyle(
                                                fontSize: 13.5 * htio,
                                                fontFamily: 'Pretendard',
                                              ),
                                              decoration: getInputDecoration(
                                                  '식단을 입력해주세요.\n(최대 150자)', htio, wtio),
                                              onChanged: (value) {
                                                input.isUpdate = true;
                                                setState(() {}); // 높이 갱신
                                              },
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 7 * wtio),
                                        // 칼로리 + 단백질
                                        Expanded(
                                          flex: 4,
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 48 * htio,
                                                child: TextField(
                                                  controller: input.calorie,
                                                  keyboardType:
                                                      const TextInputType.numberWithOptions(decimal: true),
                                                  decoration: getInputDecoration('칼로리', htio, wtio),
                                                  style: TextStyle(
                                                    fontSize: 13.5 * htio,
                                                    fontFamily: 'Pretendard',
                                                  ),
                                                  inputFormatters: [
                                                    LimitValueFormatter(max: 9999.9),
                                                    FilteringTextInputFormatter.allow(
                                                        RegExp(r'^(\d{0,4})(\.\d?)?$')),
                                                  ],
                                                  onChanged: (value) {
                                                    input.calorie.text = value;
                                                    input.isUpdate = true;
                                                  },
                                                ),
                                              ),
                                              SizedBox(height: 6 * htio),
                                              SizedBox(
                                                height: 48 * htio,
                                                child: TextField(
                                                  controller: input.protein,
                                                  decoration: getInputDecoration('단백질', htio, wtio),
                                                  inputFormatters: [
                                                    LimitValueFormatter(max: 999.9),
                                                    FilteringTextInputFormatter.allow(
                                                        RegExp(r'^\d{0,3}(\.\d{0,})?$')),
                                                  ],
                                                  style: TextStyle(
                                                    fontSize: 13.5 * htio,
                                                    fontFamily: 'Pretendard',
                                                  ),
                                                  keyboardType:
                                                      const TextInputType.numberWithOptions(decimal: true),
                                                  onChanged: (value) {
                                                    input.protein.text = value;
                                                    input.isUpdate = true;
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12 * htio),
                                    makeBorder(),
                                  ],
                                ),
                              );
                            }),
                          
                            if(inputList.length < 10)
                            // 하단 추가 버튼
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  inputList.add(DietInputData.def());
                                });
                              },
                              icon: Icon(
                                size: 18 * htio,
                                Icons.add_circle_outline
                              ),
                              label: Text(
                                '식단 추가',
                                style: TextStyle(
                                  fontSize: 14 * htio
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
      
                    SizedBox(height: 16 * htio),
                    requestBtn(htio, wtio),
                    SizedBox(height: 18 * htio),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration getInputDecoration(String hint, double htio, double wtio) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 14 * htio,
        fontWeight: FontWeight.w400,
        fontFamily: 'Pretendard',
        color: const Color(0xFF999999),
      ),
      contentPadding: EdgeInsets.all(12 * wtio),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8 * wtio),
        borderSide: BorderSide(color: const Color(0xFFDDDDDD), width: 1 * wtio),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8 * wtio),
        borderSide: BorderSide(color: const Color(0xFF0D86E7), width: 1.5 * wtio),
      ),
      suffixText: hint == '칼로리' ? 'kcal' : (hint == '단백질' ? 'g' : ''),
      suffixStyle: (hint == '칼로리' || hint == '단백질')
          ? TextStyle(
              color: const Color(0xFF999999),
              fontSize: 14 * htio,
              fontFamily: 'Pretendard',
            )
          : null,
    );
  }

  Widget requestBtn(double htio, double wtio) {
    bool isAllNotEmpty = false;

    for(DietInputData dietInput in inputList) {
      if(dietInput.isEmpty) {
        isAllNotEmpty = false;
      } else {
        isAllNotEmpty = true;
      }
    }

    return SizedBox(
      height: 48 * htio,
      width: double.infinity,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () async {
          if(!isAllNotEmpty) {
            showAppMessage(context, message: '추가한 식단의 항목을 한 가지 이상 입력해야 합니다.');
            return;
          }
          final String day = DateFormat('yyyy-MM-dd').format(focusedDay);
          final insertList = <DayDietModel>[];
          final updateList = <DayDietModel>[];

          try {
            for (final input in inputList) {
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
              await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) {
                  return const SuccessAfterLoadingDialog();
                },
              );
              widget.onSaved();
              if (mounted) {
                Navigator.of(context).pop(); 
              }
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
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: ShapeDecoration(
            color: _isPressed
                ? const Color.fromARGB(255, 81, 172, 230)
                : const Color(0xFF0D85E7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12 * wtio),
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
    );
  }

  Container makeBorder() {
    return Container(height: 1, color: const Color(0xFFEEEEEE));
  }
}
