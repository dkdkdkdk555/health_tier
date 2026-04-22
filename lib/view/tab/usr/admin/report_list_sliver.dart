import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/extension/cmu_invalidate_collect.dart' show CmuInvalidateCollect;
import 'package:my_app/model/cmu/common/result.dart';
import 'package:my_app/model/usr/admin/feed_report_model.dart' show FeedReportModel;
import 'package:my_app/model/usr/admin/reply_report_model.dart' show ReplyReportModel;
import 'package:my_app/model/usr/admin/report_action_request.dart';
import 'package:my_app/model/usr/user/ht_user_block_dto.dart';
import 'package:my_app/providers/user_cud_providers.dart';
import 'package:my_app/util/dialog_utils.dart';
import 'package:my_app/util/spinner_utils.dart' show AppLoadingIndicator;
import 'package:my_app/util/user_prefs.dart' show UserPrefs;
import 'package:my_app/view/common/error_widget.dart';

class ReportListSliver extends ConsumerStatefulWidget {
  final String topic;
  const ReportListSliver({
    super.key,
    required this.topic
  });

  @override
  ConsumerState<ReportListSliver> createState() => _ReportListSliverState();
}

class _ReportListSliverState extends ConsumerState<ReportListSliver> {
  // 피드 신고 리스트
  List<FeedReportModel> feedReportList = [];
  // 댓글 신고 리스트
  List<ReplyReportModel> replyReportList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final topicHangle = widget.topic == 'feed' ? '피드' : '댓글';
    // 목록 가져오기
    final reportListAsync = topicHangle == '피드'
      ? ref.watch(feedReportedListProvider)
      : ref.watch(replyReportedListProvider);

    return reportListAsync.when(
      data: (result) {
        final list = result.data;
        late int totalCount;
        // 초기 로딩 시 한 번만 저장
        if (topicHangle == '피드') {
          feedReportList = List.from(list);
          totalCount = feedReportList.length;
        } else {
          replyReportList = List.from(list);
          totalCount = replyReportList.length;
        }

        // 리스트 없는 경우 → SliverToBoxAdapter 직접 반환
        if (totalCount == 0) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Text(
                  '$topicHangle 신고건이 없습니다.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
            ),
          );
        }

        // 신고건이 있는 경우 → SliverList 반환
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 헤더
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "총 $totalCount건의 처리되지 않은 신고가 있어요.",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    _buildReportItem(context, topicHangle=='피드' ? 
                      feedReportList[index] : replyReportList[index]
                    ),
                  ],
                );
              }
              return _buildReportItem(context, topicHangle=='피드' ? 
                feedReportList[index] : replyReportList[index]
              );
            },
            childCount: totalCount,
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: AppLoadingIndicator(),
          ),
        ),
      ),
      error: (err, stack) => const SliverToBoxAdapter(
        child: ErrorContentWidget(
          mainText: '신고 목록을 불러오는 중 오류가 발생했습니다.',
        ),
      ),
    );
  }

  Widget _buildReportItem(BuildContext context, Object item) {
    final bool isFeed = item is FeedReportModel;

    final String reporterNickname =
        isFeed ? item.reporterNickname : (item as ReplyReportModel).reporterNickname;
    final String writerNickname =
        isFeed ? item.writerNickname : (item as ReplyReportModel).writerNickname;
    final String reason =
        isFeed ? item.reason : (item as ReplyReportModel).reason;
    final String createDttm =
        isFeed ? item.createDttm : (item as ReplyReportModel).createDttm;
    final int cmuId = 
        isFeed ? item.cmuId : (item as ReplyReportModel).cmuId;

    final Widget content =
        isFeed ? _buildFeedContent(item)
              : _buildReplyContent(item as ReplyReportModel);

    final int reportId =
        isFeed ? (item).reportId : (item as ReplyReportModel).reportId;

    return GestureDetector(
      onTap: () {
        context.push('/cmu/feed/$cmuId');
      },
      child: _buildSlidableReportItem(
        context: context,
        key: ValueKey('${isFeed ? 'feed' : 'reply'}_$reportId'),
        reportId: reportId,
        isFeed: isFeed,
        reporterNickname: reporterNickname,
        writerNickname: writerNickname,
        reason: reason,
        createDttm: createDttm,
        content: content,
      ),
    );
  }

  Widget _buildSlidableReportItem({
    required BuildContext context,
    required Key key,
    required int reportId,
    required bool isFeed,
    required String reporterNickname,
    required String writerNickname,
    required String reason,
    required String createDttm,
    required Widget content,
  }) {
    final String dateText =
        createDttm.length >= 10 ? createDttm.substring(0, 10) : createDttm;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Slidable(
        key: key,
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (ctx) async{
                await showAppDialog(context, message: '유지 처리 하시겠습니까?', 
                  confirmText: '확인',
                  cancelText: '취소',
                  onCancel: () {
                    Navigator.pop(context); // 바텀 시트 닫기
                  },
                  onConfirm: () {
                    _doActionReport(reportId, '유지', isFeed, null);
                  }
                );
              },
              backgroundColor: Colors.grey.shade300,
              foregroundColor: Colors.black87,
              label: '유지',
            ),
            SlidableAction(
              onPressed: (ctx) async{
                await showAppDialog(context, message: '경고 처리 하시겠습니까?', 
                  confirmText: '확인',
                  cancelText: '취소',
                  onCancel: () {
                    Navigator.pop(context); // 바텀 시트 닫기
                  },
                  onConfirm: () {
                    _doActionReport(reportId, '경고', isFeed, null);
                  }
                );
              },
              backgroundColor: Colors.orange.shade400,
              foregroundColor: Colors.white,
              label: '경고',
            ),
            SlidableAction(
              onPressed: (ctx) async{
                final reason = await showInputDialog(
                  context,
                  title: "삭제 사유를 입력해주세요",
                  hintText: "자세한 삭제 사유를 작성해주세요.",
                  confirmText: "삭제하기",
                  cancelText: "취소",
                  minLines: 3,
                  maxLines: 5,
                  maxLength: 200,
                );

                if(reason != null) {
                  _doActionReport(reportId, '삭제', isFeed, reason);
                }
              },
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              label: '삭제',
            ),
          ],
        ),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16.0),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '신고자: $reporterNickname',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  dateText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '작성자: $writerNickname',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '신고 사유',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reason.isEmpty ? '(사유 없음)' : reason,
                  style: const TextStyle(
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                // 여기부터는 피드/댓글 각각의 내용
                content,
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _doActionReport(int reportId, String action, bool isFeed, String? deleteReason) async{
    final service = await ref.read(userCudServiceProvider.future);
    try {
      final request = ReportActionRequest(
        reportId: reportId, 
        action: action, 
        reason: deleteReason
      );
      // 신고조치 API 호출
      final result = isFeed ? await service.handleFeedReport(request)
                    : await service.handleReplyReport(request);

      if(result == "success") {
        // 캐시비우기 => UI 즉각반영
        if(isFeed) {
          ref.invalidate(feedReportedListProvider);
        } else {
          ref.invalidate(replyReportedListProvider);
        }

        // 안내 메세지
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("신고조치 완료")),);
      }
    } catch(e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("처리 실패: $e")),);
    }
  }

  Widget _buildFeedContent(FeedReportModel item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title.isEmpty ? '(제목 없음)' : item.title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          item.ctntPreview,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black87,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildReplyContent(ReplyReportModel item) {
    return Text(
      item.replyCtnt.isEmpty ? '(내용 없음)' : item.replyCtnt,
      style: const TextStyle(
        fontSize: 13,
        color: Colors.black87,
      ),
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
    );
  }
}
