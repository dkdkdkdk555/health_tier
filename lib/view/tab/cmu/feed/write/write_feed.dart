import 'dart:io' as io;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:my_app/util/quill_video_player.dart';
import 'package:my_app/view/tab/cmu/feed/item/cmu_write_app_bar.dart';
import 'package:my_app/view/tab/cmu/feed/write/write_feed_category_select_bar.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class WriteFeed extends StatefulWidget {
  const WriteFeed({super.key});

  @override
  State<WriteFeed> createState() => _WriteFeedState();
}

class _WriteFeedState extends State<WriteFeed> {
  final TextEditingController _titleController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Quill 에디터 컨트롤러
  late QuillController _controller;
  // 포커스 노드 : 에디터 포커스 상태 관리
  final FocusNode _editorFocusNode = FocusNode();
  // 에디터 내부 스크롤 컨트롤러
  final ScrollController _editorScrollController = ScrollController();
  // 툴바 가시성 상태
  bool _showToolbar = false;
  // 에디터의 현재 높이를 저장할 변수
  double _currentEditorHeight = 0.0;
  // 파일 선택 중인지 나타내는 플래그 추가
  bool _isPickingFile = false;

  @override
  void initState() {
    super.initState();

    _controller = QuillController.basic(
      config: QuillControllerConfig(
        clipboardConfig: QuillClipboardConfig(
          enableExternalRichPaste: false,
          onImagePaste: (imageBytes) async {
            if (kIsWeb) {
              return null;
            }
            final newFileName = 'image-file-${DateTime.now().toIso8601String()}.png';
            final newPath = path.join(io.Directory.systemTemp.path, newFileName);
            final file = await io.File(newPath).writeAsBytes(imageBytes, flush: true);
            return file.path;
          },
          onClipboardPaste: () async {
            final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
            final text = clipboardData?.text;
            if (text != null) {
              final youtubeVideoId = YoutubePlayer.convertUrlToId(text);
              if (youtubeVideoId != null) {
                final int index = _controller.selection.extentOffset;
                // 여기서 youtube://$youtubeVideoId 대신 표준 유튜브 URL 형식으로 변경
                _controller.document.insert(
                  index,
                  BlockEmbed.video('https://www.youtube.com/watch?v=$youtubeVideoId'), // **수정된 부분**
                );
                _controller.updateSelection(
                  TextSelection.collapsed(offset: index + 1),
                  ChangeSource.local,
                );
                debugPrint('YouTube video embedded via onClipboardPaste: $youtubeVideoId');
                return true;
              }
            }
            return false;
          },
        ),
      ),
    );

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


  void _scrollUp() async{
    await Future.delayed(const Duration(milliseconds: 50));
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
                          style: const TextStyle(fontSize: 16, color: Color(0xff000000)),
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
                                    // debugPrint(imageUrl);
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
                                    debugPrint('customVideoBuilder called with URL: $videoUrl');

                                    final youtubeVideoIdFromUrl = YoutubePlayer.convertUrlToId(videoUrl); // **새로 추가된 부분**

                                    if (youtubeVideoIdFromUrl != null) {
                                      debugPrint('Detected YouTube video with ID: $youtubeVideoIdFromUrl');
                                      return QuillVideoPlayer(youtubeVideoId: youtubeVideoIdFromUrl); // **수정된 부분**
                                    }

                                    Uri? uri = Uri.tryParse(videoUrl);
                                    if (uri == null) {
                                      debugPrint('Invalid URI: $videoUrl');
                                      return const SizedBox();
                                    }

                                    // 로컬 파일 및 네트워크 비디오 처리 (기존 로직 유지)
                                    late VideoPlayerController videoController;
                                    if (uri.scheme == 'file') {
                                      videoController = VideoPlayerController.file(io.File(uri.toFilePath()));
                                    } else {
                                      videoController = VideoPlayerController.networkUrl(uri);
                                    }
                                    return QuillVideoPlayer(controller: videoController);
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
                        videoButtonOptions: QuillToolbarVideoButtonOptions(
                          
                          videoConfig: QuillToolbarVideoConfig(
                             // onVideoInsertCallback을 커스터마이징합니다.
                            onVideoInsertCallback: (video, controller) => _handleVideoInsert(video, controller),
                          )
                        )
                      ),
                      buttonOptions: QuillSimpleToolbarButtonOptions(
                        linkStyle: QuillToolbarLinkStyleButtonOptions(
                          validateLink: (link) {
                            debugPrint('호호');
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

  // 비디오 선택시
   Future<void> _handleVideoInsert(String video, QuillController controller) async {
    debugPrint('헤헤');
    
    if (_isPickingFile) {
      // 이미 파일 선택 중이면 추가 요청을 무시합니다.
      debugPrint('File picking in progress, ignoring duplicate request.');
      return;
    }

    setState(() {
      _isPickingFile = true; // 파일 선택 시작 플래그 설정
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        debugPrint('No video selected or operation cancelled.');
        return; // 사용자가 파일을 선택하지 않았거나 취소했습니다.
      }

      final pickedFile = result.files.single;
      final videoPath = pickedFile.path;

      if (videoPath == null) {
        debugPrint('Video path is null.');
        return;
      }

      final originalFile = io.File(videoPath);
      if (!await originalFile.exists()) {
        debugPrint('Original video file does not exist.');
        return;
      }

      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'vid-${DateTime.now().millisecondsSinceEpoch}.mp4';
      final savedFile = await originalFile.copy(path.join(appDir.path, fileName));
      final videoUrl = 'file://${savedFile.path}';

      controller.document.insert(
        controller.selection.extentOffset,
        BlockEmbed.video(videoUrl),
      );
      controller.updateSelection(
        TextSelection.collapsed(
          offset: controller.selection.extentOffset + 1,
        ),
        ChangeSource.local,
      );
    } catch (e) {
      debugPrint('Error picking video: $e');
      // 오류 발생 시 사용자에게 알림을 표시할 수 있습니다.
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('비디오 선택 중 오류가 발생했습니다: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isPickingFile = false; // 파일 선택 완료 또는 오류 발생 후 플래그 해제
      });
    }
  }
} 