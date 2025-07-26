import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart'; // 유튜브 플레이어 임포트

class QuillVideoPlayer extends StatefulWidget {
  const QuillVideoPlayer({
    super.key,
    this.controller, // nullable로 변경
    this.youtubeVideoId,
  });

  final VideoPlayerController? controller; // 로컬/네트워크 비디오 컨트롤러 (nullable)
  final String? youtubeVideoId; // 유튜브 비디오 ID

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

      debugPrint('플레이어 : ${widget.youtubeVideoId}');
      // 유튜브 비디오 ID가 있으면 유튜브 컨트롤러 초기화
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
    } else if (widget.controller != null) {
      // 로컬/네트워크 비디오 컨트롤러가 있으면 초기화
      _initializeVideoPlayerFuture = widget.controller!.initialize().then((_) {
        setState(() {}); // 상태 업데이트
      }).catchError((error) {
        debugPrint('Error initializing video player: $error');
      });
    }
  }

  @override
  void dispose() {
    if (widget.controller != null) {
      widget.controller!.dispose(); // 기존 컨트롤러 해제
    }
    _youtubePlayerController?.dispose(); // 유튜브 컨트롤러 해제
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