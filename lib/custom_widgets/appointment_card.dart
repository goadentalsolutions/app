import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/classes/alert.dart';
import 'package:goa_dental_clinic/models/app_model.dart';
import 'package:goa_dental_clinic/models/patient_model.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/appointment_screen.dart';
import 'package:goa_dental_clinic/screens/patient_screens/patient_view_appointments.dart';

import '../constants.dart';
import '../screens/doctor_screens/nav_screen.dart';
import '../screens/doctor_screens/view_appointments.dart';
import '../screens/patient_screens/patient_details_screen.dart';
import 'package:http/http.dart' as http;

class AppointmentCard extends StatefulWidget {
  AppointmentCard({
    required this.size,
    required this.patientName,
    required this.week,
    required this.date,
    required this.time,
    required this.onMorePressed,
    required this.doctorName,
    required this.doctorUid,
    required this.patientUid,
    required this.appId,
    required this.pm,
    required this.startTimeInMil,
    required this.month,
    required this.endTimeInMil,
    this.isDoc = true,
    this.status = 'normal',
    required this.refresh,
  });

  final Size size;
  final String patientName, doctorName, date, week, time, status, doctorUid, patientUid, appId, startTimeInMil, endTimeInMil, month;
  Function onMorePressed;
  PatientModel? pm;
  bool isDoc;
  Function refresh;

  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  sendNotificationToPatient() async {
    String msgId = DateTime.now().millisecondsSinceEpoch.toString();
    firestore.collection('Patients').doc(widget.patientUid).collection('Messages').doc(msgId).set({
      'msg' : 'Cancelled appointment scheduled on ${widget.date}(${widget.week}) at ${widget.time}.',
      'msgId' : msgId,
      'docUid' : widget.doctorUid,
      'docName' : widget.doctorName,
      'date' : widget.date,
      'week' : widget.week,
      'time' : widget.time,
    });
  }

