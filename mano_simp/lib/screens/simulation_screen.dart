import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mano_simp/providers/simulation_provider.dart';
import 'package:mano_simp/widgets/register_widget.dart';
import 'package:mano_simp/widgets/bus_widget.dart';
import 'package:mano_simp/widgets/memory_grid.dart';

class SimulationScreen extends StatelessWidget {
  const SimulationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final simulationProvider = Provider.of<SimulationProvider>(context);

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            // Main simulation view with registers and bus
            Expanded(
              flex: 3, // More space for registers and bus
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

            // Memory and controls - more compact
            Expanded(
              flex: 2, // Less space for memory and controls
              child: Column(
                children: [
                  // Memory cells - closer to the registers
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: MemoryGrid(
                      memoryConfig: simulationProvider.memoryConfig,
                      memory: simulationProvider.simulationState.memory,
                      selectedAddress: simulationProvider
                          .simulationState.selectedMemoryAddress,
                    ),
                  ),

                  // Simple controls - more compact
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                            minimumSize:
                                MaterialStateProperty.all(Size(75, 32)),
                            padding: MaterialStateProperty.all(
                                EdgeInsets.symmetric(horizontal: 8)),
                          ),
                          onPressed: () {
                            simulationProvider.simulateBusTransfer('AR', 'DR');
                          },
                          child:
                              Text('AR → DR', style: TextStyle(fontSize: 12)),
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            minimumSize:
                                MaterialStateProperty.all(Size(75, 32)),
                            padding: MaterialStateProperty.all(
                                EdgeInsets.symmetric(horizontal: 8)),
                          ),
                          onPressed: () {
                            simulationProvider.simulateAdd('DR');
                          },
                          child:
                              Text('AC + DR', style: TextStyle(fontSize: 12)),
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            minimumSize:
                                MaterialStateProperty.all(Size(75, 32)),
                            padding: MaterialStateProperty.all(
                                EdgeInsets.symmetric(horizontal: 8)),
                          ),
                          onPressed: () {
                            simulationProvider.setRegisterValue('AC', 0x1234);
                            simulationProvider.setRegisterValue('DR', 0x00FF);
                            simulationProvider.setMemoryValue(0, 0xAAAA);
                          },
                          child: Text('Set', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
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
