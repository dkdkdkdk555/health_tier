import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:http/http.dart' as http;
import 'dart:io' as io show Directory, File;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class RichTextEditorPage extends StatefulWidget {
  const RichTextEditorPage({super.key});

  @override
  State<RichTextEditorPage> createState() => _RichTextEditorPageState();
}

class _RichTextEditorPageState extends State<RichTextEditorPage> {
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

                  debugPrint('들옴?');
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
  void initState() {
    super.initState();
    // Load document
    // _controller.document = Document.fromJson(kQuillDefaultSample);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Quill Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.output),
            tooltip: 'Print Delta JSON to log',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content:
                      Text('The JSON Delta has been printed to the console.')));
              debugPrint(jsonEncode(_controller.document.toDelta().toJson()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new_outlined),
            onPressed: () async {

              debugPrint(jsonEncode(_controller.document.toDelta().toJson()));
              return;
              final delta = _controller.document.toDelta();

              // 1. file:// 이미지 경로 수집
              final fileImagePaths = <String>[];
              for (final op in delta.toList()) {
                if (op.isInsert && op.data is Map) {
                  final dataMap = op.data as Map;
                  final imageUrl = dataMap['image'];
                  if (imageUrl is String && imageUrl.startsWith('file://')) {
                    fileImagePaths.add(Uri.parse(imageUrl).toFilePath());
                  }
                }
              }

              // 2. 이미지 서버 업로드 (multipart/form-data)
              final uri = Uri.parse('http://192.168.0.26:8080/cud/cmu/feed/images/upload-multiple');
              final request = http.MultipartRequest('POST', uri);

              for (final filePath in fileImagePaths) {
                final file = io.File(filePath);
                final fileName = path.basename(filePath);
                final bytes = await file.readAsBytes();
                request.files.add(http.MultipartFile.fromBytes(
                  'images',
                  bytes,
                  filename: fileName,
                ));
              }

              final streamedResponse = await request.send();
              final response = await http.Response.fromStream(streamedResponse);

              if (response.statusCode != 200) {
                // ignore: use_build_context_synchronously
                debugPrint(response.statusCode.toString());
                debugPrint(response.body);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('이미지 업로드 실패')),
                );
                return;
              }

              final uploadedUrls = List<String>.from(jsonDecode(response.body));

              // 3. Delta 내 file:// 경로를 업로드된 URL로 치환
              int imageIndex = 0;
              final newDelta = Delta();

              for (final op in delta.toList()) {
                if (op.isInsert && op.data is Map) {
                  final map = op.data as Map;
                  final imageUrl = map['image'];
                  if (imageUrl is String && imageUrl.startsWith('file://')) {
                    newDelta.insert({'image': uploadedUrls[imageIndex++]}, op.attributes);
                  } else {
                    newDelta.insert(op.data, op.attributes);
                  }
                } else {
                  newDelta.insert(op.data, op.attributes);
                }
              }

              // 4. ctnt를 json string으로 변환
              final contentJson = jsonEncode(newDelta.toJson());

              // 5. 게시글 등록 요청
              final feedPostResponse = await http.post(
                Uri.parse('http://192.168.0.26:8080/cud/cmu/feed'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'title': '임시 제목',
                  'categoryId': 2,
                  'userId': 1,
                  'ctnt': contentJson,
                }),
              );

              if (feedPostResponse.statusCode == 200) {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('게시글이 성공적으로 등록되었습니다.')),
                );
              } else {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('게시글 등록 실패')),
                );
              }
            },
          )
        ],
      ),
      body: SafeArea(
          child: Column(
        children: [
          QuillSimpleToolbar(
            controller: _controller,
            config: QuillSimpleToolbarConfig(
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
                showClipboardPaste: true,
                customButtons: [
                  QuillToolbarCustomButtonOptions(
                      icon: const Icon(Icons.add_alarm_rounded),
                      onPressed: () {
                        _controller.document.insert(
                          _controller.selection.extentOffset,
                          TimeStampEmbed(
                            DateTime.now().toString(),
                          ),
                        );

                        _controller.updateSelection(
                            TextSelection.collapsed(
                              offset: _controller.selection.extentOffset + 1,
                            ),
                            ChangeSource.local);
                      })
                ],
                buttonOptions: QuillSimpleToolbarButtonOptions(
                    linkStyle: QuillToolbarLinkStyleButtonOptions(
                  validateLink: (link) {
                    final uri = Uri.tryParse(link);
                    return uri != null && (uri.hasScheme && (uri.isAbsolute));
                  },
                ))),
          ),
          Expanded(
            child: QuillEditor(
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
                          debugPrint('여기? $imageUrl');
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
                    TimeStampEmbedBuilder(),
                  ]
                ),
            ),
          )
        ],
      )),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _editorScrollController.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }
}

/*
  리치텍스트 에디터 커스텀 요소
 */
class TimeStampEmbed extends Embeddable {
  const TimeStampEmbed(
    String value,
  ) : super(timeStampType, value);

  static const String timeStampType = 'timeStamp';

  static TimeStampEmbed fromDocument(Document document) =>
      TimeStampEmbed(jsonEncode(document.toDelta().toJson()));

  Document get document => Document.fromJson(jsonDecode(data));
}

class TimeStampEmbedBuilder extends EmbedBuilder {
  @override
  String get key => 'timeStamp';

  @override
  String toPlainText(Embed node) {
    return node.value.data;
  }

  @override
  Widget build(
    BuildContext context,
    EmbedContext embedContext,
  ) {
    return Row(
      children: [
        const Icon(Icons.access_time_rounded),
        Text(embedContext.node.value.data as String),
      ],
    );
  }
}
