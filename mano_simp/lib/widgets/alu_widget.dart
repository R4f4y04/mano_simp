import 'package:flutter/material.dart';

class ALUWidget extends StatelessWidget {
  final Map<String, dynamic> aluConfig;

  const ALUWidget({Key? key, required this.aluConfig}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Position ALU below the bus
    final double x = MediaQuery.of(context).size.width / 2 - 40; // Centered
    final double y = MediaQuery.of(context).size.height * 0.45; // Below the bus
    final double w = 80.0;
    final double h = 40.0;

    return Positioned(
      left: x,
      top: y,
      child: Column(
        children: [
          // ALU Label
          Text(
            'ALU',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2),

          // Simple ALU rectangle
          Container(
            width: w,
            height: h,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 1.0),
            ),
            alignment: Alignment.center,
            child: Text(
              '+/-',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
