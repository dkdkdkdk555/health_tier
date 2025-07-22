import 'package:dio/dio.dart';

class ImageUploadArgs {
  final List<MultipartFile> images;
  final List<String>? deleteUrls;

  ImageUploadArgs({
    required this.images,
    this.deleteUrls,
  });

  // Equatable 또는 == 및 hashCode 오버라이딩을 통해 고유성 보장 (선택 사항이지만 권장)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ImageUploadArgs &&
           listEquals(images, other.images) && // listEquals 헬퍼 함수 필요
           listEquals(deleteUrls, other.deleteUrls);
  }

  @override
  int get hashCode => Object.hash(Object.hashAll(images), Object.hashAll(deleteUrls ?? []));
}

// List 비교를 위한 간단한 헬퍼 함수 (Dart Collection 패키지의 listEquals 사용 권장)
bool listEquals<T>(List<T>? a, List<T>? b) {
  if (a == b) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}