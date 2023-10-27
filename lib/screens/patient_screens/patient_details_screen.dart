import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:goa_dental_clinic/classes/alert.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:goa_dental_clinic/custom_widgets/custom_button.dart';
import 'package:goa_dental_clinic/custom_widgets/done_plan_card.dart';
import 'package:goa_dental_clinic/custom_widgets/image_des_container.dart';
import 'package:goa_dental_clinic/custom_widgets/image_viewer.dart';
import 'package:goa_dental_clinic/custom_widgets/pending_plan_card.dart';
import 'package:goa_dental_clinic/custom_widgets/pre_card.dart';
import 'package:goa_dental_clinic/custom_widgets/selection_prescription_card.dart';
import 'package:goa_dental_clinic/models/image_model.dart';
import 'package:goa_dental_clinic/models/patient_model.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/test_screen.dart';
import 'package:goa_dental_clinic/screens/login_screen.dart';
import 'package:goa_dental_clinic/screens/patient_screens/view_patient_appointments.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../classes/get_patient_details.dart';
import '../../custom_widgets/file_input_card.dart';
import '../../custom_widgets/image_container.dart';
import '../../models/plan_model.dart';
import '../../models/pre_model.dart';
import 'package:fluttertoast/fluttertoast.dart' as flut;

class PatientDetailsScreen extends StatefulWidget {
  PatientDetailsScreen(
      {required this.pm, this.uid = '', this.isPatient = false, this.showBackIcon = true});
  PatientModel? pm;
  String uid;
  bool isPatient;
  bool showBackIcon;

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  bool isLoading = false;
  bool isImgUploading = false;
  bool isImgUploading2 = false;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  List<String> medHisList = [];
  String profileUrl = '';
  List<PlanModel> pendingPlanList = [];
  List<PlanModel> donePlanList = [];
  List<PreModel> preList = [];
  List<ImageModel> imList = [];
  List<ImageModel> bloodList = [];
  String accessToken = 'No token';

  getMedicalHistory() async {
    setState(() {
      isLoading = true;
    });
    final diseases = await firestore
        .collection('Patients')
        .doc(widget.uid)
        .collection('Medical History')
        .get();
    setState(() {
      for (var disease in diseases.docs) {
        medHisList.add(disease['disease']);
        print(disease['disease']);
      }
    });
    setState(() {
      isLoading = false;
    });
  }

