import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

Widget titleDescContent({
  required String title,
  required String description,
  required double htio,
  required double wtio,
}) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 20 * wtio),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 21 * htio,
          ),
        ),
        SizedBox(height: 4 * htio),
        Text(
          description,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15 * htio,
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