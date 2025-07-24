import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:my_app/view/tab/cmu/feed/item/cmu_write_app_bar.dart';
import 'package:my_app/view/tab/cmu/feed/write/write_feed_category_select_bar.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class WriteFeed extends StatefulWidget {
  const WriteFeed({super.key});

  @override
  State<WriteFeed> createState() => _WriteFeedState();
}

class _WriteFeedState extends State<WriteFeed> {
  final TextEditingController _titleController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Quill 에디터 컨트롤러
  final QuillController _controller = QuillController.basic(
    config: QuillControllerConfig(
      clipboardConfig: QuillClipboardConfig(
        enableExternalRichPaste: true,
        onImagePaste: (imageBytes) async {
          if (kIsWeb) {
            return null;
          }
          final newFileName = 'image-file-${DateTime.now().toIso8601String()}.png';
          final newPath = path.join(io.Directory.systemTemp.path, newFileName);
          final file = await io.File(newPath).writeAsBytes(imageBytes, flush: true);
          return file.path;
        },
      ),
    ),
  );
  // 포커스 노드 : 에디터 포커스 상태 관리
  final FocusNode _editorFocusNode = FocusNode();
  // 에디터 내부 스크롤 컨트롤러
  final ScrollController _editorScrollController = ScrollController();
  // 툴바 가시성 상태
  bool _showToolbar = false;
  // 에디터의 현재 높이를 저장할 변수
  double _currentEditorHeight = 0.0;

  @override
  void initState() {
    super.initState();
    // 포커스 노드에 리스너 추가: 에디터의 포커스 상태가 변경될 때마다 _updateToolbarVisibility 호출
    _editorFocusNode.addListener(_updateToolbarVisibility);

    // QuillEditor 변경 감지
    _controller.document.changes.listen((event) {
      _onDocumentContentChanged();
    });
  }

