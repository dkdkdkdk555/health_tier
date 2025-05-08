import 'package:flutter/foundation.dart';

@immutable
class DayRange {
  final String startDay;
  final String endDay;

  const DayRange(this.startDay, this.endDay);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayRange &&
          startDay == other.startDay &&
          endDay == other.endDay;

  @override
  int get hashCode => startDay.hashCode ^ endDay.hashCode;
}
