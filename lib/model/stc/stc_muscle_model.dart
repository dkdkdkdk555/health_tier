import 'package:my_app/model/stc/chart_common_model.dart';

class MuscleModel implements ChartData {
  @override
  final String day;
  final double muscle;

  MuscleModel({required this.day, required this.muscle});
  
  @override
  double get value => muscle;
}