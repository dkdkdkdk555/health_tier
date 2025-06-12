class Result<T> {
  final T data;
  final int count;
  final String message;

  Result({required this.data, required this.count, required this.message});

  factory Result.fromJson(Map<String, dynamic> json, T Function(Object? json) fromJsonT) {
    return Result(
      data: fromJsonT(json['data']),
      count: json['count'],
      message: json['message'] ?? '',
    );
  }
}