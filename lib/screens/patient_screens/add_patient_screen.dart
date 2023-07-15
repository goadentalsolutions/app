import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
import 'package:goa_dental_clinic/screens/doctor_screens/test_screen.dart';
import 'package:goa_dental_clinic/screens/patient_screens/add_patient_screen4.dart';
import 'package:provider/provider.dart';

import '../../providers/add_patient_provider.dart';
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
  String uid = '', actualUrl = '';
  UploadTask? uploadTask;
  var data1;
  List<String> data3 = [];
  File? fi;
  bool isLoading = false, dataUploading = false;

  uploadData() async {
    setState(() {
      dataUploading = true;
    });

    try {
      setState(() {
        isLoading = true;
      });
      if (data1 != null) {
        print('cool');
        try {
          await firestore.collection('Patients').doc(uid).set({
            'patientName': data1['patientName'],
            'gender': data1['gender'],
            'dob': data1['dob'],
            'patientUid': uid,
            'phoneNumber': data1['phoneNumber'],
            'email': data1['email'],
            'streetAddress': data1['streetAddress'],
            'token': '',
          }, SetOptions(merge: true));
        } catch (e) {
          print('$e');
        }
      }

      if (data3.isNotEmpty || data3 != null) {
        for (var disease in data3) {
          await firestore
              .collection('Patients')
              .doc(uid)
              .collection('Medical History')
              .doc(disease)
              .set({'disease': disease.trim()});
        }
      }

      String url = '';
      if (fi != null && actualUrl == '') {
        try {
          url = await uploadImage();
          await firestore.collection('Patients').doc(uid).set({
            'profileUrl': url,
          }, SetOptions(merge: true));
        } catch (e) {
          print(e);
          Alert(context, e);
        }
      } else if (fi == null && actualUrl == '') {
        await firestore.collection('Patients').doc(uid).set({
          'profileUrl': '',
        }, SetOptions(merge: true));
      }
      await firestore.collection('Users').doc(uid).set({
        'setup': 2,
      }, SetOptions(merge: true));

      if (widget.status != 'normal') {
        await firestore.collection('Users').doc(uid).set({
          'name': data1['patientName'].toString().trim(),
          'phoneNumber': data1['phoneNumber'].toString().trim(),
          'email': data1['email'].toString().trim(),
          'role': 'patient',
          'uid': uid,
          'token': '',
          'setup': 2,
        });
      }

      setState(() {
        isLoading = false;
        dataUploading = false;
      });
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => TestScreen(patientUid: uid)));
    } catch (e) {
      Alert(context, "ada $e");
    }
  }

  Future<String> uploadImage() async {
    try {
      final data = await storage
          .ref()
          .child('profiles')
          .child(DateTime.now().millisecondsSinceEpoch.toString());

      uploadTask = data.putFile(fi!);
      final snapshot = await uploadTask?.whenComplete(() => () {});
      return (await snapshot?.ref.getDownloadURL())!;
    } catch (e) {
      return '';
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.status == 'normal')
      uid = auth.currentUser!.uid;
    else
      uid = DateTime.now().millisecondsSinceEpoch.toString();
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
                  Row(
                    children: [
                      InkWell(
                        child: Icon(
                          Icons.arrow_back_ios_new_outlined,
                          color: Colors.black,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Text(
                        'Add Details',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    'Fill this form to get started !',
                    style: TextStyle(color: kGrey, fontSize: 24),
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  Expanded(
                    child: PageView(
                      controller: pageController,
                      scrollDirection: Axis.horizontal,
                      onPageChanged: (pageIndex) {},
                      children: [
                        AddPatientScreen1(
                          updateData: (Map<String, String> data) {
                            setState(() {
                              data1 = data;
                              Provider.of<AddPatientProvider>(context,
                                      listen: false)
                                  .setPatient(PatientModel(
                                      patientUid: data1['patientUid'] ?? "",
                                      patientName: data1['patientName'] ?? "",
                                      email: data1['email'] ?? "",
                                      dob: data1['dob'] ?? "",
                                      gender: data1['gender'],
                                      phoneNumber1: data1['phoneNumber'] ?? "",
                                      streetAddress:
                                          data1['streetAddress'] ?? "",
                                      profileUrl: data1['profileUrl'] ?? ""));
                            });
                          },
                          status: widget.status,
                        ),
                        AddPatientScreen3(
                          updateData: (file, url) {
                            setState(() {
                              fi = file;
                              actualUrl = url;
                            });
                          },
                        ),
                        AddPatientScreen4(updateData: (List<String> data) {
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
                              pageController.previousPage(
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.ease);
                              int? pageIndex = pageController.page?.toInt();
                              switch (pageIndex) {
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
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: kPrimaryColor,
                        onPressed: () {
                          if (!(data1['patientName'] == "" ||
                              data1['gender'] == "" ||
                              data1['phone1'] == "phoneNumber")) {
                            pageController.nextPage(
                                duration: Duration(milliseconds: 500),
                                curve: Curves.ease);
                            int? pageIndex = pageController.page?.toInt();

                            if (pageIndex == 2) {
                              if(!dataUploading)
                              uploadData();
                            }
                            switch (pageIndex) {
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
                          }else{
                            Alert(context, "Name, gender, Phone No. are mandatory fields!");
                          }
                        },
                      ),
                    ),
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
