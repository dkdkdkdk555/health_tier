
import 'package:dio/dio.dart';
import 'package:my_app/api/api_routes.dart';
import 'package:my_app/model/cmu/common/result.dart';
import 'package:my_app/model/cmu/feed/like_and_crtifi_accept_request_dto.dart';
import 'package:my_app/model/cmu/feed/feed_cud_dto.dart';
import 'package:my_app/model/cmu/feed/feed_detail.dart';
import 'package:my_app/model/cmu/feed/report_request_dto.dart';

class FeedCudService {
  final Dio dio;
  FeedCudService(this.dio);

  // 게시글 생성 (POST)
  Future<int> createFeed(FeedDto dto) async {
    try {
      final response = await dio.post(
        FeedCudAPI.createFeed, // '/cud/cmu/feed/'
        data: dto.toJson(), // FeedDto를 JSON으로 변환하여 전송
      );

      // 백엔드 응답: ResponseEntity.ok(new Result<Long>(resultId, 1, "게시글이 등록되었습니다."));
      // Result.fromJson의 두 번째 인자는 data 필드를 파싱하는 함수입니다.
      // 서버에서 Long 타입을 넘겨주므로, Dart의 int로 받아야 합니다.
      final result = Result<int>.fromJson(
        response.data,
        (json) => (json as int), // `json['data']`가 `int`로 직접 들어옴
      );

      // result.count가 서버의 상태 코드 1(성공)을 나타낸다고 가정
      if (result.count == 1) {
        return result.data; // 새로 생성된 feedId 반환
      } else {
        throw Exception('게시글 생성 실패: ${result.message}');
      }
    } on DioException catch (e) {
      // DioError 처리 (네트워크 오류, 4xx/5xx 상태 코드 등)
      throw Exception('게시글 생성 Dio 에러: ${e.response?.statusCode ?? ''} - ${e.message}');
    } catch (e) {
      // 기타 에러 처리
      throw Exception('게시글 생성 중 알 수 없는 에러: $e');
    }
  }

  // 게시글 수정 (PUT)
  Future<int> updateFeed(int feedId, FeedDto dto) async {
    try {
      final response = await dio.put(
        FeedCudAPI.updateFeed, // '/cud/cmu/feed/'
        data: dto.toJson(), // FeedDto를 JSON으로 변환하여 전송
      );

      // 백엔드 응답: ResponseEntity.ok("수정 성공");
      if (response.statusCode == 200 && response.data == "수정 성공") {
        return feedId; // 성공 시 void 반환
      } else {
        throw Exception('게시글 수정 실패: ${response.data}');
      }
    } on DioException catch (e) {
      throw Exception('게시글 수정 Dio 에러: ${e.response?.statusCode ?? ''} - ${e.message}');
    } catch (e) {
      throw Exception('게시글 수정 중 알 수 없는 에러: $e');
    }
  }

  // 피드 상세 조회 - 수정하기 화면용
  Future<Result<FeedDetailDto>> getFeedDetail(int id) async{
    final response = await dio.get('${FeedCudAPI.getFeedWhenUpate}/$id');
    return Result.fromJson(
      response.data,
      (json) => FeedDetailDto.fromJson(json as Map<String, dynamic>),
    );
  }

  // 이미지 업로드 및 삭제
  Future<Result<List<String>>> uploadImages({
    required List<MultipartFile> images,
    List<String>? deleteUrls, // 삭제할 이미지 URL은 선택 사항
  }) async {
    final formData = FormData();

    // 1. 이미지 파일들을 FormData에 추가합니다.
    for (var image in images) {
      formData.files.add(MapEntry(
        'images', // Spring의 @RequestParam(value = "images")와 이름이 일치해야 합니다.
        image,
      ));
    }

    // 2. 삭제할 URL이 있다면 FormData에 추가합니다.
    if (deleteUrls != null && deleteUrls.isNotEmpty) {
      // Spring에서 List<String>을 @RequestParam으로 받기 위해 각 요소를 개별 필드로 추가합니다.
      // 동일한 키('deleteUrls')로 여러 값을 추가하면 Spring이 리스트로 인식합니다.
      for (var url in deleteUrls) {
        formData.fields.add(MapEntry('deleteUrls', url));
      }
    }

    try {
      final response = await dio.post(FeedCudAPI.uploadImages, data: formData);

      // 서버 응답을 Result<List<String>> 형태로 파싱하여 반환합니다.
      // Result.fromJson의 두 번째 인자는 `(json) => (json as List).map((e) => e.toString()).toList()`와 같이
      // JSON 리스트를 Dart List<String>으로 변환하는 함수입니다.
      return Result.fromJson(
        response.data,
        (json) => (json as List).map((e) => e.toString()).toList(),
      );
    } on DioException catch (e) {
      // Dio 에러 발생 시 예외를 다시 던져 상위 계층에서 처리하도록 합니다.
      throw Exception('이미지 업로드 실패: ${e.response?.data ?? e.message}');
    }
  }

  // 게시글 신고하기
  Future<String> reportFeed(ReportRequestDto dto) async {
    try {
      final response = await dio.post(
        FeedCudAPI.reportFeed,
        data: dto.toJson(),
      );
      return response.data.toString(); // "신고가 접수되었습니다."
    } on DioException catch (e) {
      // 서버에서 보낸 메시지를 파싱
      if (e.response?.statusCode == 409) {
        final message = e.response?.data['message'] ?? '이미 신고된 게시글입니다.';
        throw Exception(message);
      } else {
        throw Exception('신고 실패: ${e.response?.statusCode}');
      }
    } catch (e) {
      throw Exception('알 수 없는 오류: $e');
    }
  }

  // 게시글 인증하기
  Future<String> acceptCertification({
    required LikeAndCrtifiRequestDto dto,
  }) async {
    try {
      final response = await dio.post(
        FeedCudAPI.certificate,
        data: dto.toJson(),
      );

      if (response.statusCode == 200) {
        return response.data.toString(); // 예: "success"
      } else {
        throw Exception('인증 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? '인증 요청 실패';
      throw Exception(message);
    } catch (e) {
      throw Exception('알 수 없는 에러: $e');
    }
  }

  // 좋아요 요청
  Future<String> likeFeed(LikeAndCrtifiRequestDto dto) async {
    try {
      final response = await dio.post(
        FeedCudAPI.like, // 좋아요 API 엔드포인트
        data: dto.toJson(),
      );

      if (response.statusCode == 200) {
        return response.data.toString(); // 서버가 반환하는 "Like!" 메시지
      } else {
        throw Exception('좋아요 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? '좋아요 요청 실패';
      throw Exception(message);
    } catch (e) {
      throw Exception('알 수 없는 좋아요 에러: $e');
    }
  }

  // 좋아요 취소 요청
  Future<String> cancelFeedLike(LikeAndCrtifiRequestDto dto) async {
    try {
      final response = await dio.delete( // DELETE 메소드 사용
        FeedCudAPI.cancelLike, // 좋아요 취소 API 엔드포인트
        data: dto.toJson(), // 요청 바디에 DTO 전송 (DELETE 요청도 body를 가질 수 있습니다)
      );

      if (response.statusCode == 200) {
        return response.data.toString(); // 서버가 반환하는 "좋아요 취소 완료" 메시지
      } else {
        throw Exception('좋아요 취소 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? '좋아요 취소 요청 실패';
      throw Exception(message);
    } catch (e) {
      throw Exception('알 수 없는 좋아요 취소 에러: $e');
    }
  }
}
