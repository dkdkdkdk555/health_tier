import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class QuillVideoPlayer extends StatefulWidget {
  const QuillVideoPlayer({super.key, 
    required this.controller,
  });

  final VideoPlayerController controller;

  @override
  State<QuillVideoPlayer> createState() => QuillVideoPlayerState();
}

class QuillVideoPlayerState extends State<QuillVideoPlayer> {
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayerFuture = widget.controller.initialize().then((_) {
      // 비디오가 초기화되면 재생할 준비가 되었음을 알립니다.
      // 필요에 따라 자동 재생하거나 컨트롤을 표시할 수 있습니다.
      setState(() {}); // 상태를 업데이트하여 VideoPlayer를 다시 빌드
    }).catchError((error) {
      debugPrint('Error initializing video player: $error');
    });
  }

  @override
  void dispose() {
    widget.controller.dispose(); // 컨트롤러 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // 비디오가 초기화되면 AspectRatio로 비디오를 표시합니다.
          return AspectRatio(
            aspectRatio: widget.controller.value.aspectRatio,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                VideoPlayer(widget.controller),
                // 비디오 재생/일시정지 버튼 (선택 사항)
                if (!widget.controller.value.isPlaying)
                  Center(
                    child: IconButton(
                      icon: const Icon(Icons.play_arrow, color: Colors.white, size: 50.0),
                      onPressed: () {
                        setState(() {
                          widget.controller.play();
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
                          widget.controller.pause();
                        });
                      },
                    ),
                  ),
                VideoProgressIndicator(
                  widget.controller,
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
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error loading video: ${snapshot.error}'),
          );
        } else {
          // 비디오가 아직 로드 중이면 로딩 인디케이터를 표시합니다.
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}