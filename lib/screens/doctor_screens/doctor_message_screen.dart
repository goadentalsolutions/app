import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:goa_dental_clinic/classes/pref.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:goa_dental_clinic/custom_widgets/message_card.dart';
import 'package:goa_dental_clinic/models/app_model.dart';
import 'package:goa_dental_clinic/models/appointment_msg_model.dart';
import 'package:goa_dental_clinic/models/patient_msg_model.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/appointment_screen.dart';
import 'package:goa_dental_clinic/screens/patient_screens/patient_message_screen.dart';

import '../../classes/get_patient_details.dart';
import '../../custom_widgets/patient_msg_card.dart';
import '../../models/patient_model.dart';
import '../../models/patient_msg_model2.dart';

class DoctorMessageScreen extends StatefulWidget {
  const DoctorMessageScreen({Key? key}) : super(key: key);

  @override
  State<DoctorMessageScreen> createState() => _DoctorMessageScreenState();
}

class _DoctorMessageScreenState extends State<DoctorMessageScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? uid, doctorName;
  List<MessageCard> msgList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    uid = auth.currentUser!.uid;
    getName();
  }

  getName() async {
    try {
      final data = await firestore.collection('Users').doc(uid).get();
      doctorName = data['name'];
    } catch (e) {
      print('Message screen exception: $e');
    }
    setState(() {});
  }

  onAccept(AppointmentMessageModel amm) async {
    final datas = await firestore.collection('Patients').get();
    PatientModel? pm;
    setState(() {
      for (var data in datas.docs) {
        print(data['patientName'] + data['patientName']);
        if (amm.patientName == data['patientName']) {
          pm = GetPatientDetails().get(data);
          break;
        }
      }
    });

    // print(pm!.patientName+pm!.dob+pm!.language+pm!.age+pm!.age);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AppointmentScreen(
                  am: AppModel(
                      patientName: amm.patientName.toString(),
                      doctorName: doctorName.toString(),
                      date: amm.date.toString(),
                      week: amm.week.toString(),
                      time: amm.startTime.toString(),
                      doctorUid: uid.toString(),
                      patientUid: amm.patientUid.toString(),
                      appId: amm.appId.toString(),
                      pm: pm,
                      startTimeInMil: amm.startTimeInMil,
                      endTimeInMil: amm.endTimeInMil,
                      month: amm.month),
                )));

    removeMsg(amm.msgId);
    setState(() {});
  }

  removeMsg(msgId) async {
    await firestore
        .collection('Doctors')
        .doc(uid)
        .collection('Messages')
        .doc(msgId)
        .delete();
    msgList.removeWhere((msg) {
      return (msg.am?.msgId == msgId);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'Messages',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 16,
                ),
                SizedBox(
                  height: 16,
                ),
                StreamBuilder(
                    stream: firestore
                        .collection('Doctors')
                        .doc(uid)
                        .collection('Messages')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: kPrimaryColor,
                          ),
                        );
                      }
                      if (snapshot.hasData) {
                        final messages = snapshot.data;

                        msgList.clear();
                        for (var msg in (messages?.docs)!) {
                          String msgId = msg.reference.id;
                          msgList.add(
                            MessageCard(
                              onAccept: (AppointmentMessageModel amm) {
                                onAccept(amm);
                              },
                              onReject: () {
                                removeMsg(msgId);
                              },
                              am: AppointmentMessageModel(
                                  date: msg['date'],
                                  startTime: msg['startTime'],
                                  endTime: msg['endTime'],
                                  message: msg['message'],
                                  patientName: msg['patientName'],
                                  patientUid: msg['patientUid'],
                                  week: msg['week'],
                                  appId: msg['appId'],
                                  msgId: msgId,
                                  startTimeInMil: msg['startTimeInMil'],
                                  endTimeInMil: msg['endTimeInMil'],
                                  month: msg['month']),
                            ),
                          );
                        }
                      }
                      if (msgList.isEmpty) {
                        return Container(
                          child: Center(
                              child: Column(
                            children: [
                              SvgPicture.asset(
                                'svgs/no_data.svg',
                                height: size.height * 0.3,
                                width: size.width * 0.3,
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              Text(
                                'No Messages yet',
                                style: TextStyle(fontSize: 18, color: kGrey),
                              ),
                            ],
                          )),
                        );
                      }
                      return ListView.builder(
                        itemBuilder: (context, index) {
                          return msgList[index];
                        },
                        itemCount: msgList.length,
                        shrinkWrap: true,
                      );
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
