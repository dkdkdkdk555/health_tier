
import 'package:flutter/material.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_app/model/cmu/feed/feed_detail.dart';
import 'package:my_app/providers/feed_cud_providers.dart';
import 'package:my_app/providers/feed_providers.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:my_app/providers/notifier_provider.dart';
import 'dart:convert';

import 'package:my_app/util/quill_image_embed_builder.dart';
import 'package:my_app/util/quill_video_player.dart';
import 'package:my_app/view/tab/cmu/feed/dtl/feed_detail_profile_section.dart';
import 'package:my_app/view/tab/cmu/feed/dtl/feed_like_and_certifi_section.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class FeedDetailMain extends ConsumerStatefulWidget {
  final int feedId;
  const FeedDetailMain({
    super.key,
    required this.feedId,
  });

    @override
  ConsumerState<FeedDetailMain> createState() => _FeedDetailMainState();
}

class _FeedDetailMainState extends ConsumerState<FeedDetailMain> {
  @override
  void initState() {
    super.initState();
    // 위젯이 처음 생성될 때만 호출
    _incrementPostView(widget.feedId);
  }


  Future<void> _incrementPostView(int feedId) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. 캐시된 조회 기록 불러오기
    String? cachedViewsJson = prefs.getString('post_view_cache');
    Map<String, String> cachedViewsMap = {}; // 키를 String으로 유지하는 것이 안전합니다.

    if (cachedViewsJson != null && cachedViewsJson.isNotEmpty) {
      try {
        final decodedData = jsonDecode(cachedViewsJson);
        // 디코딩된 데이터가 Map<String, dynamic> 타입인지 확인
        if (decodedData is Map<String, dynamic>) {
          // Map의 각 엔트리를 순회하며 Map<String, String>으로 변환
          decodedData.forEach((key, value) {
            if (value is String) { // 값이 String 타입인지 확인
              cachedViewsMap[key] = value;
            } else {
              debugPrint('캐시된 데이터의 값 타입이 String이 아닙니다: $key: $value');
              // 필요하다면 해당 엔트리를 스킵하거나 기본값으로 처리
            }
          });
        } else {
          debugPrint('캐시된 데이터가 Map<String, dynamic> 타입이 아닙니다: $decodedData');
          // 이전에 잘못된 형식으로 저장된 경우, 캐시를 초기화합니다.
          await prefs.remove('post_view_cache');
        }
      } catch (e) {
        debugPrint('캐시 데이터 디코딩 중 에러 발생: $e');
        // JSON 파싱 에러 발생 시, 캐시를 초기화합니다.
        await prefs.remove('post_view_cache');
      }
    }

    DateTime? lastViewTime;
    // feedId를 String으로 변환하여 캐시 키로 사용
    if (cachedViewsMap.containsKey(feedId.toString())) {
      try {
        lastViewTime = DateTime.parse(cachedViewsMap[feedId.toString()]!);
      } catch (e) {
        debugPrint('캐시된 시간 데이터 파싱 중 에러 발생: $e');
        // 시간 데이터 파싱 에러 시, 해당 캐시 엔트리를 무효화합니다.
        cachedViewsMap.remove(feedId.toString());
        await prefs.setString("post_view_cache", jsonEncode(cachedViewsMap));
      }
    }

    // 2. 24시간이 경과했는지 확인
    final now = DateTime.now();
    final cachingTime = now.subtract(const Duration(hours: 24));