  void _onDocumentContentChanged() {
    // 문서 내용이 변경될 때마다 높이를 다시 측정
    // 다음 프레임에 측정해야 정확한 높이를 얻을 수 있습니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureEditorHeight();
    });
  }

  void _measureEditorHeight() {
    // RenderBox를 통해 위젯의 실제 크기를 얻습니다.
    final RenderBox? renderBox = _editorFocusNode.context?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final newHeight = renderBox.size.height;
      if (newHeight != _currentEditorHeight) {
        setState(() {
          _currentEditorHeight = newHeight;
        });
        _scrollUp();
      }
    }

  }

  void _updateToolbarVisibility() {
    setState(() {
      _showToolbar = _editorFocusNode.hasFocus; // 에디터에 포커스가 있으면 툴바 표시
    });
  }

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
    _editorFocusNode.removeListener(_updateToolbarVisibility); // 리스너 제거
    _editorFocusNode.dispose();
     _editorScrollController.dispose();
    _controller.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Column(
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
                                color: Color(0xFF555555),
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
                       const Padding(
                        padding: EdgeInsets.only(left: 20, right: 20, bottom: 6),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: 4,),
                              child: Text(
                                '피드 내용',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF555555),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 1,
                          color:Colors.grey.shade300
                        ),
                        QuillEditor(
                          focusNode: _editorFocusNode,
                          controller: _controller,
                          scrollController: _editorScrollController,
                          config: QuillEditorConfig(
                            scrollable: false, // QuillEditor 자체의 스크롤을 비활성화
                            autoFocus: false, // 필요에 따라 자동 포커스 설정
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20), // 기본 패딩 제거
                            placeholder: '내용을 입력해주세요...',
                            customStyles: const DefaultStyles(
                              placeHolder: DefaultTextBlockStyle(
                                TextStyle(
                                  fontSize: 14,
                                  color: Color.fromRGBO(158, 158, 158, 0.8),
                                ),
                                HorizontalSpacing.zero,
                                VerticalSpacing.zero,
                                VerticalSpacing.zero,
                                null,
                              ),
                            ),
                            textSelectionThemeData: const TextSelectionThemeData(
                              cursorColor: Color(0xFF0D85E7), // 원하는 커서 색상으로 변경
                            ),
                            embedBuilders: [
                              ...FlutterQuillEmbeds.editorBuilders(
                                imageEmbedConfig: QuillEditorImageEmbedConfig(
                                  imageProviderBuilder: (context, imageUrl) {
                                    debugPrint(imageUrl);
                                    if (imageUrl.startsWith('file://')) {
                                      final path = Uri.parse(imageUrl).toFilePath();
                                      final file = io.File(path);
                        
                                      final exists = file.existsSync();
                                      debugPrint('File at $path exists: $exists');
                        
                                      if (exists) return FileImage(file);
                                    }
                                    return null;
                                  },
                                ),
                                videoEmbedConfig: QuillEditorVideoEmbedConfig(
                                  customVideoBuilder: (videoUrl, readOnly) {
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                         // 툴바 높이 + 키보드 높이와 동일한 아래쪽 패딩 추가
                      // 이는 콘텐츠가 툴바/키보드 아래에 숨겨지지 않도록 보장
                        SizedBox(height: _showToolbar ? 50.0 + keyboardHeight : 0),  
                    ],
                  )
                ),
              ),
            ],
          ),

          // 키보드 위에 위치한 툴바
          if (_showToolbar)
            Positioned(
              bottom: keyboardHeight, // 키보드 바로 위에 위치
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 50.0,
                color: Colors.grey[200],
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: QuillSimpleToolbar(
                    controller: _controller,
                    config: QuillSimpleToolbarConfig(
                      customButtons: [
                        QuillToolbarCustomButtonOptions(
                          icon: const Icon(Icons.keyboard_hide_outlined),
                          tooltip: 'Hide Keyboard',
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                          },
                        ),
                      ],
                      showBoldButton: true,
                      showUnderLineButton: true,
                      showStrikeThrough: true,
                      showListBullets: true,
                      showListNumbers: true,
                      showUndo: true,
                      showRedo: true,
                      showListCheck: false,
                      showItalicButton: false,
                      showSmallButton: false,
                      showInlineCode: false,
                      showCodeBlock: false,
                      showQuote: false,
                      showDirection: false,
                      showSubscript: false,
                      showSuperscript: false,
                      showFontFamily: false,
                      showFontSize: false,
                      showColorButton: false,
                      showBackgroundColorButton: false,
                      showClearFormat: false,
                      showAlignmentButtons: false,
                      showHeaderStyle: false,
                      showIndent: false,
                      showLink: false,
                      showSearchButton: false,
                      showLineHeightButton: false,
                      showClipboardCut: false,
                      showClipboardCopy: false,
                      showClipboardPaste: false,
                      embedButtons: FlutterQuillEmbeds.toolbarButtons(
                        imageButtonOptions: QuillToolbarImageButtonOptions(
                          imageButtonConfig: QuillToolbarImageConfig(
                            onImageInsertCallback: (image, controller) async {
                              final originalFile = io.File(image);
                              if (!await originalFile.exists()) return;

                              final appDir = await getApplicationDocumentsDirectory();
                              final fileName = 'img-${DateTime.now().millisecondsSinceEpoch}.png';
                              final savedFile = await originalFile.copy(path.join(appDir.path, fileName));
                              final imageUrl = 'file://${savedFile.path}';

                              controller.document.insert(
                                controller.selection.extentOffset,
                                BlockEmbed.image(imageUrl),
                              );
                              controller.updateSelection(
                                TextSelection.collapsed(
                                  offset: controller.selection.extentOffset + 1,
                                ),
                                ChangeSource.local,
                              );
                            },
                          ),
                        ),
                      ),
                      buttonOptions: QuillSimpleToolbarButtonOptions(
                        linkStyle: QuillToolbarLinkStyleButtonOptions(
                          validateLink: (link) {
                            final uri = Uri.tryParse(link);
                            return uri != null && (uri.hasScheme && (uri.isAbsolute));
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
} 