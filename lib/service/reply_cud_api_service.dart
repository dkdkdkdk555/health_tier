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
      ReplyCudAPI.likeReply,
      data: dto.toJson(),
    );

    return response.data.toString();
  }

  // 댓글 좋아요 취소 요청
  Future<String> cancelReplyLike(ReplyLikeRequestDto dto) async {
    final response = await dio.delete(
      ReplyCudAPI.cancelLikeReply,
      data: dto.toJson(),
    );
    return response.data.toString();
  }
  
  // 댓글 삭제요청
  Future<String> deleteReply(int id) async {
    final response = await dio.delete( 
      '${ReplyCudAPI.deleteReply}/$id',
    );

    return response.data.toString();
  }

  // 댓글 신고하기
  Future<String> reportReply(ReportRequestDto dto) async {
    final response = await dio.post(
      ReplyCudAPI.reportReply,
      data: dto.toJson(),
    );
    return response.data.toString();
  }


  // 댓글 작성 요청
  Future<ReplyResponseDto?> writeReply(ReplyWriteRequestDto dto) async {
    final response = await dio.post(
      ReplyCudAPI.writeReply,
      data: dto.toJson(),
    );
    if(response.data == null) { // relogin_required의 경우 ReplyCudAPI.writeReply 에서 응답하지 않으므로 null이 리턴됨
      return null;
    }
    return ReplyResponseDto.fromJson(response.data);
  }

  // 댓글 수정 요청
  Future<ReplyResponseDto?> updateReply(ReplyWriteRequestDto dto) async {
    final response = await dio.put(
      ReplyCudAPI.updateReply,
      data: dto.toJson(),
    );
    if(response.data == null) { // relogin_required의 경우 ReplyCudAPI.updateReply 에서 응답하지 않으므로 null이 리턴됨
      return null;
    }
    return ReplyResponseDto.fromJson(response.data);
  }
}