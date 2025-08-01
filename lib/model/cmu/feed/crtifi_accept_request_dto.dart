class CrtifiAcceptRequestDto {
  final int userId;
  final int feedId;

  CrtifiAcceptRequestDto({required this.userId, required this.feedId});

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'cmuId': feedId,
      };
}
