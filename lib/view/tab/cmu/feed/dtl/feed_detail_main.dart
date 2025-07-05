
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_app/model/cmu/feed/feed_detail.dart';
import 'package:my_app/providers/api_feed_providers.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'dart:convert';

import 'package:my_app/util/quill_image_embed_builder.dart';

class FeedDetailMain extends ConsumerWidget {
  final int feedId;
  const FeedDetailMain({
    super.key,
    required this.feedId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(feedDetailProvider(feedId));
    
    return detailAsync.when(
      data: (result) {
        final feed = result.data;

        debugPrint('DEBUG: feed.ctnt value: "${feed.ctnt}"');
        debugPrint('DEBUG: feed.ctnt type: ${feed.ctnt.runtimeType}');
        debugPrint('DEBUG: feed.ctnt is empty: ${feed.ctnt.isEmpty}');
        debugPrint('DEBUG: feed.ctnt is null: ${feed.ctnt == null}');

        final docContent = feed.ctnt.isNotEmpty
            ? List<Map<String, dynamic>>.from(jsonDecode(feed.ctnt) as List)
            : [];

        debugPrint('DEBUG: Content being passed to quill.Document.fromJson(): $docContent');
        debugPrint('DEBUG: Type of content being passed: ${docContent.runtimeType}');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 375,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      creatorProfile(feed),
                      const SizedBox(width: 10),
                      creatorNickname(feed),
                    ],
                  ),
                ],
              ),
            ),
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
                                          embedBuilders: [
                                            // 직접 만든 CustomImageEmbedBuilder를 추가합니다.
                                            CustomImageEmbedBuilder(),
                                            // 다른 임베드(예: 비디오)가 필요하면, 여기에 해당 EmbedBuilder를 추가해야 합니다.
                                            // 예를 들어, FlutterQuillEmbeds에서 비디오 빌더만 가져와야 한다면:
                                            // ...FlutterQuillEmbeds.editorBuilders().where((builder) => builder.key == 'video'),
                                          ]
                                        ),
                                      ),
                                    )
                                ],
                            ),
                        ),
                        likeWidget(feed),
                    ],
                ),
            ),
          ],
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

  Column creatorNickname(FeedDetailDto feed) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                feed.nickname,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  height: 1.50,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Container creatorProfile(FeedDetailDto feed) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: (feed.imgPath.isEmpty)
            ? SvgPicture.asset(
                'assets/widgets/default_user_profile.svg',
                fit: BoxFit.cover,
              )
            : Image.network(
                feed.imgPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return SvgPicture.asset(
                    'assets/widgets/default_user_profile.svg',
                    fit: BoxFit.cover,
                  );
                },
              ),
      ),
    );
  }
  
}