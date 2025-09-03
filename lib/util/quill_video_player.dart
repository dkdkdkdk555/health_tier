import 'dart:io' as io; // File을 사용하기 위해 필요
import 'package:flutter/material.dart';
import 'package:my_app/util/error_message_utils.dart';
import 'package:my_app/util/spinner_utils.dart' show AppLoadingIndicator;
import 'package:my_app/view/common/error_media_widget.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart'; // 유튜브 플레이어 임포트

class QuillVideoPlayer extends StatefulWidget {
  const QuillVideoPlayer({
    super.key,
    this.videoUrl, // 일반 비디오 URL 또는 파일 경로를 문자열로 받음
    this.youtubeVideoId, // 유튜브 비디오 ID
  });

  final String? videoUrl; // 로컬/네트워크 비디오 URL/경로 (nullable)
  final String? youtubeVideoId; // 유튜브 비디오 ID (nullable)

  @override
  State<QuillVideoPlayer> createState() => QuillVideoPlayerState();
}

class QuillVideoPlayerState extends State<QuillVideoPlayer> {
  VideoPlayerController? _videoController; // 로컬/네트워크 비디오 컨트롤러
  YoutubePlayerController? _youtubePlayerController; // 유튜브 컨트롤러
  Future<void>? _initializeVideoPlayerFuture; // 비디오 플레이어 초기화 퓨처

  @override
  void initState() {
    super.initState();
    _initializeControllers(); // 위젯 초기화 시 컨트롤러 초기화 로직 호출
  }

  // 핵심: 위젯이 업데이트될 때 컨트롤러를 관리합니다.
  @override
  void didUpdateWidget(covariant QuillVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // YouTube ID 또는 비디오 URL이 변경되었는지 확인
    if (widget.youtubeVideoId != oldWidget.youtubeVideoId ||
        widget.videoUrl != oldWidget.videoUrl) {
      debugPrint('비디오 소스 변경 감지: 이전 YouTube ID: ${oldWidget.youtubeVideoId}, 새 YouTube ID: ${widget.youtubeVideoId}');
      debugPrint('이전 Video URL: ${oldWidget.videoUrl}, 새 Video URL: ${widget.videoUrl}');
      _disposeControllers(); // 이전 컨트롤러들 해제
      _initializeControllers(); // 새로운 컨트롤러 초기화
    }
  }

