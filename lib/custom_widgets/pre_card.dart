import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/models/pre_model.dart';

import '../constants.dart';


class PreCard extends StatelessWidget {

  PreCard({required this.pm});
  PreModel pm;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(border: Border.all(color: kGrey), borderRadius: BorderRadius.circular(12),),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${pm.title}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
            SizedBox(height: 8,),
            Text('${pm.des}'),
          ],
        ),
      ),
    );;
  }
}
