import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_app/model/cmu/feed/feed_list_model.dart';

class CategoryAnotherFeedItem extends StatelessWidget {
  final FeedPreviewDto feed;
  const CategoryAnotherFeedItem({
    super.key,
    required this.feed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 240,
        padding: const EdgeInsets.all(20),
        decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
                SizedBox(
                    width: double.infinity,
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                            SizedBox(
                                width: 200,
                                child: Text(
                                    feed.title,
                                    maxLines: 1,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontFamily: 'Pretendard',
                                        fontWeight: FontWeight.w700,
                                        height: 1.50,
                                    ),
                                ),
                            ),
                            SizedBox(
                                width: 200,
                                height: 48,
                                child: Text(
                                    '${feed.ctntPreview}',
                                    style: const TextStyle(
                                        color: Color(0xFF777777),
                                        fontSize: 14,
                                        fontFamily: 'Pretendard',
                                        fontWeight: FontWeight.w400,
                                        height: 1.50,
                                    ),
                                ),
                            ),
                        ],
                    ),
                ),
                SizedBox(
                    width: double.infinity,
                    height: 18,
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 8,
                        children: [
                            Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 12,
                                children: [
                                    Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 2,
                                        children: [
                                            SvgPicture.asset(
                                              'assets/icons/like.svg',
                                              fit: BoxFit.cover,
                                            ),
                                            Text(
                                                '${feed.likeCnt}',
                                                style: const TextStyle(
                                                    color: Color(0xFF777777),
                                                    fontSize: 12,
                                                    fontFamily: 'Pretendard',
                                                    fontWeight: FontWeight.w500,
                                                    height: 1.50,
                                                ),
                                            ),
                                        ],
                                    ),
                                    Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 2,
                                        children: [
                                            SvgPicture.asset(
                                              'assets/icons/reply.svg',
                                              fit: BoxFit.cover,
                                            ),
                                            Text(
                                                '${feed.replyCnt}',
                                                style: const TextStyle(
                                                    color: Color(0xFF777777),
                                                    fontSize: 12,
                                                    fontFamily: 'Pretendard',
                                                    fontWeight: FontWeight.w500,
                                                    height: 1.50,
                                                ),
                                            ),
                                        ],
                                    ),
                                ],
                            ),
                        ],
                    ),
                ),
            ],
        ),
    );
  }
}