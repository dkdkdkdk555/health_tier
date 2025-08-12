import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return Scaffold(
      backgroundColor: Colors.grey[50], // 배경색을 연한 회색으로 변경
      appBar: AppBar(
        title: const Text(
          '기록 옮기기',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1, // 앱바에 그림자 추가
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
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
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return const AlertDialog(
                            backgroundColor: Colors.white,
                            title: Text(
                              '📦 기록 옮기기 안내',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            content: Padding(
                              padding: EdgeInsets.only(bottom: 10.0),
                              child: Text(
                                '새로운 기기에서 헬스티어를 사용할 때, 기존 기기의 체중 및 식단 기록을 안전하게 옮길 수 있습니다.\n\n'
                                '백업된 데이터는 24시간 동안 서버에 보관되며, 복원 여부와 관계없이 기간이 지나면 자동 삭제됩니다.\n\n'
                                '데이터를 복원하면 즉시 서버에서 삭제되며, 복원 후 24시간 동안은 다시 기록 옮기기 기능을 이용할 수 없습니다.',
                                style: TextStyle(fontSize: 14, height: 1.4),
                              ),
                            ),
                          );
                        },
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
              const SizedBox(height: 30),

              // 데이터 복원 카드
              ModernButtonCard(
                icon: Icons.cloud_download,
                title: '데이터 복원',
                subtitle: '이전에 저장했던 기록을 불러옵니다.',
                color: Colors.blue.shade100,
                onTap: () {
                  // TODO: 데이터 복원 로직 추가
                },
              ),
              const SizedBox(height: 20),

              // 데이터 백업 카드
              ModernButtonCard(
                icon: Icons.cloud_upload,
                title: '데이터 백업',
                subtitle: '현재의 기록을 클라우드에 저장합니다.',
                color: Colors.amber.shade100,
                onTap: () {
                  // TODO: 데이터 백업 로직 추가
                },
              ),
            ],
          ),
        ),
      ),
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