    if (lastViewTime == null || lastViewTime.isBefore(cachingTime)) {
      // 3. 24시간이 경과했거나 처음 조회하는 경우 -> 조회수 증가
      try {
        await ref.read(feedService).increaseView(feedId);
        debugPrint('게시글 $feedId 에 대한 조회수 증가 API 호출 성공');

        // 4. API 호출 성공 시에만 캐시 업데이트
        cachedViewsMap[feedId.toString()] = now.toIso8601String();
        await prefs.setString("post_view_cache", jsonEncode(cachedViewsMap));
      } catch (e) {
        debugPrint('조회수 증가 API 호출 실패: $e');
        // API 호출 실패 시 캐시를 업데이트하지 않으므로 다음번에 다시 시도할 수 있습니다.
      }
    } else {
      debugPrint('게시글 $feedId 는 24시간 이내에 이미 조회되어 API 호출 생략');
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(feedDetailProvider(widget.feedId));
    
    return detailAsync.when(
      data: (result) {
        final feed = result.data;

         Future.microtask(() { // 위젯 트리가 빌드되는 중에 프로바이더의 상태를 변경할 수 없다는 오류로
         // 아래 프로바이더 작업의 실행 시점을 위젯 생명주기 밖으로 옮기는것
            // 다른 위젯과 공유할 값들 changeNotifier 에 값 설정
            ref.read(feedMainChangeNotifierProvider).changeUserIdValue(feed.userId);
            ref.read(feedMainChangeNotifierProvider).changeCategoryId(feed.categoryId);
            ref.read(feedMainChangeNotifierProvider).changeCategoryNm(feed.categoryName);
          }
         );

        return Stack(
          children: [
              Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FeedDetailProfileSection(userId:feed.userId),
                Container(
                    width: 375,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 40,
                        children: [
                            SizedBox(
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 24,
                                    children: [
                                        SizedBox(
                                            child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                spacing: 8,
                                                children: [
                                                    feedCategory(feed),
                                                    feedTitle(feed),
                                                    feedMetaData(feed),
                                                ],
                                            ),
                                        ),
                                        SizedBox(
                                          width: 335,
                                          child: quill.QuillEditor.basic(
                                            controller: quill.QuillController(
                                              readOnly: true,
                                              document: quill.Document.fromJson(
                                                feed.ctnt.isNotEmpty
                                                    ? List<Map<String, dynamic>>.from(jsonDecode(feed.ctnt) as List)
                                                    : [
                                                        {"insert": "\n"}
                                                      ],
                                              ),
                                              selection: const TextSelection.collapsed(offset: 0),
                                            ),
                                            config: quill.QuillEditorConfig(
                                              showCursor: false,
                                              embedBuilders: [
                                                CustomImageEmbedBuilder(), // 이미지 렌더링
                                                ...FlutterQuillEmbeds.editorBuilders(
                                                  videoEmbedConfig: QuillEditorVideoEmbedConfig(
                                                    customVideoBuilder: (videoUrl, readOnly) {
                                                      final youtubeVideoIdFromUrl = YoutubePlayer.convertUrlToId(videoUrl); // **새로 추가된 부분**
            
                                                      if (youtubeVideoIdFromUrl != null) {
                                                        return QuillVideoPlayer(youtubeVideoId: youtubeVideoIdFromUrl); // **수정된 부분**
                                                      }
            
                                                      return QuillVideoPlayer(videoUrl: videoUrl,);
                                                    },
                                                  )
                                                )
                                              ]
                                            ),
                                          ),
                                        )
                                    ],
                                ),
                            ),
                            FeedLikeAndCertifiSection(feed: feed),
                        ],
                    ),
                ),
                Container( // 구분선
                  height: 8,
                  decoration: const BoxDecoration(color: Color(0xFFF5F5F5)),
                ),
                Container(
                    height: 53,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                            const Text(
                                '댓글',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w500,
                                    height: 1.50,
                                ),
                            ),
                            Text(
                                '${feed.replyCount}',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w400,
                                    height: 1.50,
                                ),
                            ),
                        ],
                    ),
                )
              ],
            ),
            // 인증게시글의 경우 인증상태라면 인증벳지 보여주기
            if(feed.crtifiId != 0 && feed.crtifiYn == 'Y')...{
              Positioned(
                top: 0,
                right: 18,
                child: SizedBox(
                  width: 82,
                  height: 82,
                  child: Image.asset(
                    'assets/widgets/feed_certifi_${feed.crtifiWho!.toLowerCase()}.png'
                  ),
                )
              )
            }
          ]
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('에러: $err')),
    );
  }

  SizedBox likeWidget(FeedDetailDto feed) {
    return SizedBox(
        width: 335,
        child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
                Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [
                        Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 4,
                            children: [
                                Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: ShapeDecoration(
                                        shape: RoundedRectangleBorder(
                                            side: const BorderSide(
                                                width: 1,
                                                color: Color(0xFFDDDDDD),
                                            ),
                                            borderRadius: BorderRadius.circular(99),
                                        ),
                                    ),
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        spacing: 10,
                                        children: [
                                            Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                spacing: 2,
                                                children: [
                                                    SizedBox(
                                                      width: 16,
                                                      height: 16,
                                                      child: SvgPicture.asset(
                                                        'assets/icons/like.svg',
                                                        width: 16,
                                                        height: 16,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    Text(
                                                      feed.likeCnt == 0 ? '좋아요' : '${feed.likeCnt}',
                                                      style: const TextStyle(
                                                        color: Color(0xFF333333),
                                                        fontSize: 12,
                                                        fontFamily: 'Pretendard',
                                                        fontWeight: FontWeight.w400,
                                                        height: 1.50,
                                                      ),
                                                    ),
                                                ],
                                            ),
                                        ],
                                    ),
                                ),
                            ],
                        ),
                    ],
                ),
            ],
        ),
    );
  }

  Row feedMetaData(FeedDetailDto feed) {
    return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 4,
        children: [
            Text(
                feed.displayDttm,
                style: const TextStyle(
                    color: Color(0xFF777777),
                    fontSize: 14,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                ),
            ),
            const Text(
                '·',
                style: TextStyle(
                    color: Color(0xFF777777),
                    fontSize: 14,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                ),
            ),
            Text(
                '조회수 ${feed.views}',
                style: const TextStyle(
                    color: Color(0xFF777777),
                    fontSize: 14,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                ),
            ),
        ],
    );
  }

  SizedBox feedTitle(FeedDetailDto feed) {
    return SizedBox(
        width: 335,
        child: Text(
            feed.title,
            style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
                height: 1.40,
            ),
        ),
    );
  }

  Container feedCategory(FeedDetailDto feed) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: ShapeDecoration(
            color: const Color(0xFFF5F5F5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(99),
            ),
        ),
        child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
                Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 4,
                    children: [
                        Text(
                            feed.categoryName,
                            style: const TextStyle(
                                color: Color(0xFF777777),
                                fontSize: 12,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w400,
                                height: 1.50,
                            ),
                        ),
                    ],
                ),
            ],
        ),
    );
  }
  
}

