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
    // Get screen width to calculate positions
    double screenWidth = WidgetsBinding.instance.window.physicalSize.width /
        WidgetsBinding.instance.window.devicePixelRatio;

    // Define sizes
    const double registerWidth = 64;
    const double registerHeight = 30;

    // Calculate horizontal spacing to distribute registers evenly
    double totalRegisterWidth = registerWidth * 3; // 3 registers per row
    double availableSpace =
        screenWidth - totalRegisterWidth - 40; // 20px padding on each side
    double horizontalSpacing = availableSpace / 2; // Space between 3 registers

    // Bus will be at y=120
    const double busY = 120;
    // Equal vertical spacing for top and bottom registers (50px from bus)
    const double verticalSpacing = 50;
    const double topRowY = busY -
        verticalSpacing -
        registerHeight; // Above the bus with more space
    const double bottomRowY = busY + verticalSpacing; // Below the bus

    // Calculate x-coordinates for even distribution
    double leftX = 20;
    double centerX = leftX + registerWidth + horizontalSpacing;
    double rightX = centerX + registerWidth + horizontalSpacing;

    registers = [
      // Top row - above the bus, evenly distributed across screen width
      Register(
          id: "AR", x: leftX, y: topRowY, w: registerWidth, h: registerHeight),
      Register(
          id: "PC",
          x: centerX,
          y: topRowY,
          w: registerWidth,
          h: registerHeight),
      Register(
          id: "DR", x: rightX, y: topRowY, w: registerWidth, h: registerHeight),

      // Bottom row - below the bus, evenly distributed across screen width
      Register(
          id: "AC",
          x: leftX,
          y: bottomRowY,
          w: registerWidth,
          h: registerHeight),
      Register(
          id: "IR",
          x: centerX,
          y: bottomRowY,
          w: registerWidth,
          h: registerHeight),
      Register(
          id: "TR",
          x: rightX,
          y: bottomRowY,
          w: registerWidth,
          h: registerHeight),
    ];
    notifyListeners();
  }

  void initConfigs() {
    // Make the bus more prominent
    busConfig = {"y": 120, "h": 5}; // Bus positioned at y=120
    memoryConfig = {
      "rows": 3,
      "cols": 4,
      "cellW": 50.0,
      "cellH": 25.0,
    };
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
