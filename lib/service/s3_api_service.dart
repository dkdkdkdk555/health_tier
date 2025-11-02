import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:my_app/api/api_routes.dart';

class S3ApiService {
  final Dio dio;
  S3ApiService(this.dio);

  /// presigned URL 요청 (업로드 or 삭제)
  /// - [folder]: 업로드 폴더 (예: 'uploads/profile')
  /// - [files]: 업로드할 파일정보들
  /// - [deleteUrls]: 삭제할 기존 파일 URL 목록 (있을 경우 삭제 먼저 수행)
  Future<List<String>> getPresignedUrls({
    required String folder,
    required List<Map<String, String>> files, // [{fileName, contentType}, ...]
    List<String>? deleteUrls,
  }) async {
    final response = await dio.post(
      AuthAPI.getS3PresignedUrl,
      data: {
        'folder': folder,
        'files': files,
        if (deleteUrls != null && deleteUrls.isNotEmpty) 'deleteUrls': deleteUrls,
      },
      options: Options(contentType: Headers.jsonContentType),
    );

    if (response.statusCode == 200) {
      return List<String>.from(response.data);
    } else {
      throw Exception('Presigned URL 요청 실패: ${response.statusCode}');
    }
  }


  /// 실제 파일을 presigned URL로 S3에 업로드
  /// - [presignedUrl]: 서버에서 발급받은 URL
  /// - [file]: 업로드할 File 객체
  /// - [contentType]: MIME 타입
  Future<void> uploadFileToS3({
    required String presignedUrl,
    required File file,
    required String contentType,
  }) async {
    try {
      final bytes = await file.readAsBytes();

      // presigned URL은 절대 인코딩하지 않는다
      final uri = Uri.parse(presignedUrl);

      // 반드시 auth 없는 Dio 사용
      final dio = Dio(BaseOptions(
        headers: {
          'Content-Type': contentType,
        },
        followRedirects: false,
        validateStatus: (status) => status != null && status < 500,
      ));

      final response = await dio.putUri(
        uri,
        data: bytes, // 🔹 그대로 전송 (Stream X)
      );

      if (response.statusCode == 200) {
        debugPrint('✅ S3 업로드 성공: ${file.path}');
      } else {
        debugPrint('⚠️ S3 업로드 실패 (status: ${response.statusCode}) → ${response.data}');
      }
    } on DioException catch (e) {
      debugPrint('❌ 업로드 중 Dio 오류: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ 업로드 중 오류: $e');
      rethrow;
    }
  }
}
