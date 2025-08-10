
class ScrollResponse<T> {
  final List<T> items;
  final int? lastCursorId;
  final bool hasNext;

  ScrollResponse({required this.items, required this.lastCursorId, required this.hasNext});

  factory ScrollResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    return ScrollResponse<T>(
      items: (json['items'] as List<dynamic>)
              .map((item) => fromJsonT(item as Map<String, dynamic>))
              .toList(),
      lastCursorId: json['lastCursorId'],
      hasNext: json['hasNext'] ?? false,
    );
  }

  // copyWith 메서드 추가
  ScrollResponse<T> copyWith({
    List<T>? items,
    int? lastCursorId,
    bool? hasNext,
  }) {
    return ScrollResponse<T>(
      items: items ?? this.items,
      lastCursorId: lastCursorId ?? this.lastCursorId,
      hasNext: hasNext ?? this.hasNext,
    );
  }
}