  notifyPatient(patientToken, body, title) async {
    try {
      await http.post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: <String, String>{
          "Content-Type": "application/json",
          "Authorization": "key=$messagingServerKey"
        },
        body: jsonEncode(
          <String, dynamic>{
            "priority": "high",
            "data": <String, dynamic>{
              "click_action": "FLUTTER_NOTIFICATION_CLICK",
              "status": "done",
              "body": body,
              "title": title,
              "type": "chat",
            },
            "notification": <String, dynamic>{
              "title": title,
              "body": body,
              "android_channel_id": "dbfood",
              'icon' : 'assets/logo.png'
            },
            "to": patientToken,
          },
        ),
      );
      print('Notification sent!');
    } catch (e) {
      print(e);
    }

    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data saved !'), backgroundColor: Colors.green,));
    // Navigator.push(context, MaterialPageRoute(builder: (context) => NavScreen(screenNo: 2)));
  }

  updateHistory() async {
    await firestore.collection('Doctors').doc(widget.doctorUid).collection('History').doc('${widget.patientUid}_${widget.appId}').set(
      {
        'status' : 'Cancelled',
      },
      SetOptions(merge: true),
    );
  }

  deleteAppointment(){
    // Navigator.pop(context);
    Timer(Duration(milliseconds: 500), () {
      showDialog(context: context, builder: (context){

        return AlertDialog(
          title: Text('Are you sure?'),
          content: Text('Delete appointment!'),
          actions: [
            ElevatedButton(onPressed: () async {
              Navigator.pop(context);
              try {
                final data = await firestore.collection('Patients').doc(widget.patientUid).get();
                String patientToken = data['token'];
              await firestore.collection('Doctors').doc(widget.doctorUid).collection(
                    'Appointments').doc('${widget.patientUid}_${widget.appId}').delete();
                await firestore.collection('Patients').doc(widget.patientUid).collection(
                    'Appointments').doc('${widget.patientUid}_${widget.appId}').delete();
                widget.refresh(widget.appId,);
                updateHistory();
                sendNotificationToPatient();
                notifyPatient(patientToken, 'Canceled appointment scheduled on ${widget.date}(${widget.week}) at ${widget.time}.', 'Notification from Dr. ${widget.doctorName}');
              }
              catch(e){
                Alert(context, 'Error deleting : $e');
              }
            }, child: Text('Yes')),
            ElevatedButton(onPressed: (){
              Navigator.pop(context);
            }, child: Text('No')),
          ],
        );
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        print(widget.doctorUid);
        if(widget.status == 'patienthomescreen')
        Navigator.push(context, MaterialPageRoute(builder: (context) => PatientViewAppointmentScreen(am: AppModel(patientName: widget.patientName, doctorName: widget.doctorName, date: widget.date, week: widget.week, time: widget.time, doctorUid: widget.doctorUid, patientUid: widget.patientUid, appId: widget.appId, pm: widget.pm, startTimeInMil: widget.startTimeInMil, endTimeInMil: widget.endTimeInMil, month: widget.month),),));
        else
        Navigator.push(context, MaterialPageRoute(builder: (context) => ViewAppointmentScreen(am: AppModel(patientName: widget.patientName, doctorName: widget.doctorName, date: widget.date, week: widget.week, time: widget.time, doctorUid: widget.doctorUid, patientUid: widget.patientUid, appId: widget.appId, pm: widget.pm, startTimeInMil: widget.startTimeInMil, endTimeInMil: widget.endTimeInMil, month: widget.month),),));
      },
    child: Container(
        padding: EdgeInsets.all(16),
        height: widget.size.height * 0.12,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: kGrey,
            ), color: Colors.white),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kGrey),),
                child: Column(
                  children: [
                    Text('${widget.date}', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),),
                    Text('${widget.week}', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black),),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 12,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: widget.size.width * 0.8 * 0.2,
                      decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(16)),
                      child: Center(child: Text('${widget.time}', style: TextStyle(color: Colors.white, fontSize: 12),)),
                    ),
                    SizedBox(height: 4,),
                    Expanded(child: (widget.isDoc) ? Text('${widget.patientName}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), maxLines: 1,) : Text('Dr. ${widget.doctorName}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), maxLines: 1,), flex: 2,),
                    SizedBox(height: 4,),
                    Expanded(child: (widget.isDoc) ? Text('By Dr. ${widget.doctorName}') : Text(''), flex: 2,),
                  ],
                ),
              ),
              flex: 6,
            ),
            PopupMenuButton(itemBuilder: (context) => (widget.status == 'patienthomescreen') ? [
            PopupMenuItem(child: Text('View details'), onTap: (){
              if(widget.status == 'normal'){
                widget.onMorePressed(4);
              }
              else{
                Timer(Duration(milliseconds: 200), () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PatientDetailsScreen(pm: widget.pm, uid: widget.patientUid,)));
                });
              }
            },),
            ] : [
              PopupMenuItem(child: Text('Add treatment plan'), onTap: (){
                if(widget.status == 'normal'){
                  widget.onMorePressed(1);
                }
                else{
                  Timer(Duration(milliseconds: 200), () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ViewAppointmentScreen(am: AppModel(patientName: widget.patientName, doctorName: widget.doctorName, date: widget.date, week: widget.week, time: widget.time, doctorUid: widget.doctorUid, patientUid: widget.patientUid, appId: widget.appId, pm: widget.pm, startTimeInMil: widget.startTimeInMil, endTimeInMil: widget.endTimeInMil, month: widget.month), itemNo: 1,)));
                  });
                }
              }, value: 1,),
              PopupMenuItem(child: Text('Add prescription'), onTap: (){
                if(widget.status == 'normal'){
                  widget.onMorePressed(2);
                }
                else{
                  Timer(Duration(milliseconds: 200), () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ViewAppointmentScreen(am: AppModel(patientName: widget.patientName, doctorName: widget.doctorName, date: widget.date, week: widget.week, time: widget.time, doctorUid: widget.doctorUid, patientUid: widget.patientUid, appId: widget.appId, pm: widget.pm, startTimeInMil: widget.startTimeInMil, endTimeInMil: widget.endTimeInMil, month: widget.month), itemNo: 2,),));
                  });
                }
              },),
              PopupMenuItem(child: Text('Add note'), onTap: (){
                if(widget.status == 'normal'){
                  widget.onMorePressed(3);
                }
                else{
                  Timer(Duration(milliseconds: 200), () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ViewAppointmentScreen(am: AppModel(patientName: widget.patientName, doctorName: widget.doctorName, date: widget.date, week: widget.week, time: widget.time, doctorUid: widget.doctorUid, patientUid: widget.patientUid, appId: widget.appId, pm: widget.pm, startTimeInMil: widget.startTimeInMil, endTimeInMil: widget.endTimeInMil, month: widget.month), itemNo: 3,),),);
                  });
                }
              },),
              PopupMenuItem(child: Text('View details'), onTap: (){
                if(widget.status == 'normal'){
                  widget.onMorePressed(4);
                }
                else{
                  Timer(Duration(milliseconds: 200), () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PatientDetailsScreen(pm: widget.pm, uid: widget.patientUid,)));
                  });
                }
              },),
              PopupMenuItem(child: Text('Cancel appointment'), onTap: (){
                deleteAppointment();
              },),
            ], icon: Icon(Icons.more_vert),),
          ],
        ),
      ),
    );
  }
}
