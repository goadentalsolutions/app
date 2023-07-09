import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:goa_dental_clinic/custom_widgets/custom_button.dart';
import 'package:goa_dental_clinic/custom_widgets/selection_with_tooth.dart';
import 'package:goa_dental_clinic/providers/add_plan_provider.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/nav_screen.dart';
import 'package:provider/provider.dart';

import '../../models/plan_model.dart';

class TestScreen extends StatefulWidget {
  TestScreen({required this.patientUid});
  String patientUid;

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {

  List<Widget> cards = [];
  bool isCreatingCard = false;
  String titleName = '';
  List<String> titles = [];
  List<Map> toothListMap = [];
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  List<PlanModel> planList = [];
  List<PlanModel> selectedPlanList = [];

  createCard(){

    showDialog(context: context, builder: (context){

      return Material(
        color: Colors.transparent,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),),
                  child: TextField(
                    maxLines: null,
                    onChanged: (newValue){
                      setState(() {
                        titleName = newValue;
                      });
                    },
                    decoration: InputDecoration(hintText: 'Enter title'),
                  ),
                ),
              ),
              SizedBox(height: 12,),
              Container(child: CustomButton(text: 'ADD', backgroundColor: kPrimaryColor, onPressed: (){
                setState(() {
                  planList.add(
                    PlanModel(title: titleName, toothList: [])
                  );
                  Provider.of<AddPlanProvider>(context, listen: false).setPList(selectedPlanList);
                });
                Navigator.pop(context);
              }), width: 80,),
            ],
          ),
        ),
      );
    });
  }

  save() async {
    for(var e in selectedPlanList){
      print(e.toothList);
    }

    for(var plan in selectedPlanList){
      firestore.collection('Patients').doc(widget.patientUid).collection('Plans').doc(plan.title).set(
        {
          "title" : plan.title,
          "toothList" : plan.toothList,
        }
      );
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) => NavScreen()));
  }

  getPlansUsingProvider(){

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    addInitialCards();
  }

  addInitialCards(){
    setState(() {
      var list = Provider.of<AddPlanProvider>(context, listen: false).pList;

      if(list.isEmpty) {
        planList.add(
          PlanModel(title: 'Clining', toothList: []),
        );
        planList.add(
          PlanModel(title: 'Washing', toothList: [23, 123, 2]),
        );
      }
      else{
        planList = list;
      }

      for(var plan in planList){
        if(plan.isChecked)
          selectedPlanList.add(plan);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // addInitialCards();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          save();
        },
        child: Icon(Icons.save),
      ),
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(children: [
            ListView(
              shrinkWrap: true,
              children: planList.map((e){

                return SelectionWithTooth(title: e.title, addList: e.toothList ,onAdd: (list, title, isChecked){
                  e.toothList = list;
                  if(isChecked){
                    selectedPlanList.forEach((element) {
                      if(element == title){
                        element.toothList = list;
                      }
                    });
                    Provider.of<AddPlanProvider>(context, listen: false).setPList(selectedPlanList);
                  }
                  else{
                    selectedPlanList.remove(e);
                    Provider.of<AddPlanProvider>(context, listen: false).setPList(selectedPlanList);
                  }
                }, onChecked: (value, title){
                  try {
                    if (value) {
                      selectedPlanList.add(PlanModel(title: e.title, toothList: e.toothList, isChecked: value));
                      Provider.of<AddPlanProvider>(context, listen: false).setPList(selectedPlanList);
                    }
                    else {
                      selectedPlanList.remove(e);
                      Provider.of<AddPlanProvider>(context, listen: false).setPList(selectedPlanList);
                    }
                  }catch(e){
                    print(e);
                  }
                }, isChecked: e.isChecked,);
              }).toList(),
            ),
            InkWell(
              onTap: (){
                setState(() {
                  createCard();
                });
              },
              child: !isCreatingCard ? Container(
                height: 80,
                decoration: BoxDecoration(color: kPrimaryColor, borderRadius: BorderRadius.circular(12)),
                child: Center(
                  child: Text("Add Plan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                ),
              ) : Container(),
            )
          ],),
        ),
      ),),
    );
  }
}

class TitleTooth{
  String title;
  List<int> tooth;

  TitleTooth({required this.title, required this.tooth});
}