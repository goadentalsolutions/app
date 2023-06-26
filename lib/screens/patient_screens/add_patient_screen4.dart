import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:goa_dental_clinic/custom_widgets/custom_button.dart';
import 'package:goa_dental_clinic/custom_widgets/treatment_text_field.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants.dart';
import '../../custom_widgets/patient_dropdown.dart';
import '../../custom_widgets/patient_text_field.dart';

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
  List<DropDownValueModel> diseaseList = [];
  List<String> selectedDiseaseList = [];
  bool isLoading = true;
  TextEditingController controller = TextEditingController();
  
  updateData() {
    widget.updateData(selectedDiseaseList);
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    uid = auth.currentUser!.uid;
    initDiseaseList();
    getDetails();
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

  initDiseaseList(){
    diseaseList.add(DropDownValueModel(name: 'Diabates', value: 'Diabates'),);
    diseaseList.add(DropDownValueModel(name: 'Corona', value: 'Corona',));
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
            Row(
              children: [
                Expanded(
                  flex: 2,
                  // child: DropDownTextField(dropDownList: diseaseList, onChanged: (value){
                  //   if(value != null) {
                  //     setState(() {
                  //       DropDownValueModel val = value;
                  //       selectedDisease = val.name;
                  //     });
                  //   }
                  // }, controller: controller,),
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(hintText: 'Type here...'),
                  ),
                ),
                SizedBox(width: 12,),
                Expanded(child: CustomButton(text: 'ADD', backgroundColor: kPrimaryColor, onPressed: (){
                  setState(() {
                    if(!checkIfExists(controller.text))
                      selectedDiseaseList.add(controller.text);
                    controller.text = '';
                    updateData();
                  });
                })),
              ],
            ),
            SizedBox(height: 32,),
            ListView.builder(itemBuilder: (context, index){

              return ListTile(title: Text(selectedDiseaseList[index]), trailing: InkWell(child: Icon(Icons.cancel, color: Colors.red,), onTap: (){
                setState(() {
                  selectedDiseaseList.removeAt(index);
                });
                print('delete');
              },),);
            }, itemCount: selectedDiseaseList.length, shrinkWrap: true,),
          ],
        ),
      ),
    );
  }
}
