import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class DocBodyCalendar extends StatelessWidget {
  const DocBodyCalendar({super.key});

  @override
  Widget build(BuildContext context) {

    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        //TODO: 모바일, 테블릿 반응형 분기처리
        return Scaffold(
          body: Column(
            children: [
              // AppBar 대체 영역 (flex: 1)
              Expanded(
                flex: 14,
                child: Container(
                  color: Colors.blue,
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top), // status bar 고려
                  alignment: Alignment.center,
                  child: const Text(
                    'Custom AppBar',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),

              // Body 영역 (flex: 6)
              Expanded(
                flex: 49,
                child: Container(
                  color: Colors.white,
                  child: const Center(child: Text('Body Area')),
                ),
              ),

              // BottomSheet 대체 영역 (flex: 4)
              Expanded(
                flex: 36,
                child: Container(
                  color: Colors.grey[200],
                  child: const Center(child: Text('Bottom Sheet Area')),
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}