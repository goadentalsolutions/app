import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:goa_dental_clinic/custom_widgets/image_viewer.dart';
import 'package:goa_dental_clinic/models/image_model.dart';
import 'package:goa_dental_clinic/models/patient_model.dart';

import '../../classes/get_patient_details.dart';

class PatientDetailsScreen extends StatefulWidget {
  PatientDetailsScreen({required this.pm, this.uid = ''});
  PatientModel? pm;
  String uid;

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  bool isLoading = false;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  List<String> medHisList = [];

  getMedicalHistory() async {
    setState(() {
      isLoading = true;
    });
    final diseases = await firestore.collection('Patients').doc(widget.uid).collection('Medical History').get();
    setState(() {
      for(var disease in diseases.docs){
        medHisList.add(disease['disease']);
        print(disease['disease']);
      }
    });
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.pm == null) {
      getDetails();
    }
    getMedicalHistory();
  }

  getDetails() async {
    print('ada');
    setState(() {
      isLoading = true;
    });
    final datas = await firestore.collection('Patients').doc(widget.uid).get();
    widget.pm = GetPatientDetails().get(datas);
    print(widget.pm!.profileUrl);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: !isLoading ? SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(child: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.black,), onTap: (){
                      Navigator.pop(context);
                    },),
                    SizedBox(width: 8,),
                    InkWell(child: CircleAvatar(backgroundImage: CachedNetworkImageProvider(widget.pm!.profileUrl),), onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ImageViewer(im: ImageModel(url: widget.pm!.profileUrl))));
                    },),
                    SizedBox(width: 8,),
                    Text('Rounak Naik', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),),
                  ],
                ),
                SizedBox(height: 12,),
                ExpansionTile(title: Text('Personal details', style: TextStyle(fontSize: 20),),
                children: [
                  RowText(title: 'Name: ', content: widget.pm!.patientName),
                  RowText(title: 'PatientId: ', content: widget.pm!.patientId),
                  RowText(title: 'Aadhar Id: ', content: widget.pm!.aadharId),
                  RowText(title: 'Gender: ', content: widget.pm!.gender),
                  RowText(title: 'Date of birth: ', content: widget.pm!.dob),
                  RowText(title: 'Age: ', content: widget.pm!.age),
                  RowText(title: 'Anniversary: ', content: widget.pm!.anniversary),
                  RowText(title: 'Blood group: ', content: widget.pm!.bloodGrp),
                ], initiallyExpanded: true,),
                SizedBox(height: 12,),
                ExpansionTile(title: Text('Contact details', style: TextStyle(fontSize: 20),),
                children: [
                  RowText(title: 'Primary Phonenumber: ', content: widget.pm!.phoneNumber1),
                  RowText(title: 'Secondary Phonenumber: ', content: widget.pm!.phoneNumber2),
                  RowText(title: 'Language: ', content: widget.pm!.language),
                  RowText(title: 'Email: ', content: widget.pm!.email),
                  RowText(title: 'Street Address: ', content: widget.pm!.streetAddress),
                  RowText(title: 'Locality: ', content: widget.pm!.locality),
                  RowText(title: 'City: ', content: widget.pm!.city),
                  RowText(title: 'Pincode: ', content: widget.pm!.pincode),
                ],),
                SizedBox(height: 12,),
                ExpansionTile(title: Text('Medical History', style: TextStyle(fontSize: 20),),
                  children: [
                    ListView.builder(itemBuilder: (context, index){

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(medHisList[index], style: TextStyle(fontSize: 16),),
                      );
                    }, itemCount: medHisList.length, shrinkWrap: true,),
                  ],),
              ]
            ),
          ) : Center(child: CircularProgressIndicator(color: kPrimaryColor,),),
        ),
      ),
    );
  }
}

class RowText extends StatelessWidget {
  RowText({required this.title, required this.content});
  String title, content;

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(title), subtitle: Text(content),);
  }
}

