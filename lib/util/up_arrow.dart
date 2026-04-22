import 'package:flutter/material.dart';

class UpArrowIndicator extends StatefulWidget {
  final int durationTime;
  final Color color;
  const UpArrowIndicator({
    super.key,
    this.durationTime = 2200,
    this.color = Colors.grey
  });

  @override
  State<UpArrowIndicator> createState() => _UpArrowIndicatorState();
}

class _UpArrowIndicatorState extends State<UpArrowIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.durationTime),
    )..repeat(reverse: true);

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -0.2),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Icon(
        Icons.keyboard_double_arrow_up_outlined,
        size: 32,
        color: widget.color,
      ),
    );
  }
}
