import 'package:drift/drift.dart';

class DayDietModel {
  final int id;
  final String day;
  final String title;
  final String? diet;
  final double? calorie;
  final double? protein;

  DayDietModel({
    required this.id,
    required this.day,
    required this.title,
    this.diet,
    this.calorie,
    this.protein,
  });

   factory DayDietModel.fromRow(QueryRow row) {
      return DayDietModel(
        id: row.readNullable<int>('id') ?? 0, // ← 여기 'id' (소문자!)
        day: row.read<String>('day'),
        title: row.read<String>('title'),
        diet: row.readNullable<String>('diet'),
        calorie: row.readNullable<double>('calorie'),
        protein: row.readNullable<double>('protein'),
      );
    }
}
