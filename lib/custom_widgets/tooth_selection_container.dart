import 'package:flutter/material.dart';

class ToothSelectionWidget extends StatelessWidget {
  final int numberOfTeeth;
  final Function(int) onToothSelected;

  ToothSelectionWidget({required this.numberOfTeeth, required this.onToothSelected});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6, // Adjust the number of columns as per your requirement
      ),
      itemCount: numberOfTeeth,
      itemBuilder: (context, index) {
        final toothNumber = index + 1;
        return GestureDetector(
          onTap: () {
            onToothSelected(toothNumber);
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 2.0,
              ),
            ),
            child: Center(
              child: Text(
                toothNumber.toString(),
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ),
        );
      },
    );
  }
}
