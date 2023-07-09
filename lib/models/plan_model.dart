import 'package:flutter/material.dart';

class PlanModel{

  String title;
  List<dynamic> toothList = [];
  bool isChecked;

  PlanModel({required this.title, required this.toothList, this.isChecked = false});
}