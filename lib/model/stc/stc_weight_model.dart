import 'package:my_app/model/stc/chart_common_model.dart';

class WeightModel implements ChartData{
  @override
  final String day;
  final double weight;

  WeightModel({required this.day, required this.weight});
  
  @override
  double get value => weight;
}