import 'package:auto_size_text/auto_size_text.dart' show AutoSizeText;
import 'package:flutter/material.dart';

class CustomWeekdayRow extends StatelessWidget {
  const CustomWeekdayRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 17,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              children: [
                const Spacer(flex: 36),
                for (int i = 0; i < 7; i++) ...[
                  Expanded(
                    flex: 10,
                    child: Center(
                      child: AutoSizeText(
                        ['일', '월', '화', '수', '목', '금', '토'][i],
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          color: Color.fromARGB(102, 0, 0, 0),
                        ),
                      ),
                    ),
                  ),
                  if (i != 6) const Spacer(flex: 38),
                ],
                const Spacer(flex: 36,)
              ],
            ),
          ),
        ),
        const Spacer(flex: 29),
      ],
    );
  }
}

