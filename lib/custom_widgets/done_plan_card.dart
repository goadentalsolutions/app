import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:goa_dental_clinic/custom_widgets/custom_button.dart';
import 'package:goa_dental_clinic/custom_widgets/fixed_sized_tooth.dart';
import 'package:goa_dental_clinic/models/patient_model.dart';
import 'package:goa_dental_clinic/models/plan_model.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/calendar_screen2.dart';

class DonePlanCard extends StatelessWidget {
  DonePlanCard({required this.plan, required this.toothList, required this.pm});
  String plan;
  PatientModel pm;
  List<dynamic> toothList;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(12),),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${plan}'),
              SizedBox(height: 8,),
              Wrap(
                children: toothList.map((e) {
                  return FixedSizeTooth(
                    index: e,
                    onTap: () {},
                    height: 40,
                    width: 40,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
