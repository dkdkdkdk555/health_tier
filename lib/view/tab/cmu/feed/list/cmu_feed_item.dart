import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/model/cmu/feed/feed_list_model.dart';
import 'package:my_app/view/tab/cmu/feed/dtl/feed_detail.dart';

class CmuFeedItem extends StatelessWidget {
  final FeedPreviewDto feed;
  const CmuFeedItem({
    super.key,
    required this.feed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/cmu/feed/${feed.id}?categoryId=${feed.categoryId}');
      },
      child: Container(
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
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    profileImage(feed.userImgPath),
                    feedProfile()
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if(feed.imgPreview == null || feed.imgPreview!.isEmpty)... {
                    title(),
                    ctntPreview()
                  } else... {
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              title(),
                              ctntPreview(),
                            ],
                          ),
                        ),
                        imagePreview()
                      ],
                    ),
                  }
                  ,likeAndReply()
                ],
              )
            ],
          ),
      ),
    );
  }

  Widget likeAndReply() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,
          children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 12,
                  children: [
                      Row(
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
    );
  }

  Container imagePreview() {
    return Container(
      width: 70,
      height: 70,
      margin: const EdgeInsets.only(left:16),
      alignment: Alignment.topCenter,
      decoration: ShapeDecoration(
          image: DecorationImage(
              image: NetworkImage('${feed.imgPreview}'),
              fit: BoxFit.cover,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }

  Widget ctntPreview() {
    return Container(
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      margin: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        height: 44,
        child: Text(
          '${feed.ctntPreview}',
          textAlign: TextAlign.left,
          style: const TextStyle(
            color: Color(0xFF777777),
              overflow: TextOverflow.ellipsis,
            fontSize: 14,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w400,
            height: 1.40,
          ),
        ),
      ),
    );
  }

  ConstrainedBox title() {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 44, // 두 줄 텍스트의 최대 높이
      ),
      child: Text(
        feed.title,
        textAlign: TextAlign.left,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w700,
          height: 1.40,
        ),
      ),
    );
  }

  Column feedProfile() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 1,
      children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 2,
              children: [
                  Text( // nickname
                    feed.nickName,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        height: 1.50,
                    ),
                  ),
                  Container( // tier
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: ShapeDecoration(
                          color: const Color(0x33FAA131),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 10,
                          children: [
                              Text(
                                  '${feed.tier}',
                                  style: const TextStyle(
                                      color: Color(0xFFFAA131),
                                      fontSize: 10,
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w700,
                                      height: 1.50,
                                  ),
                              ),
                          ],
                      ),
                  ),
              ],
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 2,
              children: [
                  Text(
                    feed.category,
                    style: const TextStyle(
                        color: Color(0xFF777777),
                        fontSize: 12,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                    ),
                  ),
                  dot(),
                  Text(
                    feed.viewDttm,
                    style: const TextStyle(
                        color: Color(0xFF777777),
                        fontSize: 12,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                    ),
                  ),
                  dot(),
                  Text(
                      '조회수 ${feed.views}',
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
  );
  }

  Text dot() {
    return const Text(
        '·',
        style: TextStyle(
            color: Color(0xFF777777),
            fontSize: 12,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w400,
            height: 1.50,
        ),
    );
  }

  Widget profileImage(String? imageUrl) {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.only(right: 10),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.hardEdge,
      child: (imageUrl != null && imageUrl.isNotEmpty)
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return SvgPicture.asset(
                  'assets/widgets/default_user_profile.svg',
                  fit: BoxFit.cover,
                );
              },
            )
          : SvgPicture.asset(
              'assets/widgets/default_user_profile.svg',
              fit: BoxFit.cover,
            ),
    );
  }
}