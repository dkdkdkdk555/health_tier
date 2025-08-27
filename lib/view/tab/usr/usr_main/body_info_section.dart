import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:my_app/extension/limit_value_formatter.dart' show LimitValueFormatter;
import 'package:my_app/providers/db_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 키(height)를 관리하는 프로바이더
final heightProvider = StateNotifierProvider<HeightNotifier, double?>((ref) {
  return HeightNotifier();
});

class HeightNotifier extends StateNotifier<double?> {
  HeightNotifier() : super(null) {
    _loadHeight();
  }

  void _loadHeight() async {
    final prefs = await SharedPreferences.getInstance();
    final savedHeight = prefs.getDouble('height');
    state = savedHeight;
  }

  void saveHeight(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('height', value);
    state = value;
  }
}

// 성별(sex)을 관리하는 프로바이더
final sexProvider = StateNotifierProvider<SexNotifier, String?>((ref) {
  return SexNotifier();
});

class SexNotifier extends StateNotifier<String?> {
  SexNotifier() : super(null) {
    _loadSex();
  }

  void _loadSex() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSex = prefs.getString('sex');
    state = savedSex;
  }

  void saveSex(String sex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sex', sex);
    state = sex;
  }
}

// BMR (기초대사량)을 계산하는 프로바이더
final bmrProvider = Provider.family<double?, String>((ref, sex) {
  final height = ref.watch(heightProvider);
  final weight = ref.watch(getLatestWeightProvider).asData?.value;

  if (height == null || weight == null) {
    return null;
  }

  // 해리스-베네딕트 방정식 수정 버전 사용
  if (sex == 'man') {
    return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * 25); // 나이 25세로 가정
  } else if (sex == 'woman') {
    return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * 25); // 나이 25세로 가정
  }
  return null;
});

// TDEE (활동대사량)을 계산하는 프로바이더
final tdeeProvider = Provider.family<double?, String>((ref, sex) {
  final bmr = ref.watch(bmrProvider(sex));
  // 활동량 계수 (낮은 활동량 1.2로 가정)
  const activityFactor = 1.2;

  if (bmr != null) {
    return bmr * activityFactor;
  }
  return null;
});

class BodyInfoSection extends ConsumerStatefulWidget {
  const BodyInfoSection({super.key});

  @override
  ConsumerState<BodyInfoSection> createState() => _BodyInfoSectionState();
}

class _BodyInfoSectionState extends ConsumerState<BodyInfoSection> {
  final TextEditingController _heightController = TextEditingController();
  late FocusNode _heightFocusNode;

  @override
  void initState() {
    super.initState();
    _heightFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _heightController.dispose();
    _heightFocusNode.dispose();
    super.dispose();
  }

  void _saveHeight(String value) {
    final double? height = double.tryParse(value);
    if (height != null && height > 0) {
      ref.read(heightProvider.notifier).saveHeight(height);
    }
  }

  void _saveSex(String sex) {
    ref.read(sexProvider.notifier).saveSex(sex);
  }

  @override
  Widget build(BuildContext context) {
    final latestWeight = ref.watch(getLatestWeightProvider);
    final currentSex = ref.watch(sexProvider);
    final height = ref.watch(heightProvider);

    final bmr = ref.watch(bmrProvider(currentSex ?? ''));
    final tdee = ref.watch(tdeeProvider(currentSex ?? ''));

    // 키 입력 TextField의 테두리 색상 처리
    final borderColor = _heightFocusNode.hasFocus
        ? Theme.of(context).primaryColor // 포커스 시 색상
        : const Color(0xFFDDDDDD);
  
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (height != null && _heightController.text != height.toString()) {
        _heightController.text = height.toString();
      }
    });

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          // 키 입력
          SizedBox(
            height: 48,
            child: Row(
              children: [
                const SizedBox(
                  width: 80,
                  child: Text(
                    '키',
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 16,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _heightController,
                    focusNode: _heightFocusNode,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.right, 
                    onSubmitted: (value) => _saveHeight(value),
                    inputFormatters: [
                      LimitValueFormatter(max: 999.9),
                      FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}(\.\d{0,})?$')),
                    ],
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      suffixText: "cm",
                      suffixStyle: const TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 16,
                        fontFamily: 'Pretendard',
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF0D86E7), ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 성별 선택
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(
                width: 80,
                child: Text(
                  '성별',
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 16,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  GestureDetector(
                    onTap: () => _saveSex('man'),
                    child: _genderChip(
                      icon: 'assets/icons/ico_man.svg',
                      label: '남성',
                      isSelected: currentSex == 'man',
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _saveSex('woman'),
                    child: _genderChip(
                      icon: 'assets/icons/ico_woman.svg',
                      label: '여성',
                      isSelected: currentSex == 'woman',
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          // 체중
          bodyInfoItem(
            '체중',
            latestWeight.when(
              data: (weight) => '${weight?.toStringAsFixed(1) ?? '0'} kg',
              loading: () => '계산 중...',
              error: (err, stack) => '불러오기 실패',
            ),
          ),
          const SizedBox(height: 24),
          // 기초대사량
          bodyInfoItem(
            '기초대사량',
            bmr != null ? '${bmr.toStringAsFixed(1)} kcal' : '정보 없음',
          ),
          const SizedBox(height: 24),
          // 활동대사량
          bodyInfoItem(
            '활동대사량',
            tdee != null ? '${tdee.toStringAsFixed(1)} kcal' : '정보 없음',
          ),
        ],
      ),
    );
  }

  Widget bodyInfoItem(String title, String value) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF333333),
                fontSize: 16,
                fontFamily: 'Pretendard',
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.centerRight,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF999999),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 성별 선택 버튼 위젯
  Widget _genderChip({
    required String icon,
    required String label,
    required bool isSelected,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? const Color(0xFF333333) : const Color(0xFFDDDDDD),
        ),
        borderRadius: BorderRadius.circular(99),
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            icon, 
            width: 16, 
            height: 16,
            colorFilter: ColorFilter.mode(
              isSelected ? const Color(0xFF333333) : const Color(0xFFDDDDDD),
              BlendMode.srcIn, // SVG 내부 색상만 바뀜
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF333333) : const Color(0xFFAAAAAA),
              fontSize: 12,
              fontFamily: 'Pretendard',
            ),
          ),
        ],
      ),
    );
  }
}