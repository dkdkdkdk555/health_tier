import 'dart:convert';
import 'dart:io' as io;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mime/mime.dart';
import 'package:my_app/api/api_routes.dart';
import 'package:my_app/model/cmu/feed/feed_cud_dto.dart';
import 'package:my_app/model/cmu/feed/image_upload_args.dart';
import 'package:my_app/model/cmu/feed/user_weight_crtifi_dto.dart';
import 'package:my_app/providers/feed_cud_providers.dart';
import 'package:my_app/providers/feed_providers.dart' show feedDetailProvider, feedPaginationProvider, feedParamsProvider;
import 'package:my_app/service/feed_cud_api_service.dart';
import 'package:my_app/util/dialog_utils.dart';
import 'package:my_app/util/error_message_utils.dart';
import 'package:my_app/util/quill_video_player.dart';
import 'package:my_app/util/spinner_utils.dart' show AppLoadingIndicator;
import 'package:my_app/view/tab/cmu/feed/item/cmu_write_app_bar.dart';
import 'package:my_app/view/tab/cmu/feed/write/write_feed_category_select_bar.dart';
import 'package:my_app/view/tab/simple_cache.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:http_parser/http_parser.dart';


class WriteFeed extends ConsumerStatefulWidget {
  final int? feedId;
  const WriteFeed({
    super.key,
    this.feedId
  });

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
  int categoryId = 0;
  // 수정 모드일 때 데이터 로딩 완료 여부
  bool _isEditDataLoaded = false;
   // 수정 전 게시글에 있던 서버 이미지/비디오 URL 목록
  List<String> _initialServerMediaUrls = [];
  // WriteFeedCategorySelectBar에서 전달받을 운동 항목 데이터
  List<ExerciseEntry> _currentExerciseEntries = [];
  // 이미지,비디오 업로드 상태관리
  bool _isUploading = false;

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

