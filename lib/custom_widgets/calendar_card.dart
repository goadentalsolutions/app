// import 'package:dropdown_textfield/dropdown_textfield.dart';
// import 'package:flutter/material.dart';
//
// import '../constants.dart';
// import '../models/app_model.dart';
// import '../screens/doctor_screens/appointment_screen.dart';
// import 'custom_button.dart';
//
// class CalendarCard extends StatefulWidget {
//   const CalendarCard({Key? key}) : super(key: key);
//
//   @override
//   State<CalendarCard> createState() => _CalendarCardState();
// }
//
// class _CalendarCardState extends State<CalendarCard> {
//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//
//     return Materiaxl(
//       color: Colors.transparent,
//       child: Center(
//         child: Container(
//           padding: EdgeInsets.all(16),
//           decoration: BoxDecoration(
//               color: Colors.white, borderRadius: BorderRadius.circular(16)),
//           height: size.height * 0.4,
//           width: size.width * 0.8,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Appointment at',
//                   style: TextStyle(
//                       fontSize: 22,
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold)),
//               SizedBox(
//                 height: 8,
//               ),
//               Text(
//                 '$formattedTime $formmatedDate',
//                 style: TextStyle(
//                     fontSize: 18,
//                     color: Colors.black,
//                     fontWeight: FontWeight.w500),
//               ),
//               SizedBox(
//                 height: 16,
//               ),
//               Text(
//                 'Doctor: ',
//                 style: TextStyle(fontSize: 16),
//               ),
//               SizedBox(
//                 height: 8,
//               ),
//               DropDownTextField(
//                 dropDownList: doctorList,
//                 onChanged: (value) {
//                   setState(() {
//                     DropDownValueModel val = value;
//                     doctorName = val.name;
//                   });
//                 },
//                 textFieldDecoration: InputDecoration(
//                     border: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.black),
//                     ),
//                     hintText: 'Add Doctor'),
//               ),
//               SizedBox(
//                 height: 16,
//               ),
//               Text(
//                 'Patient: ',
//                 style: TextStyle(fontSize: 16),
//               ),
//               SizedBox(
//                 height: 8,
//               ),
//               DropDownTextField(
//                 dropDownList: patientList,
//                 onChanged: (value) {
//                   setState(() {
//                     DropDownValueModel val = value;
//                     patientName = val.name;
//                     patientUid = val.value;
//                     print(patientUid);
//                   });
//                 },
//                 textFieldDecoration: InputDecoration(
//                     border: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.black),
//                     ),
//                     hintText: 'Add Patient'),
//               ),
//               Spacer(),
//               CustomButton(
//                   text: 'Schedule',
//                   backgroundColor: kPrimaryColor,
//                   onPressed: () {
//                     print(patientUid);
//                     AppModel am = AppModel(
//                         patientName: patientName,
//                         doctorName: doctorName,
//                         date: parser.date,
//                         week: parser.getWeek(),
//                         time: parser.getFormattedTime(),
//                         doctorUid: uid,
//                         patientUid: patientUid);
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => AppointmentScreen(am: am)));
//                   }),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
