import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show debugPrint;
import 'package:http_parser/http_parser.dart';
import 'package:my_app/api/api_routes.dart' show DocAPI;
import 'package:my_app/model/diet/food_analysis_result.dart'
    show FoodAnalysisResult;

class DocApiService {
  final Dio dio;
  DocApiService(this.dio);

  /*
    식단 이미지 분석 API 호출 (POST /api/food/analyze)
    - 파일을 스트리밍 방식으로 전송하여 메모리 부족 문제를 방지합니다.
    - 호출 전 이미지 크기를 압축하여 사용하시길 강력히 권장합니다.
  */
  Future<FoodAnalysisResult?> analyzeImage(File imageFile) async {
    try {
      // 1. 파일 크기 확인 (스트림 전송에 필요)
      final fileLength = await imageFile.length();
      final fileName = imageFile.path.split('/').last;

      // 2. Dio가 전송할 FormData 생성 (File.openRead() 사용)
      // 파일을 메모리에 통째로 올리는 대신, 스트림으로 데이터를 읽어 전송합니다.
      final formData = FormData.fromMap({
        'image': MultipartFile.fromStream(
          () => imageFile.openRead(), // Stream을 전달
          fileLength, // 파일 크기를 명시
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      final response = await dio.post(
        DocAPI.geminiFoodAnalyze,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      // 서버 응답 본문(Map<String, dynamic>)을 FoodAnalysisResult 모델로 변환
      final result = FoodAnalysisResult.fromJson(response.data);
      return result;
    } on DioException catch (e) {
      // 네트워크 요청 실패 (타임아웃, 서버 에러 등)
      debugPrint('🚨 Dio 에러 발생 (analyzeImage): $e');
      // e.response.statusCode 등을 확인하여 서버 응답 상태 진단
      return null;
    } catch (e) {
      // I/O 에러나 다른 치명적인 오류 포착
      debugPrint('🚨 치명적인 일반 에러 발생 (analyzeImage): $e');
      return null;
    }
  }
}