     // 수정 모드일 경우 데이터 로드
    if (widget.feedId != null) {
      // ref.listen을 사용하여 데이터가 로드될 때 UI 업데이트
      ref.listenManual(feedDetailProviderForUpdate(widget.feedId!), (previous, next) {
        if (next.hasValue && next.value != null) {
          final feedDetail = next.value!.data;
          // 데이터 로드 완료 플래그 설정
          _isEditDataLoaded = true;
          // UI 업데이트
          _titleController.text = feedDetail.title;
          try {
            // ctnt는 JSON 문자열이므로 Delta로 변환
            final decodedContent = jsonDecode(feedDetail.ctnt);
            final loadedDelta = Delta.fromJson(decodedContent);
            _controller.document = Document.fromDelta(loadedDelta);

             // 중요: 기존 문서에서 서버 이미지/비디오 URL 추출하여 저장
            _initialServerMediaUrls = _extractServerMediaUrls(loadedDelta);
            debugPrint('Initial Server Media URLs: $_initialServerMediaUrls');
          } catch (e) {
            debugPrint('Error parsing Quill content JSON: $e');
            showAppMessage(context, message: 'Error parsing Quill content JSON: $e');
            // 파싱 실패 시 기본 문서로 초기화하거나 에러 처리
            _controller.document = Document.fromDelta(Delta()..insert('\n'));
          }
          setState(() {
            categoryId = feedDetail.categoryId;
          });
          debugPrint('수정할 피드 데이터 로드 완료: ${feedDetail.title}');
        } else if (next.hasError) {
          debugPrint('수정할 피드 데이터 로드 실패: ${next.error}');
          if (mounted) {
            showAppMessage(context, message: '게시글 정보를 불러오는데 실패했습니다');
          }
        }
      });
    }
  }

  // Quill Delta에서 서버 이미지/비디오 URL을 추출하는 헬퍼 함수
  List<String> _extractServerMediaUrls(Delta delta) {
    final List<String> urls = [];
    for (var op in delta.operations) {
      if (op.isInsert && op.data is Map) {
        final Map<String, dynamic> insertData = op.data as Map<String, dynamic>;
        String? url;
        if (insertData.containsKey('image')) {
          url = insertData['image'] as String;
        } else if (insertData.containsKey('video')) {
          url = insertData['video'] as String;
        }

        // 'file://'로 시작하지 않는 URL (즉, 서버 URL)만 추가
        if (url != null && (url.startsWith('http://') || url.startsWith('https://'))) {
          urls.add(url);
        }
      }
    }
    return urls;
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

  // 제목과 카테고리를 선택했는지피
  bool _isFeedContentValid() {
    // 1. categoryId가 0이 아닌지 확인
    if (categoryId == 0) {
      return false;
    }

    // 2. titleText가 비어있지 않은지 확인 (공백만 있는 경우도 비어있는 것으로 간주)
    if (_titleController.text.trim().isEmpty) {
      return false;
    }

    // 카테고리 3(중량인증)일 경우, 운동 항목 유효성 검사 추가
    if (categoryId == 3) {
      if (_currentExerciseEntries.isEmpty) {
        return false; // 항목이 없으면 유효하지 않음
      }
      for (var entry in _currentExerciseEntries) {
        if (entry.type == null || entry.weightController.text.trim().isEmpty) {
          return false; // 타입 또는 중량이 비어있으면 유효하지 않음
        }
        if (int.tryParse(entry.weightController.text.trim()) == null) {
          return false; // 중량이 유효한 숫자가 아니면 유효하지 않음
        }
      }
    }

    return true; // 모든 조건을 통과하면 유효함
  }


  void _updateToolbarVisibility() {
    setState(() {
      _showToolbar = _editorFocusNode.hasFocus; // 에디터에 포커스가 있으면 툴바 표시
    });
  }

  void _onCategoryChange({required int index}) {
    categoryId = index;
  }

  // ✅ WriteFeedCategorySelectBar에서 운동 항목이 변경될 때 호출될 콜백 함수
  void _onExerciseEntriesChanged(List<ExerciseEntry> entries) {
    _currentExerciseEntries = entries;
    // 여기서는 setState를 호출하지 않아도 됨.
    // _currentExerciseEntries는 _onSubmit에서 사용될 데이터이므로 UI 업데이트와 직접 연결되지 않음.
    // 만약 이 데이터 변경으로 인해 WriteFeed의 UI가 변경되어야 한다면 setState를 호출해야 함.
  }

  void _onSubmit(
    FeedCudService feedCudServiceInstance
  ) async {
    if (_isSubmitting) return; // 이미 업로드 중이면 중복 실행 방지

     // 유효성검증
    if (!_isFeedContentValid()) {
      if (!mounted) return;
      showAppMessage(context, message: '카테고리, 제목을 모두 입력해주세요.');
      
      return; // 유효성 검증 실패 시 함수 종료
    }

    setState(() {
      _isSubmitting = true; // 로딩 상태 시작
    });

    String ctntPreview = '';
    String imgPreview = '';
    List<UserWeightCrtifiDto>? userWeightsData;

    try {
      // 카테고리 3(중량인증)일 경우, _currentExerciseEntries에서 중량 데이터 가져오기
      if (categoryId == 3) {
        userWeightsData = _currentExerciseEntries.map((entry) {
          return UserWeightCrtifiDto(
            weightType: entry.type,
            weightKg: int.tryParse(entry.weightController.text),
          );
        }).toList();
      }

      // 1. Quill Delta에서 로컬 이미지/비디오 경로 추출
      final documentJson = _controller.document.toDelta().toJson();
      final Delta currentDelta = Delta.fromJson(documentJson);
      
      // 업로드할 파일 리스트와 원본 Delta의 해당 operation 인덱스 및 키를 저장
      final List<io.File> filesToUpload = [];
      final Map<String, int> localPathToIndexMap = {}; // localPath -> original op index
      final List<Map<String, dynamic>> operationsToUpdate = []; // {index: opIndex, type: 'image'/'video', localPath: 'file://...'}

      // 현재 에디터에 있는 서버 이미지/비디오 URL 목록 (수정 후)
      final List<String> currentServerMediaUrls = [];

      bool hasVideo = false;
      for (int i = 0; i < currentDelta.operations.length; i++) {
        final op = currentDelta.operations[i];
        if (op.isInsert && op.data is Map) {
          final Map<String, dynamic> insertData = op.data as Map<String, dynamic>;

          if (insertData.containsKey('image')) {
            final String imageUrl = insertData['image'];
            // 첫 번째 이미지의 URL을 imgPreview로 설정 (로컬이든 서버 URL이든 상관없음)
            if (imgPreview.isEmpty) { // 이미 설정되지 않았을 경우에만
              imgPreview = imageUrl;
            }

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
            } else if(imageUrl.startsWith('data:image/')) {
              // 🔥 base64 data:image 처리 추가
              final base64Data = imageUrl.split(',').last;
              final bytes = base64Decode(base64Data);

              final newFileName = 'paste-${DateTime.now().millisecondsSinceEpoch}.png';
              final newPath = path.join(io.Directory.systemTemp.path, newFileName);
              final file = await io.File(newPath).writeAsBytes(bytes, flush: true);

              filesToUpload.add(file);
              operationsToUpdate.add({
                'index': i,
                'type': 'image',
                'localPath': imageUrl, // base64 URI 그대로 key로 둠
              });
              localPathToIndexMap[imageUrl] = filesToUpload.length - 1;
            } else if(imageUrl.contains(APIServer.s3Url)) {
              // 기존 서버에 저장된 url추가
              currentServerMediaUrls.add(imageUrl);
            }
          } else if (insertData.containsKey('video')) {
            final String videoUrl = insertData['video'];
            hasVideo = true;
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
            } else if(videoUrl.contains(APIServer.baseUrl)) {
              // 기존 서버에 저장된 url추가
              currentServerMediaUrls.add(videoUrl);
            }
          } 
        } else if(op.isInsert && op.data is String) {
            final String text = op.data as String;
            // ctntPreview는 첫 번째 텍스트가 있는 insert operation에서 추출
            if (ctntPreview.isEmpty && text.trim().isNotEmpty && text != '\n') { // 이미 설정되지 않았고, 비어있지 않은 실제 텍스트인 경우
              ctntPreview = text;
              if (ctntPreview.length > 90) { // 90자 제한
                ctntPreview = ctntPreview.substring(0, 90);
              }
            }
        }
      }

      // 수정 모드이고, 기존 미디어 URL이 존재할 경우 삭제할 URL 식별
      List<String> deleteUrls = [];
      if (widget.feedId != null && _initialServerMediaUrls.isNotEmpty) {
        for (String initialUrl in _initialServerMediaUrls) {
          if (!currentServerMediaUrls.contains(initialUrl)) {
            // 기존 URL이 현재 문서에 없으면 삭제 목록에 추가
            deleteUrls.add(initialUrl);
          }
        }
        debugPrint('Identified URLs to delete: $deleteUrls');
      }

      // 2. 파일들을 MultipartFile로 변환
      final List<File> rawFiles = [];
      final List<Map<String, String>> fileMetaList = [];
      for (var file in filesToUpload) {
        final String filename = path.basename(file.path);
        // 파일 경로를 기반으로 MIME 타입 자동 추론
        final String? mimeType = lookupMimeType(file.path);
        // 서버 요청용 파일정보 리스트
        fileMetaList.add({
          'fileName': filename,
          'contentType': mimeType!,
        });

        rawFiles.add(File(file.path));
      }
      
      // 3. 서버에 업로드 (업로드할 파일이 있는 경우에만)
      List<String> uploadedUrls = [];
      if (fileMetaList.isNotEmpty || deleteUrls.isNotEmpty) {
        final presignedUrls = await ref.read(s3PresignedProvider((
          folder: 'uploads',
          files: fileMetaList,
          deleteUrls: deleteUrls,
        )).future); // FutureProvider 호출
        
        final s3Service = await ref.read(s3ApiServiceProvider.future);

        for (int i = 0; i < rawFiles.length; i++) {
          final presignedUrl = presignedUrls[i];
          final file = rawFiles[i];
          final mimeType = fileMetaList[i]['contentType'] ?? 'application/octet-stream';

          await s3Service.uploadFileToS3(
            presignedUrl: presignedUrl,
            file: file,
            contentType: mimeType,
          );

          // 업로드 후, 실제 S3 퍼블릭 접근 URL 추출
          final s3PublicUrl = presignedUrl.split('?').first;
          uploadedUrls.add(s3PublicUrl);
          debugPrint('✅ 업로드 완료 → $s3PublicUrl');
        }

        // 서버 업로드된 첫 번째 이미지 URL 넣어주기
        if ((imgPreview.startsWith('file://') || imgPreview.startsWith('data:image/')) && uploadedUrls.isNotEmpty) {
          imgPreview = uploadedUrls.first; // 첫 번째 업로드된 이미지 URL로 대체
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
      final String title = _titleController.text;
      final String content = jsonEncode(_controller.document.toDelta().toJson()); // 최종 Delta JSON

      if(categoryId == 2 || categoryId ==3) {
        if(rawFiles.isEmpty) {
          if(!mounted)return;
          showAppDialog(context, message: '인증피드는 사진이나 영상이 필수입니다.', confirmText: '확인');
          return;
        }
      }
      
      final FeedDto feedDto = FeedDto(
        id: widget.feedId,
        categoryId: categoryId,
        title: title,
        ctnt: content,
        ctntPreview: ctntPreview.replaceAll(RegExp(r'[\r\n]+'), ' ').trim(),
        imgPreview: imgPreview,
        userWeights: userWeightsData,
        videoExist: hasVideo ? 'Y' : 'N',
      );

      int resultFeedId;

      if (widget.feedId != null) {
        // 수정 모드: updateFeed 호출
        resultFeedId = await feedCudServiceInstance.updateFeed(widget.feedId!, feedDto);
      } else {
        // 생성 모드: createFeed 호출
        resultFeedId = await feedCudServiceInstance.createFeed(feedDto);
      }

      // 성공 메시지 표시 및 화면 이동 등
      if (!mounted) return;
      showAppMessage(context, message: '피드가 성공적으로 ${widget.feedId != null ? '수정' : '등록'}되었습니다.');
      context.go('/cmu/feed/$resultFeedId?categoryId=$categoryId&isFromWriteFeed=true');
      ref.invalidate(feedDetailProvider);
      ref.invalidate(feedPaginationProvider);
      ref.invalidate(feedParamsProvider);
    } catch (e) {
      debugPrint('게시글 등록 중 오류 발생: $e');

      final errorMsg = e.toString();
      if (errorMsg.contains('422')){
        debugPrint('차단됨');
        return; // interceptor에서 이미 처리된 것으로 간주
      }
      if (!mounted) return;
      showAppMessage(context, message: '피드 등록 중 오류가 발생했습니다.', type: AppMessageType.dialog);
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
     for (var entry in _currentExerciseEntries) {
      entry.dispose();
    }
    _currentExerciseEntries.clear();
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

    // 수정 모드일 때만 데이터를 watch하고, 로딩 상태를 보여줍니다.
    final feedDetailAsyncValue = widget.feedId != null
        ? ref.watch(feedDetailProviderForUpdate(widget.feedId!))
        : null;

    // 수정 모드이고 데이터가 아직 로드되지 않았다면 로딩 인디케이터를 보여줍니다.
    if (widget.feedId != null && (feedDetailAsyncValue == null || feedDetailAsyncValue.isLoading || !_isEditDataLoaded)) {
      return const Scaffold(
        body: Center(child: AppLoadingIndicator()),
      );
    }

    
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
           FocusScope.of(context).unfocus(); // 여백 클릭시 키보드 들어가게
        },
        child: Stack(
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
                        WriteFeedCategorySelectBar(onCategoryChange: _onCategoryChange, selectedCategoryId: categoryId, onExerciseEntriesChanged: _onExerciseEntriesChanged,),
                        // 제목 입력 섹션
                        GestureDetector(
                          onTap: (){
                            
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
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(100), // 최대 100자
                            ],
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
                          
                                        if (exists) return FileImage(file);
                                      } else if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
                                        // 네트워크 이미지 (GIF 포함) 처리
                                        return NetworkImage(imageUrl);
                                      }
                                      return null;
                                    },  
                                    onImageClicked:(imageSource) {
                                      // 여기에 이미지 클릭했을때 나오는 메뉴들을 커스텀할 수 있다.
                                    },                          
                                  ),
                                  videoEmbedConfig: QuillEditorVideoEmbedConfig(
                                    customVideoBuilder: (videoUrl, readOnly) {
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
                        if (_showToolbar)
                        SizedBox(height: 50.0 + keyboardHeight),
                        // 제목 입력 시에도 키보드 높이만큼 패딩
                        if (!_showToolbar && keyboardHeight > 0)
                        SizedBox(height: keyboardHeight),
                      ],
                    )
                  ),
                ),
              ],
            ),
            if(_isUploading)
            Positioned.fill(
              child: Container(
                // 배경을 흐릿하게 만들기 위한 반투명 컨테이너
                color: Colors.black.withValues(alpha: 0.4),
                child: const Center(
                  child: AppLoadingIndicator(),
                ),
              ),
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
                            icon: const Icon(Icons.photo_library),
                            tooltip: '갤러리에서 이미지 가져오기',
                            onPressed: () => _handleFilePick(context, _controller, 'image'),
                          ),
                          QuillToolbarCustomButtonOptions(
                            icon: const Icon(Icons.videocam),
                            tooltip: '갤러리에서 비디오 가져오기',
                            onPressed: () => _handleFilePick(context, _controller, 'video'),
                          ),
                          QuillToolbarCustomButtonOptions(
                            icon: const Icon(Icons.keyboard_hide_outlined),
                            tooltip: 'Hide Keyboard',
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                            },
                          ),
                        ],
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
                        // embedButtons: FlutterQuillEmbeds.toolbarButtons(
                        //   imageButtonOptions: QuillToolbarImageButtonOptions(
                        //     imageButtonConfig: QuillToolbarImageConfig(
                        //       onImageInsertCallback: (image, controller) async {
                        //         final originalFile = io.File(image);
                        //         if (!await originalFile.exists()) return;
        
                        //         final appDir = await getApplicationDocumentsDirectory();
                        //         final fileName = 'img-${DateTime.now().millisecondsSinceEpoch}.png';
                        //         final savedFile = await originalFile.copy(path.join(appDir.path, fileName));
                        //         final imageUrl = 'file://${savedFile.path}';
        
                        //         controller.document.insert(
                        //           controller.selection.extentOffset,
                        //           BlockEmbed.image(imageUrl),
                        //         );
                        //         controller.updateSelection(
                        //           TextSelection.collapsed(
                        //             offset: controller.selection.extentOffset + 1,
                        //           ),
                        //           ChangeSource.local,
                        //         );
                        //       },
                        //     ),
                        //   ),
                        //   videoButtonOptions: QuillToolbarVideoButtonOptions(
                        //     videoConfig: QuillToolbarVideoConfig(
                        //        // onVideoInsertCallback을 커스터마이징합니다.
                        //       onVideoInsertCallback: (videoPathFromPicker, controller) => _handleVideoInsert(videoPathFromPicker, controller),
                        //     )
                        //   )
                        // ),
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
      ),
    );
  }

