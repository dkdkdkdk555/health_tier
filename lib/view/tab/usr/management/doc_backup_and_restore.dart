import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/model/body/doc_detail_model.dart';
import 'package:my_app/model/diet/doc_diet_model.dart';
import 'package:my_app/providers/db_providers.dart';
import 'package:my_app/providers/user_cud_providers.dart';
import 'package:my_app/util/dialog_utils.dart' show showAppDialog;

class DocBackupAndRestore extends ConsumerStatefulWidget {
  const DocBackupAndRestore({
    super.key,
  });

  @override
  ConsumerState<DocBackupAndRestore> createState() => _DocBackupAndRestoreState();
}

class _DocBackupAndRestoreState extends ConsumerState<DocBackupAndRestore> {

  @override
  Widget build(BuildContext context) {
    final backupStatusAsync = ref.watch(backupStatusProvider);
      
    return Padding(
        padding: const EdgeInsets.only(top: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 정보 아이콘과 텍스트
            Row(
              children: [
                const Text(
                  '기록을 안전하게 백업하고 복원하세요.',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () {
                    showAppDialog(context, 
                      title: '📦 기록 옮기기 안내',
                      message: '새로운 기기에서 헬스티어를 사용할 때, 기존 기기의 체중 및 식단 기록을 안전하게 옮길 수 있습니다.\n\n'
                              '백업된 데이터는 24시간 동안 서버에 보관되며, 복원 여부와 관계없이 기간이 지나면 자동 삭제됩니다.\n\n'
                              '데이터를 복원하면 즉시 서버에서 삭제되며, 복원 후 24시간 동안은 다시 기록 옮기기 기능을 이용할 수 없습니다.',
                    );
                  },
                  child: Icon(
                    Icons.info_outline,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
      
            // 상태에 따른 UI 변경
            backupStatusAsync.when(
              data: (status) {
                if (status == "BACKUP_REQUEST") {
                  // 데이터 복원 버튼만
                  return ModernButtonCard(
                    icon: Icons.cloud_download,
                    title: '데이터 복원',
                    subtitle: '이전에 저장했던 기록을 불러옵니다.',
                    color: Colors.blue.shade100,
                    onTap: () async {
                      await showAppDialog(context, 
                        message: '기존 데이터가 사라지고 복구됩니다.\n백업 데이터는 한번 복구하면 다시 복구할 수 없습니다.\n복원하시겠습니까?',
                        confirmText: '확인',
                        cancelText: '취소',
                        onConfirm: () async {
                          if (!context.mounted) return;
                          // 로딩 다이얼로그 표시
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(child: CircularProgressIndicator()),
                          );
                          try {
                            // 1. 서버에서 JSON 문자열 요청
                            final service = await ref.read(userCudServiceProvider.future);
                            String jsonString = await service.requestRestore();
          
                            // 2. JSON 파싱
                            final Map<String, dynamic> backupData = jsonDecode(jsonString);
          
                            // 3. Map -> List<DayDietModel>, List<DocDayDetail> 변환
                            final List<dynamic> dietsJson = backupData['diets'] ?? [];
                            final List<dynamic> bodiesJson = backupData['bodies'] ?? [];
          
                            final diets = dietsJson.map((e) => DayDietModel.fromJson(e as Map<String, dynamic>)).toList();
                            final bodies = bodiesJson.map((e) => DocDayDetail.fromJson(e as Map<String, dynamic>)).toList();
          
                            // 4. 데이터 복원 함수 호출 (기존 데이터 삭제 후 insert)
                            await insertRestoreDayDetailList(ref: ref, list: bodies);
                            await insertRestoreDietList(ref: ref, list: diets);
          
                            if (!context.mounted) return;
                            Navigator.of(context).pop(); // 로딩 닫기
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('데이터 복원이 완료되었습니다.')),
                            );
                            
          
                            // 필요시 provider 새로고침 등 추가 처리
                            ref.invalidate(backupStatusProvider); // 상태 갱신
                            ref.invalidate(getAllHtDayBodyProvider);
                            ref.invalidate(getAllHtDayDietProvider);
                          } catch (e, st) {
                            debugPrint('데이터 복원 실패: $e\n$st');
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('데이터 복원 중 오류가 발생했습니다.')),
                            );
                          }
                        },
                        onCancel: () {
                          return;
                        },
                      );
                    }
                  );
                } else if (status == "NOT_FOUND") {
                  // 데이터 백업 버튼만
                  return ModernButtonCard(
                    icon: Icons.cloud_upload,
                    title: '데이터 백업',
                    subtitle: '현재의 기록을 클라우드에 저장합니다.',
                    color: Colors.amber.shade100,
                    onTap: () async {
                      await showAppDialog(context, 
                        message: '백업된 데이터는 복원 여부와 관계없이 24시간 동안만 보관됩니다.\n데이터 백업을 요청하시겠습니까?',
                        confirmText: '확인',
                        cancelText: '취소',
                        onConfirm: () async {
                          if (!context.mounted) return;
                          // 로딩 다이얼로그 표시
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(child: CircularProgressIndicator()),
                          );
          
                          try {
                            // 1. Drift DB에서 데이터 가져오기
                            final diets = await ref.read(getAllHtDayDietProvider.future);
                            final bodies = await ref.read(getAllHtDayBodyProvider.future);
          
                            // 2. 데이터가 비어있으면 안내 후 종료
                            if (diets.isEmpty && bodies.isEmpty) {
                              if (!context.mounted) return;
                              Navigator.of(context).pop(); // 로딩 닫기
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('백업할 데이터가 없습니다.')),
                              );
                              return;
                            }
          
                            // 3. Map 구조로 변환
                            final backupData = {
                              'diets': diets.map((e) => e.toJson()).toList(),
                              'bodies': bodies.map((e) => e.toJson()).toList(),
                            };
          
                            // 4. JSON 문자열로 변환
                            final backupJson = jsonEncode(backupData);
          
                            // 5. 서버 전송
                            final service = await ref.read(userCudServiceProvider.future);
                            final message = await service.requestBackup(backupJson);
          
                            if (!context.mounted) return;
                            Navigator.of(context).pop(); // 로딩 닫기
          
                            if (message == 'success') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('백업 데이터가 준비되었습니다.')),
                              );
                              ref.invalidate(backupStatusProvider); // 상태 갱신
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('데이터 백업이 실패하였습니다.')),
                              );
                            }
                          } catch (e, st) {
                            debugPrint('백업 데이터 생성 실패: $e\n$st');
                            if (context.mounted) {
                              Navigator.of(context).pop(); // 로딩 닫기
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('백업 중 오류가 발생했습니다.')),
                              );
                            }
                          }
                        },
                        onCancel: () {
                          return;
                        },
                      );
                    }
                  );
                } else if (status == "RESTORE_COMPLETE") {
                  // 안내 문구만
                  return const Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Text(
                      "데이터 복원을 성공하셨습니다.\n24시간 동안은 기록 옮기기 이용이 불가능합니다.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  );
                } else {
                  return const Text("알 수 없는 상태입니다.");
                }
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('오류 발생: $err'),
            ),
          ],
        ),
      // ),
    );
  }
}

// 재사용 가능한 모던 버튼 위젯
class ModernButtonCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const ModernButtonCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(20),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87, size: 30),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.black45, size: 18),
          ],
        ),
      ),
    );
  }
}