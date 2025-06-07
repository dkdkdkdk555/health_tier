import 'package:flutter/material.dart';
import 'package:my_app/view/tab/cmu/cmu_category_top_bar.dart';
import 'package:my_app/view/tab/cmu/cmu_category_top_bar_delegate.dart';
import 'package:my_app/view/tab/simple_cache.dart' show cachedCmuTabIndex;
import 'package:my_app/view/tab/cmu/cmu_app_bar_delegate.dart';
import 'package:my_app/extension/screen_ratio_extension.dart';

class CmuMain extends StatefulWidget {
  const CmuMain({super.key});

  @override
  State<CmuMain> createState() => _CmuMainState();
}

 var htio = 0.0;

class _CmuMainState extends State<CmuMain> {
  // 어느 하위 탭인지
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = cachedCmuTabIndex; // 캐시된 값 불러오기
  }

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
      cachedCmuTabIndex = index; // 캐싱
    });
  }

  @override
  Widget build(BuildContext context) {
    htio = ScreenRatio(context).heightRatio;

    return Container(
      color: Colors.white,
      child: CustomScrollView( 
        slivers: [
          SliverPersistentHeader(
            pinned: false,
            delegate: CmuAppBarDelegate(selectedIndex: _selectedIndex, onTap: _onTap, htio: htio)
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: CategoryTopBarDelegate(htio: htio,)
          ),
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200.0,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              childAspectRatio: 4.0,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Container(
                  alignment: Alignment.center,
                  color: Colors.teal[100 * (index % 9)],
                  child: Text('Grid Item $index'),
                );
              },
              childCount: 20,
            ),
          ),
          SliverFixedExtentList(
            itemExtent: 50.0,
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Container(
                  alignment: Alignment.center,
                  color: Colors.lightBlue[100 * (index % 9)],
                  child: Text('List Item $index'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}