// _handleFilePick 함수 수정
Future<void> _handleFilePick(BuildContext context, QuillController controller, String type, {XFile? file}) async {
  
  try {
    setState(() {
      _isUploading = true;
    });
    String? filePath;
    if (file != null) {
      filePath = file.path;
    } else {
      // file_picker 사용
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type == 'image' ? FileType.image : FileType.video,
        allowMultiple: false, //한번에 하나의 파일만 선택하도록
      );
      if (result != null && result.files.single.path != null) {
        filePath = result.files.single.path!;
      }
    }
    
    if (filePath != null && filePath.isNotEmpty) {
      // 파일 경로를 앱 문서 디렉토리에 복사
      var originalFile = io.File(filePath);

      // heic → jpg 변환
      if (filePath.toLowerCase().endsWith(".heic")) {
        final converted = await convertHeicToJpg(originalFile);
        if (converted != null) {
          originalFile = converted;
        }
      }

      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '$type-${DateTime.now().millisecondsSinceEpoch}${path.extension(originalFile.path)}';
      final savedFile = await originalFile.copy(path.join(appDir.path, fileName));
      final fileUrl = 'file://${savedFile.path}';

      // 삽입된 텍스트에 링크 속성 적용
      controller.document.insert(
        controller.selection.extentOffset,
        type == 'image' ? BlockEmbed.image(fileUrl) : BlockEmbed.video(fileUrl),
      );
      // 커서를 링크 끝으로 이동
      controller.updateSelection(
        TextSelection.collapsed(
          offset: controller.selection.extentOffset + 1,
        ),
        ChangeSource.local,
      );
      
      debugPrint('[$type] inserted into Quill editor successfully.');
    }
  } catch (e) {
    debugPrint('Error picking or inserting file: $e');
    if (context.mounted) {
      if(e.toString().contains('public.')) {
        if(osType == 'ios') {
          showAppMessage(context, message: 'icloud 파일은 바로 업로드할 수 없습니다.\n기기에 다운로드 후 다시 시도해주세요.', type: AppMessageType.dialog);
        } else {
          showAppMessage(context, message: '클라우드에 있는 사진은 바로 업로드할 수 없습니다.\n기기에 다운로드 후 다시 시도해주세요.', type: AppMessageType.dialog);
        }
      } else {
        showAppMessage(context, message: '파일 처리 및 삽입 중 오류가 발생했습니다', type: AppMessageType.dialog);
      }
    }
  }finally{
    setState(() {
      _isUploading = false;
    });
  }
}

