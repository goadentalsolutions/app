import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:goa_dental_clinic/classes/alert.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:goa_dental_clinic/custom_widgets/custom_button.dart';
import 'package:goa_dental_clinic/custom_widgets/done_plan_card.dart';
import 'package:goa_dental_clinic/custom_widgets/image_viewer.dart';
import 'package:goa_dental_clinic/custom_widgets/pending_plan_card.dart';
import 'package:goa_dental_clinic/models/image_model.dart';
import 'package:goa_dental_clinic/models/patient_model.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/test_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../classes/get_patient_details.dart';
import '../../models/plan_model.dart';
import '../../models/pre_model.dart';

class PatientDetailsScreen extends StatefulWidget {
  PatientDetailsScreen({required this.pm, this.uid = ''});
  PatientModel? pm;
  String uid;

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  bool isLoading = false;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  List<String> medHisList = [];
  String profileUrl = '';
  List<PlanModel> pendingPlanList = [];
  List<PlanModel> donePlanList = [];
  List<PreModel> preList = [];

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
    
    final data = await firestore.collection('Patient').doc(widget.pm!.patientUid).collection('Plan Prescriptions').get();

    setState(() {
      for(var pre in data.docs){
        preList.add(
          PreModel(title: pre['title'], des: pre['des']),
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
    getMedicalHistory();
    getDonePendingPlans();
  }

  getDetails() async {
    print('ada');
    setState(() {
      isLoading = true;
    });
    final datas = await firestore.collection('Patients').doc(widget.uid).get();
    widget.pm = GetPatientDetails().get(datas);
    // if (widget.pm!.profileUrl == '')
    //   profileUrl = '';
    // else
    //   profileUrl = widget.pm!.profileUrl;

    setState(() {
      isLoading = false;
    });
  }

  
  getDonePendingPlans() async {

    final apps = await firestore.collection('Patients').doc(widget.uid).collection('Appointments').get();
    final plans = await firestore.collection('Patients').doc(widget.uid).collection('Plans').get();

      for(var plan in plans.docs){
        var value = true;
        for(var app in apps.docs){
          if(app['plan'] == plan['plan']){
            value = false;
            if (DateTime
                  .now()
                  .millisecondsSinceEpoch < double.parse(app['endTimeInMil'])){
              //pending
              pendingPlanList.add(PlanModel(plan: plan['plan'], toothList: plan['toothList']));
            }
            else{
              donePlanList.add(PlanModel(plan: plan['plan'], toothList: plan['toothList']));
            }
          }
        }
        if(value){
          pendingPlanList.add(PlanModel(plan: plan['plan'], toothList: plan['toothList']));
        }
      }

    setState(() {

    });
  }

  sendEmail(email, subject, body) async {
    Uri mail = Uri.parse("mailto:$email?subject=$subject&body=$body");
    if (await launchUrl(mail)) {
      //email app opened
    }else{
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
    }
    catch(e){
      Alert(context, "Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
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
                              width: 8,
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
                                          CachedNetworkImageProvider(widget.pm!.profileUrl,
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
                            Text(
                              "${widget.pm?.patientName}",
                              style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                  fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        ExpansionTile(
                          title: Text(
                            'Personal details',
                            style: TextStyle(fontSize: 20),
                          ),
                          children: [
                            RowText(
                                title: 'Date of birth: ',
                                content: widget.pm!.dob),
                          ],
                          initiallyExpanded: true,
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        ExpansionTile(
                          initiallyExpanded: true,
                          title: Text(
                            'Contact details',
                            style: TextStyle(fontSize: 20),
                          ),
                          children: [
                            RowText(
                                title: 'Phone Number: ',
                                content: widget.pm!.phoneNumber1, func: (){
                                  call(widget.pm!.phoneNumber1);
                            }, fontColor: Colors.blue,),
                            (widget.pm!.email.isNotEmpty) ? RowText(
                                title: 'Email: ', content: widget.pm!.email, func: (){
                                  sendEmail(widget.pm!.email, "", "");
                            }, fontColor: Colors.blue,) : Container(),
                            (widget.pm!.streetAddress.isNotEmpty) ? RowText(
                                title: 'Street Address: ',
                                content: widget.pm!.streetAddress) : Container(),
                          ],
                        ),
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
                        ExpansionTile(initiallyExpanded: true, title: Text("Plans", style: TextStyle(fontSize: 20)),
                        expandedCrossAxisAlignment: CrossAxisAlignment.start,
                        expandedAlignment: Alignment.centerLeft,
                        children: pendingPlanList.map((e){

                          return PendingPlanCard(plan: e.plan, toothList: e.toothList, pm: widget.pm!,);
                        }).toList(),),
                        SizedBox(
                          height: 12,
                        ),
                        ExpansionTile(initiallyExpanded: true, title: Text("Completed Plans", style: TextStyle(fontSize: 20)),
                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                          expandedAlignment: Alignment.centerLeft,
                          children: donePlanList.map((e){

                            return DonePlanCard(plan: e.plan, toothList: e.toothList, pm: widget.pm!,);
                          }).toList(),),
                        SizedBox(height: 12,),
                        CustomButton(text: 'ADD PLAN', backgroundColor: kPrimaryColor, onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => TestScreen(patientUid: widget.pm!.patientUid)));
                        }),
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
  RowText({required this.title, required this.content, this.func, this.fontColor = Colors.black});
  String title, content;
  Function? func;
  Color fontColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: InkWell(child: Text(content, style: TextStyle(fontSize: 16, color: fontColor),), onTap: (){
        try {
          func!();
        }
        catch(e){
          print(e);
        }
      },),
    );
  }
}
