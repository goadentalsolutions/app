import 'package:flutter/material.dart';

class PatientModel {
  String patientName,
      patientUid,
      aadharId,
      gender,
      dob,
      age,
      anniversary,
      bloodGrp, profileUrl, patientId, token;

  //Contact Details
  String phoneNumber1,
      phoneNumber2,
      language,
      email,
      streetAddress,
      locality,
      city,
      pincode;

  PatientModel({
    required this.patientUid,
    required this.patientName,
    required this.email,
    required this.dob,
    required this.gender,
    required this.city,
    required this.age,
    required this.aadharId,
    required this.anniversary,
    required this.bloodGrp,
    required this.language,
    required this.locality,
    required this.phoneNumber1,
    required this.pincode,
    required this.phoneNumber2,
    required this.streetAddress,
    required this.patientId,
    required this.profileUrl,
    this.token = '',
  });
}
