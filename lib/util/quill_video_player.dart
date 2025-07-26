import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart'; // 유튜브 플레이어 임포트

class QuillVideoPlayer extends StatefulWidget {
  const QuillVideoPlayer({
    super.key,
    this.controller, // nullable로 변경
    this.youtubeVideoId,
    this.qc,
  });

  final VideoPlayerController? controller; // 로컬/네트워크 비디오 컨트롤러 (nullable)
  final String? youtubeVideoId; // 유튜브 비디오 ID
  final QuillController? qc;

  @override
  State<QuillVideoPlayer> createState() => QuillVideoPlayerState();
}

class QuillVideoPlayerState extends State<QuillVideoPlayer> {
  late Future<void> _initializeVideoPlayerFuture;
  YoutubePlayerController? _youtubePlayerController; // 유튜브 컨트롤러

  @override
  void initState() {
    super.initState();

    if (widget.youtubeVideoId != null) {

      // 유튜브 비디오 ID가 있으면 유튜브 컨트롤러 초기화
      _youtubePlayerController = YoutubePlayerController(
        initialVideoId: widget.youtubeVideoId!,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: true,
          disableDragSeek: false,
          loop: false,
          isLive: false,
          forceHD: false,
          enableCaption: false,
        ),
      );
    } else if (widget.controller != null) {
      // 로컬/네트워크 비디오 컨트롤러가 있으면 초기화
      _initializeVideoPlayerFuture = widget.controller!.initialize().catchError((error) {
        debugPrint('Error initializing video player: $error');
      });
    }
  }



  // @override
  // void didUpdateWidget(covariant QuillVideoPlayer oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   // 컨트롤러가 변경되었는지 확인하고, 변경되었다면 이전 컨트롤러를 dispose하고 새 컨트롤러를 초기화
  //   if (widget.controller != oldWidget.controller) {
  //     oldWidget.controller?.dispose(); // 이전 컨트롤러 dispose
  //     if (widget.controller != null) {
  //       _initializeVideoPlayerFuture = widget.controller!.initialize().then((_) {
  //         setState(() {});
  //       }).catchError((error) {
  //         debugPrint('Error initializing video player in didUpdateWidget: $error');
  //       });
  //     }
  //   }
  // }

  @override
  void dispose() {
    debugPrint('QuillVideoPlayer dispose 호출됨. YouTube ID: ${widget.youtubeVideoId}');
    if (_youtubePlayerController != null) {
      // 컨트롤러가 아직 초기화되지 않았거나 이미 dispose된 경우를 대비
      // 하지만 dispose()는 이미 dispose된 컨트롤러에 대해 안전하게 호출될 수 있어야 합니다.
      // 중요한 것은 컨트롤러가 null이 아닌지 확인하는 것입니다.
      _youtubePlayerController!.dispose();
      _youtubePlayerController = null; // dispose 후 null로 설정
      debugPrint('YoutubePlayerController disposed.');
    }
    // 로컬/네트워크 비디오 컨트롤러 처리 (기존 로직 유지)
    widget.controller?.dispose();
      super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.youtubeVideoId != null && _youtubePlayerController != null) {
      // 유튜브 영상인 경우
      return YoutubePlayer(
        controller: _youtubePlayerController!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.blueAccent,
        onReady: () {
          debugPrint('Youtube Player is ready.');
        },
      );
    } else if (widget.controller != null) {
      debugPrint(jsonEncode(widget.qc?.document.toDelta().toJson()));
      debugPrint('로컬/네트워크');
      // 로컬/네트워크 영상인 경우
      return FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error loading video: ${snapshot.error}'),
              );
            }
            // 비디오가 초기화되면 AspectRatio로 비디오를 표시합니다.
            return AspectRatio(
              aspectRatio: widget.controller!.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  VideoPlayer(widget.controller!),
                  // 비디오 재생/일시정지 버튼 (선택 사항)
                  if (!widget.controller!.value.isPlaying)
                    Center(
                      child: IconButton(
                        icon: const Icon(Icons.play_arrow, color: Colors.white, size: 50.0),
                        onPressed: () {
                          setState(() {
                            widget.controller!.play();
                          });
                        },
                      ),
                    )
                  else
                    Center(
                      child: IconButton(
                        icon: const Icon(Icons.pause, color: Colors.white, size: 50.0),
                        onPressed: () {
                          setState(() {
                            widget.controller!.pause();
                          });
                        },
                      ),
                    ),
                  VideoProgressIndicator(
                    widget.controller!,
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
            return const Center(child: CircularProgressIndicator());
          }
        },
      );
    } else {
      // 컨트롤러도, 유튜브 ID도 없는 경우
      return const SizedBox();
    }
  }
}