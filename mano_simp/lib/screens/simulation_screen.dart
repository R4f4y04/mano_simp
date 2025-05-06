import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mano_simp/providers/simulation_provider.dart';
import 'package:mano_simp/widgets/register_widget.dart';
import 'package:mano_simp/widgets/bus_widget.dart';
import 'package:mano_simp/widgets/memory_grid.dart';
import 'package:mano_simp/config/theme_config.dart';
import 'package:mano_simp/widgets/custom_dropdown_button.dart';
import 'package:mano_simp/screens/instruction_screen.dart';

class SimulationScreen extends StatelessWidget {
  const SimulationScreen({Key? key}) : super(key: key);

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
            ThemeConfig.config['appName'],
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
            // Switch to instruction mode
            IconButton(
              icon: Icon(Icons.school), // Education/instruction icon
              tooltip: "Switch to Instruction Mode",
              onPressed: () {
                simulationProvider.toggleInstructionMode();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InstructionScreen()),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Main simulation view with registers and bus - reduced flex
            Expanded(
              flex: 2, // Reduced from 3 to 2
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

            // Action buttons in a horizontal row - made more compact
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 4.0), // Reduced vertical padding
              constraints:
                  BoxConstraints(maxHeight: 48), // Reduced from 56 to 48
              child: Row(
                children: [
                  // Bus Operations
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: CustomDropdownButton(
                        label: "Bus",
                        icon: Icons.swap_horiz,
                        color: Colors.blueGrey.shade800,
                        actions: [
                          DropdownAction(
                            label: "PC → AR",
                            onPressed: () => simulationProvider
                                .simulateBusTransfer('PC', 'AR'),
                          ),
                          DropdownAction(
                            label: "M[AR] → DR",
                            onPressed: () {
                              // First, simulate memory to DR transfer
                              int arIndex = simulationProvider.registers
                                  .indexWhere((r) => r.id == 'AR');
                              int arValue =
                                  simulationProvider.registers[arIndex].value;

                              // Get memory value at AR address
                              int memValue =
                                  simulationProvider.getMemoryValue(arValue);

                              // Simulate memory read, then set DR value
                              simulationProvider.highlightRegister('AR');
                              Future.delayed(Duration(milliseconds: 300), () {
                                simulationProvider.setRegisterValue(
                                    'DR', memValue);
                                simulationProvider.highlightRegister('DR');
                                Future.delayed(Duration(milliseconds: 300), () {
                                  simulationProvider.clearAllHighlights();
                                });
                              });
                            },
                          ),
                          DropdownAction(
                            label: "DR → AC",
                            onPressed: () => simulationProvider
                                .simulateBusTransfer('DR', 'AC'),
                          ),
                          DropdownAction(
                            label: "AC → TR",
                            onPressed: () => simulationProvider
                                .simulateBusTransfer('AC', 'TR'),
                          ),
                          DropdownAction(
                            label: "TR → AC",
                            onPressed: () => simulationProvider
                                .simulateBusTransfer('TR', 'AC'),
                          ),
                          DropdownAction(
                            label: "AC → M[AR]",
                            onPressed: () {
                              // Get AR value to determine memory address
                              int arIndex = simulationProvider.registers
                                  .indexWhere((r) => r.id == 'AR');
                              int arValue =
                                  simulationProvider.registers[arIndex].value;

                              // Get AC value to store in memory
                              int acIndex = simulationProvider.registers
                                  .indexWhere((r) => r.id == 'AC');
                              int acValue =
                                  simulationProvider.registers[acIndex].value;

                              // Simulate memory write
                              simulationProvider.highlightRegister('AC');
                              Future.delayed(Duration(milliseconds: 300), () {
                                simulationProvider.highlightRegister('AR');
                                simulationProvider.setMemoryValue(
                                    arValue, acValue);
                                Future.delayed(Duration(milliseconds: 300), () {
                                  simulationProvider.clearAllHighlights();
                                });
                              });
                            },
                          ),
                          DropdownAction(
                            label: "PC++",
                            onPressed: () {
                              int pcIndex = simulationProvider.registers
                                  .indexWhere((r) => r.id == 'PC');
                              if (pcIndex != -1) {
                                int currentValue =
                                    simulationProvider.registers[pcIndex].value;
                                simulationProvider.highlightRegister('PC');
                                Future.delayed(Duration(milliseconds: 300), () {
                                  simulationProvider.setRegisterValue(
                                      'PC', currentValue + 1);
                                  Future.delayed(Duration(milliseconds: 300),
                                      () {
                                    simulationProvider.clearAllHighlights();
                                  });
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Memory Reference Operations
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: CustomDropdownButton(
                        label: "Memory Ref",
                        icon: Icons.memory,
                        color: Colors.green.shade700,
                        actions: [
                          DropdownAction(
                            label: "AND",
                            onPressed: () =>
                                simulationProvider.simulateAnd('DR'),
                          ),
                          DropdownAction(
                            label: "ADD",
                            onPressed: () =>
                                simulationProvider.simulateAdd('DR'),
                          ),
                          DropdownAction(
                            label: "LDA",
                            onPressed: () {
                              // LDA operation: M[AR] → DR → AC
                              int arIndex = simulationProvider.registers
                                  .indexWhere((r) => r.id == 'AR');

                              if (arIndex != -1) {
                                int arValue =
                                    simulationProvider.registers[arIndex].value;

                                // Show that we're accessing AR
                                simulationProvider.highlightRegister('AR');
                                simulationProvider.selectMemoryAddress(arValue);

                                Future.delayed(Duration(milliseconds: 300), () {
                                  // Get memory value at AR address
                                  int memValue = simulationProvider
                                      .getMemoryValue(arValue);

                                  // Step 1: M[AR] → DR
                                  simulationProvider.setRegisterValue(
                                      'DR', memValue);
                                  simulationProvider.highlightRegister('DR');

                                  // Step 2: DR → AC
                                  Future.delayed(Duration(milliseconds: 400),
                                      () {
                                    simulationProvider.setRegisterValue(
                                        'AC', memValue);
                                    simulationProvider.highlightRegister('AC');
                                    simulationProvider.clearAllHighlights('DR');

                                    // Clear highlights
                                    Future.delayed(Duration(milliseconds: 400),
                                        () {
                                      simulationProvider.clearAllHighlights();
                                    });
                                  });
                                });
                              }
                            },
                          ),
                          DropdownAction(
                            label: "STA",
                            onPressed: () {
                              // STA operation: AC → M[AR]
                              int arIndex = simulationProvider.registers
                                  .indexWhere((r) => r.id == 'AR');
                              int acIndex = simulationProvider.registers
                                  .indexWhere((r) => r.id == 'AC');

                              if (arIndex != -1 && acIndex != -1) {
                                int arValue =
                                    simulationProvider.registers[arIndex].value;
                                int acValue =
                                    simulationProvider.registers[acIndex].value;

                                // Show that we're accessing the AC and AR
                                simulationProvider.highlightRegister('AC');
                                simulationProvider
                                    .simulationState.isHighlightedBus = true;
                                simulationProvider
                                    .simulationState.sourceRegister = 'AC';
                                simulationProvider
                                    .simulationState.destinationRegister = null;

                                Future.delayed(Duration(milliseconds: 300), () {
                                  // Also highlight AR as the destination address
                                  simulationProvider.highlightRegister('AR');
                                  // Select memory address to visually indicate where we're storing
                                  simulationProvider
                                      .selectMemoryAddress(arValue);

                                  Future.delayed(Duration(milliseconds: 300),
                                      () {
                                    // Actually store the value in memory
                                    simulationProvider.setMemoryValue(
                                        arValue, acValue);

                                    // Clear highlights after a delay
                                    Future.delayed(Duration(milliseconds: 400),
                                        () {
                                      simulationProvider.clearAllHighlights();
                                    });
                                  });
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Register Reference Operations
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: CustomDropdownButton(
                        label: "Register Ref",
                        icon: Icons.settings,
                        color: Colors.purple.shade700,
                        actions: [
                          DropdownAction(
                            label: "INC",
                            onPressed: () {
                              int acIndex = simulationProvider.registers
                                  .indexWhere((r) => r.id == 'AC');
                              if (acIndex != -1) {
                                int currentValue =
                                    simulationProvider.registers[acIndex].value;
                                simulationProvider.highlightRegister('AC');
                                Future.delayed(Duration(milliseconds: 300), () {
                                  simulationProvider.setRegisterValue(
                                      'AC', currentValue + 1);
                                  Future.delayed(Duration(milliseconds: 300),
                                      () {
                                    simulationProvider.clearAllHighlights();
                                  });
                                });
                              }
                            },
                          ),
                          DropdownAction(
                            label: "CIL",
                            onPressed: () {
                              int acIndex = simulationProvider.registers
                                  .indexWhere((r) => r.id == 'AC');
                              if (acIndex != -1) {
                                int currentValue =
                                    simulationProvider.registers[acIndex].value;
                                // Simulate circulate left (shift left with wrap)
                                int mask = 0xFFFF; // 16-bit mask
                                int msb = (currentValue & 0x8000) >>
                                    15; // Get MSB (bit 15)
                                int newValue = ((currentValue << 1) & mask) |
                                    msb; // Shift left and wrap MSB

                                simulationProvider.highlightRegister('AC');
                                Future.delayed(Duration(milliseconds: 300), () {
                                  simulationProvider.setRegisterValue(
                                      'AC', newValue);
                                  Future.delayed(Duration(milliseconds: 300),
                                      () {
                                    simulationProvider.clearAllHighlights();
                                  });
                                });
                              }
                            },
                          ),
                          DropdownAction(
                            label: "CIR",
                            onPressed: () {
                              int acIndex = simulationProvider.registers
                                  .indexWhere((r) => r.id == 'AC');
                              if (acIndex != -1) {
                                int currentValue =
                                    simulationProvider.registers[acIndex].value;
                                // Simulate circulate right (shift right with wrap)
                                int lsb =
                                    currentValue & 0x0001; // Get LSB (bit 0)
                                int shiftedValue =
                                    currentValue >> 1; // Shift right
                                int newValue = shiftedValue |
                                    (lsb << 15); // Place LSB at MSB position

                                simulationProvider.highlightRegister('AC');
                                Future.delayed(Duration(milliseconds: 300), () {
                                  simulationProvider.setRegisterValue(
                                      'AC', newValue);
                                  Future.delayed(Duration(milliseconds: 300),
                                      () {
                                    simulationProvider.clearAllHighlights();
                                  });
                                });
                              }
                            },
                          ),
                          DropdownAction(
                            label: "CME",
                            onPressed: () {
                              // Since E is not explicitly modeled, we'll just show a simulation
                              // In a real implementation, this would toggle the E bit
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text('E bit complemented'),
                                duration: Duration(seconds: 1),
                              ));
                            },
                          ),
                          DropdownAction(
                            label: "CMA",
                            onPressed: () {
                              int acIndex = simulationProvider.registers
                                  .indexWhere((r) => r.id == 'AC');
                              if (acIndex != -1) {
                                int currentValue =
                                    simulationProvider.registers[acIndex].value;
                                // 1's complement (invert all bits)
                                int newValue = (~currentValue) &
                                    0xFFFF; // Apply 16-bit mask

                                simulationProvider.highlightRegister('AC');
                                Future.delayed(Duration(milliseconds: 300), () {
                                  simulationProvider.setRegisterValue(
                                      'AC', newValue);
                                  Future.delayed(Duration(milliseconds: 300),
                                      () {
                                    simulationProvider.clearAllHighlights();
                                  });
                                });
                              }
                            },
                          ),
                          DropdownAction(
                            label: "CLE",
                            onPressed: () {
                              // Since E is not explicitly modeled, we'll just show a simulation
                              // In a real implementation, this would clear the E bit
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text('E bit cleared'),
                                duration: Duration(seconds: 1),
                              ));
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2), // Minimal spacing

            // Memory cells - increased flex for more space
            Expanded(
              flex: 3, // Increased from default 1 to 3
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 2.0), // Reduced padding
                child: MemoryGrid(
                  memoryConfig: simulationProvider.memoryConfig,
                  memory: simulationProvider.simulationState.memory,
                  selectedAddress:
                      simulationProvider.simulationState.selectedMemoryAddress,
                ),
              ),
            ),

            // Small bottom padding to prevent content from touching the edge
            SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
