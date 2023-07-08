import 'package:age_calculator/age_calculator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/providers/add_patient_provider.dart';
import 'package:googleapis/connectors/v1.dart';
// import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';
import '../../custom_widgets/patient_dropdown.dart';
import '../../custom_widgets/patient_text_field.dart';
import 'package:provider/provider.dart' as pro;

class AddPatientScreen1 extends StatefulWidget {
  AddPatientScreen1({required this.updateData, this.status = 'normal'});
  String status;
  Function updateData;

  @override
  State<AddPatientScreen1> createState() => _AddPatientScreen1State();
}

class _AddPatientScreen1State extends State<AddPatientScreen1> {
  String gender = '';
  String patientName = '',
      patientId = '',
      dob = '';
  Map<String, String>? data;
  DateTime? pickedDate;
  TextEditingController dobController = TextEditingController();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String uid = '';
  bool isLoading = false;
  FirebaseAuth auth = FirebaseAuth.instance;
  String phone1 = '', streetAddress = '', email = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    uid = auth.currentUser!.uid;
    if(widget.status == 'normal')
      getName();
    getDetails();
    WidgetsBinding.instance.addPostFrameCallback((_) => updateData());

  }

  getDetails() async {
    try {
      final data = await firestore.collection('Patients').doc(uid).get();
      setState(() {
        gender = data['gender'];
        dobController.text = data['dob'];
        phone1 = data['phoneNumber'];
        email = data['email'];
        streetAddress = data['streetAddress'];
      });
    }
    catch(e){
      print(e);
    }
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
        'gender': gender,
        'dob': dob!,
        'phoneNumber' : phone1,
        'email' : email,
        'streetAddress' : streetAddress,
      };
    });

    widget.updateData(data);
  }

  @override
  Widget build(BuildContext context) {
    var pm = pro.Provider.of<AddPatientProvider>(context).pm;
    patientName = pm.patientName;
    gender = pm.gender;
    dobController.text = pm.dob;
    dob = pm.dob;
    email = pm.email;
    phone1 = pm.phoneNumber1;
    streetAddress = pm.streetAddress;


    return Container(
      child: isLoading ? Center(child: CircularProgressIndicator(color: kPrimaryColor,),) : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Fields marked with * are mandatory to be filled", style: TextStyle(color: kGrey),),
            SizedBox(height: 16,),
            PatientTextField(
                title: 'Patient Name*: ',
                onChanged: (value) {
                  setState(() {
                    patientName = value;
                    updateData();
                  });
                }, inputValue: patientName.toString(), readOnly: (widget.status == 'normal'),),
            SizedBox(
              height: 32,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Gender*: ',
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
              height: 32,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Date of birth*: ',
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
                            firstDate:DateTime(1900), //DateTime.now() - not to allow to choose before today.
                            lastDate: DateTime(2101)
                        );

                        if (pickedDate != null) {
                        setState(() {
                          print(pickedDate);
                          dob = DateFormat('yyyy-MM-dd').format(pickedDate!);
                          // DateTime dateTime = DateTime(pickedDate!.year,
                          //     pickedDate!.month, pickedDate!.day);
                          // ageController.text = AgeCalculator
                          //     .age(dateTime)
                          //     .years
                          //     .toString();
                          dobController.text = dob!;
                        });

                        }
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
            PatientTextField(title: 'Phone no.*: ', onChanged: (value){
              setState(() {
                phone1 = value;
                updateData();
              });
            }, inputType: TextInputType.number, inputValue: phone1,),
            SizedBox(height: 32,),
            PatientTextField(title: 'Email Address', inputType: TextInputType.emailAddress, onChanged: (value){
              setState(() {
                email = value;
                updateData();
              });
            }, inputValue: email,),
            SizedBox(height: 32,),
            PatientTextField(title: 'Address: ', onChanged: (value){
              setState(() {
                streetAddress = value;
                updateData();
              });
            }, inputValue: streetAddress,),
            SizedBox(height: 32,),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Expanded(
            //       child: Text(
            //         'Age: ',
            //         style: TextStyle(color: kGrey, fontSize: 16),
            //       ),
            //     ),
            //     SizedBox(width: 16,),
            //     // Expanded(
            //     //   flex: 2,
            //     //   child: TextField(
            //     //     onChanged: (value) {
            //     //       // widget.onChanged(value);
            //     //     },
            //     //     controller: ageController,
            //     //     readOnly: true,
            //     //     decoration: InputDecoration(
            //     //       hintText: 'Age',
            //     //       border: OutlineInputBorder(
            //     //         borderSide: BorderSide(color: Colors.black),
            //     //       ),
            //     //     ),
            //     //   ),
            //     // ),
            //   ],
            // ),
            SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }
}
