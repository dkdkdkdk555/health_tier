import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:my_app/api/api_routes.dart' show DocAPI;
import 'package:my_app/model/diet/food_analysis_result.dart' show FoodAnalysisResult; 


class DocApiService {
  final Dio dio;
  DocApiService(this.dio);

  /*
    식단 이미지 분석 API 호출 (POST /api/food/analyze)
    이미지를 MultipartFile 형태로 전송하고 FoodAnalysisResult 객체를 반환합니다.
  */
  Future<FoodAnalysisResult> analyzeImage(File imageFile) async {
    // 1. Dio가 전송할 FormData 생성
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split('/').last, // 파일명 추출
        contentType: MediaType('image', 'jpeg'), // 서버에서 요구하는 MIME 타입 지정 (필요에 따라 변경)
      ),
    });

    final response = await dio.post(
      DocAPI.geminiFoodAnalyze, 
      data: formData, // FormData 전송
      options: Options(
        contentType: 'multipart/form-data', // 명시적으로 지정
      ),
    );

    // 서버 응답 본문(Map<String, dynamic>)을 FoodAnalysisResult 모델로 변환
    final result = FoodAnalysisResult.fromJson(response.data);
    return result;
  }
}