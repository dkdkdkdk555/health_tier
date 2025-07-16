import 'package:flutter/material.dart';
import 'package:my_app/model/cmu/feed/feed_list_model.dart';
import 'package:my_app/view/tab/cmu/feed/item/category_widget.dart';
import 'package:my_app/view/tab/cmu/feed/item/content_preview_widget_highlight.dart';
import 'package:my_app/view/tab/cmu/feed/item/image_preview_widget.dart';
import 'package:my_app/view/tab/cmu/feed/item/like_and_reply_widget.dart';
import 'package:my_app/view/tab/cmu/feed/item/title_widget_highlight.dart';

class SrchResultFeedItem extends StatelessWidget {
  final FeedPreviewDto feed;
  final String searchKeyword; 

  const SrchResultFeedItem({
    super.key,
    required this.feed,
    this.searchKeyword = '',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0), // 아이템 상하 간격
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이미지 미리보기가 없는 경우 (텍스트만)
          if (feed.imgPreview == null || feed.imgPreview!.isEmpty) ...{
            CategoryWidget(categoryNm: feed.category),
            TitleWidgetHighlight(title: feed.title, categoryNm: feed.category, searchKeyword: searchKeyword, ),
            ContentPreviewWidgetHighlight(ctntPreview: feed.ctntPreview ?? '', searchKeyword: searchKeyword, ),
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
                      TitleWidgetHighlight(title: feed.title, categoryNm: feed.category, searchKeyword: searchKeyword, ),
                      ContentPreviewWidgetHighlight(ctntPreview: feed.ctntPreview ?? '', searchKeyword: searchKeyword, ),
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
    );
  }
}