import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:my_app/api/api_routes.dart';
import 'package:my_app/model/cmu/feed/reply_response.dart';
import 'package:my_app/model/cmu/feed/report_request_dto.dart';
import 'package:my_app/model/cmu/reply/reply_like_request_dto.dart';
import 'package:my_app/model/cmu/reply/reply_write_request_dto.dart';

class ReplyCudService {
  final Dio dio;
  ReplyCudService(this.dio);

  // 댓글 좋아요 요청
  Future<String> likeReply(ReplyLikeRequestDto dto) async {
    final response = await dio.post(
      ReplyCudAPI.likeReply, // 좋아요 API 엔드포인트
      data: dto.toJson(),
    );

    return response.data.toString();
  }

  // 댓글 좋아요 취소 요청
  Future<String> cancelReplyLike(ReplyLikeRequestDto dto) async {
    final response = await dio.delete( // DELETE 메소드 사용
      ReplyCudAPI.cancelLikeReply, // 좋아요 취소 API 엔드포인트
      data: dto.toJson(), // 요청 바디에 DTO 전송 (DELETE 요청도 body를 가질 수 있습니다)
    );

    return response.data.toString(); // 서버가 반환하는 "좋아요 취소 완료" 메시지
  }
  
  // 댓글 삭제요청
  Future<String> deleteReply(int id) async {
    try {
      final response = await dio.delete( 
        '${ReplyCudAPI.deleteReply}/$id',
      );

      if (response.statusCode == 200) {
        return response.data.toString();
      } else {
        throw Exception('댓글 삭제 취소 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('알 수 없는 댓글 삭제 에러: $e');
    }
  }

  // 댓글 신고하기
  Future<String> reportReply(ReportRequestDto dto) async {
    try {
      final response = await dio.post(
        ReplyCudAPI.reportReply,
        data: dto.toJson(),
      );
      return response.data.toString(); // "신고가 접수되었습니다."
    } on DioException catch (e) {
      // 서버에서 보낸 메시지를 파싱
      if (e.response?.statusCode == 409) {
        final message = e.response?.data['message'] ?? '이미 신고된 댓글입니다.';
        throw Exception(message);
      } else {
        throw Exception('신고 실패: ${e.response?.statusCode}');
      }
    } catch (e) {
      throw Exception('알 수 없는 오류: $e');
    }
  }


  // 댓글 작성 요청
  Future<ReplyResponseDto> writeReply(ReplyWriteRequestDto dto) async {
    try {
      final response = await dio.post(
        ReplyCudAPI.writeReply,
        data: dto.toJson(),
      );

      if (response.statusCode == 200) {
        return ReplyResponseDto.fromJson(response.data);
      } else {
        throw Exception('댓글 작성 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('알 수 없는 댓글 작성 에러: $e');
    }
  }

  // 댓글 수정 요청
  Future<ReplyResponseDto> updateReply(ReplyWriteRequestDto dto) async {
    try {
      final response = await dio.put(
        ReplyCudAPI.updateReply,
        data: dto.toJson(),
      );

      if (response.statusCode == 200) {
        return ReplyResponseDto.fromJson(response.data);
      } else {
        throw Exception('댓글 수정 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('알 수 없는 댓글 수정 에러: $e');
    }
  }
}