import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

Widget titleDescContent({
  required String title,
  required String description,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 21,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      ],
    ),
  );
}

TargetFocus buildTarget({
  required String id,
  required GlobalKey key,
  required ContentAlign align,
  required Widget Function(BuildContext, TutorialCoachMarkController) builder,
  Alignment alignSkip = Alignment.topRight,
  bool enableOverlayTab = true,
  Duration? focusDuration,
  Duration? unFocusDuration,
  ShapeLightFocus? shape,
}) {
  return TargetFocus(
    identify: id,
    keyTarget: key,
    alignSkip: alignSkip,
    enableOverlayTab: enableOverlayTab,
    focusAnimationDuration: focusDuration,
    unFocusAnimationDuration: unFocusDuration,
    shape: shape,
    contents: [
      TargetContent(
        align: align,
        builder: builder,
      ),
    ],
  );
}