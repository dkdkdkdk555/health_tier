import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/extension/limit_value_formatter.dart' show LimitValueFormatter;
import 'package:my_app/model/cmu/feed/category_model.dart';
import 'package:my_app/model/cmu/common/result.dart';
import 'package:my_app/providers/feed_providers.dart';
import 'package:flutter/services.dart';
import 'package:my_app/util/error_message_utils.dart' show showAppMessage;
import 'package:my_app/util/screen_ratio.dart' show ScreenRatio;
import 'package:my_app/util/spinner_utils.dart' show AppLoadingIndicator;
import 'package:my_app/util/user_prefs.dart' show UserPrefs; // TextInputFormatter를 위해 추가

// ✅ 운동 항목 데이터를 위한 모델 정의
class ExerciseEntry {
  String? type; // 벤치프레스, 스쿼트, 데드리프트 (BENCH, SQUAT, DEAD)
  TextEditingController weightController;

  ExerciseEntry({this.type, String initialWeight = ''})
      : weightController = TextEditingController(text: initialWeight);

  // dispose 메서드: TextEditingController를 해제하여 메모리 누수 방지
  void dispose() {
    weightController.dispose();
  }
}

class WriteFeedCategorySelectBar extends ConsumerStatefulWidget {
  final void Function({required int index}) onCategoryChange;
  final int selectedCategoryId;
  final void Function(List<ExerciseEntry> exerciseEntries)? onExerciseEntriesChanged;


  const WriteFeedCategorySelectBar({
    super.key,
    required this.onCategoryChange,
    required this.selectedCategoryId,
    this.onExerciseEntriesChanged, 
  });

  @override
  ConsumerState<WriteFeedCategorySelectBar> createState() => _WriteFeedCategorySelectBarState();
}

class _WriteFeedCategorySelectBarState extends ConsumerState<WriteFeedCategorySelectBar> {
  late int selectedCategoryId;
  // 3대 운동 항목 리스트
  final List<ExerciseEntry> _exerciseEntries = [];
  late String? currLoginId;
  

  // 모든 운동 타입 정의 (상수로 유지)
  final Map<String, String> _allExerciseTypes = const {
    'BENCH': '벤치프레스',
    'SQUAT': '스쿼트',
    'DEAD': '데드리프트',
  };

  @override
  void initState() {
    super.initState();
    selectedCategoryId = widget.selectedCategoryId;
    _initializeExerciseEntries(selectedCategoryId); // 초기 상태에 따라 운동 항목 초기화
     _notifyExerciseEntriesChange();
  }

