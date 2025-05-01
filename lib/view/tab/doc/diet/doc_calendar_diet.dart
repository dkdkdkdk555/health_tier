import 'package:flutter/material.dart';

class DocCalendarDiet extends StatefulWidget {
  const DocCalendarDiet({super.key});

  @override
  State<DocCalendarDiet> createState() => _DocCalendarDietState();
}

class _DocCalendarDietState extends State<DocCalendarDiet> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex:128,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
        ),
      ),
    );
  }
}