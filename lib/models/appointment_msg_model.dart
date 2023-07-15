import 'package:goa_dental_clinic/models/patient_model.dart';

class AppointmentMessageModel {
  String message,
      date,
      endTime,
      startTime,
      patientUid,
      patientName,
      week,
      appId,
      msgId,
      startTimeInMil,
      endTimeInMil, month, plan;
  List<dynamic> toothList = [];

  AppointmentMessageModel(
      {required this.date,
      this.message = '',
      required this.startTime,
      required this.endTime,
      required this.patientName,
      required this.patientUid,
      required this.appId,
      required this.week,
      required this.msgId,
      required this.startTimeInMil,
      required this.endTimeInMil,
      required this.month,
          required this.toothList,
          required this.plan,
      });
}
