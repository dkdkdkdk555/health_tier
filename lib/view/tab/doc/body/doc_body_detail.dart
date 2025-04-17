import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:my_app/extension/screen_ratio_extension.dart';
import 'package:my_app/model/doc_detail_model.dart';
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
    final searchDay = DateFormat('yyyy-MM-dd').format(focusedDay);
    final docDtl = ref.watch(htDayDocDetail(searchDay));

    final detail = docDtl.asData?.value;
    final today = DateFormat('yyyy.MM.dd (E)', 'ko').format(focusedDay);
   
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
            Expanded(
              flex:41,
              child: Row(
                children: [
                  const Spacer(flex: 65),
                  Column(
                    children: [
                      makeRow1(wtio, today, htio, detail),
                      const Spacer(flex:9),
                      Expanded(
                        flex: 18,
                        child: Row(
                          children: [
                            
                          ],
                        ),
                      ),
                      const Spacer(flex:4),
                      Expanded(
                        flex: 6,
                        child: Row(
                          
                        ),
                      ),
                      const Spacer(flex:9),
                      Expanded(
                        flex: 27,
                        child: Row(
                          
                        ),
                      ),
                    
                    ],
                  ),
                  const Spacer(flex: 65),
                ],
              )
            ),
            const Spacer(flex:23,),
          ],
        ),
      )
    );
  }

  Expanded makeRow1(double wtio, String today, double htio, DocDayDetail? detail) {
    return Expanded(
      flex: 9,
      child: Row(
        children: [
          SizedBox(
            width: 87 * wtio,
            child: AutoSizeText(
              '$today',
              style: const TextStyle(
                fontFamily: 'Pretendard',
              ),
            ),
          ),
          boundary(wtio, htio),
          textYN(wtio, text:"운동 여부", yn:detail?.workYn),
          iconYN(wtio, htio, 'assets/icons/work_out.svg', detail?.workYn),
          boundary(wtio, htio),
          textYN(wtio, text:"음주 여부", yn:detail?.drunYn),
          iconYN(wtio, htio, 'assets/icons/drink.svg', detail?.drunYn),
        ],
      ),
    );
  }

  SizedBox iconYN(double wtio, double htio, String path, int? yn) {
    return SizedBox(
      width: 16 * wtio,
      height: 16 * htio,
      child: SvgPicture.asset(
        path,
        colorFilter: ColorFilter.mode(
          yn == 1 ?Color(0xFF333333) : Colors.black.withValues(alpha: 0.30000001192092896),
          BlendMode.srcIn
        ),
      ),
    );
  }

  Padding textYN(double wtio, {required String text, required int? yn}) {
    return Padding(
      padding: EdgeInsets.only(right: 4 * wtio),
      child: SizedBox(
        width: 45 * wtio,
        child: AutoSizeText(
          text,
          style: TextStyle(
            color: yn == 1 ? Color(0xFF333333) : Colors.black.withValues(alpha: 0.30000001192092896),
            fontFamily: 'Pretendard',
          ),
        ),
      ),
    );
  }

  Container boundary(double wtio, double htio) {
    return Container(
      width: 1 * wtio,
      height: 8 * htio,
      margin: EdgeInsets.symmetric(horizontal: 6 * wtio),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.10000000149011612),
      ),
    );
  }
}