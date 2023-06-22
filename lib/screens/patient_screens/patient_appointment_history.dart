import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:goa_dental_clinic/custom_widgets/appointment_history_card.dart';

import '../../custom_widgets/appointment_card.dart';

class PatientAppointmentHistory extends StatefulWidget {
  const PatientAppointmentHistory({Key? key}) : super(key: key);

  @override
  State<PatientAppointmentHistory> createState() => _PatientAppointmentHistoryState();
}

class _PatientAppointmentHistoryState extends State<PatientAppointmentHistory> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? uid;
  bool isLoading = true;
  List<AppointmentHistoryCard> appList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    uid = auth.currentUser!.uid;
    getAppointments();
  }

  getAppointments() async {
    setState(() {
      isLoading = true;
    });

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Appointment History',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: StreamBuilder(
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: kPrimaryColor,
                  ),
                );
              } else {
                appList.clear();
                for (var app in snapshot.data!.docs) {
                  try {
                    String status = app['status'];
                    if(status != 'Cancelled')
                      if(DateTime.now().millisecondsSinceEpoch > double.parse(app['startTimeInMil'])){
                        status = 'Completed';
                      }
                    appList.add(AppointmentHistoryCard(
                        size: size,
                        patientName: app['patientName'],
                        week: app['week'],
                        date: app['date'],
                        time: app['time'],
                        onMorePressed: () {},
                        doctorName: app['doctorName'],
                        doctorUid: app['doctorUid'],
                        patientUid: app['patientUid'],
                        appId: app['appId'],
                        status: status,
                        pm: null,
                        startTimeInMil: app['startTimeInMil'],
                        month: app['month'],
                        endTimeInMil: app['endTimeInMil'],
                        refresh: () {}),);
                  } catch (e) {
                    print(e);
                    continue;
                  }
                }

                return ListView.builder(
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: appList[index],
                      );
                    },
                    itemCount: appList.length);
              }
            },
            stream: firestore
                .collection('Patients')
                .doc(uid)
                .collection('History')
                .snapshots(),
          ),
        ),
      ),
    );
  }
}
