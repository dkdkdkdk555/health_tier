import 'package:flutter/material.dart';

class DocBodyDetail extends StatelessWidget {
  const DocBodyDetail({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 148,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(47)),
          border: Border(
            left: BorderSide(width: 2 ,color: Color(0xFFEEEEEE)),
            top: BorderSide(width: 2, color: Color(0xFFEEEEEE)),
            right: BorderSide(width: 2, color: Color(0xFFEEEEEE)),
            bottom: BorderSide(color: Color(0xFFEEEEEE)),
          ),
        ),
      )
    );
  }
}