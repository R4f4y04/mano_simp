import 'package:flutter/material.dart';
import 'package:mano_simp/config/theme_config.dart';
import 'package:provider/provider.dart';
import 'package:mano_simp/providers/simulation_provider.dart';

class BusWidget extends StatelessWidget {
  final Map<String, dynamic> busConfig;

  const BusWidget({Key? key, required this.busConfig}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final simulationProvider = Provider.of<SimulationProvider>(context);
    final simulationState = simulationProvider.simulationState;
    final registers = simulationProvider.registers;
    final screenWidth = MediaQuery.of(context).size.width;

    // Position the bus in the middle of the screen horizontally
    final double busY =
        MediaQuery.of(context).size.height * 0.4; // Middle of the screen
    final double busHeight = 2.0; // Very thin bus line
    final double busWidth = screenWidth - 40; // Width with padding

    final animDuration = Duration(
      milliseconds: ThemeConfig.config['animations']['highlightDurationMs'],
    );

    // Calculate connection lines for each register to the bus
    final List<Widget> connectionLines = [];
    for (var register in registers) {
      final double registerCenterX = register.x + (register.w / 2);
      final bool isAboveBus = register.y < busY;
      final double connectionStartY =
          isAboveBus ? register.y + register.h : register.y;
      final double connectionEndY = busY;
      final bool isHighlighted =
          simulationState.sourceRegister == register.id ||
              simulationState.destinationRegister == register.id;

      connectionLines.add(Positioned(
        left: registerCenterX,
        top: isAboveBus ? connectionStartY : busY,
        child: AnimatedContainer(
          duration: animDuration,
          width: 1, // Thin line
          height:
              isAboveBus ? busY - connectionStartY : connectionStartY - busY,
          color: isHighlighted ? Colors.black : Colors.grey,
        ),
      ));
    }

    return Stack(
      children: [
        // Main horizontal bus
        Positioned(
          left: 20,
          top: busY,
          child: AnimatedContainer(
            duration: animDuration,
            width: busWidth,
            height: busHeight,
            color:
                simulationState.isHighlightedBus ? Colors.black : Colors.grey,
          ),
        ),

        // Connection lines from registers to bus
        ...connectionLines,
      ],
    );
  }
}
