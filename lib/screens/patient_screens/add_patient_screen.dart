
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/classes/alert.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:goa_dental_clinic/custom_widgets/custom_button.dart';
import 'package:goa_dental_clinic/custom_widgets/patient_dropdown.dart';
import 'package:goa_dental_clinic/custom_widgets/patient_text_field.dart';
import 'package:goa_dental_clinic/custom_widgets/text_textfield_dropdown.dart';
import 'package:goa_dental_clinic/custom_widgets/treatment_text_field.dart';
import 'package:goa_dental_clinic/models/patient_model.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/nav_screen.dart';
import 'package:goa_dental_clinic/screens/patient_screens/add_patient_screen4.dart';

import 'add_patient_screen1.dart';
import 'add_patient_screen2.dart';
import 'add_patient_screen3.dart';

class AddPatientScreen extends StatefulWidget {
  AddPatientScreen({this.pm, this.status = 'normal'});
  PatientModel? pm;
  String status;

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  PageController pageController = PageController();
  bool isNextVisible = true;
  bool isPrevVisible = false;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  String uid = '';
  UploadTask? uploadTask;
  var data1, data2;
  List<String> data3 = [];
  File? fi;
  bool isLoading = false;

  uploadData() async {
    try {
      setState(() {
        isLoading = true;
      });
      if (data1 != null) {
        print('cool');
        try {
          await firestore.collection('Patients').doc(uid).set({
            'patientName': data1['patientName'],
            'patientId': data1['patientId'],
            'aadharId': data1['aadharId'],
            'gender': data1['gender'],
            'dob': data1['dob'],
            'age': data1['age'],
            'anniversary': data1['anniversary'],
            'bloodGrp': data1['bloodGrp'],
            'patientUid': uid,
          }, SetOptions(merge: true));
        }
        catch (e) {
          print('$e ada');
        }
      }
      if (data2 != null) {
        print('cool2 $uid');
        try {
          await firestore.collection('Patients').doc(uid).set({
            'phoneNumber1': data2['phoneNumber1'],
            'phoneNumber2': data2['phoneNumber2'],
            'language': data2['language'],
            'email': data2['email'],
            'streetAddress': data2['streetAddress'],
            'locality': data2['locality'],
            'pincode': data2['pincode'],
            'city': data2['city'],
          }, SetOptions(merge: true));
        }
        catch (e) {
          print(e);
        }
      }

      if (data3.isNotEmpty || data3 != null) {
        print('reached2');
        for (var disease in data3) {
          await firestore.collection('Patients').doc(uid)
              .collection('Medical History')
              .doc(disease).set({'disease': disease});
        }
      }

      String url = '';
      if (fi != null) {
        url = await uploadImage();
        await firestore.collection('Patients').doc(uid).set({
          'profileUrl': url,
        }, SetOptions(merge: true));
      }
      else{
        await firestore.collection('Patients').doc(uid).set({
          'profileUrl': '',
        }, SetOptions(merge: true));
      }
      await firestore.collection('Users').doc(uid).set({
        'setup': 2,
      }, SetOptions(merge: true));

      setState(() {
        isLoading = false;
      });
      Navigator.push(context, MaterialPageRoute(builder: (context) => NavScreen()));
    }
    catch(e){
      Alert(context, e);
    }
  }

  Future<String> uploadImage() async {
    try {
      final data = await storage.ref().child('profiles').child(DateTime.now().millisecondsSinceEpoch.toString());

      uploadTask = data.putFile(fi!);
      final snapshot = await uploadTask?.whenComplete(() => () {});
      return (await snapshot?.ref.getDownloadURL())!;
    }
    catch(e){

      return '';
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    uid = auth.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Stack(
            alignment: AlignmentDirectional.bottomEnd,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Details',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold,),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Text('Fill this form to get started !', style: TextStyle(color: kGrey, fontSize: 24),),
                  SizedBox(
                    height: 32,
                  ),
                  Expanded(
                    child: PageView(
                      controller: pageController,
                      scrollDirection: Axis.horizontal,
                      onPageChanged: (pageIndex) {

                      },
                      children: [
                        AddPatientScreen1(updateData: (Map<String, String> data){
                          setState(() {
                            data1 = data;
                            print(data1);
                          });
                        },),
                        AddPatientScreen2(updateData: (Map<String, String> data){
                          setState(() {
                            data2 = data;
                            print(data2);
                          });
                        },),
                        AddPatientScreen3(updateData: (file){
                          setState(() {
                            fi = file;
                          });
                        },),
                        AddPatientScreen4(updateData: (List<String> data){
                          setState(() {
                            data3 = data;
                          });
                        }),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Visibility(
                    visible: isPrevVisible,
                    child: Container(
                        width: 100,
                        child: CustomButton(
                            text: 'PREVIOUS',
                            backgroundColor: kPrimaryColor,
                            onPressed: () {
                              pageController.previousPage(duration: Duration(
                                  milliseconds: 500), curve: Curves.ease);
                              int? pageIndex = pageController.page?.toInt();
                              switch(pageIndex){
                                case 1:
                                  setState(() {
                                    isPrevVisible = true;
                                    isNextVisible = true;
                                  });
                                  break;
                                case 2:
                                  setState(() {
                                    isPrevVisible = true;
                                    isNextVisible = true;
                                  });
                                  break;
                                case 3:
                                  setState(() {
                                    isPrevVisible = true;
                                    isNextVisible = true;
                                  });
                                  break;
                                case 0:
                                  setState(() {
                                    isPrevVisible = false;
                                    isNextVisible = true;
                                  });
                                  break;
                              }
                            })),
                  ),
                  Visibility(
                    visible: isNextVisible,
                    child: Container(
                        width: 100,
                        child: CustomButton(
                            text: 'NEXT',
                            isLoading: isLoading,
                            loadingWidget: Center(
                              child: CircularProgressIndicator(color: Colors.white,),
                            ),
                            backgroundColor: kPrimaryColor,
                            onPressed: () {
                              pageController.nextPage(duration: Duration(
                                  milliseconds: 500), curve: Curves.ease);
                              int? pageIndex = pageController.page?.toInt();

                              if(pageIndex == 3){
                                uploadData();
                              }
                              switch(pageIndex){
                                case 0:
                                  setState(() {
                                    isPrevVisible = true;
                                    isNextVisible = true;
                                  });
                                  break;
                                case 1:
                                  setState(() {
                                    isPrevVisible = true;
                                    isNextVisible = true;
                                  });
                                  break;
                                case 2:
                                  setState(() {
                                    isPrevVisible = false;
                                    isNextVisible = true;
                                  });
                                  break;
                                case 3:
                                  setState(() {
                                    isPrevVisible = false;
                                    isNextVisible = true;
                                  });
                                  break;
                              }
                            })),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
