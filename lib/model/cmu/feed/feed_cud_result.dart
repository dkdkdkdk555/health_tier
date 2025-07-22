enum FeedCudType { create, update }

class FeedCudResult {
  final FeedCudType type;
  final int? feedId; // 생성 시 할당될 ID, 수정 시는 입력된 ID
  final String message;

  FeedCudResult({required this.type, this.feedId, required this.message});
}