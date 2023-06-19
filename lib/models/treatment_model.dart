import 'package:flutter/material.dart';

class TreatmentModel {
  String procedure, note, discountSymbol, id;
  double cost, discount, total;
  int unit;

  TreatmentModel({
    required this.procedure,
    required this.note,
    required this.discount,
    required this.discountSymbol,
    required this.total,
    required this.cost,
    required this.unit,
    required this.id,
  });
}
