import 'package:flutter/material.dart';
import 'package:my_app/view/tab/cmu/feed/item/cmu_basic_app_bar.dart';
import 'package:my_app/view/tab/cmu/feed/write/write_feed_category_select_bar.dart';

class WriteFeed extends StatefulWidget {
  const WriteFeed({super.key});

  @override
  State<WriteFeed> createState() => _WriteFeedState();
}

class _WriteFeedState extends State<WriteFeed> {
  final TextEditingController _titleController = TextEditingController();

  void _onCategoryChange({required int index}) {

  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 44,),
        child: Column(
          children: [
            // 상단 바 
            const CmuBasicAppBar(centerText: '피드 작성하기'),
            // 카테고리 선택 바
            WriteFeedCategorySelectBar(onCategoryChange: _onCategoryChange, selectedCategoryId: 0,),
            // 제목 입력 섹션
            const Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 15),
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 4,),
                  child: Text(
                    '피드 제목',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: '제목을 입력해주세요',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFF0D85E7), // 원하는 색상
                      width: 2.0,
                    ),
                  ),
                ),
                style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
              ),
            ),
          ],
        )
      ),
    );
  }
} 