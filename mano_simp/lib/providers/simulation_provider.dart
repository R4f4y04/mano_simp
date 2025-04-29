import 'package:flutter/material.dart';
import 'package:mano_simp/models/register_model.dart';
import 'package:mano_simp/models/simulation_state.dart';

class SimulationProvider extends ChangeNotifier {
  // Registers
  List<Register> registers = [];

  // ALU configuration
  Map<String, dynamic> aluConfig = {};

  // Bus configuration
  Map<String, dynamic> busConfig = {};

  // Memory configuration
  Map<String, dynamic> memoryConfig = {};

  // Simulation state
  final SimulationState simulationState = SimulationState();

  SimulationProvider() {
    initConfigs();
    // Wait for the first frame to get screen dimensions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initRegisters();
    });
  }

  void initRegisters() {
    // Create registers with new positions to surround the central bus
    registers = [
      // Top row - above the bus
      Register(id: "AR", x: 30, y: 50, w: 64, h: 32),
      Register(id: "PC", x: 114, y: 50, w: 64, h: 32),
      Register(id: "DR", x: 198, y: 50, w: 64, h: 32),
      Register(id: "AC", x: 282, y: 50, w: 64, h: 32),

      // Bottom row - below the bus
      Register(id: "INPR", x: 30, y: 170, w: 64, h: 32),
      Register(id: "IR", x: 114, y: 170, w: 64, h: 32),
      Register(id: "TR", x: 198, y: 170, w: 64, h: 32),
      Register(id: "OUTR", x: 282, y: 170, w: 64, h: 32),
    ];
    notifyListeners();
  }

  void initConfigs() {
    // Simple configs - the specific values aren't as important anymore since
    // our widgets are more responsive now
    aluConfig = {"x": 160, "y": 100, "w": 80, "h": 40};
    busConfig = {"y": 120, "h": 2};
    memoryConfig = {};
  }

  // Methods to update register values
  void setRegisterValue(String id, int value) {
    final index = registers.indexWhere((register) => register.id == id);
    if (index != -1) {
      registers[index].value = value;
      notifyListeners();
    }
  }

  // Methods to highlight registers and bus during simulation
  void highlightRegister(String id, {bool highlight = true}) {
    final index = registers.indexWhere((register) => register.id == id);
    if (index != -1) {
      registers[index].isHighlighted = highlight;
      notifyListeners();
    }
  }

  void clearAllHighlights() {
    for (var register in registers) {
      register.isHighlighted = false;
    }
    simulationState.isHighlightedBus = false;
    simulationState.sourceRegister = null;
    simulationState.destinationRegister = null;
    notifyListeners();
  }

  // Bus transfer animation
  void simulateBusTransfer(String from, String to) {
    // First clear any existing highlights
    clearAllHighlights();

    // Highlight source register and bus
    highlightRegister(from);
    simulationState.isHighlightedBus = true;
    simulationState.sourceRegister = from;
    simulationState.destinationRegister = to;
    notifyListeners();

    // After a delay, highlight destination register
    Future.delayed(Duration(milliseconds: 400), () {
      highlightRegister(to);
      notifyListeners();

      // After another delay, clear all highlights
      Future.delayed(Duration(milliseconds: 400), () {
        clearAllHighlights();
      });
    });
  }

  // Memory operations
  void setMemoryValue(int address, int value) {
    final row = address ~/ 8;
    final col = address % 8;

    if (row < simulationState.memory.length &&
        col < simulationState.memory[row].length) {
      simulationState.memory[row][col] = value;
      notifyListeners();
    }
  }

  void selectMemoryAddress(int address) {
    simulationState.selectedMemoryAddress = address;
    notifyListeners();
  }
}
