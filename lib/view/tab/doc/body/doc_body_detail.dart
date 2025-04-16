import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:my_app/extension/screen_ratio_extension.dart';
import 'package:my_app/providers/db_providers.dart';

class DocBodyDetail extends ConsumerWidget {
  const DocBodyDetail({
    super.key,
    required this.focusedDay,
  });

  final DateTime focusedDay;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final htio = ScreenRatio(context).heightRatio;
    final wtio = ScreenRatio(context).widthRatio;
    final searchDay = DateFormat('yyyy-MM-DD').format(focusedDay);
    final docDtl = ref.watch(htDayDocDetail(searchDay));
    return Expanded(
      flex: 148,
      child: Container(
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
            const Spacer(flex:2),
            Expanded(
              flex:1,
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