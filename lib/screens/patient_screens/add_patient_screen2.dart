import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../custom_widgets/patient_dropdown.dart';
import '../../custom_widgets/patient_text_field.dart';

class AddPatientScreen2 extends StatefulWidget {
  AddPatientScreen2({required this.updateData});
  Function updateData;

  @override
  State<AddPatientScreen2> createState() => _AddPatientScreen2State();
}

class _AddPatientScreen2State extends State<AddPatientScreen2> {

  String phone1 = '', phone2 = '', language = '', email = '', streetAddress = '', locality = '', city = '', pincode = '';
  Map<String, String>? data;

  updateData(){
    data = {
      'phoneNumber1' : phone1,
      'phoneNumber2' : phone2,
      'language' : language,
      'email' : email,
      'streetAddress' : streetAddress,
      'locality' : locality,
      'city' : city,
      'pincode' : pincode,
    };
    widget.updateData(data);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            PatientTextField(title: 'Primary phone no.: ', onChanged: (value){
              setState(() {
                phone1 = value;
                updateData();
              });
            }, inputType: TextInputType.number,),
            SizedBox(height: 16,),
            PatientTextField(title: 'Secondary phone no.: ', onChanged: (value){
              setState(() {
                phone2 = value;
                updateData();
              });
            }, inputType: TextInputType.number,),
            SizedBox(height: 16,),
            PatientDropDown(title: 'Language', list: [
              DropDownValueModel(name: 'English', value: 'English'),
              DropDownValueModel(name: 'Hindi', value: 'Hindi'),
              DropDownValueModel(name: 'Konkani', value: 'Konkani'),
              DropDownValueModel(name: 'Marathi', value: 'Marathi'),
            ], onChanged: (value){
              DropDownValueModel val = value;
               setState(() {
                language = val.name;
                updateData();
              });
            }),
            SizedBox(height: 16,),
            PatientTextField(title: 'Email Address', inputType: TextInputType.emailAddress, onChanged: (value){
              setState(() {
                email = value;
                updateData();
              });
            }),
            SizedBox(height: 16,),
            PatientTextField(title: 'Street Address: ', onChanged: (value){
              setState(() {
                streetAddress = value;
                updateData();
              });
            }),
            SizedBox(height: 16,),
            PatientTextField(title: 'Locality', onChanged: (value){
              setState(() {
                locality = value;
                updateData();
              });
            }),
            SizedBox(height: 16,),
            PatientTextField(title: 'City', onChanged: (value){
              setState(() {
                city = value;
                updateData();
              });
            }),
            SizedBox(height: 16,),
            PatientTextField(title: 'Pincode', inputType: TextInputType.number, onChanged: (value){
              setState(() {
                pincode = value;
                updateData();
              });
            },),
          ],
        ),
      ),
    );
  }
}
