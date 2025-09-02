import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:my_app/util/spinner_utils.dart' show AppLoadingIndicator; // import 추가

class CustomImageEmbedBuilder implements quill.EmbedBuilder {
  @override
  String get key => 'image';

  @override
  Widget build(BuildContext context, quill.EmbedContext embedContext) {
    final String imageUrl = embedContext.node.value.data;

    // CachedNetworkImage를 사용하여 이미지 로딩 및 오류 처리
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => const Center(
        child: AppLoadingIndicator(), // 로딩 중 표시
      ),
      errorWidget: (context, url, error) {
        // SocketException 등 이미지 로딩 실패 시 호출
        debugPrint('--- Image loading failed using CachedNetworkImage ---');
        debugPrint('Image URL: $url');
        debugPrint('Error: $error');
        debugPrint('--------------------------------------------------');

        // 사용자에게 빈 박스와 에러 메시지 표시
        return Container(
          width: 150, // 원하는 너비
          height: 150, // 원하는 높이
          color: Colors.grey[200], // 배경색
          alignment: Alignment.center,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline, // 에러 아이콘
                color: Colors.red,
                size: 40,
              ),
              SizedBox(height: 8),
              Text(
                '이미지 로드 실패\n(네트워크 문제)', //TODO: 고정 이미지로 교체
                style: TextStyle(color: Colors.red, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
  
  @override
  WidgetSpan buildWidgetSpan(Widget widget) {
    return WidgetSpan(child: widget);
  }
  
  @override
  bool get expanded => false; // 이미지 삽입 시 확장 여부, false로 설정하여 기본 동작 유지

  @override
  String toPlainText(quill.Embed node) {
    return ' [Image: ${node.value.data}] ';
  }
}