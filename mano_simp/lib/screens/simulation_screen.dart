import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mano_simp/providers/simulation_provider.dart';
import 'package:mano_simp/widgets/register_widget.dart';
import 'package:mano_simp/widgets/bus_widget.dart';
import 'package:mano_simp/widgets/memory_grid.dart';
import 'package:mano_simp/config/theme_config.dart';
import 'package:mano_simp/widgets/custom_dropdown_button.dart';

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

            // Action buttons in a horizontal row
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              constraints: BoxConstraints(maxHeight: 56),
              child: Row(
                children: [
                  // Data Transfer
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: CustomDropdownButton(
                        label: "Bus",
                        icon: Icons.swap_horiz,
                        color: Colors.blueGrey.shade800,
                        actions: [
                          DropdownAction(
                            label: "AR → DR",
                            onPressed: () => simulationProvider
                                .simulateBusTransfer('AR', 'DR'),
                          ),
                          DropdownAction(
                            label: "DR → AC",
                            onPressed: () => simulationProvider
                                .simulateBusTransfer('DR', 'AC'),
                          ),
                          DropdownAction(
                            label: "AC → AR",
                            onPressed: () => simulationProvider
                                .simulateBusTransfer('AC', 'AR'),
                          ),
                          DropdownAction(
                            label: "PC → AR",
                            onPressed: () => simulationProvider
                                .simulateBusTransfer('PC', 'AR'),
                          ),
                          DropdownAction(
                            label: "IR → AR",
                            onPressed: () => simulationProvider
                                .simulateBusTransfer('IR', 'AR'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Operations
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: CustomDropdownButton(
                        label: "Mem Ref",
                        icon: Icons.calculate,
                        color: Colors.green.shade700,
                        actions: [
                          DropdownAction(
                            label: "AC + DR",
                            onPressed: () =>
                                simulationProvider.simulateAdd('DR'),
                          ),
                          DropdownAction(
                            label: "AC AND DR",
                            onPressed: () =>
                                simulationProvider.simulateAnd('DR'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Register Values
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: CustomDropdownButton(
                        label: "Register Ref",
                        icon: Icons.memory,
                        color: Colors.purple.shade700,
                        actions: [
                          DropdownAction(
                            label: "Set Values",
                            onPressed: () {
                              simulationProvider.setRegisterValue('AC', 0x1234);
                              simulationProvider.setRegisterValue('DR', 0x00FF);
                              simulationProvider.setRegisterValue('AR', 0x0008);
                              simulationProvider.setRegisterValue('PC', 0x0100);
                              simulationProvider.setRegisterValue('IR', 0x5678);
                              simulationProvider.setRegisterValue('TR', 0xABCD);
                              simulationProvider.setMemoryValue(0, 0xAAAA);
                            },
                          ),
                          DropdownAction(
                            label: "Clear All",
                            onPressed: () {
                              simulationProvider.setRegisterValue('AC', 0);
                              simulationProvider.setRegisterValue('DR', 0);
                              simulationProvider.setRegisterValue('AR', 0);
                              simulationProvider.setRegisterValue('PC', 0);
                              simulationProvider.setRegisterValue('IR', 0);
                              simulationProvider.setRegisterValue('TR', 0);
                            },
                          ),
                          DropdownAction(
                            label: "PC++",
                            onPressed: () {
                              final index = simulationProvider.registers
                                  .indexWhere((r) => r.id == 'PC');
                              if (index != -1) {
                                int currentValue =
                                    simulationProvider.registers[index].value;
                                simulationProvider.setRegisterValue(
                                    'PC', currentValue + 1);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Memory cells
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: MemoryGrid(
                  memoryConfig: simulationProvider.memoryConfig,
                  memory: simulationProvider.simulationState.memory,
                  selectedAddress:
                      simulationProvider.simulationState.selectedMemoryAddress,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
