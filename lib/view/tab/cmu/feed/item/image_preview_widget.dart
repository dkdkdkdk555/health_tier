import 'package:flutter/material.dart';

class ImagePreviewWidget extends StatelessWidget {
  final String imgPreview;
  const ImagePreviewWidget({super.key, required this.imgPreview});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: ShapeDecoration(
        image: DecorationImage(
          image: NetworkImage(imgPreview),
          fit: BoxFit.cover,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}