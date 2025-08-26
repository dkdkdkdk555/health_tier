import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_app/view/tab/usr/usr_main/body_info_section.dart';

// 운동 데이터 모델
class ExerciseData {
  final String name;
  final String weight;
  final Widget icon;

  ExerciseData({
    required this.name,
    required this.weight,
    required this.icon,
  });
}

class MyBodyInfo extends StatefulWidget {
  const MyBodyInfo({super.key});

  @override
  State<MyBodyInfo> createState() => _MyBodyInfoState();
}

class _MyBodyInfoState extends State<MyBodyInfo> {

  // 운동 데이터 리스트
  List<ExerciseData> get exercises => [
    ExerciseData(
      name: '벤치프레스',
      weight: '120kg',
      icon: SvgPicture.asset(
        'assets/icons/benchpress.svg'
      ),
    ),
    ExerciseData(
      name: '데드리프트',
      weight: '300kg',
      icon: SvgPicture.asset(
        'assets/icons/deadlift.svg'
      ),
    ),
    ExerciseData(
      name: '스쿼트',
      weight: '240kg',
      icon: SvgPicture.asset(
        'assets/icons/squat.svg'
      ),
    ),
  ];


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader('3대 중량', false),
          _buildExerciseSection(),
          _buildHeader('신체정보', true),
          const BodyInfoSection(),
        ],
      )
    );
  }

  Widget _buildHeader(String title, bool isThereDescription) {
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
          Padding(
            padding: const EdgeInsets.only(left: 5, top: 1, bottom: 1),
            child: SizedBox(
              width: 14,
              height: 14,
              child: SvgPicture.asset(
                'assets/icons/description.svg'
              ),
            ),
          ) : const SizedBox.shrink(),
        ],
      ),
    );
  }
  
  // 운동 섹션 위젯
  Widget _buildExerciseSection() {
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
              children: _buildExerciseItems(),
            ),
          ),
        ],
      ),
    );
  }

  // 운동 아이템들 생성
  List<Widget> _buildExerciseItems() {
    List<Widget> items = [];
    
    for (int i = 0; i < exercises.length; i++) {
      items.add(_buildExerciseItem(exercises[i]));
      
      // 마지막 아이템이 아니면 간격 추가
      if (i < exercises.length - 1) {
        items.add(const SizedBox(width: 40));
      }
    }
    
    return items;
  }
  // 개별 운동 아이템 위젯
  Widget _buildExerciseItem(ExerciseData exercise) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 36,
          height: 36,
          child: exercise.icon,
        ),
        const SizedBox(height: 8),
        _buildExerciseInfo(exercise.name, exercise.weight),
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