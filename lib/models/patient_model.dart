import 'package:flutter/material.dart';

class PatientModel {
  String patientName,
      patientUid,
      gender,
      dob,
      age, profileUrl, token;

  //Contact Details
  String phoneNumber1,
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
    required this.locality,
    required this.phoneNumber1,
    required this.pincode,
    required this.streetAddress,
    required this.profileUrl,
    this.token = '',
  });
}
