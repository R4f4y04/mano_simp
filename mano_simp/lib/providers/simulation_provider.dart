import 'package:flutter/material.dart';
import 'package:mano_simp/models/register_model.dart';
import 'package:mano_simp/models/simulation_state.dart';

class SimulationProvider extends ChangeNotifier {
  // Registers
  List<Register> registers = [];

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
    // Create registers with new positions - removed INPR and OUTR
    // Positioning registers around the central bus
    registers = [
      // Top row - above the bus
      Register(id: "AR", x: 30, y: 60, w: 64, h: 32),
      Register(id: "PC", x: 114, y: 60, w: 64, h: 32),
      Register(id: "DR", x: 198, y: 60, w: 64, h: 32),

      // Bottom row - below the bus
      Register(id: "AC", x: 30, y: 170, w: 64, h: 32),
      Register(id: "IR", x: 114, y: 170, w: 64, h: 32),
      Register(id: "TR", x: 198, y: 170, w: 64, h: 32),
    ];
    notifyListeners();
  }

  void initConfigs() {
    // Make the bus more prominent
    busConfig = {"y": 120, "h": 5}; // Increased height to 5
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

  // AC operation animation (replacing ALU operation)
  void simulateAcOperation(String input) {
    // First clear all highlights
    clearAllHighlights();

    // Step 1: Highlight input register
    highlightRegister(input);
    simulationState.isHighlightedBus = true;
    simulationState.sourceRegister = input;
    simulationState.destinationRegister = "AC";
    notifyListeners();

    // Step 2: After delay, highlight AC register
    Future.delayed(Duration(milliseconds: 400), () {
      highlightRegister("AC");
      notifyListeners();

      // Step 3: Clear all highlights
      Future.delayed(Duration(milliseconds: 400), () {
        clearAllHighlights();
      });
    });
  }

  // Simulate ADD operation with AC
  void simulateAdd(String source) {
    // Get register values
    final acIndex = registers.indexWhere((register) => register.id == "AC");
    final sourceIndex =
        registers.indexWhere((register) => register.id == source);

    if (acIndex != -1 && sourceIndex != -1) {
      final acValue = registers[acIndex].value;
      final sourceValue = registers[sourceIndex].value;

      // Perform operation animation
      simulateAcOperation(source);

      // Update AC value after the animation completes
      Future.delayed(Duration(milliseconds: 800), () {
        setRegisterValue("AC", acValue + sourceValue);
      });
    }
  }

  // Simulate AND operation with AC
  void simulateAnd(String source) {
    // Get register values
    final acIndex = registers.indexWhere((register) => register.id == "AC");
    final sourceIndex =
        registers.indexWhere((register) => register.id == source);

    if (acIndex != -1 && sourceIndex != -1) {
      final acValue = registers[acIndex].value;
      final sourceValue = registers[sourceIndex].value;

      // Perform operation animation
      simulateAcOperation(source);

      // Update AC value after the animation completes
      Future.delayed(Duration(milliseconds: 800), () {
        setRegisterValue("AC", acValue & sourceValue);
      });
    }
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
