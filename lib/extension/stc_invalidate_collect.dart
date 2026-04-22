import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/providers/db_providers.dart';

class StcInvalidator {
  StcInvalidator();

  void stcInvalidate(WidgetRef ref) {
    ref.invalidate(selectWeightList);
    ref.invalidate(selectMuscleList);
    ref.invalidate(selectFatList);
    ref.invalidate(selectStampList);
  }

}