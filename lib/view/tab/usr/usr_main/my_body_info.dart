import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_app/model/usr/user/weight_3_info.dart';
import 'package:my_app/util/dialog_utils.dart';
import 'package:my_app/util/spinner_utils.dart' show AppLoadingIndicator;
import 'package:my_app/view/tab/usr/usr_main/body_info_section.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/providers/user_cud_providers.dart';

// MyBodyInfo를 ConsumerWidget으로 변경
class MyBodyInfo extends ConsumerWidget {
  const MyBodyInfo({super.key});

  // pose에 따른 아이콘 경로를 매핑
  static const Map<String, String> _iconPaths = {
    'BENCH': 'assets/icons/benchpress.svg',
    'DEAD': 'assets/icons/deadlift.svg',
    'SQUAT': 'assets/icons/squat.svg',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // userWeightListProvider를 watch하여 데이터 상태를 감지
    final userWeightsAsync = ref.watch(userWeightListProvider);

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(context, '3대 중량', true,
            '',
            '중량인증 카테고리로 피드를 게시하고\n사용자 또는 관리자에게 인증을 받은\n종목별 최대 중량이 보여집니다.'
          ),
          userWeightsAsync.when(
            data: (weightsResult) {
              final weights = weightsResult.data;
              return _buildExerciseSection(weights);
            },
            loading: () => Container(
              height: 183,
              alignment: Alignment.center,
              child: const AppLoadingIndicator(),
            ),
            error: (err, stack) => Container(
              height: 183,
              alignment: Alignment.center,
              child: const Text('3대 중량을 불러오는데 실패했습니다.'),
            ),
          ),
          _buildHeader(context, '신체정보', true,
            '',
            '체중은 바디 캘린더에 기록한 가장 최근 기록을 가져옵니다.\n입력한 키, 성별, 체중 정보를 바탕으로 일일 기초대사량,\n활동대사량을 자동으로 계산해줍니다.'
          ),
          const BodyInfoSection(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title, bool isThereDescription,
    String subscriptTitle, String subscription) {
    return Container(
      width: double.infinity,
      height: 86,
      padding: const EdgeInsets.only(
        top: 48,
        left: 20,
        right: 20,
        bottom: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontFamily: 'Pretendard',
              height: 0.07,
            ),
          ),
          isThereDescription ?
          InkWell(
            onTap: () {
              showAppDialog(
                context, 
                title: subscriptTitle,
                message: subscription
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 5, top: 1, bottom: 1),
              child: SizedBox(
                width: 14,
                height: 14,
                child: SvgPicture.asset(
                  'assets/icons/description.svg',
                ),
              ),
            ),
          ) : const SizedBox.shrink(),
        ],
      ),
    );
  }

  // 운동 섹션 위젯
  Widget _buildExerciseSection(List<Weight3Info> weights) {
    return Container(
      width: double.infinity,
      height: 183,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 28,
            ),
            decoration: ShapeDecoration(
              gradient: const LinearGradient(
                begin: Alignment(0.00, -1.00),
                end: Alignment(0, 1),
                colors: [Color(0xFFFFF3E0), Color(0xFFE7F3FF)],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildExerciseItems(weights),
            ),
          ),
        ],
      ),
    );
  }

  // 운동 아이템들 생성
  List<Widget> _buildExerciseItems(List<Weight3Info> weights) {
    List<Widget> items = [];

    // 'BENCH', 'SQUAT', 'DEAD' 순서로 정렬 (API 결과가 순서를 보장하지 않을 경우)
    final sortedWeights = <Weight3Info>[];
    for (var pose in ['BENCH', 'SQUAT', 'DEAD']) {
      final item = weights.firstWhere((w) => w.pose == pose, orElse: () => Weight3Info(pose: pose, weight: 0));
      sortedWeights.add(item);
    }
    
    for (int i = 0; i < sortedWeights.length; i++) {
      final weightInfo = sortedWeights[i];
      items.add(_buildExerciseItem(weightInfo.pose, weightInfo.weight));
      
      // 마지막 아이템이 아니면 간격 추가
      if (i < sortedWeights.length - 1) {
        items.add(const SizedBox(width: 40));
      }
    }
    
    return items;
  }

  // 개별 운동 아이템 위젯
  Widget _buildExerciseItem(String pose, int weight) {
    String name = '';
    switch(pose) {
      case 'BENCH': name = '벤치프레스'; break;
      case 'DEAD': name = '데드리프트'; break;
      case 'SQUAT': name = '스쿼트'; break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 36,
          height: 36,
          child: SvgPicture.asset(
            _iconPaths[pose] ?? 'assets/icons/default.svg', // pose에 맞는 아이콘 표시
          ),
        ),
        const SizedBox(height: 8),
        _buildExerciseInfo(name, '${weight}kg'),
      ],
    );
  }

  // 운동 정보 위젯 (이름과 중량)
  Widget _buildExerciseInfo(String name, String weight) {
    return SizedBox(
      width: 66,
      child: Column(
        children: [
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF777777),
              fontSize: 14,
              fontFamily: 'Pretendard',
              height: 0.11,
            ),
          ),
          const SizedBox(height: 30),
          Text(
            weight,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontFamily: 'Pretendard',
              height: 0.07,
            ),
          ),
        ],
      ),
    );
  }
}