import 'package:flutter/material.dart';
import 'package:my_app/view/tab/simple_cache.dart';
import 'package:my_app/view/tab/stc/stc_app_bar.dart';
import 'package:responsive_builder/responsive_builder.dart';

class StcMain extends StatefulWidget {
  const StcMain({super.key});

  @override
  State<StcMain> createState() => _StcMainState();
}

class _StcMainState extends State<StcMain> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = cachedStcTabIndex; // 캐시된 값 불러오기
  }

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
      cachedStcTabIndex = index; // 캐시된 값 불러오기
    });
  }


  @override
  Widget build(BuildContext context) {
    // debugPrint("$_selectedIndex");
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        if(sizingInformation.isMobile){
          return Scaffold(
            body: Column(
              children: [
                StcAppBar(selectedIndex:_selectedIndex, onTap: _onTap,),
                Expanded(
                  flex: 329,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.amber.shade300
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return const Scaffold(

          );
        }
      },
    );
  }
}

