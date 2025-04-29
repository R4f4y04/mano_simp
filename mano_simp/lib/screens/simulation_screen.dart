import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mano_simp/providers/simulation_provider.dart';
import 'package:mano_simp/widgets/register_widget.dart';
import 'package:mano_simp/widgets/bus_widget.dart';
import 'package:mano_simp/widgets/alu_widget.dart';
import 'package:mano_simp/widgets/memory_grid.dart';

class SimulationScreen extends StatelessWidget {
  const SimulationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final simulationProvider = Provider.of<SimulationProvider>(context);

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            // Bus widget (rendered first to be behind registers)
            BusWidget(
              busConfig: simulationProvider.busConfig,
            ),

            // Registers
            ...simulationProvider.registers
                .map((register) => RegisterWidget(register: register))
                .toList(),

            // ALU
            ALUWidget(
              aluConfig: simulationProvider.aluConfig,
            ),

            // Memory grid
            Positioned(
              left: simulationProvider.memoryConfig['x'].toDouble(),
              top: simulationProvider.memoryConfig['y'].toDouble(),
              child: MemoryGrid(
                memoryConfig: simulationProvider.memoryConfig,
                memory: simulationProvider.simulationState.memory,
                selectedAddress:
                    simulationProvider.simulationState.selectedMemoryAddress,
              ),
            ),

            // Demo controls for testing animations (optional)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Simulate data transfer from AR to DR
                      simulationProvider.simulateBusTransfer('AR', 'DR');
                    },
                    child: const Text('AR → DR'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Simulate data transfer from PC to AR
                      simulationProvider.simulateBusTransfer('PC', 'AR');
                    },
                    child: const Text('PC → AR'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Update some registers with sample values
                      simulationProvider.setRegisterValue('AC', 0x1234);
                      simulationProvider.setRegisterValue('PC', 0x00FF);
                      simulationProvider.setMemoryValue(0, 0xAAAA);
                    },
                    child: const Text('Set Values'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