Future<File?> convertHeicToJpg(File file) async {
  final targetPath = file.path.replaceAll(".heic", ".jpg");

  final result = await FlutterImageCompress.compressAndGetFile(
    file.path,
    targetPath,
    format: CompressFormat.jpeg,
    quality: 95,
  );

  if (result == null) return null;
  return File(result.path); // XFile → File 변환
}

// 비디오 선택시 -> image_picker 사용 코드
// Future<void> _handleVideoInsert(String videoPathFromPicker, QuillController controller) async {
//   debugPrint('[_handleVideoInsert] Function called with path: $videoPathFromPicker');

//   // _isPickingFile 플래그는 ImagePicker 호출 시점을 제어하는 용도로 사용되었으나,
//   // 이제 ImagePicker 호출은 FlutterQuillEmbeds.toolbarButtons()의 내부 로직이 담당하므로,
//   // 이 함수 내에서는 _isPickingFile 관련 setState 로직은 필요 없습니다.
//   // 다만, 중복 삽입 방지나 UI 상태 관리를 위해 여전히 유용할 수 있습니다.
//   // 이 함수 호출 시점에는 이미 파일이 선택되어 Path가 넘어왔다고 가정합니다.

//   if (videoPathFromPicker.isEmpty) {
//     debugPrint('[_handleVideoInsert] Video path from picker is empty. Skipping insertion.');
//     return;
//   }

