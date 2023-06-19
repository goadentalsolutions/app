import '../models/patient_model.dart';

class  GetPatientDetails{

  get(data){
    PatientModel? pm;
    try {
      pm = PatientModel(patientUid: data['patientUid'],
        patientName: data['patientName'],
        email: data['email'],
        dob: data['dob'],
        gender: data['gender'],
        city: data['city'],
        age: data['age'],
        aadharId: data['aadharId'],
        anniversary: data['anniversary'],
        bloodGrp: data['bloodGrp'],
        language: data['language'],
        locality: data['locality'],
        phoneNumber2: data['phoneNumber2'],
        pincode:
        data['pincode'],
        phoneNumber1: data['phoneNumber1'],
        streetAddress: data['streetAddress'],
        patientId: data['patientId'],
        profileUrl: data['profileUrl'], token: data['token']);
      print(pm.patientUid+pm.locality+pm.anniversary+pm.dob+pm.token);
    }
    catch(e){
      print(e);
    }
    return pm;
    }
}