  getPreList() async {
    final data = await firestore
        .collection('Patients')
        .doc(widget.uid)
        .collection('Plan Prescriptions')
        .get();

    print(widget.uid);
    setState(() {
      for (var pre in data.docs) {
        preList.add(
          PreModel(title: pre['title'], des: pre['des'], preId: pre['preId']),
        );
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.pm == null) {
      getDetails();
    }
    checkRole();
    getAccessToken();
    getMedicalHistory();
    getDonePendingPlans();
    getPreList();
    getFiles();
  }

  getAccessToken() async {
    final data = await firestore.collection('Users').doc(widget.uid).get();

    accessToken = data['accessToken'];
  }

  checkRole() async {
    final data = await firestore
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    if (data['role'] != 'doctor') {
      widget.isPatient = true;
    }
  }

  getDetails() async {
    setState(() {
      isLoading = true;
    });
    final datas = await firestore.collection('Patients').doc(widget.uid).get();
    widget.pm = GetPatientDetails().get(datas);
    setState(() {
      isLoading = false;
    });
  }

  getDonePendingPlans() async {
    final apps = await firestore
        .collection('Patients')
        .doc(widget.uid)
        .collection('Appointments')
        .get();
    final plans = await firestore
        .collection('Patients')
        .doc(widget.uid)
        .collection('Plans')
        .get();

    for (var plan in plans.docs) {
      var value = true;
      for (var app in apps.docs) {
        if (app['plan'] == plan['plan']) {
          value = false;
          if (DateTime.now().millisecondsSinceEpoch <
              double.parse(app['endTimeInMil'])) {
            //pending
            pendingPlanList.add(
                PlanModel(plan: plan['plan'], toothList: plan['toothList']));
          } else {
            donePlanList.add(
                PlanModel(plan: plan['plan'], toothList: plan['toothList']));
          }
        }
      }
      if (value) {
        pendingPlanList
            .add(PlanModel(plan: plan['plan'], toothList: plan['toothList']));
      }
    }

    setState(() {});
  }

  sendEmail(email, subject, body) async {
    Uri mail = Uri.parse("mailto:$email?subject=$subject&body=$body");
    if (await launchUrl(mail)) {
      //email app opened
    } else {
      Alert(context, 'Error: Invaid email');
      //email app is not opened
    }
  }

  call(number) async {
    try {
      if (number.startsWith("+91"))
        await FlutterPhoneDirectCaller.callNumber("$number");
      else if (number.startsWith("91"))
        await FlutterPhoneDirectCaller.callNumber("+$number");
      else
        await FlutterPhoneDirectCaller.callNumber("+91$number");
    } catch (e) {
      Alert(context, "Error: $e");
    }
  }

  getFiles() async {
    setState(() {
      isLoading = true;
    });
    final data = await firestore.collection('Patients').doc(widget.uid).collection('Files').get();
    final data2 = await firestore.collection('Patients').doc(widget.uid).collection('Blood Report').get();

    setState(() {
      imList.clear();
      for(var pic in data.docs){
        imList.add(ImageModel(url: pic['url'], description: pic['des']));
      }
    });
    setState(() {
      bloodList.clear();
      for(var pic in data2.docs){
        bloodList.add(ImageModel(url: pic['url'], description: pic['des']));
      }
    });
    setState(() {
      isLoading = false;
    });
  }

  uploadImage(file, des) async {
    try {
      if (file != null) {
        setState(() {
          isImgUploading = true;
        });
        late UploadTask ut;
        FirebaseStorage storage = FirebaseStorage
            .instance;

        ut = storage.ref().child('images').child(
            DateTime
                .now()
                .millisecondsSinceEpoch
                .toString()).putFile(file);
        var snapshot = await ut
            .whenComplete(() {});

        String url = await snapshot.ref
            .getDownloadURL();
        imList.add(ImageModel(
            url: url, description: des));
        setState;
        await firestore.collection('Patients').doc(
            widget.uid).collection('Files').doc(
            des).set(
            {
              'url': url,
              'des': des,
            }
        );
        setState(() {
          isImgUploading = false;
        });
        print(url);
      }
    }catch(e){
      Alert(context, e);
      setState(() {
        isImgUploading = false;
      });
    }
  }

  uploadBloodReport(file, des) async {
    try {
      if (file != null) {
        setState(() {
          isImgUploading2 = true;
        });
        late UploadTask ut;
        FirebaseStorage storage = FirebaseStorage
            .instance;

        ut = storage.ref().child('images').child(
            DateTime
                .now()
                .millisecondsSinceEpoch
                .toString()).putFile(file);
        var snapshot = await ut
            .whenComplete(() {});

        String url = await snapshot.ref
            .getDownloadURL();
        imList.add(ImageModel(
            url: url, description: des));
        setState;
        await firestore.collection('Patients').doc(
            widget.uid).collection('Blood Report').doc(
            des).set(
            {
              'url': url,
              'des': des,
            }
        );
        setState(() {
          isImgUploading2 = false;
        });
        print(url);
      }
    }catch(e){
      Alert(context, e);
      setState(() {
        isImgUploading2 = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: !isLoading
              ? SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            widget.showBackIcon ? InkWell(
                              child: Icon(
                                Icons.arrow_back_ios_new_outlined,
                                color: Colors.black,
                              ),
                              onTap: () {
                                Navigator.pop(context);
                              },
                            ) : Container(
                              height: 1,
                              width: 1,
                            ),
                            SizedBox(
                              width: widget.showBackIcon ? 8 : 0,
                            ),
                            (widget.pm!.profileUrl == '')
                                ? InkWell(
                                    child: CircleAvatar(
                                      backgroundColor: kPrimaryColor,
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ImageViewer(
                                                  im: ImageModel(
                                                      url: widget
                                                          .pm!.profileUrl))));
                                    },
                                  )
                                : InkWell(
                                    child: CircleAvatar(
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                              widget.pm!.profileUrl,
                                              errorListener: () {}),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ImageViewer(
                                                  im: ImageModel(
                                                      url: widget
                                                          .pm!.profileUrl))));
                                    },
                                  ),
                            SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: Text(
                                "${widget.pm?.patientName}",
                                style: TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            ElevatedButton(onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ViewPatientAppointments(uid: widget.uid)));
                            }, child: Text('View Appointments')),
                          ],
                        ),
                        SizedBox(height: 12,),
                        Wrap(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Container(
                                child: Row(
                                  children: [
                                    Text('Access Token: ', style: TextStyle(fontSize: 16),),
                                    Expanded(
                                      child: InkWell(child: Text('${accessToken}', style: TextStyle(fontSize: 18, color: kPrimaryColor),), onTap: () async {
                                              await  Clipboard.setData(ClipboardData(text: accessToken));
                                              flut.Fluttertoast.showToast(
                                                  msg: "Access Token Copied!",
                                                  toastLength: flut.Toast.LENGTH_LONG,
                                                  gravity: ToastGravity.BOTTOM,
                                                  timeInSecForIosWeb: 2,
                                                  backgroundColor: Colors.black,
                                                  textColor: Colors.white,
                                                  fontSize: 16.0
                                              );
                                      },),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            (widget.pm!.email.isNotEmpty) ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Container(
                                child: Row(
                                  children: [
                                    Text('Email: ', style: TextStyle(fontSize: 16),),
                                    InkWell(child: Text('${widget.pm!.email}', style: TextStyle(fontSize: 16, color: kPrimaryColor),), onTap: (){
                                      sendEmail(widget.pm!.email, "", "");
                                    },),
                                  ],
                                ),
                              ),
                            ) : Container(height: 1, width: 1,),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Container(
                                child: Row(
                                  children: [
                                    Text('Phone: ', style: TextStyle(fontSize: 16),),
                                    Expanded(
                                      child: InkWell(child: Text('${widget.pm!.phoneNumber1}', style: TextStyle(fontSize: 16, color: kPrimaryColor),), onTap: (){
                                        call(widget.pm!.phoneNumber1);
                                      },),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        (widget.pm!.dob.isNotEmpty) ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Container(
                                child: Row(
                                  children: [
                                    Text('Dob: ', style: TextStyle(fontSize: 16),),
                                    Expanded(child: Text('${widget.pm!.dob}', style: TextStyle(fontSize: 16),),),
                                  ],
                                ),
                              ),
                            ) : Container(height: 1, width: 1,),
                        (widget.pm!.streetAddress.isNotEmpty) ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Container(
                                child: Row(
                                  children: [
                                    Text('Address: ', style: TextStyle(fontSize: 16),),
                                    Expanded(child: Text('${widget.pm!.streetAddress}', style: TextStyle(fontSize: 16),)),
                                  ],
                                ),
                              ),
                            ) : Container(height: 1, width: 1,),
                          ],
                        ),
                        // ExpansionTile(
                        //   title: Text(
                        //     'Access Token',
                        //     style: TextStyle(fontSize: 20),
                        //   ),
                        //   children: [
                        //     InkWell(child: Text('$accessToken', style: TextStyle(fontSize: 16, color: Colors.blue),), onTap: () async {
                        //       //copy
                        //       await  Clipboard.setData(ClipboardData(text: accessToken));
                        //       flut.Fluttertoast.showToast(
                        //           msg: "Access Token Copied!",
                        //           toastLength: flut.Toast.LENGTH_LONG,
                        //           gravity: ToastGravity.BOTTOM,
                        //           timeInSecForIosWeb: 2,
                        //           backgroundColor: Colors.black,
                        //           textColor: Colors.white,
                        //           fontSize: 16.0
                        //       );
                        //     },),
                        //     SizedBox(height: 8,),
                        //   ],
                        //   initiallyExpanded: true,
                        // ),
                        // SizedBox(
                        //   height: widget.pm!.dob.isNotEmpty ? 12 : 0,
                        // ),
                        // Visibility(
                        //   visible: widget.pm!.dob.isNotEmpty,
                        //   child: ExpansionTile(
                        //     title: Text(
                        //       'Personal details',
                        //       style: TextStyle(fontSize: 20),
                        //     ),
                        //     children: [
                        //       RowText(
                        //           title: 'Date of birth: ',
                        //           content: widget.pm!.dob),
                        //     ],
                        //     initiallyExpanded: true,
                        //   ),
                        // ),
                        // SizedBox(
                        //   height: 12,
                        // ),
                        // ExpansionTile(
                        //   initiallyExpanded: true,
                        //   title: Text(
                        //     'Contact details',
                        //     style: TextStyle(fontSize: 20),
                        //   ),
                        //   children: [
                        //     RowText(
                        //       title: 'Phone Number: ',
                        //       content: widget.pm!.phoneNumber1,
                        //       func: () {
                        //         call(widget.pm!.phoneNumber1);
                        //       },
                        //       fontColor: Colors.blue,
                        //     ),
                        //     (widget.pm!.email.isNotEmpty)
                        //         ? RowText(
                        //             title: 'Email: ',
                        //             content: widget.pm!.email,
                        //             func: () {
                        //               sendEmail(widget.pm!.email, "", "");
                        //             },
                        //             fontColor: Colors.blue,
                        //           )
                        //         : Container(),
                        //     (widget.pm!.streetAddress.isNotEmpty)
                        //         ? RowText(
                        //             title: 'Street Address: ',
                        //             content: widget.pm!.streetAddress)
                        //         : Container(),
                        //   ],
                        // ),
                        SizedBox(
                          height: 12,
                        ),
                        ExpansionTile(
                          initiallyExpanded: true,
                          title: Text(
                            'Medical History',
                            style: TextStyle(fontSize: 20),
                          ),
                          children: [
                            ListView.builder(
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '${medHisList[index]}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                );
                              },
                              itemCount: medHisList.length,
                              shrinkWrap: true,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        ExpansionTile(
                          initiallyExpanded: true,
                          title: Text("Treatment Plans", style: TextStyle(fontSize: 20)),
                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                          expandedAlignment: Alignment.centerLeft,
                          children: pendingPlanList.map((e) {
                            return PendingPlanCard(
                              plan: e.plan,
                              toothList: e.toothList,
                              pm: widget.pm!,
                              hideButton: widget.isPatient,
                            );
                          }).toList(),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        ExpansionTile(
                          initiallyExpanded: true,
                          title: Text("Completed Treatment Plans",
                              style: TextStyle(fontSize: 20)),
                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                          expandedAlignment: Alignment.centerLeft,
                          children: donePlanList.map((e) {
                            return DonePlanCard(
                              plan: e.plan,
                              toothList: e.toothList,
                              pm: widget.pm!,
                            );
                          }).toList(),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        ExpansionTile(
                          initiallyExpanded: true,
                          title: Text("Prescriptions",
                              style: TextStyle(fontSize: 20)),
                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                          expandedAlignment: Alignment.centerLeft,
                          children: preList.map((e) {
                            return PreCard(
                              pm: e,
                            );
                          }).toList(),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        ExpansionTile(
                          initiallyExpanded: true,
                          trailing: (!widget.isPatient) ? InkWell(
                            child: CircleAvatar(
                              child: isImgUploading ? Center(child: CircularProgressIndicator(color: Colors.white,),) : Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                              radius: 15,
                              backgroundColor: kPrimaryColor,
                            ),
                            onTap: () {

                              if(!isImgUploading) {
                                showDialog(context: context, builder: (
                                    context) {
                                  return FileInputCard(
                                      size: size, onUpload: (file, des) async {
                                    uploadImage(file, des);
                                  });
                                },);
                              }else{

                              }
                            },
                          ) : Icon(Icons.keyboard_arrow_down_outlined, color: kPrimaryColor,),
                          title:
                              Text("X-rays", style: TextStyle(fontSize: 20)),
                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                          expandedAlignment: Alignment.centerLeft,
                          children: [Container(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: imList.map((e) {
                                  return Padding(
                                    padding: EdgeInsets.all(4),
                                    child: ImageDesContainer(im: e),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),]
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        ExpansionTile(
                            initiallyExpanded: true,
                            trailing: (!widget.isPatient) ? InkWell(
                              child: CircleAvatar(
                                child: isImgUploading ? Center(child: CircularProgressIndicator(color: Colors.white,),) : Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                                radius: 15,
                                backgroundColor: kPrimaryColor,
                              ),
                              onTap: () {

                                if(!isImgUploading2) {
                                  showDialog(context: context, builder: (
                                      context) {
                                    return FileInputCard(
                                        size: size, onUpload: (file, des) async {
                                      uploadBloodReport(file, des);
                                    });
                                  },);
                                }else{

                                }
                              },
                            ) : Icon(Icons.keyboard_arrow_down_outlined, color: kPrimaryColor,),
                            title:
                            Text("Blood Report", style: TextStyle(fontSize: 20)),
                            expandedCrossAxisAlignment: CrossAxisAlignment.start,
                            expandedAlignment: Alignment.centerLeft,
                            children: [Container(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: bloodList.map((e) {
                                    return Padding(
                                      padding: EdgeInsets.all(4),
                                      child: ImageDesContainer(im: e),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),]
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        !widget.isPatient
                            ? CustomButton(
                                text: 'ADD PLAN & PRESCRIPTION',
                                backgroundColor: kPrimaryColor,
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => TestScreen(
                                                patientUid:
                                                    widget.uid,
                                                status: 'not-normal',
                                              )));
                                })
                            : Container(),
                      ]),
                )
              : Center(
                  child: CircularProgressIndicator(
                    color: kPrimaryColor,
                  ),
                ),
        ),
      ),
    );
  }
}

class RowText extends StatelessWidget {
  RowText(
      {required this.title,
      required this.content,
      this.func,
      this.fontColor = Colors.black});
  String title, content;
  Function? func;
  Color fontColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: InkWell(
        child: Text(
          content,
          style: TextStyle(fontSize: 16, color: fontColor),
        ),
        onTap: () {
          try {
            func!();
          } catch (e) {
            print(e);
          }
        },
      ),
    );
  }
}