//   try {
//     final originalFile = io.File(videoPathFromPicker);
//     if (!await originalFile.exists()) {
//       debugPrint('[_handleVideoInsert] Original video file does not exist at path: $videoPathFromPicker');
//       // 사용자가 갤러리에서 선택했지만, 파일이 존재하지 않는 극히 드문 경우를 대비
//       if (!mounted) return;
//       showAppMessage(context, message: '선택된 비디오 파일을 찾을 수 없습니다.', type: AppMessageType.dialog);
//       return;
//     }

//     final appDir = await getApplicationDocumentsDirectory();
//     final fileName = 'vid-${DateTime.now().millisecondsSinceEpoch}.mp4';
//     final savedFile = await originalFile.copy(path.join(appDir.path, fileName));
//     final videoUrl = 'file://${savedFile.path}';
//     debugPrint('[_handleVideoInsert] Saved video URL: $videoUrl');

//     controller.document.insert(
//       controller.selection.extentOffset,
//       BlockEmbed.video(videoUrl),
//     );
//     controller.updateSelection(
//       TextSelection.collapsed(
//         offset: controller.selection.extentOffset + 1,
//       ),
//       ChangeSource.local,
//     );
//     debugPrint('[_handleVideoInsert] Video inserted into Quill editor successfully.');
//   } catch (e) {
//     debugPrint('[_handleVideoInsert] !!! Error processing/inserting video: $e');
//     if (!mounted) return;
//     showAppMessage(context, message: '비디오 처리 및 삽입 중 오류가 발생했습니다', type: AppMessageType.dialog);
//   } finally {
    
//   }
// }

} 