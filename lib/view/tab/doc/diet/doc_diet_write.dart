import 'dart:io' show File;
import 'dart:ui' show ImageFilter;

import 'package:dio/dio.dart' show DioException;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter, LengthLimitingTextInputFormatter, PlatformException;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource, XFile;
import 'package:intl/intl.dart';
import 'package:my_app/extension/limit_value_formatter.dart' show LimitValueFormatter;
import 'package:my_app/model/diet/diet_input_data.dart' show DietInputData;
import 'package:my_app/model/diet/doc_diet_model.dart';
import 'package:my_app/model/diet/food_database_dto.dart';
import 'package:my_app/providers/food_database_providers.dart';
import 'package:my_app/notifier/tutorial_notifier.dart' show dietWriteTutorialStorageProvider;
import 'package:my_app/providers/db_providers.dart';
import 'package:my_app/providers/feed_cud_providers.dart';
import 'package:my_app/providers/usr_auth_providers.dart' show jwtTokenVerificationProvider;
import 'package:my_app/service/doc_api_service.dart';
import 'package:my_app/util/dialog_utils.dart';
import 'package:my_app/util/error_message_utils.dart' show AppMessageType, showAppMessage;
import 'package:my_app/util/hoverable_icon.dart';
import 'package:my_app/util/image_compress.dart';
import 'package:my_app/util/ai_diet_loading_dialog.dart' show showAiAnalysisLoadingDialog;
import 'package:my_app/util/saving_success_dialog.dart';
import 'package:my_app/util/screen_ratio.dart' show ScreenRatio;
import 'package:my_app/view/tab/simple_cache.dart' show osType;
import 'package:my_app/view/tutorial/common_functions.dart' show buildTarget, titleDescContent;
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

