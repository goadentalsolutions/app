import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:goa_dental_clinic/custom_widgets/custom_button.dart';
import 'package:goa_dental_clinic/custom_widgets/tooth.dart';

class ToothSelectionWidget extends StatefulWidget {
  final int numberOfTeeth;
  Function(List<int>) onDone;
  List<int>? tList;

  ToothSelectionWidget({required this.numberOfTeeth, required this.onDone, this.tList = null});

  @override
  State<ToothSelectionWidget> createState() => _ToothSelectionWidgetState();
}

class _ToothSelectionWidgetState extends State<ToothSelectionWidget> {

  List<int> toothList = [];

  bool isSelected(toothNumber){
    bool selected = true;
    toothList.forEach((element) {
      if(element == toothNumber) {
        selected = false;
      }
    });
    return selected;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.tList != null) {
      toothList = widget.tList!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8, // Adjust the number of columns as per your requirement
                    ),
                    itemCount: widget.numberOfTeeth,
                    itemBuilder: (context, index) {
                      final toothNumber = index + 1;
                      bool initialValue = false;
                      toothList.forEach((element) {
                        if(element == toothNumber){
                          initialValue = true;
                        }
                      });
                      return Tooth(index: toothNumber, initialValue: initialValue, onTap: (toothNumber, isSelected){
                        // print(toothNumber);
                        if(!isSelected){
                          toothList.remove(toothNumber);
                        }
                        else{
                          toothList.add(toothNumber);
                        }
                        // toothList.add(toothNumber);
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(child: CustomButton(text: 'Done', backgroundColor: kPrimaryColor, onPressed: (){
                    widget.onDone(toothList);
                    Navigator.pop(context);
                  }), height: 60,),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
