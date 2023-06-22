import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:goa_dental_clinic/classes/get_patient_details.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:goa_dental_clinic/models/patient_model.dart';
import 'package:goa_dental_clinic/screens/patient_screens/add_patient_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../classes/get_initials.dart';
import '../../classes/pref.dart';
import '../../custom_widgets/appointment_card.dart';
import '../../custom_widgets/home_top_bar.dart';
import '../../custom_widgets/image_container.dart';
import '../../custom_widgets/long_image_container.dart';
import '../../custom_widgets/search_box.dart';
import 'manage_appointments_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  FirebaseAuth auth = FirebaseAuth.instance;
  String name = 'A';
  late String uid;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<AppointmentCard> appList = [];
  bool isLoading = true;
  bool isAppLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // fetchData().getData();
    uid = auth.currentUser!.uid;
    getDetails();
    getUpcomingAppoitments(context);
  }

  getUpcomingAppoitments(context) async {
    setState(() {
      isAppLoading = true;
    });
    final patients = await firestore.collection('Doctors').doc(uid).collection('Appointments').get();

    appList.clear();

    for(var patient in patients.docs){

      if(DateTime.fromMillisecondsSinceEpoch(int.parse(patient['appId'])).day == DateTime.now().day) {
        final datas = await firestore.collection('Patients').get();
        PatientModel? pm;
        if (DateTime
            .now()
            .millisecondsSinceEpoch < double.parse(patient['startTimeInMil'])) {
          for (var data in datas.docs) {
            if (patient['patientName'] == data['patientName'])
              pm = GetPatientDetails().get(data);
          }
          appList.add(AppointmentCard(size: MediaQuery
              .of(context)
              .size,
            patientName: patient['patientName'],
            week: patient['week'],
            date: patient['date'],
            time: patient['time'],
            onMorePressed: (int itemNo) {},
            doctorName: patient['doctorName'],
            doctorUid: patient['doctorUid'],
            patientUid: patient['patientUid'],
            status: 'homescreen',
            appId: patient['appId'],
            startTimeInMil: patient['startTimeInMil'],
            endTimeInMil: patient['endTimeInMil'],
            month: patient['month'],
            refresh: (appId) {
              late AppointmentCard card;
              appList.forEach((element) {
                if (element.appId == appId) {
                  card = element;
                }
              });
              setState(() {
                if (card != null)
                  appList.remove(card);
              });
            },
            pm: pm,));
        }
      }
    }
    appList.sort((a, b) => a.appId.compareTo(b.appId));
    setState(() {
      isAppLoading = false;
    });
  }

  getDetails() async {
    print(uid);
    setState(() {
      isLoading = true;
    });
    final data = await firestore.collection('Doctors').doc(uid).get();
    name = data['name'];
    setState(() {
      isLoading = false;
    });
  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     Navigator.push(context, MaterialPageRoute(builder: (context) => AddPatientScreen()));
      //     // auth.signOut();
      //     // extractText();
      //   },
      //   child: Icon(Icons.add),
      // ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeTopBar(
                initials: GetInitials(name).get(),
                primaryText: '$name',
              ),
              SizedBox(
                height: 16,
              ),
              LongImageContainer(
                  size: MediaQuery.of(context).size,
                  imgAddress: 'svgs/doctors.svg',
                  text: 'All Appointments',
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ManageAppointmentsScreen()));
                  }
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                'Today\'s Appointments',
                style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 16,
              ),
              isLoading ? Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: kPrimaryColor),
                )
              ):
              Expanded(
                child: !(appList.isEmpty) ? ListView.builder(itemBuilder: (context, index){

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: appList[index],
                  );
                }, itemCount: appList.length,) : Container(
                  child: Center(
                    child: Text('No Appointments as of now', style: TextStyle(fontSize: 18, color: kGrey),),
                    // child: SvgPicture.asset('svgs/doctors.svg', height: MediaQuery.of(context).size.height * 0.3, width: MediaQuery.of(context).size.width * 0.3,),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

