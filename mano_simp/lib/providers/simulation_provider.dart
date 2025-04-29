import 'package:flutter/material.dart';
import 'package:mano_simp/config/theme_config.dart';
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
    initRegisters();
    initConfigs();
  }

  void initRegisters() {
    final registerConfigs = ThemeConfig.config['layout']['screens']
        ['Simulation']['registers'] as List;

    registers = registerConfigs
        .map((config) => Register(
              id: config['id'],
              x: config['x'].toDouble(),
              y: config['y'].toDouble(),
              w: config['w'].toDouble(),
              h: config['h'].toDouble(),
            ))
        .toList();
  }

  void initConfigs() {
    final simulationConfig =
        ThemeConfig.config['layout']['screens']['Simulation'];

    aluConfig = simulationConfig['alu'];
    busConfig = simulationConfig['bus'];
    memoryConfig = simulationConfig['memory'];
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
    Future.delayed(
        Duration(
            milliseconds:
                ThemeConfig.config['animations']['highlightDurationMs'] ~/ 2),
        () {
      highlightRegister(to);
      notifyListeners();

      // After another delay, clear all highlights
      Future.delayed(
          Duration(
              milliseconds: ThemeConfig.config['animations']
                  ['highlightDurationMs']), () {
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
