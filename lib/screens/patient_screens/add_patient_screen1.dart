import 'package:age_calculator/age_calculator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';
import '../../custom_widgets/patient_dropdown.dart';
import '../../custom_widgets/patient_text_field.dart';

class AddPatientScreen1 extends StatefulWidget {
  AddPatientScreen1({required this.updateData, this.model});
  String? model;
  Function updateData;

  @override
  State<AddPatientScreen1> createState() => _AddPatientScreen1State();
}

class _AddPatientScreen1State extends State<AddPatientScreen1> {
  String gender = '';
  String? patientName = '',
      patientId = '',
      aadharId = '',
      dob = '',
      age = '',
      bloodGrp = '',
      anniversary = '';
  Map<String, String>? data;
  DateTime? pickedDate;
  TextEditingController dobController = TextEditingController();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String uid = '';
  bool isLoading = false;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    uid = auth.currentUser!.uid;
    if (widget.model == null) {

    }
    getName();
  }

  getName() async {

    setState(() {
      isLoading = true;
    });
    final data = await firestore.collection('Users').doc(uid).get();

    // SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      // patientName = pref.getString('name');
      patientName = data['name'];
      isLoading = false;

    });
    print(patientName);
  }

  updateData() {
    setState(() {
      data = {
        'patientName': patientName!,
        'patientId': patientId!,
        'aadharId': aadharId!,
        'gender': gender,
        'anniversary': anniversary!,
        'dob': dob!,
        'age': age!,
        'bloodGrp': bloodGrp!,
      };
    });

    widget.updateData(data);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: isLoading ? Center(child: CircularProgressIndicator(color: kPrimaryColor,),) : SingleChildScrollView(
        child: Column(
          children: [
            PatientTextField(
                title: 'Patient Name: ',
                onChanged: (value) {
                  setState(() {
                    patientName = value;
                    updateData();
                  });
                }, inputValue: patientName.toString(), readOnly: true,),
            SizedBox(
              height: 16,
            ),
            // PatientTextField(
            //     title: 'Patient ID: ',
            //     onChanged: (value) {
            //       setState(() {
            //         patientId = value;
            //         updateData();
            //       });
            //     }, inputType: TextInputType.number,),
            // SizedBox(
            //   height: 16,
            // ),
            PatientTextField(
              title: 'Aadhar ID: ',
              onChanged: (value) {
                setState(() {
                  aadharId = value;
                  updateData();
                });
              },
              inputType: TextInputType.number,
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Gender: ',
                    style: TextStyle(color: kGrey, fontSize: 16),
                  ),
                ),
                Expanded(
                  child: RadioMenuButton(
                    value: 'male',
                    groupValue: gender,
                    onChanged: (newValue) {
                      setState(() {
                        gender = newValue.toString();
                        updateData();
                      });
                    },
                    child: Text('Male'),
                  ),
                ),
                Expanded(
                  child: RadioMenuButton(
                    value: 'female',
                    groupValue: gender,
                    onChanged: (newValue) {
                      setState(() {
                        gender = newValue.toString();
                        updateData();
                      });
                    },
                    child: Text('Female'),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Date of birth: ',
                    style: TextStyle(color: kGrey, fontSize: 16),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    child: TextField(
                      controller: dobController,
                      onTap: () async {

                        DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(), //get today's date
                            firstDate:DateTime(2000), //DateTime.now() - not to allow to choose before today.
                            lastDate: DateTime(2101)
                        );

                        if (pickedDate != null) {
                        setState(() {
                          dob = DateFormat('yyyy-MM-dd').format(pickedDate!);
                          DateTime dateTime = DateTime(pickedDate!.year,
                              pickedDate!.month, pickedDate!.day);
                          age = AgeCalculator
                              .age(dateTime)
                              .years
                              .toString();
                          print(age);
                          dobController.text = dob!;
                        });

                        }
                        print(age);
                        updateData();
                      },
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'Tap to select',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            PatientTextField(
                title: 'Anniversary',
                onChanged: (value) {
                  setState(() {
                    anniversary = value;
                    updateData();
                  });
                }),
            SizedBox(
              height: 16,
            ),
            PatientDropDown(
                title: 'Blood group',
                list: [
                  DropDownValueModel(name: 'A+', value: 'A+'),
                  DropDownValueModel(name: 'A-', value: 'A-'),
                  DropDownValueModel(name: 'B+', value: 'B+'),
                  DropDownValueModel(name: 'B-', value: 'B-'),
                  DropDownValueModel(name: 'O+', value: 'O+'),
                  DropDownValueModel(name: 'O-', value: 'O-'),
                  DropDownValueModel(name: 'AB+', value: 'AB+'),
                  DropDownValueModel(name: 'AB-', value: 'AB-'),
                ],
                onChanged: (value) {
                  DropDownValueModel val = value;
                  setState(() {
                    bloodGrp = val.name;
                    updateData();
                  });
                }),
          ],
        ),
      ),
    );
  }
}
