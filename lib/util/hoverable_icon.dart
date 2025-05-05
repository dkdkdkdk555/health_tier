import 'package:flutter/material.dart';

class HoverableIcon extends StatefulWidget {
  const HoverableIcon({
    super.key, 
    this.onTap,
    required this.icon,
    this.originColor,
    this.changedColor
  });

  final VoidCallback? onTap;
  final Color? originColor;
  final Color? changedColor;
  final IconData icon;

  @override
  State<HoverableIcon> createState() => _HoverableIconState();
}

class _HoverableIconState extends State<HoverableIcon> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => setState(() {
        _hovering = true;
      }),
      onTapUp: (details) => setState(() {
        _hovering = false;
      }),
      onTapCancel: () {
        setState(() {
          _hovering = false;
        });
      },
      onTap: widget.onTap,
      child: Icon(
        widget.icon,
        color: _hovering ? widget.changedColor : widget.originColor,
      ),
    );
  }
}
