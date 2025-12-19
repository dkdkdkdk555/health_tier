import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:my_app/model/stc/day_range_param.dart' show DayRange;
import 'package:my_app/providers/db_providers.dart';

class StcInvalidator {
  StcInvalidator();

  void stcInvalidate(WidgetRef ref) {
    DateTime startDate = DateTime.now().subtract(const Duration(days: 365));
    DateTime endDate = DateTime.now();
    DayRange invalidateDayRange = DayRange(
      DateFormat('yyyy-MM-dd').format(startDate),
      DateFormat('yyyy-MM-dd').format(endDate),
    );

    ref.invalidate(selectWeightList(invalidateDayRange));
    ref.invalidate(selectMuscleList(invalidateDayRange));
    ref.invalidate(selectFatList(invalidateDayRange));
    ref.invalidate(selectStampList(invalidateDayRange));
  }

}