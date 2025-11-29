// 예시: 이미지 압축 및 임시 파일 저장 함수
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<File> compressImage(File file) async {
  // 앱의 임시 디렉토리를 얻습니다.
  final dir = await getTemporaryDirectory();
  final targetPath = "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

  // 이미지 압축 (품질을 80%로, 크기는 원본을 유지하되 파일 크기를 줄임)
  var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 75, // 파일 크기를 줄이는 핵심 설정
      minWidth: 1024, // 필요하다면 해상도도 줄일 수 있습니다.
      minHeight: 1024,
  );

  return result != null ? File(result.path) : file;
}