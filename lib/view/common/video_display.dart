import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoDisplay extends StatefulWidget {
  final String videoUrl;
  
  const VideoDisplay({
    super.key,
    required this.videoUrl,
  });

  @override
  State<VideoDisplay> createState() => _VideoDisplayWidgetState();
}

class _VideoDisplayWidgetState extends State<VideoDisplay> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // 1. 컨트롤러 초기화
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );
    _controller.setLooping(true);
    _controller.setVolume(0); // 무음

    // 2. 비디오 초기화 완료 후 재생 준비
    _controller.initialize().then((_) {
      // 3. 초기화 완료 후 상태 업데이트 (화면에 비디오를 그릴 준비)
      setState(() {
        _controller.setLooping(true); // 반복 재생 설정
        _controller.play();           // 즉시 재생 시작
      });
    }).catchError((error) {
      // 비디오 로드 실패 처리
      debugPrint("Video load failed: $error");
    });
  }

  @override
  void dispose() {
    // 4. 위젯이 파괴될 때 컨트롤러 해제 (필수!)
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 5. 초기화 상태에 따라 렌더링 분기
    if (_controller.value.isInitialized) {
      // 초기화 완료: 비디오 화면 렌더링
      return AspectRatio(
        // 비디오의 가로:세로 비율을 유지
        aspectRatio: _controller.value.aspectRatio,
        child: VideoPlayer(_controller),
      );
    } else {
      // 초기화 중: 로딩 스피너 표시
      return const Center(
        child: SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}