import 'package:dio/dio.dart';
import 'package:my_app/api/api_routes.dart';
import 'package:my_app/model/cmu/reply/reply_like_request_dto.dart';

class ReplyCudService {
  final Dio dio;
  ReplyCudService(this.dio);

  // 댓글 좋아요 요청
  Future<String> likeReply(ReplyLikeRequestDto dto) async {
    try {
      final response = await dio.post(
        ReplyCudAPI.likeReply, // 좋아요 API 엔드포인트
        data: dto.toJson(),
      );

      if (response.statusCode == 200) {
        return response.data.toString(); // 서버가 반환하는 "Like!" 메시지
      } else {
        throw Exception('댓글좋아요 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? '댓글좋아요 요청 실패';
      throw Exception(message);
    } catch (e) {
      throw Exception('알 수 없는 댓글좋아요 에러: $e');
    }
  }

  // 댓글 좋아요 취소 요청
  Future<String> cancelReplyLike(ReplyLikeRequestDto dto) async {
    try {
      final response = await dio.delete( // DELETE 메소드 사용
        ReplyCudAPI.cancelLikeReply, // 좋아요 취소 API 엔드포인트
        data: dto.toJson(), // 요청 바디에 DTO 전송 (DELETE 요청도 body를 가질 수 있습니다)
      );

      if (response.statusCode == 200) {
        return response.data.toString(); // 서버가 반환하는 "좋아요 취소 완료" 메시지
      } else {
        throw Exception('댓글좋아요 취소 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? '댓글좋아요 취소 요청 실패';
      throw Exception(message);
    } catch (e) {
      throw Exception('알 수 없는 댓글좋아요 취소 에러: $e');
    }
  }
  
}