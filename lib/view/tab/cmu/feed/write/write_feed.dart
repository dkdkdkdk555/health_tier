import 'dart:convert';
import 'dart:io' as io;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/model/cmu/feed/feed_cud_dto.dart';
import 'package:my_app/model/cmu/feed/image_upload_args.dart';
import 'package:my_app/providers/feed_auth_providers.dart';
import 'package:my_app/service/feed_cud_api_service.dart';
import 'package:my_app/util/quill_video_player.dart';
import 'package:my_app/view/tab/cmu/feed/item/cmu_write_app_bar.dart';
import 'package:my_app/view/tab/cmu/feed/write/write_feed_category_select_bar.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';


class WriteFeed extends ConsumerStatefulWidget {
  const WriteFeed({super.key});

  @override
  ConsumerState<WriteFeed> createState() => _WriteFeedState();
}

class _WriteFeedState extends ConsumerState<WriteFeed> {
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

  // 피드저장 로딩상태 관리
  bool _isSubmitting = false;


  @override
  void initState() {
    super.initState();

    _controller = QuillController.basic(
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
             return 'file://${file.path}'; 
          },
          onClipboardPaste: () async {
            final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
            final text = clipboardData?.text;
            if (text != null) {
              final youtubeVideoId = YoutubePlayer.convertUrlToId(text);
              if (youtubeVideoId != null) {
                final int index = _controller.selection.extentOffset;
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
              } else if (text.toLowerCase().contains('.gif') && (text.startsWith('http://') || text.startsWith('https://') || text.startsWith('file://'))) {
                // 클립보드 텍스트가 .gif를 포함하고, URL 또는 파일 경로 형식인 경우
                final int index = _controller.selection.extentOffset;
                _controller.document.insert(
                  index,
                  BlockEmbed.image(text), // GIF URL/경로를 이미지로 삽입
                );
                _controller.updateSelection(
                  TextSelection.collapsed(offset: index + 1),
                  ChangeSource.local,
                );
                debugPrint('GIF image embedded via onClipboardPaste: $text');
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
        _currentEditorHeight = newHeight;
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

  void _onSubmit(
    FeedCudService feedCudServiceInstance
  ) async {
    if (_isSubmitting) return; // 이미 업로드 중이면 중복 실행 방지

    setState(() {
      _isSubmitting = true; // 로딩 상태 시작
    });

    try {
      // 1. Quill Delta에서 로컬 이미지/비디오 경로 추출
      final documentJson = _controller.document.toDelta().toJson();
      final Delta currentDelta = Delta.fromJson(documentJson);
      
      // 업로드할 파일 리스트와 원본 Delta의 해당 operation 인덱스 및 키를 저장
      final List<io.File> filesToUpload = [];
      final Map<String, int> localPathToIndexMap = {}; // localPath -> original op index
      final List<Map<String, dynamic>> operationsToUpdate = []; // {index: opIndex, type: 'image'/'video', localPath: 'file://...'}

      for (int i = 0; i < currentDelta.operations.length; i++) {
        final op = currentDelta.operations[i];
        if (op.isInsert && op.data is Map) {
          final Map<String, dynamic> insertData = op.data as Map<String, dynamic>;

          if (insertData.containsKey('image')) {
            final String imageUrl = insertData['image'];
            if (imageUrl.startsWith('file://')) {
              final String filePath = Uri.parse(imageUrl).toFilePath();
              final file = io.File(filePath);
              if (await file.exists()) {
                filesToUpload.add(file);
                operationsToUpdate.add({
                  'index': i,
                  'type': 'image',
                  'localPath': imageUrl,
                });
                localPathToIndexMap[imageUrl] = filesToUpload.length - 1; // filesToUpload 리스트에서의 인덱스
              } else {
                debugPrint('Warning: Local image file not found: $filePath');
              }
            }
          } else if (insertData.containsKey('video')) {
            final String videoUrl = insertData['video'];
            // YouTube URL은 서버에 업로드할 필요가 없으므로 건너뜁니다.
            if (videoUrl.startsWith('file://')) {
              final String filePath = Uri.parse(videoUrl).toFilePath();
              final file = io.File(filePath);
              if (await file.exists()) {
                filesToUpload.add(file);
                operationsToUpdate.add({
                  'index': i,
                  'type': 'video',
                  'localPath': videoUrl,
                });
                localPathToIndexMap[videoUrl] = filesToUpload.length - 1; // filesToUpload 리스트에서의 인덱스
              } else {
                debugPrint('Warning: Local video file not found: $filePath');
              }
            }
          }
        }
      }

      // 2. 파일들을 MultipartFile로 변환
      final List<MultipartFile> multipartFiles = [];
      for (var file in filesToUpload) {
        multipartFiles.add(
          await MultipartFile.fromFile(
            file.path,
            filename: path.basename(file.path),
          ),
        );
      }

      // 3. 서버에 업로드 (업로드할 파일이 있는 경우에만)
      List<String> uploadedUrls = [];
      if (multipartFiles.isNotEmpty) {
        final uploadArgs = ImageUploadArgs(images: multipartFiles);
        final uploadResult = await ref.read(imageUploadProvider(uploadArgs).future); // FutureProvider 호출
        
        if (uploadResult.count == 1) {
          uploadedUrls = uploadResult.data;
          debugPrint('Uploaded URLs: $uploadedUrls');
        } else {
          throw Exception('이미지/비디오 업로드 실패: ${uploadResult.message}');
        }
      }

      // 4. Quill Delta 업데이트: file:// 경로를 서버 경로로 치환
      if (uploadedUrls.isNotEmpty) {
        final Delta newDelta = Delta.fromJson(documentJson); // 원본 Delta를 복사하여 수정
        
        // uploadedUrls 리스트의 순서와 filesToUpload 리스트의 순서가 일치한다고 가정합니다.
        // 즉, filesToUpload[0]이 업로드되어 uploadedUrls[0]이 되었다고 가정합니다.
        // 따라서 localPathToIndexMap을 사용하여 매핑합니다.

        for (var opToUpdate in operationsToUpdate) {
          final int originalOpIndex = opToUpdate['index'] as int;
          final String localPath = opToUpdate['localPath'] as String;
          final String type = opToUpdate['type'] as String;

          final int fileIndex = localPathToIndexMap[localPath]!;
          final String serverUrl = uploadedUrls[fileIndex];

          // 해당 operation을 찾아 내용을 업데이트
          final Map<String, dynamic> originalInsertData = newDelta.operations[originalOpIndex].data as Map<String, dynamic>;
          
          if (type == 'image') {
            originalInsertData['image'] = serverUrl;
          } else if (type == 'video') {
            originalInsertData['video'] = serverUrl;
          }
          // 실제 Delta 객체는 불변(immutable)이므로, 새로운 Delta를 생성하거나
          // replace 메서드를 사용하여 변경된 부분을 적용해야 합니다.
          // 여기서는 `newDelta`를 직접 수정하는 방식은 `Delta`의 내부 구현에 따라
          // 예상치 못한 동작을 할 수 있습니다.
          // 더 안전한 방법은 `_controller.document.replace`를 사용하는 것입니다.
          // 하지만 현재 `newDelta.operations[originalOpIndex].data`를 직접 수정하는 방식은
          // `Delta`가 내부적으로 `List<Operation>`을 참조하기 때문에 동작할 수 있습니다.
          // 좀 더 명확하고 안전한 방법은 `Delta.forEach`를 사용하여 새로운 Delta를 빌드하는 것입니다.
          
          // 간단한 구현을 위해 현재 Delta를 복사하고, 해당 operation의 data를 직접 수정하는 방식으로 진행합니다.
          // 실제 프로덕션 코드에서는 Quill 라이브러리의 Delta 조작 API를 더 깊이 이해하고 사용하는 것이 좋습니다.
        }
        
        // 수정된 Delta로 Quill 에디터 업데이트
        _controller.document = Document.fromDelta(newDelta);
        debugPrint('Quill document updated with server URLs. : \n${_controller.document}');
      }

      // 5. 최종 FeedDto 구성 및 게시글 생성 요청
      // final String title = _titleController.text;
      // final String content = jsonEncode(_controller.document.toDelta().toJson()); // 최종 Delta JSON
      
      // final FeedDto feedDto = FeedDto(
      //   title: title,
      //   ctnt: content,
      //   // categoryId 등 필요한 다른 필드 추가
      // );

      // // 게시글 생성 서비스 호출
      // final int newFeedId = await feedCudServiceInstance.createFeed(feedDto);
      // debugPrint('게시글 생성 성공! Feed ID: $newFeedId');

      // // 성공 메시지 표시 및 화면 이동 등
      // if (!mounted) return;
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('게시글이 성공적으로 등록되었습니다.')),
      // );
      // Navigator.pop(context); // 이전 화면으로 돌아가기 등
      
    } catch (e) {
      debugPrint('게시글 등록 중 오류 발생: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시글 등록 실패: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isSubmitting = false; // 로딩 상태 종료
      });
    }
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
     // build 메서드 내에서 ref.watch로 서비스 인스턴스를 가져옵니다.
    final feedCudServiceAsyncValue = ref.watch(feedCudServiceProvider); // <-- FutureProvider를 watch

    // 서비스 인스턴스가 로딩 중이거나 에러 상태인지 확인합니다.
    final bool isServiceLoadingOrError = feedCudServiceAsyncValue.isLoading || feedCudServiceAsyncValue.hasError;
    final bool canSubmit = !_isSubmitting && !isServiceLoadingOrError;

    final FeedCudService? feedCudService = feedCudServiceAsyncValue.valueOrNull;
    
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
                child: CmuWriteAppBar(
                  centerText: '피드 작성하기', 
                  onSubmit: canSubmit ? () => _onSubmit(feedCudService!) : () {debugPrint('아직로드안됐다..');},
                )
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      // 카테고리 선택 바
                      WriteFeedCategorySelectBar(onCategoryChange: _onCategoryChange, selectedCategoryId: 0,),
                      // 제목 입력 섹션
                      GestureDetector(
                        onTap: (){
                          debugPrint(jsonEncode(_controller.document.toDelta().toJson()));
                        },
                        child: const Padding(
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
                                    if (imageUrl.startsWith('file://')) {
                                      final path = Uri.parse(imageUrl).toFilePath();
                                      final file = io.File(path);
                        
                                      final exists = file.existsSync();
                                      debugPrint('File at $path exists: $exists');
                        
                                      if (exists) return FileImage(file);
                                    } else if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
                                      // 네트워크 이미지 (GIF 포함) 처리
                                      debugPrint('Network image detected: $imageUrl');
                                      return NetworkImage(imageUrl);
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

                                    return QuillVideoPlayer(videoUrl: videoUrl,);
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
                width: MediaQuery.of(context).size.width,
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
                            onVideoInsertCallback: (videoPathFromPicker, controller) => _handleVideoInsert(videoPathFromPicker, controller),
                          )
                        )
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

// 비디오 선택시
Future<void> _handleVideoInsert(String videoPathFromPicker, QuillController controller) async {
  debugPrint('[_handleVideoInsert] Function called with path: $videoPathFromPicker');

  // _isPickingFile 플래그는 ImagePicker 호출 시점을 제어하는 용도로 사용되었으나,
  // 이제 ImagePicker 호출은 FlutterQuillEmbeds.toolbarButtons()의 내부 로직이 담당하므로,
  // 이 함수 내에서는 _isPickingFile 관련 setState 로직은 필요 없습니다.
  // 다만, 중복 삽입 방지나 UI 상태 관리를 위해 여전히 유용할 수 있습니다.
  // 이 함수 호출 시점에는 이미 파일이 선택되어 Path가 넘어왔다고 가정합니다.

  if (videoPathFromPicker.isEmpty) {
    debugPrint('[_handleVideoInsert] Video path from picker is empty. Skipping insertion.');
    return;
  }

  try {
    final originalFile = io.File(videoPathFromPicker);
    if (!await originalFile.exists()) {
      debugPrint('[_handleVideoInsert] Original video file does not exist at path: $videoPathFromPicker');
      // 사용자가 갤러리에서 선택했지만, 파일이 존재하지 않는 극히 드문 경우를 대비
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('선택된 비디오 파일을 찾을 수 없습니다.')),
      );
      return;
    }

    final appDir = await getApplicationDocumentsDirectory();
    final fileName = 'vid-${DateTime.now().millisecondsSinceEpoch}.mp4';
    final savedFile = await originalFile.copy(path.join(appDir.path, fileName));
    final videoUrl = 'file://${savedFile.path}';
    debugPrint('[_handleVideoInsert] Saved video URL: $videoUrl');

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
    debugPrint('[_handleVideoInsert] Video inserted into Quill editor successfully.');
  } catch (e) {
    debugPrint('[_handleVideoInsert] !!! Error processing/inserting video: $e');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('비디오 처리 및 삽입 중 오류가 발생했습니다: ${e.toString()}')),
    );
  } finally {
    
  }
}

} 