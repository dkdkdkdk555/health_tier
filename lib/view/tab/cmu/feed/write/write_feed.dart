import 'package:flutter/material.dart';
import 'package:my_app/view/tab/cmu/feed/item/cmu_write_app_bar.dart';
import 'package:my_app/view/tab/cmu/feed/write/write_feed_category_select_bar.dart';
import 'package:my_app/view/tab/cmu/feed/write/write_feed_editor.dart';

class WriteFeed extends StatefulWidget {
  const WriteFeed({super.key});

  @override
  State<WriteFeed> createState() => _WriteFeedState();
}

class _WriteFeedState extends State<WriteFeed> {
  final TextEditingController _titleController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _onCategoryChange({required int index}) {

  }

  void _onSubmit(){

  }


  void _scrollUp(){
    // 스크롤 가능한 최대 범위(바닥)로 이동
    final double targetOffset = _scrollController.position.maxScrollExtent;
    if (_scrollController.hasClients) { // 컨트롤러가 attached 되어 있는지 확인
        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
    }
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
      // resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          // 상단바
          Padding(
            padding: const EdgeInsets.only(top: 44),
            child: CmuWriteAppBar(centerText: '피드 작성하기', onSubmit: _onSubmit),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
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
                        hintStyle: TextStyle(
                          fontSize: 14,
                           color: Color.fromRGBO(158, 158, 158, 0.8), 
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF0D85E7),
                            width: 2.0,
                          ),
                        ),
                      ),
                      style: const TextStyle(fontSize: 16, color: Color(0xff0000000)),
                      cursorColor: const Color(0xFF0D85E7),
                    ),
                  ),
            
                   const SizedBox(height: 24),
                  WriteFeedEditor(scrollUp: _scrollUp,)
                ],
              )
            ),
          ),
        ],
      ),
    );
  }
} 