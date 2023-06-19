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

  String phone1 = '', phone2 = '', language = '', email = '', streetAddress = '', locality = '', city = '', pincode = '';
  Map<String, String>? data;
  File? fi;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  String uid = '';

  updateData(){
    data = {
      'phoneNumber1' : phone1,
      'phoneNumber2' : phone2,
      'language' : language,
      'email' : email,
      'streetAddress' : streetAddress,
      'locality' : locality,
      'city' : city,
      'pincode' : pincode,
    };
    widget.updateData(data);
  }

  pickImage() async {
    final image = await ImagePicker.platform.pickImage(source: ImageSource.gallery);
    if(image == null){
      print('image null');
    }
    else{
      setState(() {
        fi = File(image.path);
      });
      widget.updateData(fi);
    }
  }

  uploadImage() async {
    try {
      await storage.ref().child('profiles').child(DateTime.now().millisecondsSinceEpoch.toString()).putFile(fi!).whenComplete(() {
        print('hello moto');
      });
    }
    catch(e){
      print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    uid = auth.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    
    return Container(
      child: SingleChildScrollView(
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
                  child: (fi == null) ? SvgPicture.asset('svgs/file.svg') : Image.file(fi!, fit: BoxFit.cover,),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
