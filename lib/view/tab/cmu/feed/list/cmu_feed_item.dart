import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/model/cmu/feed/badge_info_dto.dart';
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
                    profileImage(feed.userImgPath, feed.badges, htio, wtio),
                    feedProfile(feed.badges, htio, wtio)
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if((feed.imgPreview == null || feed.imgPreview!.isEmpty) && feed.videoExist != 'Y')... {
                    title(htio),
                    ctntPreview(htio)
                  } else if((feed.imgPreview == null || feed.imgPreview!.isEmpty) && feed.videoExist == 'Y')... {
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
                        videoExist(htio, wtio)
                      ],
                    ),
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

  Widget imagePreview(double htio, double wtio) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 70 * htio,
          height: 70 * htio,
          alignment: Alignment.topCenter,
          decoration: ShapeDecoration(
              image: DecorationImage(
                  image: NetworkImage('${feed.imgPreview}'),
                  fit: BoxFit.cover,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        if (feed.videoExist == 'Y')
        Container(
          width: 28 * htio,
          height: 28 * htio,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black54, // 반투명 배경
          ),
          child: const Icon(
            Icons.play_arrow,
            color: Colors.white,
            size: 20,
          ),
        ),
      ]
    );
  }

  Widget videoExist(double htio, double wtio) {
    return SizedBox(
      width: 70 * htio,
      height: 70 * htio,
      child: Center(
        child: Container(
          width: 28 * htio,
          height: 28 * htio,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black54, // 반투명 배경
          ),
          child: const Icon(
            Icons.play_arrow,
            color: Colors.white,
            size: 20,
          ),
        ),
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
          maxLines: 2,
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

  Column feedProfile(List<BadgeInfoDto>? badges, double htio, double wtio) {
    final weightBadge = badges==null ? BadgeInfoDto(badgeId: '', badgeName: '', badgeType: '') : badges
        .firstWhere(
          (badge) => badge.badgeType == 'weight',
          orElse: () => BadgeInfoDto(badgeId: '', badgeName: '', badgeType: ''),
        );

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
                  Text(
                    feed.nickName,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14 * htio,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        height: 1.50 * htio,
                    ),
                  ),
                  if (weightBadge.badgeId.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(left: 2 * wtio),
                    child: SvgPicture.asset(
                      height: 19 * htio,
                      'assets/widgets/${weightBadge.badgeId}.svg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox.shrink();
                      },
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

  Widget profileImage(String? imageUrl, List<BadgeInfoDto>? badges, double htio, double wtio) {
    final todayBadge = badges==null ? BadgeInfoDto(badgeId: '', badgeName: '', badgeType: '') : badges
        .firstWhere(
          (badge) => badge.badgeType == 'today',
          orElse: () => BadgeInfoDto(badgeId: '', badgeName: '', badgeType: ''),
        );
    
    return Container(
      width: 40 * htio,
      height: 40 * htio,
      margin: EdgeInsets.only(right: 10 *  wtio),
      child: Stack(
        children: [
          // 프로필 이미지
          Container(
            width: 40 * wtio,
            height: 40 * htio,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipOval(
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
            ),
          ),

          // 오늘 뱃지 표시
          if (todayBadge.badgeId.isNotEmpty)
            Positioned.fill(
              child: SvgPicture.asset(
                'assets/widgets/${todayBadge.badgeId}.svg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
        ],
      ),
    );
  }
}