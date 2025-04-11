import 'package:flutter/material.dart';

class DocCalendarBody extends StatefulWidget {
  const DocCalendarBody({super.key});

  @override
  State<DocCalendarBody> createState() => _DocCalendarBodyState();
}

class _DocCalendarBodyState extends State<DocCalendarBody> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          flex: 201,
          child: Container(
            color: Color(0xFFF5F5F5)
          )
        ),
        Expanded(
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
        ),
      ],
    );
  }
}