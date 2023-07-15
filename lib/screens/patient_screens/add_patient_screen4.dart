import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:goa_dental_clinic/custom_widgets/custom_button.dart';
import 'package:goa_dental_clinic/custom_widgets/medical_check_box.dart';
import 'package:goa_dental_clinic/custom_widgets/treatment_text_field.dart';
import 'package:googleapis/chat/v1.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../custom_widgets/patient_dropdown.dart';
import '../../custom_widgets/patient_text_field.dart';
import '../../providers/add_patient_provider.dart';

class AddPatientScreen4 extends StatefulWidget {
  AddPatientScreen4({required this.updateData});
  Function updateData;

  @override
  State<AddPatientScreen4> createState() => _AddPatientScreen4State();
}

class _AddPatientScreen4State extends State<AddPatientScreen4> {

  File? fi;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  String uid = '';
  List<String> selectedDiseaseList = [];
  bool isLoading = false;
  TextEditingController controller = TextEditingController();
  late TextEditingController historyController;
  List<String> alreadyCheckedList = [" lij", '2908'];
  List<String> checkedList = [];

  updateData() {
    widget.updateData(checkedList);
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    uid = auth.currentUser!.uid;
    historyController =  TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_){
      updateData();
    });
    // initDiseaseList();
    // getDetails();
  }

  getDetails() async {
    try {
      final data = await firestore.collection('Patients').doc(uid).collection(
          'Medical History').get();
        selectedDiseaseList.clear();
        for (var disease in data.docs) {
          selectedDiseaseList.add(disease['disease']);
        }
    }catch(e){
      setState(() {
        isLoading = false;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  checkIfExists(disease){
    if(disease != '')
    for(var dis in selectedDiseaseList){
      if(dis.trim() == disease.trim()){
        return true;
      }
    }
    return false;
  }


  bool isChecked(e){
    for(var element in alreadyCheckedList){
      if(e.trim() == element.trim())
        return true;
    }
    return false;
  }

  addCustom(){

    showDialog(context: context, builder: (context){

      Size size = MediaQuery.of(context).size;
      return Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white,),
            height: size.height * 0.2,
            width: size.width * 0.9,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    controller: historyController,
                    decoration: InputDecoration(hintText: 'Type here', border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),),
                    onChanged: (newValue){

                    },
                  ),
                  SizedBox(height: 16,),
                  CustomButton(text: 'ADD', backgroundColor: kPrimaryColor, onPressed: (){
                    setState(() {
                      diseaseList.add(historyController.text);
                    });
                    Navigator.pop(context);
                  }),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    alreadyCheckedList = Provider.of<AddPatientProvider>(context).mList;
    checkedList = alreadyCheckedList;

    return Stack(
      children: [
        Container(
          child: isLoading ? Center(child: CircularProgressIndicator(color: kPrimaryColor,),) : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Medical History',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      '(Optional)',
                      style: TextStyle(color: kGrey),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Container(
                  height: size.height * 0.6,
                  child: SingleChildScrollView(
                    child: Column(
                      children: diseaseList.map((e){
                        bool val = isChecked(e);
                        return MedicalCheckBox(title: e, onChanged: (val, title){
                          if(val) {
                            checkedList.add(title);
                            Provider.of<AddPatientProvider>(context, listen: false).setList(checkedList);
                            updateData();
                          }
                          else {
                            checkedList.remove(title);
                            Provider.of<AddPatientProvider>(context, listen: false).setList(checkedList);
                          }
                        }, isChecked: val,);
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: InkWell(
            onTap: (){
              addCustom();
            },
            child: CircleAvatar(
              child: Icon(Icons.add, color: Colors.white, size: 30,),
              backgroundColor: kPrimaryColor,
              radius: 30,
            ),
          ),
        )
      ],
    );
  }
}
