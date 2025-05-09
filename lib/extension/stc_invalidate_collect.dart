 import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/providers/db_providers.dart';
import 'package:my_app/view/tab/simple_cache.dart';

class StcInvalidator {
  StcInvalidator();

  void stcInvalidate(WidgetRef ref) {
    ref.invalidate(selectWeightList(cachedDayRange));
    ref.invalidate(selectMuscleList(cachedDayRange));
    ref.invalidate(selectFatList(cachedDayRange));
    ref.invalidate(selectStampList(cachedDayRange));
  }

}