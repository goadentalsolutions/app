import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:goa_dental_clinic/custom_widgets/custom_button.dart';
import 'package:goa_dental_clinic/custom_widgets/selection_prescription_card.dart';
import 'package:goa_dental_clinic/custom_widgets/selection_with_tooth.dart';
import 'package:goa_dental_clinic/providers/add_plan_provider.dart';
import 'package:goa_dental_clinic/providers/add_pre_provider.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/nav_screen.dart';
import 'package:googleapis/vision/v1.dart';
import 'package:provider/provider.dart';

import '../../models/plan_model.dart';
import '../../models/pre_model.dart';

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
  List<PreModel> preList = [];
  List<PlanModel> selectedPlanList = [];
  List<PreModel> selectedPreList = [];
  String title = '', des = '';
  bool isChecked = false;

  createCard() {
    showDialog(
        context: context,
        builder: (context) {
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        maxLines: null,
                        onChanged: (newValue) {
                          setState(() {
                            titleName = newValue;
                          });
                        },
                        decoration: InputDecoration(hintText: 'Enter title'),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Container(
                    child: CustomButton(
                        text: 'ADD',
                        backgroundColor: kPrimaryColor,
                        onPressed: () {
                          setState(() {
                            planList
                                .add(PlanModel(plan: titleName, toothList: []));
                            Provider.of<AddPlanProvider>(context, listen: false)
                                .setPList(selectedPlanList);
                          });
                          Navigator.pop(context);
                        }),
                    width: 80,
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Container(
                    child: CustomButton(
                        text: 'CANCEL',
                        backgroundColor: kPrimaryColor,
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    width: 80,
                  ),
                ],
              ),
            ),
          );
        });
  }

  createPre(){
    showDialog(
        context: context,
        builder: (context) {
          return Material(
            color: Colors.transparent,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SelectionPrescriptionCard(title: '', readOnly: false, onChecked: (checked, tit, d){
                      setState(() {
                        isChecked = checked;
                        title = tit;
                        des = d;
                      });
                    }, des: '', onChanged: (checked, tit, d){
                      setState(() {
                        isChecked = checked;
                        title = tit;
                        des = d;
                      });
                    },),
                    SizedBox(
                      height: 12,
                    ),
                    Container(
                      child: CustomButton(
                          text: 'ADD',
                          backgroundColor: kPrimaryColor,
                          onPressed: () {
                            setState(() {
                              PreModel pm = PreModel(title: title, des: des, isChecked: isChecked);
                              preList.add(pm);
                              if(isChecked){
                                selectedPreList.add(pm);
                                Provider.of<AddPreProvider>(context, listen: false)
                                    .setPList(selectedPreList);
                              }
                            });
                            Navigator.pop(context);
                          }),
                      width: 80,
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Container(
                      child: CustomButton(
                          text: 'CANCEL',
                          backgroundColor: kPrimaryColor,
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                      width: 80,
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }


  save() async {
    for (var e in selectedPreList) {
      print("${e.title + e.des.toString()}");
    }

    for (var plan in selectedPlanList) {
      firestore
          .collection('Patients')
          .doc(widget.patientUid)
          .collection('Plans')
          .doc(plan.plan)
          .set({
        "plan": plan.plan,
        "toothList": plan.toothList,
      });
    }


    for (var pre in selectedPreList) {
      firestore
          .collection('Patients')
          .doc(widget.patientUid)
          .collection('Plan Prescriptions')
          .doc(pre.title)
          .set({
        "title": pre.title,
        "des": pre.des,
      });
    }

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => NavScreen()));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    addInitialCards();
  }

  addInitialCards() {
    setState(() {
      var list = Provider.of<AddPlanProvider>(context, listen: false).pList;
      var list2 = Provider.of<AddPreProvider>(context, listen: false).pList;

      planList.add(
        PlanModel(plan: 'Scalling and polishing', toothList: []),
      );
      planList.add(
        PlanModel(plan: 'Deep Scaling', toothList: []),
      );
      planList.add(
        PlanModel(plan: 'Composite filings', toothList: []),
      );
      planList.add(
        PlanModel(plan: 'GIC fillings', toothList: []),
      );
      planList.add(
        PlanModel(plan: 'Root canal treatment', toothList: []),
      );
      planList.add(
        PlanModel(plan: 'Crowns and bridges', toothList: []),
      );
      planList.add(
        PlanModel(plan: 'Implants', toothList: []),
      );
      planList.add(
        PlanModel(plan: 'Removable partial denture', toothList: []),
      );
      planList.add(
        PlanModel(plan: 'Complete denture', toothList: []),
      );

      preList.add(
        PreModel(title: 'Drug', des: 'drug is harmful'),
      );

      List<PlanModel> pmList = [];
      List<PreModel> pmList2 = [];
      for (var li in list) {
        var value = 0;
        for (var plan in planList) {
          if (li.plan == plan.plan) {
            value = 1;
            plan.toothList = li.toothList;
            plan.isChecked = li.isChecked;
          }
        }
        if (value == 0) {
          pmList.add(li);
        }
      }

      for (var li in list2) {
        var value = 0;
        for (var pre in preList) {
          if (li.title == pre.title) {
            value = 1;
            pre.isChecked = li.isChecked;
            pre.des = li.des;
          }
        }
        if (value == 0) {
          pmList2.add(li);
        }
      }

      for (var plan in pmList) {
        planList.add(plan);
      }


      for (var pre in pmList2) {
        preList.add(pre);
      }


      for (var plan in planList) {
        if (plan.isChecked) selectedPlanList.add(plan);
      }

      for (var pre in preList) {
        if (pre.isChecked) selectedPreList.add(pre);
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    // addInitialCards();

    return Scaffold(
      appBar: AppBar(
        title: Text("Treatment Plan"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          save();
        },
        child: Icon(Icons.save),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Column(
                    children: planList.map((e) {
                      return SelectionWithTooth(
                        title: e.plan,
                        addList: e.toothList,
                        onAdd: (list, title, isChecked) {
                          e.toothList = list;
                          if (isChecked) {
                            selectedPlanList.forEach((element) {
                              if (element == title) {
                                element.toothList = list;
                              }
                            });
                            Provider.of<AddPlanProvider>(context, listen: false)
                                .setPList(selectedPlanList);
                          } else {
                            selectedPlanList.remove(e);
                            Provider.of<AddPlanProvider>(context, listen: false)
                                .setPList(selectedPlanList);
                          }
                        },
                        onChecked: (value, title) {
                          try {
                            if (value) {
                              selectedPlanList.add(PlanModel(
                                  plan: e.plan,
                                  toothList: e.toothList,
                                  isChecked: value));
                              Provider.of<AddPlanProvider>(context,
                                      listen: false)
                                  .setPList(selectedPlanList);
                            } else {
                              selectedPlanList.remove(e);
                              Provider.of<AddPlanProvider>(context,
                                      listen: false)
                                  .setPList(selectedPlanList);
                            }
                          } catch (e) {
                            print(e);
                          }
                        },
                        isChecked: e.isChecked,
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      createCard();
                    });
                  },
                  child: !isCreatingCard
                      ? Container(
                          height: 80,
                          decoration: BoxDecoration(
                              color: kPrimaryColor,
                              borderRadius: BorderRadius.circular(12)),
                          child: Center(
                            child: Text(
                              "Add Plan",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      : Container(),
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  'Prescriptions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 8,
                ),
                Column(
                  children: preList.map((e){

                    return SelectionPrescriptionCard(title: e.title, onChecked: (value, title, des){
                      setState(() {
                        if(value){
                          selectedPreList.add(PreModel(title: title, des: des, isChecked: value),);
                          Provider.of<AddPreProvider>(context, listen: false)
                              .setPList(selectedPreList);
                        }
                        else{
                          selectedPreList.remove(PreModel(title: title, des: des, isChecked: value),);
                          Provider.of<AddPreProvider>(context, listen: false)
                              .setPList(selectedPreList);
                        }
                      });
                    }, des: e.des, isChecked: e.isChecked,);
                  }).toList(),
                ),
                SizedBox(
                  height: 16,
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      createPre();
                    });
                  },
                  child: !isCreatingCard
                      ? Container(
                          height: 80,
                          decoration: BoxDecoration(
                              color: kPrimaryColor,
                              borderRadius: BorderRadius.circular(12)),
                          child: Center(
                            child: Text(
                              "Add Prescription",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      : Container(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TitleTooth {
  String title;
  List<int> tooth;

  TitleTooth({required this.title, required this.tooth});
}
