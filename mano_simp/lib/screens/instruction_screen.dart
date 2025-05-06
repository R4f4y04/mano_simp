import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mano_simp/providers/simulation_provider.dart';
import 'package:mano_simp/widgets/register_widget.dart';
import 'package:mano_simp/widgets/bus_widget.dart';
import 'package:mano_simp/widgets/memory_grid.dart';
import 'package:mano_simp/config/theme_config.dart';

class InstructionScreen extends StatelessWidget {
  const InstructionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final simulationProvider = Provider.of<SimulationProvider>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Instruction Mode",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: IconThemeData(color: Colors.black),
          actions: [
            // Sample program menu button
            PopupMenuButton<String>(
              icon: Icon(Icons.code),
              tooltip: "Load Sample Program",
              onSelected: (programName) {
                simulationProvider.loadSampleProgram(programName);
              },
              itemBuilder: (context) {
                return simulationProvider.samplePrograms.keys
                    .map((programName) {
                  return PopupMenuItem<String>(
                    value: programName,
                    child: Text(programName),
                  );
                }).toList();
              },
            ),
            // Switch to simulation mode
            IconButton(
              icon: Icon(Icons.swap_horiz),
              tooltip: "Switch to Simulation Mode",
              onPressed: () {
                simulationProvider.toggleInstructionMode();
                Navigator.pop(context);
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Main simulation view with registers and bus
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  // Bus widget needs to be first to be behind registers
                  BusWidget(
                    busConfig: simulationProvider.busConfig,
                  ),

                  // Registers
                  ...simulationProvider.registers
                      .map((register) => RegisterWidget(register: register))
                      .toList(),
                ],
              ),
            ),

            // Decoded instruction text (appears when decoding)
            if (simulationProvider.simulationState.decodedInstructionText !=
                null)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  simulationProvider.simulationState.decodedInstructionText!,
                  style: TextStyle(fontSize: 14),
                ),
              ),

            // Fetch-Decode-Execute buttons
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  _buildPhaseButton(
                    context,
                    "Fetch",
                    Icons.download,
                    Colors.blue.shade700,
                    simulationProvider.simulationState.currentPhase == 1,
                    () => simulationProvider.fetchPhase(),
                  ),
                  SizedBox(width: 8),
                  _buildPhaseButton(
                    context,
                    "Decode",
                    Icons.search,
                    Colors.purple.shade700,
                    simulationProvider.simulationState.currentPhase == 2,
                    () => simulationProvider.decodePhase(),
                  ),
                  SizedBox(width: 8),
                  _buildPhaseButton(
                    context,
                    "Execute",
                    Icons.play_arrow,
                    Colors.green.shade700,
                    simulationProvider.simulationState.currentPhase == 3,
                    () => simulationProvider.executePhase(),
                  ),
                ],
              ),
            ),

            // Memory cells
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: MemoryGrid(
                  memoryConfig: simulationProvider.memoryConfig,
                  memory: simulationProvider.simulationState.memory,
                  selectedAddress:
                      simulationProvider.simulationState.selectedMemoryAddress,
                ),
              ),
            ),

            // Small bottom padding
            SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseButton(BuildContext context, String label, IconData icon,
      Color color, bool isActive, VoidCallback onPressed) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: isActive ? color : color.withOpacity(0.7),
          padding: EdgeInsets.symmetric(vertical: 12),
          elevation: isActive ? 4 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
