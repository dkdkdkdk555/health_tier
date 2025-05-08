import 'package:my_app/model/stc/chart_common_model.dart';

class FatModel implements ChartData{
  @override
  final String day;
  final double fat;

  FatModel({required this.day, required this.fat});
  
  @override
  double get value => fat;
}