  // 컨트롤러 초기화 로직을 별도 메서드로 분리
  void _initializeControllers() {
    _initializeVideoPlayerFuture = null; // 초기화 퓨처 리셋

    if (widget.youtubeVideoId != null) {
      debugPrint('YoutubePlayerController 초기화 중: ID = ${widget.youtubeVideoId}');
      _youtubePlayerController = YoutubePlayerController(
        initialVideoId: widget.youtubeVideoId!,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          disableDragSeek: false,
          loop: false,
          isLive: false,
          forceHD: false,
          enableCaption: false,
        ),
      );
      // YoutubePlayerController는 생성 시점에 이미 준비되므로 별도의 future는 필요 없음
    } else if (widget.videoUrl != null) {
      debugPrint('VideoPlayerController 초기화 중: URL = ${widget.videoUrl}');
      Uri? uri = Uri.tryParse(widget.videoUrl!);
      if (uri == null) {
        debugPrint('유효하지 않은 비디오 URL: ${widget.videoUrl}');
        showAppMessage(context, message: '영상 URL이 유효하지 않습니다.}');
        return; // 유효하지 않은 URL이면 초기화하지 않음
      }

      if (uri.scheme == 'file') {
        _videoController = VideoPlayerController.file(io.File(uri.toFilePath()));
      } else {
        _videoController = VideoPlayerController.networkUrl(uri);
      }

      _initializeVideoPlayerFuture = _videoController!.initialize().then((_) {
        // 비디오 초기화 완료 시 재생 상태 변경을 감지하기 위해 리스너 추가
        _videoController!.addListener(_videoListener);
        setState(() {}); // 초기화 완료 후 UI 업데이트
      }).catchError((error) {
        debugPrint('VideoPlayerController 초기화 오류: $error');
        if (mounted) {
          // 오류 발생 시 사용자에게 알림
          showAppMessage(context, message: '영상 플레이어를 로드하지 못했습니다.');
        }
      });
    }
  }

  // 비디오 컨트롤러 상태 변화 리스너
  void _videoListener() {
    // 재생 상태가 변경될 때마다 UI를 다시 그리기 위해 setState 호출
    if (_videoController != null && _videoController!.value.isPlaying != _isPlaying) {
      setState(() {
        _isPlaying = _videoController!.value.isPlaying;
      });
    }
  }
  bool _isPlaying = false; // 현재 재생 상태 추적


  // 컨트롤러 해제 로직
  void _disposeControllers() {
    debugPrint('QuillVideoPlayer _disposeControllers 호출됨');
    if (_youtubePlayerController != null) {
      _youtubePlayerController!.dispose();
      _youtubePlayerController = null;
      debugPrint('YoutubePlayerController 해제 완료.');
    }
    if (_videoController != null) {
      _videoController!.removeListener(_videoListener); // 리스너 제거
      _videoController!.dispose();
      _videoController = null;
      debugPrint('VideoPlayerController 해제 완료.');
    }
  }

  @override
  void dispose() {
    debugPrint('QuillVideoPlayer dispose 호출됨.');
    _disposeControllers(); // 위젯이 완전히 제거될 때 컨트롤러 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.youtubeVideoId != null) {
      // 유튜브 영상인 경우
      if (_youtubePlayerController == null) {
        return const Center(child: AppLoadingIndicator()); // 컨트롤러 준비 중
      }
      return YoutubePlayer(
        controller: _youtubePlayerController!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.blueAccent,
        onReady: () {
          debugPrint('Youtube Player 준비 완료.');
        },
      );
    } else if (widget.videoUrl != null) {
      // 로컬/네트워크 영상인 경우
      if (_videoController == null || _initializeVideoPlayerFuture == null) {
        return const Center(child: AppLoadingIndicator()); // 컨트롤러 또는 퓨처 준비 중
      }
      return FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              debugPrint('비디오 로드 에러: ${snapshot.error}');
              return const Center(
                child: ErrorMediaWidget(width: 150, height: 150, text: '비디오를 불러오지 못했습니다.'),
              );
            }
            if (_videoController == null || !_videoController!.value.isInitialized) {
               debugPrint('비디오 컨트롤러가 초기화되지 않았습니다.');
               return const Center(child: ErrorMediaWidget(width: 250, height: 150, text: '비디오를 불러오지 못했습니다.\n(네트워크 문제)'));
            }
            // 비디오가 초기화되면 AspectRatio로 비디오를 표시합니다.
            return AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  VideoPlayer(_videoController!),
                  // 비디오 재생/일시정지 버튼 오버레이
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _videoController!.value.isPlaying
                            ? _videoController!.pause()
                            : _videoController!.play();
                        _isPlaying = _videoController!.value.isPlaying; // 상태 업데이트
                      });
                    },
                    child: AnimatedOpacity(
                      opacity: _videoController!.value.isPlaying ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        color: Colors.black26,
                        child: Center(
                          child: Icon(
                            _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 70.0, // 아이콘 크기 약간 줄임
                          ),
                        ),
                      ),
                    ),
                  ),
                  VideoProgressIndicator(
                    _videoController!,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                      playedColor: Colors.blueAccent,
                      bufferedColor: Colors.white,
                      backgroundColor: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          } else {
            // 비디오가 아직 로드 중이면 로딩 인디케이터를 표시합니다.
            return const Center(child: AppLoadingIndicator());
          }
        },
      );
    } else {
      // 컨트롤러도, 유튜브 ID도 없는 경우
      debugPrint('비디오 URL 또는 YouTube ID가 제공되지 않았습니다.');
      return const SizedBox();
    }
  }
}