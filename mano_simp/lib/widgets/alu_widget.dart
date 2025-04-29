import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mano_simp/providers/simulation_provider.dart';

class ALUWidget extends StatelessWidget {
  final Map<String, dynamic> aluConfig;

  const ALUWidget({Key? key, required this.aluConfig}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get simulation state to check if ALU should be highlighted
    final simulationProvider = Provider.of<SimulationProvider>(context);
    final isActive = simulationProvider.simulationState.isAluActive;

    // Position ALU below the bus
    final double x = MediaQuery.of(context).size.width / 2 - 40; // Centered
    final double y = MediaQuery.of(context).size.height * 0.45; // Below the bus
    final double w = 80.0;
    final double h = 40.0;

    // Highlight color - subtle amber for better visibility
    final highlightColor = Color(0xFFFFD54F);

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
              color: isActive ? highlightColor : Colors.black,
            ),
          ),
          const SizedBox(height: 2),

          // Simple ALU rectangle with subtle animation when active
          AnimatedContainer(
            duration: Duration(milliseconds: 400),
            width: w,
            height: h,
            decoration: BoxDecoration(
              color: isActive ? highlightColor.withOpacity(0.2) : Colors.white,
              border: Border.all(
                color: isActive ? highlightColor : Colors.black,
                width: isActive ? 2.0 : 1.0,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: highlightColor.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                        offset: Offset(0, 1),
                      )
                    ]
                  : null,
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
