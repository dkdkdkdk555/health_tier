import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/extension/screen_ratio_extension.dart';

class DocBodyDetail extends ConsumerWidget {
  const DocBodyDetail({
    super.key,
    required this.focusedDay,
  });

  final DateTime focusedDay;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      flex: 148,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(47)),
          border: Border(
            left: BorderSide(width: 2 ,color: Color(0xFFEEEEEE)),
            top: BorderSide(width: 2, color: Color(0xFFEEEEEE)),
            right: BorderSide(width: 2, color: Color(0xFFEEEEEE)),
            bottom: BorderSide(color: Color(0xFFEEEEEE)),
          ),
        ),
        child: Column(
          children: [
            const Spacer(flex:2),
            Expanded(
              flex:1,
              child: Container(
                width: 40 * ScreenRatio(context).widthRatio,
                height: 4 * ScreenRatio(context).heightRatio,
                decoration: ShapeDecoration(
                  color: const Color(0xFFE6E6E6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                  ),
                ),
              )
            ),
            const Spacer(flex:7),
            const Expanded(
              flex:41,
              child: Center(

              ) 
            ),
            const Spacer(flex:23,),
          ],
        ),
      )
    );
  }
}