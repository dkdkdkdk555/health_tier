import 'package:flutter/material.dart';
import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:flutter/foundation.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:http/http.dart' as http;
import 'dart:io' as io show Directory, File;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class WriteFeedEditor extends StatefulWidget {
  const WriteFeedEditor({super.key});

  @override
  State<WriteFeedEditor> createState() => _WriteFeedEditorState();
}

class _WriteFeedEditorState extends State<WriteFeedEditor> {
   /*
   Quill 에디터의 전체 상태를 제어하는 컨트롤러
    - 역할: Quill 에디터의 전체 상태를 제어하는 컨트롤러
    - 문서의 Delta 상태, selection 범위, undo/redo 등 내부 상태를 포함
  */   
  final QuillController _controller = () {
    return QuillController.basic( // basic 기본 문서 컨트롤러를 초기화함
      config: QuillControllerConfig(
            clipboardConfig: 
              QuillClipboardConfig( // 클립보드 설정
                enableExternalRichPaste: true, // 외부 리치텍스트의 붙여넣기를 허용
                onImagePaste: (imageBytes) async { // 이미지가 붙여넣기 될 때 실행하는 콜백
                // imageBytes 는 붙여넣은 이미지의 바이트
                  if (kIsWeb) {
                    return null;
                  }
                  final newFileName = 'image-file-${DateTime.now().toIso8601String()}.png';
                  final newPath = path.join(io.Directory.systemTemp.path, newFileName,);
                  // 이미지 바이트를 디스크에 PNG 파일로 저장
                  final file = await io.File(newPath,).writeAsBytes(imageBytes, flush: true);
                  // 저장한 이미지 경로를 반환(Quill이 해당 이미지를 문서에 삽입 가능하게 함)
                  return file.path;
                },
              )
            )
    );
  }();
  // 에디터의 포커스 상태를 추적 및 제어 (예: 툴바에서 버튼 클릭 후 에디터로 다시 포커스 주기)
  final FocusNode _editorFocusNode = FocusNode();
  // 에디터 내부의 스크롤 위치 제어 (스크롤 감지, 특정 위치로 스크롤 이동)
  final ScrollController _editorScrollController = ScrollController();
  
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          QuillSimpleToolbar(
            controller: _controller,
            config: QuillSimpleToolbarConfig(
                showBoldButton: true,
                showUnderLineButton: true,
                showStrikeThrough: true,
                showListBullets: true,
                showListNumbers: true,
                showListCheck: true,
                showUndo: true,
                showRedo: true,

                // 나머지 모두 숨기기
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

                          // ✅ 앱의 문서 디렉토리에 저장
                          final appDir = await getApplicationDocumentsDirectory();
                          final fileName = 'img-${DateTime.now().millisecondsSinceEpoch}.png';
                          final savedFile = await originalFile.copy(path.join(appDir.path, fileName));

                          // ✅ Delta에는 file:// 경로 삽입
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
                    )
                  )
                ),
                customButtons: const [
                
                ],
                buttonOptions: QuillSimpleToolbarButtonOptions(
                  linkStyle: QuillToolbarLinkStyleButtonOptions(
                    validateLink: (link) {
                      final uri = Uri.tryParse(link);
                      return uri != null && (uri.hasScheme && (uri.isAbsolute));
                    },
                  )
              )
            ),
          ),
          QuillEditor(
            focusNode: _editorFocusNode,
            scrollController: _editorScrollController,
            controller: _controller,
            config: QuillEditorConfig(
              placeholder: 'Start writing your notes...',
              padding: const EdgeInsets.all(16),
              embedBuilders: [
                ...FlutterQuillEmbeds.editorBuilders(
                  imageEmbedConfig: QuillEditorImageEmbedConfig(
                    imageProviderBuilder: (context, imageUrl) {
                      debugPrint(imageUrl);
                      if (imageUrl.startsWith('file://')) {
                        final path = Uri.parse(imageUrl).toFilePath(); // 여기서 file:// 제거 해서 랜더링 제대로됨
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
              ]
            ),
          ),
        ],
      ),
    );
  }
}