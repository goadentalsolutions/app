import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants.dart';
import '../../custom_widgets/patient_dropdown.dart';
import '../../custom_widgets/patient_text_field.dart';

class AddPatientScreen3 extends StatefulWidget {
  AddPatientScreen3({required this.updateData});
  Function updateData;

  @override
  State<AddPatientScreen3> createState() => _AddPatientScreen3State();
}

class _AddPatientScreen3State extends State<AddPatientScreen3> {

  Map<String, String>? data;
  File? fi;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  String uid = '';
  String url = '';
  bool isLoading = true;

  pickImage() async {
    final image = await ImagePicker.platform.pickImage(source: ImageSource.gallery);
    if(image == null){
      print('image null');
    }
    else{
      setState(() {
        fi = File(image.path);
      });
      widget.updateData(fi, url);
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    uid = auth.currentUser!.uid;
    getDetails();
  }

  getDetails() async {
    setState(() {
      isLoading = true;
    });
    final data = await firestore.collection('Patients').doc(uid).get();
    try {
      url = data['profileUrl'];
    }catch(e){
      print(e);
      setState(() {
        isLoading = false;
      });
    }
    setState(() {
      widget.updateData(fi, url);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    
    return Container(
      child: isLoading ? Center(child: CircularProgressIndicator(color: kPrimaryColor,),) : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Add you photo', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                SizedBox(width: 8,),
                Text('(Optional)', style: TextStyle(color: kGrey),),
              ],
            ),
            SizedBox(height: 16,),
            InkWell(
              onTap: (){
                pickImage();
              },
              child: Container(
                height: size.height * 0.5,
                width: size.width * 0.9,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: kGrey), color: kBackgroundColor),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: (fi == null && url == '') ? SvgPicture.asset('svgs/file.svg') : (url == '') ? Image.file(fi!, fit: BoxFit.cover,) : Image.network(url, fit: BoxFit.cover),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
