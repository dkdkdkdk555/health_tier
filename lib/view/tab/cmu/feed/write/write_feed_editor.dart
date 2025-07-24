import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'dart:io' as io show Directory, File;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class WriteFeedEditor extends StatefulWidget {
  final VoidCallback scrollUp;
  const WriteFeedEditor({
    super.key,
    required this.scrollUp,
  });

  @override
  State<WriteFeedEditor> createState() => _WriteFeedEditorState();
}

class _WriteFeedEditorState extends State<WriteFeedEditor> {
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

  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();
  // 에디터의 현재 높이를 저장할 변수
  double _currentEditorHeight = 0.0;
  // 툴바 가시성 상태
  bool _showToolbar = false;

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
    // 문서 내용이 변경될 때마다 높이를 다시 측정합니다.
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
        widget.scrollUp();
      }
    }

  }


  void _updateToolbarVisibility() {
    setState(() {
      _showToolbar = _editorFocusNode.hasFocus; // 에디터에 포커스가 있으면 툴바 표시
    });
  }

  @override
  void dispose() {
    _editorFocusNode.removeListener(_updateToolbarVisibility); // 리스너 제거
    _editorFocusNode.dispose();
     _editorScrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column( // WriteFeedEditor가 SingleChildScrollView 내부에 있으므로, Column으로 충분합니다.
      mainAxisSize: MainAxisSize.min,
      children: [
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
                  color: Color(0xFF333333),
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
              // padding: const EdgeInsets.all(16),
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
        // 툴바 섹션
        // 키보드 높이에 따라 패딩을 조절하여 툴바를 키보드 위에 띄웁니다.
        // AnimatedContainer를 사용하여 키보드가 올라오고 내려갈 때 자연스러운 애니메이션 효과를 줍니다.
        AnimatedContainer(
          duration: const Duration(milliseconds: 300), // 애니메이션 지속 시간
          height: _showToolbar ? 50.0 : 0.0, // 툴바가 보일 때 높이, 안 보일 때 0
          margin: const EdgeInsets.only(top: 50),
          // 툴바를 가로로 스크롤 가능하게 만듭니다.
          child: _showToolbar
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    color: Colors.grey[200], // 툴바 배경색 (선택 사항)
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row( // QuillSimpleToolbar를 children으로 직접 넣기
                      children: [
                        QuillSimpleToolbar(
                          controller: _controller,
                          config: QuillSimpleToolbarConfig(
                             customButtons: [
                              QuillToolbarCustomButtonOptions(
                                icon: const Icon(
                                  Icons.keyboard_hide_outlined
                                ), // 키보드 아이콘
                                tooltip: 'Hide Keyboard', // 툴팁
                                onPressed: () {
                                  FocusScope.of(context).unfocus(); // 현재 포커스된 위젯에서 포커스를 해제하여 키보드를 내립니다.
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

                            // 나머지 모두 숨기기
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
                            showClipboardPaste: false, // 이전에 true였던 것으로 보이는데, 숨기는 목록에 포함됨
                            // 이미지 버튼은 QuillSimpleToolbar에서 embedButtons를 통해 제어
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
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(), // 툴바가 보이지 않을 때는 빈 위젯
        ),
      ],
    );
  }
}