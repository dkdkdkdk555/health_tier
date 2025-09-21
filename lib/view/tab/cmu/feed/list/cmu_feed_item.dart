import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/model/cmu/feed/feed_list_model.dart';
import 'package:my_app/util/screen_ratio.dart' show ScreenRatio;

class CmuFeedItem extends StatelessWidget {
  final FeedPreviewDto feed;
  const CmuFeedItem({
    super.key,
    required this.feed,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = ScreenRatio(context);
    final htio = ratio.heightRatio;
    final wtio = ratio.widthRatio;
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
                margin: EdgeInsets.only(bottom: 12 * htio),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    profileImage(feed.userImgPath, wtio, htio),
                    feedProfile(htio, wtio)
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if(feed.imgPreview == null || feed.imgPreview!.isEmpty)... {
                    title(htio),
                    ctntPreview(htio)
                  } else... {
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              title(htio),
                              ctntPreview(htio),
                            ],
                          ),
                        ),
                        imagePreview(htio, wtio)
                      ],
                    ),
                  }
                  ,likeAndReply(htio, wtio)
                ],
              )
            ],
          ),
      ),
    );
  }

  Widget likeAndReply(double htio, double wtio) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8 * wtio,
          children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 12 * wtio,
                  children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 2 * wtio,
                          children: [
                              SvgPicture.asset(
                                'assets/icons/like.svg',
                                fit: BoxFit.cover,
                              ),
                              Text(
                                  '${feed.likeCnt}',
                                  style: TextStyle(
                                      color: const Color(0xFF777777),
                                      fontSize: 12 * htio,
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w500,
                                      height: 1.50 * htio,
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

  Container imagePreview(double htio, double wtio) {
    return Container(
      width: 70 * htio,
      height: 70 * htio,
      margin: EdgeInsets.only(left:16 * wtio),
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

  Widget ctntPreview(double htio) {
    return Container(
      padding: EdgeInsets.only(top: 4 * htio, bottom: 2 * htio),
      margin: EdgeInsets.only(bottom: 8 * htio),
      child: SizedBox(
        height: 44 * htio,
        child: Text(
          '${feed.ctntPreview}',
          textAlign: TextAlign.left,
          style: TextStyle(
            color: const Color(0xFF777777),
              overflow: TextOverflow.ellipsis,
            fontSize: 14 * htio,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w400,
            height: 1.40 * htio,
          ),
        ),
      ),
    );
  }

  ConstrainedBox title(double htio) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 44 * htio, // 두 줄 텍스트의 최대 높이
      ),
      child: Text(
        feed.title,
        textAlign: TextAlign.left,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16 * htio,
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w700,
          height: 1.40 * htio,
        ),
      ),
    );
  }

  Column feedProfile(double htio, double wtio) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 1 * htio,
      children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 2 * wtio,
              children: [
                  Text( // nickname
                    feed.nickName,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14 * htio,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        height: 1.50 * htio,
                    ),
                  ),
                  Container( // tier
                      padding: EdgeInsets.symmetric(horizontal: 6 * wtio, vertical: 1 * htio),
                      decoration: ShapeDecoration(
                          color: const Color(0x33FAA131),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 10 * wtio,
                          children: [
                              Text(
                                  '${feed.tier}',
                                  style: TextStyle(
                                      color: const Color(0xFFFAA131),
                                      fontSize: 10 * htio,
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
              spacing: 2 * wtio,
              children: [
                  Text(
                    feed.category,
                    style: TextStyle(
                        color: const Color(0xFF777777),
                        fontSize: 12 * htio,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        height: 1.50 * htio,
                    ),
                  ),
                  dot(htio),
                  Text(
                    feed.viewDttm,
                    style: TextStyle(
                        color: const Color(0xFF777777),
                        fontSize: 12* htio,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        height: 1.50* htio,
                    ),
                  ),
                  dot(htio),
                  Text(
                      '조회수 ${feed.views}',
                      style: TextStyle(
                          color: const Color(0xFF777777),
                          fontSize: 12* htio,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w400,
                          height: 1.50* htio,
                      ),
                  ),
              ],
          ),
      ],
  );
  }

  Text dot(double htio) {
    return Text(
        '·',
        style: TextStyle(
            color: const Color(0xFF777777),
            fontSize: 12 * htio,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w400,
            height: 1.50 * htio,
        ),
    );
  }

  Widget profileImage(String? imageUrl, double wtio, double htio) {
    return Container(
      width: 40 * wtio,
      height: 40 * htio,
      margin: EdgeInsets.only(right: 10 *  wtio),
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