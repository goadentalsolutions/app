import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:goa_dental_clinic/models/treatment_model.dart';

class TreatmentPlanCard extends StatefulWidget {
  TreatmentPlanCard({required this.tm, this.size, required this.addFunc, required this.editFunc});
  TreatmentModel tm;
  Size? size;
  Function editFunc, addFunc;

  @override
  State<TreatmentPlanCard> createState() => _TreatmentPlanCardState();
}

class _TreatmentPlanCardState extends State<TreatmentPlanCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black,),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  '${widget.tm.procedure}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8,),
                InkWell(child: Icon(Icons.edit, color: kGrey,), onTap: (){
                  widget.editFunc(widget.tm);
                },),
              ],
            ),
          ),
          SizedBox(height: 16,),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Unit: ',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8,),
                    Text(
                      widget.tm.unit.toString(),
                      style: TextStyle(fontSize: 18, color: Colors.blue[600]),
                    ),
                  ],
                ),
                SizedBox(width: 12,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Cost: ',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8,),
                    Text(
                      widget.tm.cost.toString(),
                      style: TextStyle(fontSize: 18, color: Colors.blue[600]),
                    ),
                  ],
                ),
                SizedBox(width: 12,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Discount(${widget.tm.discountSymbol})',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8,),
                    Text(
                      widget.tm.discount.toString(),
                      style: TextStyle(fontSize: 18, color: Colors.blue[600]),
                    ),
                  ],
                ),
                SizedBox(width: 12,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Total: ',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8,),
                    FittedBox(
                      child: Text(
                        widget.tm.total.toString(),
                        style: TextStyle(fontSize: 18, color: Colors.blue[600]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: Text(
              'Note: ${widget.tm.note} ',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
