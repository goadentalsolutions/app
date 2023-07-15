import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/classes/get_patient_details.dart';
import 'package:goa_dental_clinic/classes/pref.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:goa_dental_clinic/custom_widgets/custom_button.dart';
import 'package:goa_dental_clinic/models/app_model.dart';
import 'package:goa_dental_clinic/models/doctor_model.dart';
import 'package:goa_dental_clinic/models/patient_model.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/appointment_screen.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import 'package:googleapis_auth/auth.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../classes/date_time_parser.dart';
import '../../classes/meeting_data_source.dart';
import '../../models/plan_model.dart';

class CalendarScreen2 extends StatefulWidget {
  CalendarScreen2({required this.planModel, required this.pm});
  PlanModel planModel;
  PatientModel pm;

  @override
  State<CalendarScreen2> createState() => _CalendarScreen2State();
}

class _CalendarScreen2State extends State<CalendarScreen2> {
  CalendarController controller = CalendarController();
  late String formattedTime, formmatedDate;
  List<DropDownValueModel> doctorList = [];
  List<DropDownValueModel> patientList = [];
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  late String uid;
  late String patientName, doctorName, patientUid;
  PatientModel? pm;
  String? appId;
  late String startTimeInMil, endTimeInMil;
  var dataSource;
  bool isLoading = true;
  List<Appointment> meetings = [];
  var _credentials, _clientID;
  static const _scopes = const [cal.CalendarApi.calendarScope];
  TextEditingController planController = TextEditingController();
  TextEditingController patientController = TextEditingController();
  late DoctorModel dm;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    uid = auth.currentUser!.uid;
    patientController.text = widget.pm.patientName;
    patientName = patientController.text;
    planController.text = widget.planModel.plan;
    getDoctors();
    getAppointments();
  }

  getAppointments() async {
    setState(() {
      isLoading = true;
    });

    final datas = await firestore
        .collection('Doctors')
        .doc(uid)
        .collection('Appointments')
        .get();

    for (var data in datas.docs) {
      DateTime dt = DateTime.fromMillisecondsSinceEpoch(
          int.parse(data['startTimeInMil']));
      DateTime dt2 =
          DateTime.fromMillisecondsSinceEpoch(int.parse(data['endTimeInMil']));
      if (dt.hour == 0) {
        meetings.add(
          Appointment(
              isAllDay: true,
              startTime: dt,
              endTime: dt2,
              subject: data['patientName'],
              color: kPrimaryColor),
        );
      } else {
        meetings.add(
          Appointment(
            startTime: dt,
            endTime: dt2,
            subject: data['patientName'],
            color: kPrimaryColor,
          ),
        );
      }
    }

    setState(() {
      isLoading = false;
    });
    return meetings;
  }

  getDoctors() async {

    //current doctor name
    final data = await firestore.collection('Doctors').doc(uid).get();
    setState(() {
      doctorName = data['name'];
      dm = DoctorModel(name: data['name'], uid: data['uid']);
    });

    //get all doctors
    final docs = await firestore.collection('Doctors').get();
    // List<DoctorModel> docmList = [];
    doctorList.clear();
    setState(() {
      for(var doc in docs.docs){
        // dmList.add(DoctorModel(name: doc['name'], uid: doc['uid']));
        doctorList.add(DropDownValueModel(name: doc['name'], value: DoctorModel(name: doc['name'], uid: doc['uid'])));
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: !isLoading
            ? Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.0),
                    height: size.height * 0.05,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Selected doctor: ', style: TextStyle(fontSize: 16),),
                        Container(
                          height: size.height * 0.05,
                          width: size.width * 0.5,
                          child: DropDownTextField(dropDownList: doctorList, onChanged: (value){
                            DropDownValueModel val = value;
                            DoctorModel dm2 = val.value;
                            setState(() {
                              doctorName = val.name;
                              dm = dm2;
                            });
                          },enableSearch: true ,textFieldDecoration: InputDecoration(hintText: doctorName, hintStyle: TextStyle(color: Colors.black),), searchDecoration: InputDecoration(hintText: 'Search'),),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SfCalendar(
                      view: CalendarView.week,
                      dataSource: MeetingDataSource(meetings),
                      onTap: (details) {
                        var parser = DateTimeParser(details.date.toString());
                        // creatingEvent(details!.date! , DateTime.now());
                        appId = DateTime.parse(details.date.toString())
                            .millisecondsSinceEpoch
                            .toString();
                        setState(() {
                          formattedTime = parser.getFormattedTime();
                          formmatedDate = parser.getFormattedDate();
                          startTimeInMil =
                              details.date!.millisecondsSinceEpoch.toString();
                          endTimeInMil = details.date!
                              .add(Duration(hours: 1))
                              .millisecondsSinceEpoch
                              .toString();
                        });
                        showDialog(
                            context: context,
                            builder: (context) {
                              return Material(
                                color: Colors.transparent,
                                child: Center(
                                  child: Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    height: size.height * 0.4,
                                    width: size.width * 0.8,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Appointment at',
                                                style: TextStyle(
                                                    fontSize: 22,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            InkWell(
                                              child: Icon(
                                                Icons.highlight_remove_outlined,
                                                color: Colors.red,
                                              ),
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          '$formattedTime $formmatedDate',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        SizedBox(
                                          height: 16,
                                        ),
                                        // Text(
                                        //   'Doctor: ',
                                        //   style: TextStyle(fontSize: 16),
                                        // ),
                                        // SizedBox(
                                        //   height: 8,
                                        // ),
                                        // DropDownTextField(
                                        //   dropDownList: doctorList,
                                        //   onChanged: (value) {
                                        //     setState(() {
                                        //       DropDownValueModel val = value;
                                        //       doctorName = val.name;
                                        //     });
                                        //   },
                                        //   textFieldDecoration: InputDecoration(
                                        //       border: OutlineInputBorder(
                                        //         borderSide: BorderSide(color: Colors.black),
                                        //       ),
                                        //       hintText: 'Add Doctor'),
                                        // ),
                                        // SizedBox(
                                        //   height: 16,
                                        // ),
                                        Text(
                                          'Patient: ',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        TextField(
                                          controller: patientController,
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.black),
                                              ),
                                              hintText: 'Add Patient'),
                                        ),
                                        SizedBox(
                                          height: 16,
                                        ),
                                        Text(
                                          'Plan: ',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        TextField(
                                          controller: planController,
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.black),
                                              ),
                                              hintText: 'Type plan'),
                                        ),
                                        SizedBox(
                                          height: 16,
                                        ),
                                        Expanded(
                                          child: CustomButton(
                                              text: 'Schedule',
                                              backgroundColor: kPrimaryColor,
                                              onPressed: () async {
                                                try {
                                                  AppModel am = AppModel(
                                                      plan: planController.text,
                                                      toothList: widget
                                                          .planModel.toothList,
                                                      patientName: patientName,
                                                      doctorName: doctorName,
                                                      date: parser.date,
                                                      week: parser.getWeek(),
                                                      time: parser
                                                          .getFormattedTime(),
                                                      doctorUid: dm.uid,
                                                      patientUid:
                                                          widget.pm.patientUid,
                                                      pm: widget.pm,
                                                      appId: appId!,
                                                      startTimeInMil:
                                                          startTimeInMil,
                                                      endTimeInMil:
                                                          endTimeInMil,
                                                      month: parser.getMonth());
                                                  Navigator.pop(context);
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              AppointmentScreen(
                                                                  am: am)));
                                                } catch (e) {
                                                  Navigator.pop(context);
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                    content: Text(
                                                        'Enter valid values $e'),
                                                    backgroundColor: Colors.red,
                                                  ));
                                                }
                                              }),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            });
                      },
                      controller: controller,
                    ),
                  ),
                ],
              )
            : Center(
                child: CircularProgressIndicator(
                  color: kPrimaryColor,
                ),
              ),
      ),
    );
  }
}
