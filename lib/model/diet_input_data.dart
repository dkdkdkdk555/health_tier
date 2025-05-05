import 'package:flutter/material.dart';

class DietInputData {
  TextEditingController mealType = TextEditingController();
  TextEditingController dietText = TextEditingController();
  TextEditingController calorie = TextEditingController();
  TextEditingController protein = TextEditingController();

  DietInputData(
    {
      required this.mealType,
      required this.dietText,
      required this.calorie,
      required this.protein,
    }
  );

  DietInputData.def();

  bool get isEmpty =>
      (mealType.text == '') &&
      (dietText.text == '') &&
      (calorie.text == '') &&
      (protein.text == '');
}
