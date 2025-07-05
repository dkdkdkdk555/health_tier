
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
}