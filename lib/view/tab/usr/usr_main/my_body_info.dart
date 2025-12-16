import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_app/model/usr/user/weight_3_info.dart';
import 'package:my_app/util/dialog_utils.dart';
import 'package:my_app/util/screen_ratio.dart' show ScreenRatio;
import 'package:my_app/util/spinner_utils.dart' show AppLoadingIndicator;
import 'package:my_app/view/common/error_widget.dart';
import 'package:my_app/view/tab/usr/usr_main/body_info_section.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/providers/user_cud_providers.dart';

// MyBodyInfo를 ConsumerWidget으로 변경
// ignore: must_be_immutable
class MyBodyInfo extends ConsumerWidget {
  MyBodyInfo({
    super.key
  });

  // pose에 따른 아이콘 경로를 매핑
  static const Map<String, String> _iconPaths = {
    'BENCH': 'assets/icons/benchpress.svg',
    'DEAD': 'assets/icons/deadlift.svg',
    'SQUAT': 'assets/icons/squat.svg',
  };

  double htio = 0;
  double wtio = 0;
  final GlobalKey<BodyInfoSectionState> bodyKey = GlobalKey<BodyInfoSectionState>();

  int totalWeight = 0;


  @override
  Widget build(BuildContext context, WidgetRef ref) {

    htio = ScreenRatio(context).heightRatio;
    wtio = ScreenRatio(context).widthRatio;
    
    // userWeightListProvider를 watch하여 데이터 상태를 감지
    final userWeightsAsync = ref.watch(userWeightListProvider);

    return SingleChildScrollView(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
           FocusScope.of(context).unfocus(); // 여백 클릭시 키보드 들어가게
           bodyKey.currentState?.saveHeight(); // 여백 클릭시 키 저장되게 하기
        },
        child: Column(
          children: [
            _buildHeader(context, '3대 중량', true,
              '💪🏻 3대 중량',
              '중량인증 카테고리로 피드를 게시하고\n타 사용자들 또는 관리자에게 인증을 받으면\n여기에 종목별 최대 중량이 보여집니다.'
            ),
            userWeightsAsync.when(
              data: (weightsResult) {
                final weights = weightsResult.data;
                return _buildExerciseSection(weights);
              },
              loading: () => Container(
                height: 183 * htio,
                alignment: Alignment.center,
                child: const AppLoadingIndicator(),
              ),
              error: (err, stack) => 
                const ErrorContentWidget(mainText: '3대 중량을 불러오는데 실패했습니다.',)
            ),
            _buildHeader(context, '신체정보', true,
              '🩻 신체정보',
              '기록탭에서 가장 최근에 입력한 체중과, 아래에 입력한 키, 성별 정보를 바탕으로 일일 기초대사량, 활동대사량을 자동으로 계산해줍니다.'
            ),
            BodyInfoSection(key: bodyKey,),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title, bool isThereDescription,
    String subscriptTitle, String subscription) {
    return Container(
      width: double.infinity,
      height: 86 * htio,
      padding: EdgeInsets.only(
        top: 48 * htio,
        left: 20 * wtio,
        right: 20 * wtio,
        bottom: 8 * htio,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20 * htio,
              fontFamily: 'Pretendard',
              height: 0.07 * htio,
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
              padding: EdgeInsets.only(left: 5 * wtio, top: 1 * htio, bottom: 1 * htio),
              child: SizedBox(
                width: 14 * wtio,
                height: 14 * htio,
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
      height: 326 * htio,
      padding: EdgeInsets.symmetric(horizontal: 20 * wtio, vertical: 24 * htio),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 24 * wtio,
          vertical: 32 * htio,
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
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildExerciseItems(weights),
            ),
            SizedBox(height: 40 * htio,),
            Text(
              '총 중량',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF777777),
                fontSize: 24 * htio,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w400
              ),
            ),
            SizedBox(height: 2 * htio),
            SizedBox(
              width: 200 * wtio,
              child: Text(
                '${totalWeight}kg',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 40 * htio,
                  fontFamily: 'Paperlogy',
                ),
              ),
            ),
          ],
        ),
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

    int weightSum = 0;
    
    for (int i = 0; i < sortedWeights.length; i++) {
      final weightInfo = sortedWeights[i];
      weightSum += weightInfo.weight;
      items.add(_buildExerciseItem(weightInfo.pose, weightInfo.weight));
      
      // 마지막 아이템이 아니면 간격 추가
      if (i < sortedWeights.length - 1) {
        items.add(SizedBox(width: 40 * wtio));
      }
    }

    totalWeight = weightSum;
    
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
          width: 36 * wtio,
          height: 36 * htio,
          child: SvgPicture.asset(
            _iconPaths[pose] ?? 'assets/icons/default.svg', // pose에 맞는 아이콘 표시
          ),
        ),
        SizedBox(height: 8 * htio),
        _buildExerciseInfo(name, '${weight}kg'),
      ],
    );
  }

  // 운동 정보 위젯 (이름과 중량)
  Widget _buildExerciseInfo(String name, String weight) {
    return SizedBox(
      width: 66 * wtio,
      child: Column(
        children: [
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF777777),
              fontSize: 14 * htio,
              fontFamily: 'Pretendard',
              height: 0.11 * htio,
              fontWeight: FontWeight.w400
            ),
          ),
          SizedBox(height: 30 * htio),
          Text(
            weight,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20 * htio,
              fontFamily: 'Pretendard',
              height: 0.07 * htio,
              fontWeight: FontWeight.w600
            ),
          ),
        ],
      ),
    );
  }
}