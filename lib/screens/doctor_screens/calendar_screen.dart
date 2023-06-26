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
import 'package:goa_dental_clinic/models/patient_model.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/appointment_screen.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import 'package:googleapis_auth/auth.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../classes/date_time_parser.dart';
import '../../classes/meeting_data_source.dart';


class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
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
  var _credentials, _clientID ;
  static const _scopes = const [cal.CalendarApi.calendarScope];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    uid = auth.currentUser!.uid;
    getDoctors();
    getPatients();
    getAppointments();
    createCredentials();
    // cell();
  }

  createCredentials(){
    // if (Theme.of(context).platform == TargetPlatform.android) {
      _credentials = new ClientId(
          "63175124233-l6vpv8a6pumkt9hvd6liamt2l20tv3qf.apps.googleusercontent.com",
          "");
      _clientID = '63175124233-l6vpv8a6pumkt9hvd6liamt2l20tv3qf.apps.googleusercontent.com';
    // } else if (Theme.of(context).platform == TargetPlatform.iOS) {
    //   _credentials = new ClientId(
    //       "63175124233-s577tq06s59rb5iclv5g447sf8biq32s.apps.googleusercontent.com",
    //       "");
    //   _clientID = '63175124233-s577tq06s59rb5iclv5g447sf8biq32s.apps.googleusercontent.com';
    // }
  }

  creatingEvent(DateTime startTime, DateTime endTime){
    cal.Event event = cal.Event(); // Create object of event

    cal.EventDateTime start = new cal.EventDateTime(); //Setting start time
    start.dateTime = startTime;
    start.timeZone = "GMT+05:00";
    event.start = start;


    cal.EventDateTime end = new cal.EventDateTime(); //setting end time
    end.timeZone = "GMT+05:00";
    end.dateTime = endTime;
    event.end = end;

    insertEvent(event);
  }

  insertEvent(event){
    try {
      clientViaUserConsent(_credentials, _scopes, prompt).then((AuthClient client){
        var calendar = cal.CalendarApi(client);
        String calendarId = "primary";
        calendar.events.insert(event,calendarId).then((value) {
          print("ADDEDDD_________________${value.status}");
          if (value.status == "confirmed") {
            log('Event added in google calendar');
          } else {
            log("Unable to add event in google calendar");
          }
        });
      });
    } catch (e) {
      log('Error creating event $e');
    }
  }


  void prompt(String url) async {

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  getAppointments() async {

    setState(() {
      isLoading = true;
    });

    final datas = await firestore.collection('Doctors').doc(uid).collection('Appointments').get();

    for(var data in datas.docs){
      print('da');
      DateTime dt = DateTime.fromMillisecondsSinceEpoch(int.parse(data['startTimeInMil']));
      DateTime dt2 = DateTime.fromMillisecondsSinceEpoch(int.parse(data['endTimeInMil']));
      if(dt.hour == 0){
        meetings.add(Appointment(isAllDay: true, startTime: dt, endTime: dt2, subject: data['patientName'], color:  kPrimaryColor),);
      }
      else{
        meetings.add(Appointment(startTime: dt, endTime: dt2, subject: data['patientName'], color:  kPrimaryColor,),);
      }
    }

    try {
      print(meetings);
    }
    catch(e){
      print(e);
    }
    setState(() {
      isLoading = false;
    });
    return meetings;
  }

  getDoctors() async {
    // final doctors  = await firestore.collection('Doctors').get();
    // doctorList.clear();
    // for(var doctor in doctors.docs){
    //   print(doctor['name']);
    //   doctorList.add(DropDownValueModel(name: doctor['name'], value: doctor['uid'], toolTipMsg:
    //   "DropDownButton is a widget that we can use to select one unique value from a set of values"),);
    // }
    final data = await firestore.collection('Doctors').doc(uid).get();
    String name = data['name'];
    doctorList.add(DropDownValueModel(name: name, value: uid));
    setState(() {});
  }

  getPatients() async {
    final patients = await firestore.collection('Patients').get();
    patientList.clear();
    for (var patient in patients.docs) {
      patientList.add(DropDownValueModel(
          name: patient['patientName'], value: patient['patientUid']));
    }
    setState(() {});
  }

  Future getPatientDetails() async {

    print('${patientUid}s');
    final datas = await firestore.collection('Patients').get();
    PatientModel? pm;
    setState(() {
      for(var data in datas.docs) {
        if(patientName == data['patientName'])
        pm = GetPatientDetails().get(data);
      }
    });
    return pm;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: !isLoading ? SfCalendar(
          view: CalendarView.week,
          dataSource: MeetingDataSource(meetings),
          // appointmentBuilder: (context, details){
          //
          //   print(meetings.first);
          //   print(details.appointments.first);
          //   for(Appointment detail in details.appointments){
          //     for(Appointment meeting in meetings){
          //       if(meeting.startTime == detail.startTime && meeting.endTime == detail.endTime){
          //         MeetingDataSource([meeting]);
          //       }
          //     }
          //   }
          //
          //   if(true){
          //     return Container(
          //       color: Colors.blue, // Set the background color for the cell
          //       child: Center(
          //         child: Icon(Icons.check, color: Colors.white,),
          //       ),
          //     );
          //   }
          //   return Container();
          // },
          onTap: (details) {
            var parser = DateTimeParser(details.date.toString());
            // creatingEvent(details!.date! , DateTime.now());
            appId = DateTime.parse(details.date.toString()).millisecondsSinceEpoch.toString();
            setState(() {
              formattedTime = parser.getFormattedTime();
              formmatedDate = parser.getFormattedDate();
              startTimeInMil = details.date!.millisecondsSinceEpoch.toString();
              endTimeInMil = details.date!.add(Duration(hours: 1)).millisecondsSinceEpoch.toString();
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
                            borderRadius: BorderRadius.circular(16)),
                        height: size.height * 0.4,
                        width: size.width * 0.8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Appointment at',
                                    style: TextStyle(
                                        fontSize: 22,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold)),
                                InkWell(child: Icon(Icons.highlight_remove_outlined, color: Colors.red,), onTap: (){
                                  Navigator.pop(context);
                                },)
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
                            Text(
                              'Doctor: ',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            DropDownTextField(
                              dropDownList: doctorList,
                              onChanged: (value) {
                                setState(() {
                                  DropDownValueModel val = value;
                                  doctorName = val.name;
                                });
                              },
                              textFieldDecoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                  hintText: 'Add Doctor'),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              'Patient: ',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            DropDownTextField(
                              dropDownList: patientList,
                              enableSearch: true,
                              searchDecoration: InputDecoration(hintText: 'Search'),
                              onChanged: (value) {
                                setState(() {
                                  DropDownValueModel val = value;
                                  patientName = val.name;
                                  patientUid = val.value;
                                  print(patientUid);
                                });
                              },
                              textFieldDecoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                  hintText: 'Add Patient'),
                            ),
                            SizedBox(height: 16,),
                            Expanded(
                              child: CustomButton(
                                  text: 'Schedule',
                                  backgroundColor: kPrimaryColor,
                                  onPressed: () async {
                                    try {
                                      AppModel am = AppModel(
                                        patientName: patientName,
                                        doctorName: doctorName,
                                        date: parser.date,
                                        week: parser.getWeek(),
                                        time: parser.getFormattedTime(),
                                        doctorUid: uid,
                                        patientUid: patientUid,
                                        pm: await getPatientDetails(),
                                        appId: appId!,
                                        startTimeInMil: startTimeInMil,
                                        endTimeInMil: endTimeInMil,
                                        month: parser.getMonth()
                                      );
                                      Navigator.pop(context);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  AppointmentScreen(am: am)));
                                    }
                                    catch(e){
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Enter valid values'), backgroundColor: Colors.red,));
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
        ) : Center(
          child: CircularProgressIndicator(color: kPrimaryColor,),
        ),
      ),
    );
  }
}

