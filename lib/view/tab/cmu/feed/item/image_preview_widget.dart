import 'package:flutter/material.dart';

class ImagePreviewWidget extends StatelessWidget {
  final String imgPreview;
  final double htio;
  final double wtio;
  const ImagePreviewWidget({
    super.key, 
    required this.imgPreview,
    required this.htio,
    required this.wtio,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70 * wtio,
      height: 70 * htio,
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