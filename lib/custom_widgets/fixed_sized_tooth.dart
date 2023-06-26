import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/constants.dart';

class FixedSizeTooth extends StatefulWidget {
  @override
  _FixedSizeToothState createState() => _FixedSizeToothState();

  FixedSizeTooth({required this.index, required this.onTap, this.initialValue = false});
  int index;
  Function onTap;
  bool initialValue;
}

class _FixedSizeToothState extends State<FixedSizeTooth> {
  bool isSelected = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.initialValue)
      isSelected = widget.initialValue;
  }
  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: GestureDetector(
        onTap: (){
          setState(() {
            isSelected = !isSelected;
          });
          widget.onTap(widget.index, isSelected);
        },
        child: Container(
          height: 60,
          width: 60,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${widget.index}',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
