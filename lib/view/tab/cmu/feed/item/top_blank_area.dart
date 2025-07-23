import 'package:flutter/material.dart';

class TopBlankArea extends StatelessWidget {
  const TopBlankArea({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      primary: false,
      toolbarHeight: 44,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(color: Colors.white),
      )
    );
  }
}