  @override
  void didUpdateWidget(covariant WriteFeedCategorySelectBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCategoryId != oldWidget.selectedCategoryId) {
      selectedCategoryId = widget.selectedCategoryId;
      _initializeExerciseEntries(selectedCategoryId); // 카테고리 변경 시 운동 항목 초기화
      _notifyExerciseEntriesChange(); 
    }
  }

  // ✅ 운동 항목 리스트 초기화 (카테고리 ID 3일 때만)
  void _initializeExerciseEntries(int categoryId) {
    if (categoryId == 3) { // 카테고리 3일 때
      if (_exerciseEntries.isEmpty) { // 아직 항목이 없다면
        _addExerciseEntry(); // 초기 1개 항목 추가
      }
    } else { // 카테고리 3이 아닐 경우
      if (_exerciseEntries.isNotEmpty) { // 항목이 있다면 모두 삭제
        // mounted 체크: 이 메서드가 initState나 didUpdateWidget이 아닌,
        // 비동기 콜백 등에서 호출될 가능성을 대비.
        if (mounted) {
          setState(() { // mounted 상태일 때만 setState로 UI 업데이트
            _disposeAllExerciseControllers(); // 컨트롤러 먼저 dispose
            _exerciseEntries.clear(); // 리스트 클리어
          });
        } else {
          // 위젯이 mounted 상태가 아니라면, setState 없이 컨트롤러만 dispose합니다.
          _disposeAllExerciseControllers();
          _exerciseEntries.clear(); // 리스트 클리어
        }
      }
    }
    _notifyExerciseEntriesChange(); 
  }

  // ✅ 모든 운동 항목 컨트롤러만 해제 (setState 불포함)
  // 이 메서드는 dispose()에서 안전하게 호출할 수 있습니다.
  void _disposeAllExerciseControllers() {
    for (var entry in _exerciseEntries) {
      entry.dispose();
    }
  }

  // ✅ 운동 항목 추가
  void _addExerciseEntry() {
    if (_exerciseEntries.length < 3) {
      if (!mounted) return;
      setState(() {
        _exerciseEntries.add(ExerciseEntry());
      });
      _notifyExerciseEntriesChange(); 
    } else {
      if (!mounted) return;
      showAppMessage(context, message: '운동 항목은 최대 3개까지 추가할 수 있습니다.');
    }
  }

  // ✅ 운동 항목 삭제
  void _removeExerciseEntry(int index) {
    if (!mounted) return;
    setState(() {
      _exerciseEntries[index].dispose(); // TextEditingController 해제
      _exerciseEntries.removeAt(index);
    });
    _notifyExerciseEntriesChange(); 
  }

  // ✅ 드롭다운에 표시할 가능한 운동 타입 목록을 반환하는 메서드
  List<DropdownMenuItem<String>> _getAvailableExerciseTypes(String? currentSelectedType) {
    Set<String?> selectedTypesInOtherRows = {};
    for (var entry in _exerciseEntries) {
      // 현재 수정 중인 행의 타입은 제외하고, 다른 행에서 선택된 타입만 집계
      if (entry.type != null && entry.type != currentSelectedType) {
        selectedTypesInOtherRows.add(entry.type);
      }
    }

    return _allExerciseTypes.entries.where((entry) {
      // 이미 다른 행에서 선택된 타입은 제외하고, 현재 행의 기존 타입은 포함
      return !selectedTypesInOtherRows.contains(entry.key);
    }).map((entry) {
      return DropdownMenuItem(
        value: entry.key,
        child: Text(entry.value),
      );
    }).toList();
  }

  // ✅ 부모 위젯에 운동 항목 데이터 변경을 알리는 헬퍼 함수
  void _notifyExerciseEntriesChange() {
    if (widget.onExerciseEntriesChanged != null) {
      widget.onExerciseEntriesChanged!(_exerciseEntries);
    }
  }

  @override
  void dispose() {
    // ⚠️ 중요: dispose() 내부에서는 setState()를 호출하지 않습니다.
    _disposeAllExerciseControllers(); // 컨트롤러만 해제
    _exerciseEntries.clear(); // 리스트 비우기
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final htio = ScreenRatio(context).heightRatio;
    final wtio = ScreenRatio(context).widthRatio;

    final categoriesAsync = ref.watch(getFeedCategories);

    final bool showNoticeBox = selectedCategoryId == 2 || selectedCategoryId == 3;
    final bool showBig3ExerciseInput = selectedCategoryId == 3; // ✅ 3대 운동 항목 표시 조건

    currLoginId = UserPrefs.currentLoginId;

    return Container(
      padding: EdgeInsets.only(left: 20 * wtio, right: 20 * wtio, top: 16 * htio, bottom: 8 * htio),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 4 * wtio, bottom: 10 * htio),
              child: Text(
                '카테고리 선택',
                style: TextStyle(
                  fontSize: 15 * htio,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF555555),
                ),
              ),
            ),
          ),
          Row(
            children: [
              buildCategoryCollapsed(categoriesAsync, htio, wtio),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: showNoticeBox
                ? Padding(
                    padding: EdgeInsets.only(top: 16 * htio),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12*wtio, vertical: 12*htio),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF0D85E7),
                          width: 1 * wtio,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Text(
                        '◎유의사항\n- 인증글은 한번 생성하면 수정할 수 없습니다.\n- 다른 사용자나 관리자가 확인할 수 있는 사진/영상을 업로드 해주세요!\n- 인증글 정책과 맞지 않는 글은 관리자에 의해 삭제될 수 있습니다.',
                        style: TextStyle(
                          fontSize: 10.5 * htio,
                          color: const Color(0xFF0D85E7),
                          height: 1.5 * htio,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(), // 없을 경우 높이 0
          ),
          // ✅ 3대 운동 항목 입력 컨테이너 추가 (애니메이션 적용)
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: showBig3ExerciseInput
                ? Padding(
                    padding: EdgeInsets.only(top: 16 * htio),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 4 * wtio, bottom: 10 * htio),
                          child: Text(
                            '3대 운동 종목',
                            style: TextStyle(
                              fontSize: 15 * htio,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF555555),
                            ),
                          ),
                        ),
                        // ✅ 운동 항목 입력 행들
                        ..._exerciseEntries.asMap().entries.map((entry) {
                          final index = entry.key;
                          final exercise = entry.value;
                          return Padding(
                            padding: EdgeInsets.only(bottom: 8.0 * htio),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12 * wtio),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: const Color(0xFFDDDDDD), width: 1 * wtio),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        value: exercise.type,
                                        hint: const Text('종목 선택'),
                                        items: _getAvailableExerciseTypes(exercise.type), // ✅ 동적 아이템 사용
                                        onChanged: (String? newValue) {
                                          if (!mounted) return;
                                          setState(() {
                                            exercise.type = newValue;
                                          });
                                          _notifyExerciseEntriesChange();
                                        },
                                        style: TextStyle(fontSize: 13 * htio, color: const Color(0xFF333333)),
                                        dropdownColor: Colors.white,
                                        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF888888)),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8 * wtio),
                                Expanded(
                                  flex: 1,
                                  child: TextField(
                                    controller: exercise.weightController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      LimitValueFormatter(max: 1000),
                                      FilteringTextInputFormatter.allow(RegExp(r'^1000$|^(\d{0,3})(\.\d{0,})?$'))
                                    ],
                                    decoration: InputDecoration(
                                      hintText: '중량(kg)',
                                      hintStyle: TextStyle(fontSize: 12 * htio, color: const Color.fromRGBO(158, 158, 158, 0.8)),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12 * wtio, vertical: 10 * htio),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: const Color(0xFF0D85E7), width: 1.5 * wtio),
                                      ),
                                    ),
                                    style: TextStyle(fontSize: 14 * htio, color: const Color(0xff000000)),
                                    cursorColor: const Color(0xFF0D85E7),
                                  ),
                                ),
                                // 첫 번째 행이 아닐 때만 삭제 버튼 표시
                                if (index > 0 || _exerciseEntries.length > 1) // 첫 행이면서 항목이 하나 이상일 때도 삭제 가능
                                  SizedBox(
                                    width: 18 * wtio,
                                    height: 18 * htio,
                                    child: Expanded(
                                      child: IconButton(
                                        icon: const Icon(Icons.remove_circle_outline_outlined, color: Colors.red),
                                        onPressed: () => _removeExerciseEntry(index),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                        // ✅ 항목 추가 버튼
                        if (_exerciseEntries.length < 3)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: _addExerciseEntry,
                              icon: SizedBox(
                                width: 18 * wtio,
                                height: 18 * htio,
                                child: const Icon(Icons.add, color: Color(0xFF0D85E7))
                              ),
                              label: Text(
                                '항목 추가',
                                style: TextStyle(
                                  color: const Color(0xFF0D85E7),
                                  fontSize: 12 * htio,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                alignment: Alignment.centerRight,
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget buildCategoryCollapsed(AsyncValue<Result<List<Category>>> categoriesAsync, double htio, double wtio) {
    return categoriesAsync.when(
      data: (categories) {
        final modifiedCategories = [
          ...categories.data,
        ];
        return Expanded(
          child: SizedBox(
            height: 34 * htio,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: modifiedCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 0,),
              itemBuilder: (context, index) {
                final category = modifiedCategories[index];
                if(category.name=='공지') {
                   if(currLoginId != null) {
                    if(currLoginId!.contains('admin')){
                      return makeCategory(category, htio, wtio);
                    }
                   } else {
                    return null;
                   }
                }
                return makeCategory(category, htio, wtio);
              },
            ),
          ),
        );
      },
      loading: () => const Center(child: AppLoadingIndicator()),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  Widget makeCategory(Category category, double htio, double wtio) {
    final isSelected = selectedCategoryId == category.id;

    return GestureDetector(
      onTap: () {
        // (1) 먼저 외부 콜백을 호출합니다.
        // 이 콜백이 Navigator.pop을 발생시켜 이 위젯이 언마운트될 수 있습니다.
        widget.onCategoryChange(index: category.id); // 직접 category.id를 넘겨줍니다.

        // (2) 만약 위젯이 여전히 마운트되어 있다면, 상태를 업데이트합니다.
        // 그렇지 않다면, 이 setState는 호출되지 않습니다.
        if (mounted) { // ✅ 다시 한번 mounted 체크
          setState(() {
            selectedCategoryId = category.id;
          });
        }
      },
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12 * wtio, vertical: 8 * htio),
          margin: EdgeInsets.only(right: 4 * wtio),
          decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  side: BorderSide(
                      width: 1 * wtio,
                      color: isSelected ? const Color(0xFF0D85E7) : const Color(0xFFDDDDDD),
                  ),
                  borderRadius: BorderRadius.circular(99),
              ),
          ),
          child: Center(
              child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                      Text(
                          category.name,
                          style: TextStyle(
                              color: isSelected ? const Color(0xFF0D85E7) : const Color(0xFF333333),
                              fontSize: 12 * htio,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w400,
                          ),
                      ),
                  ],
              ),
          ),
      ),
    );
  }
}