import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:mano_simp/providers/simulation_provider.dart';
import 'package:mano_simp/providers/editor_provider.dart';
import 'package:mano_simp/widgets/register_widget.dart';
import 'package:mano_simp/widgets/bus_widget.dart';
import 'package:mano_simp/widgets/memory_grid.dart';
import 'package:mano_simp/config/theme_config.dart';

class IntegratedScreen extends StatefulWidget {
  const IntegratedScreen({Key? key}) : super(key: key);

  @override
  _IntegratedScreenState createState() => _IntegratedScreenState();
}

class _IntegratedScreenState extends State<IntegratedScreen> {
  final PanelController _panelController = PanelController();
  bool _isPanelOpen = false;

  @override
  void initState() {
    super.initState();
    // Initialize simulation data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SimulationProvider>().initRegisters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final simulationProvider = Provider.of<SimulationProvider>(context);
    final editorProvider = Provider.of<EditorProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          ThemeConfig.config['appName'],
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        elevation: 0,
      ),
      body: SlidingUpPanel(
        controller: _panelController,
        minHeight: 0, // Hidden by default
        maxHeight:
            MediaQuery.of(context).size.height * 0.6, // 60% of screen height
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        onPanelClosed: () => setState(() => _isPanelOpen = false),
        onPanelOpened: () => setState(() => _isPanelOpen = true),
        panel: _buildEditorPanel(editorProvider),
        body: _buildSimulationView(simulationProvider),
        // Collapsed panel header with a drag handle
        collapsed: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
      // New small bottom navigation bar with editor toggle button
      bottomNavigationBar: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  _isPanelOpen = !_isPanelOpen;
                  if (_isPanelOpen) {
                    _panelController.open();
                  } else {
                    _panelController.close();
                  }
                });
              },
              child: Icon(
                _isPanelOpen ? Icons.keyboard_arrow_down : Icons.code,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Simulation view from the original simulation screen
  Widget _buildSimulationView(SimulationProvider simulationProvider) {
    return SafeArea(
      child: Column(
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
                          minimumSize: MaterialStateProperty.all(Size(75, 32)),
                          padding: MaterialStateProperty.all(
                              EdgeInsets.symmetric(horizontal: 8)),
                        ),
                        onPressed: () {
                          simulationProvider.simulateBusTransfer('AR', 'DR');
                        },
                        child: Text('AR → DR', style: TextStyle(fontSize: 12)),
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all(Size(75, 32)),
                          padding: MaterialStateProperty.all(
                              EdgeInsets.symmetric(horizontal: 8)),
                        ),
                        onPressed: () {
                          simulationProvider.simulateAdd('DR');
                        },
                        child: Text('AC + DR', style: TextStyle(fontSize: 12)),
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all(Size(75, 32)),
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
    );
  }

  // Editor panel based on the original editor screen
  Widget _buildEditorPanel(EditorProvider editorProvider) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle and title in a row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mano Assembly Code',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              IconButton(
                icon: Icon(Icons.keyboard_arrow_down),
                onPressed: () {
                  _panelController.close();
                  setState(() => _isPanelOpen = false);
                },
              ),
            ],
          ),
          SizedBox(height: 8),

          // Code editor
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: Colors.white,
              ),
              child: TextField(
                controller: editorProvider.codeController,
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 14,
                ),
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(8.0),
                  hintText: 'Enter Mano assembly code here...',
                ),
                onChanged: (_) => editorProvider.updateCode(),
              ),
            ),
          ),

          // Error messages
          if (editorProvider.errors.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.only(top: 8.0),
              decoration: BoxDecoration(
                color: Colors.black12,
                border: Border.all(color: Colors.black),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Errors:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  ...editorProvider.errors
                      .map((error) => Text(
                            '• $error',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12.0,
                            ),
                          ))
                      .toList(),
                ],
              ),
            ),

          // Controls
          Container(
            margin: EdgeInsets.only(top: 8),
            child: Row(
              children: [
                // Run button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => editorProvider.runCode(context),
                    child: Text('Run'),
                  ),
                ),
                SizedBox(width: 8),
                // Sample code button
                OutlinedButton(
                  onPressed: () {
                    editorProvider.codeController.text = '''ORG 100
LDA 500
ADD 501
STA 502
HLT
ORG 500
DEC 75
DEC 25
DEC 0
END''';
                    editorProvider.updateCode();
                  },
                  child: Text('Sample Code'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
