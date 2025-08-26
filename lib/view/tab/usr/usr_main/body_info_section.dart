import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BodyInfoSection extends StatefulWidget {
  const BodyInfoSection({super.key});

  @override
  State<BodyInfoSection> createState() => _BodyInfoSectionState();
}

class _BodyInfoSectionState extends State<BodyInfoSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
    margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 키 입력
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
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    suffixText: "cm",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        /// 성별 선택
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
                _genderChip(
                  icon: 'assets/icons/ico_man.svg',
                  label: '남성',
                  isSelected: true,
                ),
                _genderChip(
                  icon: 'assets/icons/ico_woman.svg',
                  label: '여성',
                  isSelected: false,
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 24),
        bodyInfoItem('체중', 'kg'),
        const SizedBox(height: 24),
        bodyInfoItem('기초대사량', 'kcal'),
        const SizedBox(height: 24),
        bodyInfoItem('활동대사량', 'kcal'),
      ],
    ),
  );
  }

  SizedBox bodyInfoItem(String title, String unit) {
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
                '72.1 $unit',
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
          SvgPicture.asset(icon, width: 16, height: 16),
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