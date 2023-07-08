import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:goa_dental_clinic/custom_widgets/custom_button.dart';
import 'package:goa_dental_clinic/custom_widgets/selection_with_tooth.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/nav_screen.dart';

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
                  cards.add(
                    SelectionWithTooth(title: titleName, onAdd: (List<int> list, title) {
                      toothListMap.add(
                          {
                            "title" : title,
                            "list" : list,
                          }
                      );
                    }, onChecked: (bool isChecked, String title) {
                      print(isChecked);
                      if(isChecked)
                        titles.add(title);
                      else
                        titles.remove(title);
                    }, readOnly: true,),
                  );
                  titles.add(titleName);
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
    for(var e in titles){
      print(e);
    }
    String planId = DateTime.now().millisecondsSinceEpoch.toString();
    var fire = firestore.collection('Patients').doc(widget.patientUid).collection('Plans');

    //saving titles first
    for(var title in titles){
      firestore.collection('Patients').doc(widget.patientUid).collection('Plans').doc(title).set(
        {
          "title" : title,
          "planId" : planId,
          "toothList" : [],
        }
      );

      for(var map in toothListMap){
        if(map['title'] == title){
          //getting tooth list of that title
          // for(var tooth in map['list']){
            fire.doc(title).set(
              {
                "title" : title,
                "toothList": map['list'],
                "planId" : planId
              }
            );
          // }
        }
      }


    }

    Navigator.push(context, MaterialPageRoute(builder: (context) => NavScreen()));
  }

  getPlansUsingProvider(){

    List<Map> maps = [];

    // for(var map in maps){
    //   cards.add(
    //     SelectionWithTooth(title: map['title'], onAdd: (list, title){
    //
    //     }, onChecked: (isChecked, title){
    //
    //     }, isChecked:  ,),
    //   );
    // }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    addInitialCards();
  }

  addInitialCards(){
    setState(() {
      cards.add(
        SelectionWithTooth(title: 'Clining Teeth', onAdd: (List<int> list, title) {
          print("Added tooth");
          toothListMap.add(
              {
                "title" : title,
                "list" : list,
              }
          );
        }, onChecked: (bool isChecked, title) {
          if(isChecked) {
            titles.add(title);
            toothListMap.add(
                {
                  "title" : title,
                  "list" : [],
                }
            );
          }
          else {
            titles.remove(title);
          }
        },),
      );
      cards.add(
        SelectionWithTooth(title: 'ROUNAK18', onAdd: (List<int> list, title) {
          print("Added tooth");
          toothListMap.add(
              {
                "title" : title,
                "list" : list,
              }
          );
        }, onChecked: (bool isChecked, title) {
          print(isChecked);
          if(isChecked)
            titles.add(title);
          else
            titles.remove(title);
        },),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
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
            ListView.builder(itemBuilder: (context, index){
              return cards[index];
              }, itemCount: cards.length, shrinkWrap: true,),
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