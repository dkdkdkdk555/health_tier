import 'package:flutter/widgets.dart';
import 'package:my_app/model/cmu/feed/feed_list_model.dart';

class CmuFeedItem extends StatelessWidget {
  final FeedPreviewDto feed;
  const CmuFeedItem({
    super.key,
    required this.feed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const ShapeDecoration(
        shape: RoundedRectangleBorder(
        side: BorderSide(
            width: 1,
            color: Color(0xFFEEEEEE),
          ),
        ),
      ),
      child: Column(
        children: [
          const Row(

          ),
          Column(
            children: [
              if(feed.imgPreview == null)... {
                // title 위젯,
                // ctntPreview 위젯,
              } else... {
                const Row(
                  children: [
                    Column(
                      children: [
                      // title 위젯,
                      // ctntPreview 위젯,

                      ],
                    ),
                      // imgPreview 위젯
                  ],
                ),
              }
              // likeCnt + replyCnt 위젯,
            ],
          )
        ],
      ),
    );
  }
}