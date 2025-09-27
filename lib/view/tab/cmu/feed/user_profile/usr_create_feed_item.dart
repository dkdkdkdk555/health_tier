import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/model/cmu/feed/feed_list_model.dart';
import 'package:my_app/view/tab/cmu/feed/item/category_widget.dart';
import 'package:my_app/view/tab/cmu/feed/item/content_preview_widget.dart';
import 'package:my_app/view/tab/cmu/feed/item/image_preview_widget.dart';
import 'package:my_app/view/tab/cmu/feed/item/like_and_reply_widget.dart';
import 'package:my_app/view/tab/cmu/feed/item/title_widget.dart';

class UsrCreateFeedItem extends StatelessWidget {
  final FeedPreviewDto feed; // UsrFeedPreviewDto는 요청 모델이 아닌 응답 모델이어야 합니다.

  const UsrCreateFeedItem({
    super.key,
    required this.feed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        context.push('/cmu/feed/${feed.id}?categoryId=${feed.categoryId}');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0), // 아이템 상하 간격
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 미리보기가 없는 경우 (텍스트만)
            if (feed.imgPreview == null || feed.imgPreview!.isEmpty) ...{
              CategoryWidget(categoryNm: feed.category),
              TitleWidget(title: feed.title, categoryNm: feed.category,),
              ContentPreviewWidget(ctntPreview: feed.ctntPreview ?? ''),
            } else ...{
              // 이미지 미리보기가 있는 경우 (텍스트와 이미지)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CategoryWidget(categoryNm: feed.category),
                        TitleWidget(title: feed.title, categoryNm: feed.category,),
                        ContentPreviewWidget(ctntPreview: feed.ctntPreview ?? ''),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16), // 텍스트와 이미지 사이 간격
                  Container(
                    margin: const EdgeInsets.only(top:31),
                    child: ImagePreviewWidget(imgPreview: feed.imgPreview!)
                  ),
                ],
              ),
            },
            LikeAndReplyWidget(likeCnt: feed.likeCnt, replyCnt: feed.replyCnt),
          ],
        ),
      ),
    );
  }
}