part '../../../../view/tutorial/diet_write_tutorial.dart';

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
  bool _loadingDialogClosed = false;

  // 검색 관련 상태
  List<DayDietModel> _searchResults = [];
  int _activeSearchIndex = -1;
  List<LayerLink> _layerLinks = [];
  OverlayEntry? _overlayEntry;

   void _closeLoadingDialog() {
    if (_loadingDialogClosed) return;
    _loadingDialogClosed = true;

    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    focusedDay = widget.focusDay;
    _layerLinks = [LayerLink()];

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
          _layerLinks = List.generate(inputList.length, (_) => LayerLink());
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final htio = ScreenRatio(context).heightRatio;
      final wtio = ScreenRatio(context).widthRatio;

      _createTutorial(wtio: wtio,htio: htio);
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _activeSearchIndex = -1;
  }

  Future<void> _onSearchMealType(String query, int index) async {
    if (query.trim().isEmpty) {
      _removeOverlay();
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final results = await ref.read(searchDietByTitleProvider(query).future);
    if (!mounted) return;

    setState(() {
      _searchResults = results;
      _activeSearchIndex = index;
    });

    if (results.isEmpty) {
      _removeOverlay();
      return;
    }

    _showSearchOverlay(index);
  }

  void _showSearchOverlay(int index) {
    _removeOverlay();

    final htio = ScreenRatio(context).heightRatio;
    final wtio = ScreenRatio(context).widthRatio;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 220 * wtio,
        child: CompositedTransformFollower(
          link: _layerLinks[index],
          showWhenUnlinked: false,
          offset: Offset(0, 52 * htio),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8 * wtio),
            child: Container(
              constraints: BoxConstraints(maxHeight: 200 * htio),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8 * wtio),
                border: Border.all(color: const Color(0xFFDDDDDD)),
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _searchResults.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final item = _searchResults[i];
                  return InkWell(
                    onTap: () => _onSelectSearchItem(item, index),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12 * wtio,
                        vertical: 10 * htio,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 왼쪽: title, diet
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title ?? '',
                                  style: TextStyle(
                                    fontSize: 14 * htio,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Pretendard',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (item.diet?.isNotEmpty == true) ...[
                                  SizedBox(height: 2 * htio),
                                  Text(
                                    item.diet!,
                                    style: TextStyle(
                                      fontSize: 12 * htio,
                                      color: const Color(0xFF666666),
                                      fontFamily: 'Pretendard',
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(width: 8 * wtio),
                          // 오른쪽: calorie(상단), protein(하단)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                item.formattedCalorie.isNotEmpty
                                    ? "${item.formattedCalorie}kcal"
                                    : "-",
                                style: TextStyle(
                                  fontSize: 11 * htio,
                                  color: const Color(0xFF999999),
                                  fontFamily: 'Pretendard',
                                ),
                              ),
                              SizedBox(height: 2 * htio),
                              Text(
                                item.formattedProtein.isNotEmpty
                                    ? "${item.formattedProtein}g"
                                    : "-",
                                style: TextStyle(
                                  fontSize: 11 * htio,
                                  color: const Color(0xFF999999),
                                  fontFamily: 'Pretendard',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _onSelectSearchItem(DayDietModel item, int index) {
    final input = inputList[index];
    input.mealType.text = item.title ?? '';
    input.dietText.text = item.diet ?? '';
    input.calorie.text = item.formattedCalorie;
    input.protein.text = item.formattedProtein;
    input.isUpdate = true;

    _removeOverlay();
    setState(() {
      _searchResults = [];
    });
  }

  void _createTutorial({
    required double wtio,
    required double htio,
  }) async{
    final prefs = await SharedPreferences.getInstance();
    final isShown = prefs.getBool("is_diet_write_tutorial_shown") ?? false;
    if(!isShown) {
      await createTutorial(ref:ref, wtio: wtio, htio: htio);
      await Future.delayed(const Duration(milliseconds: 300), showTutorial);
    }
  }

  void showTutorial() {
    tutorialCoachMarkDietWrite.show(context: context);
  }

  // =========================================================================
  // 0. 식품DB 검색 팝업
  // =========================================================================
  void _showFoodSearchPopup(int index) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const _FoodSearchPopup(),
    );
    if (result != null && mounted) {
      setState(() {
        final input = inputList[index];
        // 칼로리 더하기
        final prevCal = double.tryParse(input.calorie.text) ?? 0;
        final addCal = (result['kcal'] as double?) ?? 0;
        input.calorie.text = (prevCal + addCal).toStringAsFixed(1);

        // 단백질 더하기
        final prevPro = double.tryParse(input.protein.text) ?? 0;
        final addPro = (result['protein'] as double?) ?? 0;
        input.protein.text = (prevPro + addPro).toStringAsFixed(1);

        // 식단내용에 음식정보 추가
        final name = result['foodName'] as String? ?? '';
        final kcal = addCal.toStringAsFixed(1);
        final pro = addPro.toStringAsFixed(1);
        final fat = ((result['fat'] as double?) ?? 0).toStringAsFixed(1);
        final carbs = ((result['carbs'] as double?) ?? 0).toStringAsFixed(1);
        final sugar = ((result['sugar'] as double?) ?? 0).toStringAsFixed(1);
        final foodInfo =
            '$name ${kcal}kcal, 단백질 ${pro}g, 지방 ${fat}g, 탄수화물 ${carbs}g, 당류 ${sugar}g';

        if (input.dietText.text.isNotEmpty) {
          input.dietText.text += '\n$foodInfo';
        } else {
          input.dietText.text = foodInfo;
        }
        input.isUpdate = true;
      });
    }
  }

  // =========================================================================
  // 1. AI 이미지 분석용 바텀 시트 호출 메서드 추가
  // =========================================================================
  void _showImageSourcePicker(int index, DocApiService? docApiService, BuildContext parentContext) {
    FocusScope.of(context).unfocus(); // 혹시 모를 키보드 내리기

    showModalBottomSheet(
      context: parentContext,
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
                parentContext,
                icon: Icons.photo_library_outlined,
                label: '갤러리',
                onTap: () async {
                  Navigator.pop(context); // 시트 닫기
                  try {
                    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      debugPrint('식단 $index - 갤러리 이미지 경로: ${image.path}');
                      if (!parentContext.mounted) return;
                      await _showAddPromptDialog(
                        parentContext: parentContext,
                        image: image,
                        docApiService: docApiService,
                        index: index,
                      );
                    }
                  } on PlatformException catch (e) {
                    if (!parentContext.mounted) return;

                    if (e.code == 'invalid_image' ||(e.message?.contains('public.') ?? false)) {
                      if (osType == 'ios') {
                        showAppMessage(parentContext,message: 'icloud 파일은 바로 업로드할 수 없습니다.\n기기에 다운로드 후 다시 시도해주세요.',type: AppMessageType.dialog);
                      } else {
                        showAppMessage(parentContext,message: '클라우드에 있는 사진은 바로 업로드할 수 없습니다.\n기기에 다운로드 후 다시 시도해주세요.',type: AppMessageType.dialog);
                      }
                    } else {
                      showAppMessage(parentContext,message: '파일 처리 및 삽입 중 오류가 발생했습니다',type: AppMessageType.dialog);
                    }

                  } catch (e) {
                    debugPrint("알 수 없는 오류: $e");
                    if (!parentContext.mounted) return;
                    showAppMessage(parentContext,message: '파일 처리 중 오류가 발생했습니다.',type: AppMessageType.dialog);
                  }
                },
              ),

              // 카메라 선택 버튼
              _buildImageSourceItem(
                context,
                parentContext,
                icon: Icons.camera_alt_outlined,
                label: '카메라',
                onTap: () async {
                  Navigator.pop(context); // 시트 닫기
                  try {
                    final XFile? image = await picker.pickImage(source: ImageSource.camera);
                    if (image != null) {
                      debugPrint('식단 $index - 카메라 이미지 경로: ${image.path}');
                      if (!parentContext.mounted) return;
                      await _showAddPromptDialog(
                        parentContext: parentContext,
                        image: image,
                        docApiService: docApiService,
                        index: index,
                      );
                    }
                  } catch (e) {
                    debugPrint("알 수 없는 오류: $e");
                    if (!parentContext.mounted) return;
                    showAppMessage(parentContext,message: '파일 처리 중 오류가 발생했습니다.',type: AppMessageType.dialog);
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

  analyzeRequest(XFile image, DocApiService? docApiService, int index, {String addText = ''}) async{
    _loadingDialogClosed = false;

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
      final imagef = File(image.path);
      final imageFile = await compressImage(imagef);
      // ! 대신 ?를 사용하여 널이 아님을 보장했으므로, 널 체크 연산자 제거
      final s = await docApiService.analyzeImage(imageFile, addText: addText); 
      
      // UI 업데이트
      if (mounted) {
        if(s == null) {
          _closeLoadingDialog();
          return;
        }
        _closeLoadingDialog();

        setState(() {
          final input = inputList[index];
          input.mealType.text = s.foodName;
          input.dietText.text = s.description + (s.sugar!=0 ? ', 총 당류(g) : ${s.sugar}' : '');
          if(s.calories != 0) input.calorie.text = s.calories.toStringAsFixed(1);
          if(s.protein != 0)  input.protein.text = s.protein.toStringAsFixed(1);
          input.isUpdate = true;
        });
      }
    } on DioException catch (e) {
      if(mounted) {
        _closeLoadingDialog();
        if(e.response?.statusCode == 423) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            showAppMessage(
              context, message:e.response?.data['message'] ?? '오늘 무료 분석 횟수를 초과했습니다.', type: AppMessageType.dialog,
            );
          });
        }
      }
    } catch(e) {
      if (mounted) {
        _closeLoadingDialog();
      }
      debugPrint('식단 분석 API 호출 에러: $e');
    }
  }

  // 추가 프롬프트 입력 다이얼로그
  Future<void> _showAddPromptDialog({
    required BuildContext parentContext,
    required XFile image,
    required DocApiService? docApiService,
    required int index,
  }) async {
    final TextEditingController promptController = TextEditingController();
    final wtio = ScreenRatio(parentContext).widthRatio;
    final htio = ScreenRatio(parentContext).heightRatio;

    final result = await showDialog<String?>(
      context: parentContext,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16 * wtio),
          ),
          title: Text(
            '추가 설명 입력',
            style: TextStyle(
              fontSize: 17 * htio,
              fontWeight: FontWeight.bold,
              fontFamily: 'Pretendard',
            ),
          ),
          content: TextField(
            controller: promptController,
            maxLines: 3,
            maxLength: 100,
            decoration: InputDecoration(
              hintText: '(선택사항) 사진의 음식을 설명해주세요',
              hintStyle: TextStyle(
                fontSize: 14 * htio,
                color: const Color(0xFF999999),
                fontFamily: 'Pretendard',
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
            ),
            style: TextStyle(
              fontSize: 14 * htio,
              fontFamily: 'Pretendard',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text(
                '취소',
                style: TextStyle(
                  fontSize: 14 * htio,
                  color: const Color(0xFF999999),
                  fontFamily: 'Pretendard',
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, promptController.text),
              child: Text(
                '분석하기',
                style: TextStyle(
                  fontSize: 14 * htio,
                  color: const Color(0xFF0D86E7),
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Pretendard',
                ),
              ),
            ),
          ],
        );
      },
    );

    // 다이얼로그가 취소되지 않았을 때만 분석 진행
    if (result != null) {
      await analyzeRequest(image, docApiService, index, addText: result);
    }
  }

  // 바텀 시트의 각 항목을 구성하는 위젯
  Widget _buildImageSourceItem(BuildContext context, BuildContext parentContext, {required IconData icon, required String label, required VoidCallback onTap}) {
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
        _removeOverlay(); // 검색 목록 숨기기
        setState(() {
          _searchResults = [];
        });
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
                                          child: CompositedTransformTarget(
                                            link: _layerLinks[index],
                                            child: SizedBox(
                                              height: 48 * htio,
                                              child: TextField(
                                                controller: input.mealType,
                                                inputFormatters: [
                                                  LengthLimitingTextInputFormatter(
                                                      12),
                                                ],
                                                style: TextStyle(
                                                  fontSize: 13.5 * htio,
                                                  fontFamily: 'Pretendard',
                                                ),
                                                decoration: getInputDecoration(
                                                    '식사 유형', htio, wtio),
                                                onChanged: (value) {
                                                  input.isUpdate = true;
                                                  _onSearchMealType(
                                                      value, index);
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12 * wtio),
                                        // 식품DB 검색 버튼
                                        GestureDetector(
                                          key: index == 0
                                              ? foodSearchBtn
                                              : null, // 글로벌키 aiAnalyzeBtn 를 중복으로 사용하면 에러발생함
                                          onTap: () {
                                            _showFoodSearchPopup(index);
                                          },
                                          child: Icon(
                                            Icons.search,
                                            size: 28 * htio,
                                            color: const Color(0xFF666666),
                                          ),
                                        ),
                                        SizedBox(width: 8 * wtio),
                                        GestureDetector(
                                          key: index == 0 ? aiAnalyzeBtn : null, // 글로벌키 aiAnalyzeBtn 를 중복으로 사용하면 에러발생함
                                          onTap: () async{
                                            final response = await ref.read(jwtTokenVerificationProvider.future);
                                            if(response.isValid) {
                                              if(!context.mounted)return;
                                              _showImageSourcePicker(index, docApiService, context);
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
                                                  _removeOverlay();
                                                setState(() {
                                                  inputList.removeAt(index);
                                                    _layerLinks.removeAt(index);
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
                                    _layerLinks.add(LayerLink());
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

// =============================================================================
// 식품DB 검색 팝업 위젯
// =============================================================================
class _FoodSearchPopup extends ConsumerStatefulWidget {
  const _FoodSearchPopup();

  @override
  ConsumerState<_FoodSearchPopup> createState() => _FoodSearchPopupState();
}

class _FoodSearchPopupState extends ConsumerState<_FoodSearchPopup> {
  final _searchController = TextEditingController();
  List<FoodListDto> _results = [];
  bool _isLoading = false;

  // 상세 페이지 상태
  bool _showDetail = false;
  FoodDatabaseDto? _selectedFood;
  bool _useTotalWeight = false; // false=100g 기준, true=총 중량 기준
  int _divideBy = 1; // 1/n 에서 n값 (1~10)

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    try {
      final list = await ref.read(foodSearchProvider(keyword).future);
      if (mounted)
        setState(() {
          _results = list;
          _isLoading = false;
        });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectFood(int id) async {
    setState(() => _isLoading = true);
    try {
      final detail = await ref.read(foodDetailProvider(id).future);
      if (detail != null && mounted) {
        setState(() {
          _selectedFood = detail;
          _showDetail = true;
          _useTotalWeight = false;
          _divideBy = 1;
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Map<String, double> _calculateNutrients() {
    if (_selectedFood == null) return {};
    final f = _selectedFood!;
    final weightRatio = _useTotalWeight ? f.totalWeight / 100.0 : 1.0;
    final ratio = weightRatio / _divideBy;
    return {
      'kcal': f.kcal * ratio,
      'protein': f.protein * ratio,
      'fat': f.fat * ratio,
      'carbs': f.carbs * ratio,
      'sugar': f.sugar * ratio,
    };
  }

  void _addToDiet() {
    final n = _calculateNutrients();
    Navigator.of(context).pop({
      'foodName': _selectedFood!.foodName,
      'kcal': n['kcal'],
      'protein': n['protein'],
      'fat': n['fat'],
      'carbs': n['carbs'],
      'sugar': n['sugar'],
    });
  }

  void _backToSearch() {
    setState(() {
      _showDetail = false;
      _selectedFood = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final htio = ScreenRatio(context).heightRatio;
    final wtio = ScreenRatio(context).widthRatio;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding:
          EdgeInsets.symmetric(horizontal: 20 * wtio, vertical: 40 * htio),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16 * wtio)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16 * wtio),
        child: SizedBox(
          width: double.maxFinite,
          height: 500 * htio,
          child: _showDetail
              ? _buildDetailView(htio, wtio)
              : _buildSearchView(htio, wtio),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 검색 뷰
  // ---------------------------------------------------------------------------
  Widget _buildSearchView(double htio, double wtio) {
    return Column(
      children: [
        // 타이틀
        Padding(
          padding:
              EdgeInsets.fromLTRB(20 * wtio, 18 * htio, 12 * wtio, 10 * htio),
          child: Row(
            children: [
              Text(
                '식품 검색',
                style: TextStyle(
                  fontSize: 17 * htio,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Pretendard',
                  color: const Color(0xFF333333),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close, size: 22 * htio),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        Divider(height: 1 * htio, color: const Color(0xFFEEEEEE)),

        // 검색 입력
        Padding(
          padding:
              EdgeInsets.fromLTRB(16 * wtio, 12 * htio, 16 * wtio, 8 * htio),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42 * htio,
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _search(),
                    style: TextStyle(
                        fontSize: 14 * htio, fontFamily: 'Pretendard'),
                    decoration: InputDecoration(
                      hintText: '음식 이름을 검색하세요',
                      hintStyle: TextStyle(
                          fontSize: 14 * htio,
                          color: const Color(0xFF999999),
                          fontFamily: 'Pretendard'),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12 * wtio),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8 * wtio),
                        borderSide: BorderSide(
                            color: const Color(0xFFDDDDDD), width: 1 * wtio),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8 * wtio),
                        borderSide: BorderSide(
                            color: const Color(0xFF0D86E7), width: 1.5 * wtio),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8 * wtio),
              SizedBox(
                height: 42 * htio,
                child: ElevatedButton(
                  onPressed: _search,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D85E7),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8 * wtio)),
                    padding: EdgeInsets.symmetric(horizontal: 14 * wtio),
                    elevation: 0,
                  ),
                  child: Text(
                    '검색',
                    style: TextStyle(
                        fontSize: 14 * htio,
                        color: Colors.white,
                        fontFamily: 'Pretendard'),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 검색 결과
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _results.isEmpty
                  ? Center(
                      child: Text(
                        _searchController.text.isEmpty
                            ? '음식 이름으로 검색해보세요'
                            : '검색 결과가 없습니다',
                        style: TextStyle(
                            fontSize: 14 * htio,
                            color: const Color(0xFF999999),
                            fontFamily: 'Pretendard'),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 16 * wtio),
                      itemCount: _results.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final food = _results[i];
                        return InkWell(
                          onTap: () => _selectFood(food.id),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12 * htio),
                            child: Text(
                              food.foodName,
                              style: TextStyle(
                                  fontSize: 14 * htio,
                                  fontFamily: 'Pretendard',
                                  color: const Color(0xFF333333)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 상세 뷰
  // ---------------------------------------------------------------------------
  Widget _buildDetailView(double htio, double wtio) {
    final food = _selectedFood!;
    final n = _calculateNutrients();

    return Column(
      children: [
        // 타이틀 바
        Padding(
          padding:
              EdgeInsets.fromLTRB(8 * wtio, 10 * htio, 12 * wtio, 6 * htio),
          child: Row(
            children: [
              IconButton(
                onPressed: _backToSearch,
                icon: Icon(Icons.arrow_back_ios_new, size: 20 * htio),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              SizedBox(width: 4 * wtio),
              Expanded(
                child: Text(
                  food.foodName,
                  style: TextStyle(
                    fontSize: 17 * htio,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Pretendard',
                    color: const Color(0xFF333333),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close, size: 22 * htio),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        Divider(height: 1 * htio, color: const Color(0xFFEEEEEE)),

        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20 * wtio, 14 * htio, 20 * wtio, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 기준량 탭 버튼
                Text('기준량',
                    style: TextStyle(
                        fontSize: 13 * htio,
                        color: const Color(0xFF777777),
                        fontFamily: 'Pretendard')),
                SizedBox(height: 6 * htio),
                Row(
                  children: [
                    _weightTab(
                        '100g',
                        !_useTotalWeight,
                        () => setState(() => _useTotalWeight = false),
                        htio,
                        wtio),
                    SizedBox(width: 8 * wtio),
                    _weightTab(
                      '총 중량 (${food.totalWeight.toStringAsFixed(0)}g)',
                      _useTotalWeight,
                      food.totalWeight > 0
                          ? () => setState(() => _useTotalWeight = true)
                          : null,
                      htio,
                      wtio,
                    ),
                  ],
                ),
                SizedBox(height: 14 * htio),

                // 양 (1/n)
                Row(
                  children: [
                    Text('양',
                        style: TextStyle(
                            fontSize: 13 * htio,
                            color: const Color(0xFF777777),
                            fontFamily: 'Pretendard')),
                    SizedBox(width: 62 * wtio),
                    Row(
                      children: [
                        Text('1 /',
                            style: TextStyle(
                                fontSize: 15 * htio,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF333333))),
                        SizedBox(
                          width: 22 * wtio,
                          child: Text(
                            '$_divideBy',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 15 * htio,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF333333)),
                          ),
                        ),
                        SizedBox(width: 8 * wtio),
                        GestureDetector(
                          onTap: () {
                            if (_divideBy > 1) setState(() => _divideBy--);
                          },
                          child: Container(
                            width: 28 * wtio,
                            height: 28 * htio,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xFFDDDDDD),
                                  width: 1 * wtio),
                              borderRadius: BorderRadius.circular(6 * wtio),
                            ),
                            child: Icon(Icons.remove,
                                size: 16 * htio,
                                color: _divideBy > 1
                                    ? const Color(0xFF333333)
                                    : const Color(0xFFCCCCCC)),
                          ),
                        ),
                        SizedBox(width: 8 * wtio),
                        GestureDetector(
                          onTap: () {
                            if (_divideBy < 10) setState(() => _divideBy++);
                          },
                          child: Container(
                            width: 28 * wtio,
                            height: 28 * htio,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xFFDDDDDD),
                                  width: 1 * wtio),
                              borderRadius: BorderRadius.circular(6 * wtio),
                            ),
                            child: Icon(Icons.add,
                                size: 16 * htio,
                                color: _divideBy < 10
                                    ? const Color(0xFF333333)
                                    : const Color(0xFFCCCCCC)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 14 * htio),

                // 영양성분 카드
                _nutrientRow(
                    '칼로리', '${n['kcal']!.toStringAsFixed(1)} kcal', htio, wtio),
                _nutrientDivider(htio),
                _nutrientDoubleRow(
                    '단백질',
                    '${n['protein']!.toStringAsFixed(1)} g',
                    '지방',
                    '${n['fat']!.toStringAsFixed(1)} g',
                    htio,
                    wtio),
                _nutrientDivider(htio),
                _nutrientDoubleRow(
                    '탄수화물',
                    '${n['carbs']!.toStringAsFixed(1)} g',
                    '당류',
                    '${n['sugar']!.toStringAsFixed(1)} g',
                    htio,
                    wtio),
              ],
            ),
          ),
        ),

        // 식단에 추가 버튼
        Padding(
          padding:
              EdgeInsets.fromLTRB(16 * wtio, 10 * htio, 16 * wtio, 16 * htio),
          child: SizedBox(
            width: double.infinity,
            height: 46 * htio,
            child: ElevatedButton(
              onPressed: _addToDiet,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D85E7),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12 * wtio)),
                elevation: 0,
              ),
              child: Text(
                '식단에 추가',
                style: TextStyle(
                    fontSize: 15 * htio,
                    color: Colors.white,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 헬퍼 위젯
  // ---------------------------------------------------------------------------
  Widget _weightTab(String label, bool selected, VoidCallback? onTap,
      double htio, double wtio) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: 14 * wtio, vertical: 8 * htio),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0D85E7) : Colors.white,
          borderRadius: BorderRadius.circular(20 * wtio),
          border: Border.all(
            color: selected ? const Color(0xFF0D85E7) : const Color(0xFFDDDDDD),
            width: 1 * wtio,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13 * htio,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w500,
            color: selected
                ? Colors.white
                : (onTap != null
                    ? const Color(0xFF333333)
                    : const Color(0xFFBBBBBB)),
          ),
        ),
      ),
    );
  }

  Widget _nutrientRow(String label, String value, double htio, double wtio) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10 * htio),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 14 * htio,
                  fontFamily: 'Pretendard',
                  color: const Color(0xFF555555))),
          Text(value,
              style: TextStyle(
                  fontSize: 14 * htio,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF333333))),
        ],
      ),
    );
  }

  Widget _nutrientDoubleRow(
      String l1, String v1, String l2, String v2, double htio, double wtio) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10 * htio),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l1,
                    style: TextStyle(
                        fontSize: 14 * htio,
                        fontFamily: 'Pretendard',
                        color: const Color(0xFF555555))),
                Text(v1,
                    style: TextStyle(
                        fontSize: 14 * htio,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF333333))),
              ],
            ),
          ),
          SizedBox(width: 20 * wtio),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l2,
                    style: TextStyle(
                        fontSize: 14 * htio,
                        fontFamily: 'Pretendard',
                        color: const Color(0xFF555555))),
                Text(v2,
                    style: TextStyle(
                        fontSize: 14 * htio,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF333333))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _nutrientDivider(double htio) {
    return Divider(height: 1 * htio, color: const Color(0xFFF0F0F0));
  }
}
