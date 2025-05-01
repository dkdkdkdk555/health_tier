import 'package:flutter/material.dart';
import 'package:my_app/extension/screen_ratio_extension.dart';

class DocDietDetail extends StatelessWidget {
  const DocDietDetail({
    super.key,
    required this.focusedDay,
    required this.bottomHeight,
  });
  final DateTime focusedDay;
  final double bottomHeight;

  @override
  Widget build(BuildContext context) {
    final htio = ScreenRatio(context).heightRatio;
    final wtio = ScreenRatio(context).widthRatio;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
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
              const Spacer(flex:4),
              Expanded(
                flex:2,
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
              const Expanded(
                flex: 201,
                child: Row(
                  
                ),
              ),
              SizedBox(
                height: bottomHeight,
              )
            ],
          ),
        ),
      ]
    );
  }
}