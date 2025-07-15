import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_app/model/cmu/feed/feed_list_model.dart';

class UsrCreateFeedItem extends StatelessWidget {
  final FeedPreviewDto feed; // UsrFeedPreviewDto는 요청 모델이 아닌 응답 모델이어야 합니다.

  const UsrCreateFeedItem({
    super.key,
    required this.feed,
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
            _TitleWidget(title: feed.title),
            _ContentPreviewWidget(ctntPreview: feed.ctntPreview ?? ''),
          } else ...{
            // 이미지 미리보기가 있는 경우 (텍스트와 이미지)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TitleWidget(title: feed.title),
                      _ContentPreviewWidget(ctntPreview: feed.ctntPreview ?? ''),
                    ],
                  ),
                ),
                const SizedBox(width: 16), // 텍스트와 이미지 사이 간격
                _ImagePreviewWidget(imgPreview: feed.imgPreview!),
              ],
            ),
          },
          _LikeAndReplyWidget(likeCnt: feed.likeCnt, replyCnt: feed.replyCnt),
        ],
      ),
    );
  }
}

// 각 서브 위젯 분리 (가독성 향상)
class _TitleWidget extends StatelessWidget {
  final String title;
  const _TitleWidget({required this.title});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 44, // 두 줄 텍스트의 최대 높이 (Line height 1.40 * 2줄 = 2.80 * 16px = 44.8px)
      ),
      child: Text(
        title,
        textAlign: TextAlign.left,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w500,
          height: 1.40,
        ),
      ),
    );
  }
}

class _ContentPreviewWidget extends StatelessWidget {
  final String ctntPreview;
  const _ContentPreviewWidget({required this.ctntPreview});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 1),
      child: SizedBox(
        height: 44, // 두 줄 텍스트의 높이
        child: Text(
          ctntPreview,
          textAlign: TextAlign.left,
          overflow: TextOverflow.ellipsis,
          maxLines: 2, // 2줄로 제한
          style: const TextStyle(
            color: Color(0xFF777777),
            fontSize: 14,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w400,
            height: 1.40,
          ),
        ),
      ),
    );
  }
}

class _ImagePreviewWidget extends StatelessWidget {
  final String imgPreview;
  const _ImagePreviewWidget({required this.imgPreview});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: ShapeDecoration(
        image: DecorationImage(
          image: NetworkImage(imgPreview),
          fit: BoxFit.cover,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}

class _LikeAndReplyWidget extends StatelessWidget {
  final int likeCnt;
  final int replyCnt;
  const _LikeAndReplyWidget({required this.likeCnt, required this.replyCnt});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // 왼쪽 정렬
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/like.svg',
                width: 16, // 아이콘 크기 명시
                height: 16,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 2),
              Text(
                '$likeCnt',
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
          const SizedBox(width: 12), // 좋아요와 댓글 사이 간격
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/reply.svg',
                width: 16, // 아이콘 크기 명시
                height: 16,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 2),
              Text(
                '$replyCnt',
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
    );
  }
}