import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mano_simp/providers/simulation_provider.dart';
import 'package:mano_simp/widgets/register_widget.dart';
import 'package:mano_simp/widgets/bus_widget.dart';
import 'package:mano_simp/widgets/memory_grid.dart';
import 'package:mano_simp/config/theme_config.dart';
import 'package:mano_simp/widgets/expandable/expandable_action_panel.dart';

class SimulationScreen extends StatelessWidget {
  const SimulationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final simulationProvider = Provider.of<SimulationProvider>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            ThemeConfig.config['appName'],
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
        ),
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

                  // New expandable control panels
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      child: ListView(
                        children: [
                          // Data Transfer Panel
                          ExpandableActionPanel(
                            title: "Data Transfer",
                            icon: Icons.swap_horiz,
                            color: Colors.blueGrey.shade800,
                            children: [
                              ActionButton(
                                label: "AR → DR",
                                icon: Icons.arrow_forward,
                                onPressed: () => simulationProvider
                                    .simulateBusTransfer('AR', 'DR'),
                                color: Colors.blue.shade700,
                              ),
                              ActionButton(
                                label: "DR → AC",
                                icon: Icons.arrow_forward,
                                onPressed: () => simulationProvider
                                    .simulateBusTransfer('DR', 'AC'),
                                color: Colors.blue.shade700,
                              ),
                              ActionButton(
                                label: "AC → AR",
                                icon: Icons.arrow_forward,
                                onPressed: () => simulationProvider
                                    .simulateBusTransfer('AC', 'AR'),
                                color: Colors.blue.shade700,
                              ),
                              ActionButton(
                                label: "PC → AR",
                                icon: Icons.arrow_forward,
                                onPressed: () => simulationProvider
                                    .simulateBusTransfer('PC', 'AR'),
                                color: Colors.blue.shade700,
                              ),
                              ActionButton(
                                label: "IR → AR",
                                icon: Icons.arrow_forward,
                                onPressed: () => simulationProvider
                                    .simulateBusTransfer('IR', 'AR'),
                                color: Colors.blue.shade700,
                              ),
                            ],
                          ),

                          // Arithmetic Operations Panel
                          ExpandableActionPanel(
                            title: "Arithmetic Operations",
                            icon: Icons.calculate,
                            color: Colors.green.shade700,
                            children: [
                              ActionButton(
                                label: "AC + DR",
                                icon: Icons.add,
                                onPressed: () =>
                                    simulationProvider.simulateAdd('DR'),
                                color: Colors.green.shade600,
                              ),
                              ActionButton(
                                label: "AC AND DR",
                                icon: Icons.code,
                                onPressed: () =>
                                    simulationProvider.simulateAnd('DR'),
                                color: Colors.green.shade600,
                              ),
                              // Can add more arithmetic operations here
                            ],
                          ),

                          // Memory Management Panel
                          ExpandableActionPanel(
                            title: "Register Values",
                            icon: Icons.memory,
                            color: Colors.purple.shade700,
                            children: [
                              ActionButton(
                                label: "Set Sample Values",
                                icon: Icons.settings,
                                onPressed: () {
                                  simulationProvider.setRegisterValue(
                                      'AC', 0x1234);
                                  simulationProvider.setRegisterValue(
                                      'DR', 0x00FF);
                                  simulationProvider.setRegisterValue(
                                      'AR', 0x0008);
                                  simulationProvider.setRegisterValue(
                                      'PC', 0x0100);
                                  simulationProvider.setRegisterValue(
                                      'IR', 0x5678);
                                  simulationProvider.setRegisterValue(
                                      'TR', 0xABCD);
                                  simulationProvider.setMemoryValue(0, 0xAAAA);
                                },
                                color: Colors.purple.shade600,
                              ),
                              ActionButton(
                                label: "Clear Registers",
                                icon: Icons.clear_all,
                                onPressed: () {
                                  simulationProvider.setRegisterValue('AC', 0);
                                  simulationProvider.setRegisterValue('DR', 0);
                                  simulationProvider.setRegisterValue('AR', 0);
                                  simulationProvider.setRegisterValue('PC', 0);
                                  simulationProvider.setRegisterValue('IR', 0);
                                  simulationProvider.setRegisterValue('TR', 0);
                                },
                                color: Colors.purple.shade600,
                              ),
                              ActionButton(
                                label: "Increment PC",
                                icon: Icons.add_circle_outline,
                                onPressed: () {
                                  final index = simulationProvider.registers
                                      .indexWhere((r) => r.id == 'PC');
                                  if (index != -1) {
                                    int currentValue = simulationProvider
                                        .registers[index].value;
                                    simulationProvider.setRegisterValue(
                                        'PC', currentValue + 1);
                                  }
                                },
                                color: Colors.purple.shade600,
                              ),
                            ],
                          ),
                        ],
                      ),
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
