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

  // Sample programs
  final Map<String, List<int>> samplePrograms = {
    'Simple Addition': [
      0x2010, // LDA 10H - Load value from address 10H to AC
      0x1011, // ADD 11H - Add value from address 11H to AC
      0x3012, // STA 12H - Store AC to address 12H
      0x7001, // HLT - Halt
      0x0000, // (Padding)
      0x0000, // (Padding)
      0x0000, // (Padding)
      0x0000, // (Padding)
      0x0000, // (Padding)
      0x0000, // (Padding)
      0x0000, // (Padding)
      0x0000, // (Padding)
      0x0000, // (Padding)
      0x0000, // (Padding)
      0x0000, // (Padding)
      0x0000, // (Padding)
      0x000A, // Value at address 10H (10 decimal)
      0x0014, // Value at address 11H (20 decimal)
      0x0000, // Result will be stored at address 12H
    ],
    'Loop Counter': [
      0x2010, // LDA 10H - Load initial counter value (3)
      0x3011, // STA 11H - Store it to our counter variable
      0x2011, // LDA 11H - Load counter value to AC
      0x6012, // ISZ 12H - Increment and skip if zero
      0x4003, // BUN 3H - Jump back to instruction at address 3
      0x7001, // HLT - Halt program
      0x0000, // (Padding)
      0x0000, // (Padding)
      0x0000, // (Padding)
      0x0000, // (Padding)
      0x0000, // (Padding)
      0x0000, // (Padding)
      0x0000, // (Padding)
      0x0000, // (Padding)
      0x0000, // (Padding)
      0x0000, // (Padding)
      0x0003, // Initial counter value (3)
      0x0000, // Counter variable
      0xFFFF, // Value to increment (will become 0 after 3 increments)
    ],
  };

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
      "rows": 4, // Increased from 3 to 4 rows
      "cols": 4,
      "cellW": 60.0, // Increased from 50.0 to 60.0
      "cellH": 32.0, // Increased from 25.0 to 32.0
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

  void clearAllHighlights([String? except]) {
    for (var register in registers) {
      if (except == null || register.id != except) {
        register.isHighlighted = false;
      }
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

    // Get source register value
    final fromIndex = registers.indexWhere((register) => register.id == from);

    if (fromIndex != -1) {
      final sourceValue = registers[fromIndex].value;

      // Highlight source register and bus
      highlightRegister(from);
      simulationState.isHighlightedBus = true;
      simulationState.sourceRegister = from;
      simulationState.destinationRegister = to;
      notifyListeners();

      // After a delay, highlight destination register and transfer the value
      Future.delayed(Duration(milliseconds: 400), () {
        highlightRegister(to);
        // Actually transfer the value from source to destination register
        setRegisterValue(to, sourceValue);
        notifyListeners();

        // After another delay, clear all highlights
        Future.delayed(Duration(milliseconds: 400), () {
          clearAllHighlights();
        });
      });
    }
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

  // Get memory value
  int getMemoryValue(int address) {
    final row = address ~/ 8;
    final col = address % 8;

    if (row < simulationState.memory.length &&
        col < simulationState.memory[row].length) {
      return simulationState.memory[row][col];
    }
    return 0; // Return 0 if address is out of bounds
  }

  void selectMemoryAddress(int address) {
    simulationState.selectedMemoryAddress = address;
    notifyListeners();
  }

  // New methods for instruction mode

  void toggleInstructionMode() {
    simulationState.isInstructionMode = !simulationState.isInstructionMode;
    resetSimulation();
    notifyListeners();
  }

  void resetSimulation() {
    simulationState.decodedInstructionText = null;
    simulationState.currentPhase = 0;

    // Reset registers to initial state
    setRegisterValue("PC", 0);
    setRegisterValue("AC", 0);
    setRegisterValue("DR", 0);
    setRegisterValue("AR", 0);
    setRegisterValue("IR", 0);
    setRegisterValue("TR", 0);

    clearAllHighlights();
  }

  void loadSampleProgram(String programName) {
    final program = samplePrograms[programName];
    if (program != null) {
      // Reset the simulation
      resetSimulation();

      // Load the program into memory
      for (int i = 0; i < program.length; i++) {
        final row = i ~/ 8;
        final col = i % 8;
        if (row < simulationState.memory.length &&
            col < simulationState.memory[row].length) {
          simulationState.memory[row][col] = program[i];
        }
      }

      notifyListeners();
    }
  }

  // Instruction cycle phases
  void fetchPhase() {
    simulationState.currentPhase = 1; // Fetch

    // PC → AR
    final pcIndex = registers.indexWhere((register) => register.id == "PC");
    final pcValue = registers[pcIndex].value;

    // Highlight PC
    highlightRegister("PC");
    simulationState.isHighlightedBus = true;
    simulationState.sourceRegister = "PC";
    simulationState.destinationRegister = "AR";
    notifyListeners();

    // After a delay, highlight AR and set its value
    Future.delayed(Duration(milliseconds: 300), () {
      setRegisterValue("AR", pcValue);
      highlightRegister("AR");
      clearAllHighlights("PC");

      // Select the memory address
      selectMemoryAddress(pcValue);

      // After a delay, fetch from memory to IR
      Future.delayed(Duration(milliseconds: 300), () {
        final memValue = getMemoryValue(pcValue);
        setRegisterValue("IR", memValue);
        highlightRegister("IR");
        clearAllHighlights("AR");

        // Increment PC
        Future.delayed(Duration(milliseconds: 300), () {
          setRegisterValue("PC", pcValue + 1);
          highlightRegister("PC");

          // Clear all highlights
          Future.delayed(Duration(milliseconds: 300), () {
            clearAllHighlights();
            notifyListeners();
          });
        });
      });
    });
  }

  void decodePhase() {
    simulationState.currentPhase = 2; // Decode

    // Highlight IR
    highlightRegister("IR");

    // Get IR value
    final irIndex = registers.indexWhere((register) => register.id == "IR");
    final irValue = registers[irIndex].value;

    // Decode instruction
    final addressingMode = (irValue & 0x8000) >> 15; // MSB (bit 15)
    final opcode = (irValue & 0x7000) >> 12; // Bits 14-12
    final address = irValue & 0x0FFF; // Bits 11-0

    String decodedText = 'Opcode: ${opcode.toRadixString(16).toUpperCase()}, ';
    decodedText +=
        addressingMode == 1 ? 'Indirect Addressing, ' : 'Direct Addressing, ';
    decodedText += 'Address: ${address.toRadixString(16).toUpperCase()}\n';

    // Determine operation
    if (opcode != 7) {
      // Memory-reference instructions
      switch (opcode) {
        case 0:
          decodedText += 'AND: Perform bitwise AND between Memory[AR] and AC';
          break;
        case 1:
          decodedText += 'ADD: Add Memory[AR] to AC';
          break;
        case 2:
          decodedText += 'LDA: Load Memory[AR] into AC';
          break;
        case 3:
          decodedText += 'STA: Store AC into Memory[AR]';
          break;
        case 4:
          decodedText += 'BUN: Branch unconditionally to address';
          break;
        case 5:
          decodedText += 'BSA: Branch and store return address';
          break;
        case 6:
          decodedText += 'ISZ: Increment Memory[AR] and skip if zero';
          break;
      }
    } else {
      // Register-reference instructions
      if (address == 0) {
        decodedText += 'Clear Sequence Counter (SC)';
      } else {
        final setBit = _findSetBit(address);
        switch (setBit) {
          case 0:
            decodedText += 'HLT: Halt program execution';
            break;
          case 1:
            decodedText += 'SZE: Skip next instruction if E is zero';
            break;
          case 2:
            decodedText += 'SZA: Skip next instruction if AC is zero';
            break;
          case 3:
            decodedText += 'SNA: Skip next instruction if AC is negative';
            break;
          case 4:
            decodedText += 'SPA: Skip next instruction if AC is positive';
            break;
          case 5:
            decodedText += 'INC: Increment AC';
            break;
          case 6:
            decodedText += 'CIL: Circular left shift of AC';
            break;
          case 7:
            decodedText += 'CIR: Circular right shift of AC';
            break;
          case 8:
            decodedText += 'CME: Complement E';
            break;
          case 9:
            decodedText += 'CMA: Complement AC';
            break;
          case 10:
            decodedText += 'CLE: Clear E';
            break;
          case 11:
            decodedText += 'CLA: Clear AC';
            break;
          default:
            decodedText += 'Unknown Register Reference instruction';
        }
      }
    }

    // Set the decoded instruction text
    simulationState.decodedInstructionText = decodedText;
    notifyListeners();
  }

  void executePhase() {
    simulationState.currentPhase = 3; // Execute

    // Get IR value
    final irIndex = registers.indexWhere((register) => register.id == "IR");
    final irValue = registers[irIndex].value;

    // Extract instruction components
    final addressingMode = (irValue & 0x8000) >> 15;
    final opcode = (irValue & 0x7000) >> 12;
    final address = irValue & 0x0FFF;

    // Get effective address
    int effectiveAddress = address;
    if (addressingMode == 1) {
      // Indirect addressing: fetch address from memory[address]
      effectiveAddress = getMemoryValue(address);
    }

    // Set AR to the effective address (for most instructions)
    setRegisterValue("AR", effectiveAddress);

    // Execute based on opcode
    if (opcode != 7) {
      // Memory-reference instructions
      executeMemoryReferenceInstruction(opcode, effectiveAddress);
    } else {
      // Register-reference instructions
      executeRegisterReferenceInstruction(address);
    }

    // Clear highlights after execution
    Future.delayed(Duration(milliseconds: 800), () {
      clearAllHighlights();
      notifyListeners();
    });
  }

  // Helper method to find the first set bit (1) in a number
  int _findSetBit(int value) {
    for (int i = 0; i < 12; i++) {
      if ((value & (1 << i)) != 0) {
        return i;
      }
    }
    return -1;
  }

  void executeMemoryReferenceInstruction(int opcode, int address) {
    switch (opcode) {
      case 0: // AND
        _executeAnd(address);
        break;
      case 1: // ADD
        _executeAdd(address);
        break;
      case 2: // LDA
        _executeLda(address);
        break;
      case 3: // STA
        _executeSta(address);
        break;
      case 4: // BUN
        _executeBun(address);
        break;
      case 5: // BSA
        _executeBsa(address);
        break;
      case 6: // ISZ
        _executeIsz(address);
        break;
    }
  }

  void executeRegisterReferenceInstruction(int address) {
    if (address == 0) {
      // Clear SC (no-op in this simulation)
      return;
    }

    final setBit = _findSetBit(address);
    switch (setBit) {
      case 0: // HLT
        // Halt execution (no-op in this simulation)
        break;
      case 1: // SZE
        _executeSze();
        break;
      case 2: // SZA
        _executeSza();
        break;
      case 3: // SNA
        _executeSna();
        break;
      case 4: // SPA
        _executeSpa();
        break;
      case 5: // INC
        _executeInc();
        break;
      case 6: // CIL
        _executeCil();
        break;
      case 7: // CIR
        _executeCir();
        break;
      case 8: // CME
        _executeCme();
        break;
      case 9: // CMA
        _executeCma();
        break;
      case 10: // CLE
        _executeCle();
        break;
      case 11: // CLA
        _executeCla();
        break;
    }
  }

  // Memory-reference instruction implementations

  void _executeAnd(int address) {
    // Load Memory[AR] into Data Register (DR)
    final memValue = getMemoryValue(address);
    setRegisterValue("DR", memValue);
    highlightRegister("DR");

    // Get current AC value
    final acIndex = registers.indexWhere((register) => register.id == "AC");
    final acValue = registers[acIndex].value;

    // After a delay, perform AND operation
    Future.delayed(Duration(milliseconds: 300), () {
      highlightRegister("AC");

      // Perform AND operation
      final result = acValue & memValue;

      // Set result in AC
      Future.delayed(Duration(milliseconds: 300), () {
        setRegisterValue("AC", result);
      });
    });
  }

  void _executeAdd(int address) {
    // Load Memory[AR] into Data Register (DR)
    final memValue = getMemoryValue(address);
    setRegisterValue("DR", memValue);
    highlightRegister("DR");

    // Get current AC value
    final acIndex = registers.indexWhere((register) => register.id == "AC");
    final acValue = registers[acIndex].value;

    // After a delay, perform ADD operation
    Future.delayed(Duration(milliseconds: 300), () {
      highlightRegister("AC");

      // Perform ADD operation
      final result = acValue + memValue;

      // Set result in AC
      Future.delayed(Duration(milliseconds: 300), () {
        setRegisterValue("AC", result & 0xFFFF); // Apply 16-bit mask

        // Set E-bit if overflow
        if (result > 0xFFFF) {
          simulationState.eBit = true;
        }
      });
    });
  }

  void _executeLda(int address) {
    // Load Memory[AR] into Data Register (DR)
    final memValue = getMemoryValue(address);
    setRegisterValue("DR", memValue);
    highlightRegister("DR");

    // After a delay, transfer to AC
    Future.delayed(Duration(milliseconds: 300), () {
      setRegisterValue("AC", memValue);
      highlightRegister("AC");
    });
  }

  void _executeSta(int address) {
    // Get AC value
    final acIndex = registers.indexWhere((register) => register.id == "AC");
    final acValue = registers[acIndex].value;

    // Highlight AC
    highlightRegister("AC");

    // After delay, store to memory
    Future.delayed(Duration(milliseconds: 300), () {
      selectMemoryAddress(address);
      setMemoryValue(address, acValue);
    });
  }

  void _executeBun(int address) {
    // Highlight AR
    highlightRegister("AR");

    // After delay, transfer to PC
    Future.delayed(Duration(milliseconds: 300), () {
      setRegisterValue("PC", address);
      highlightRegister("PC");
    });
  }

  void _executeBsa(int address) {
    // Get PC value
    final pcIndex = registers.indexWhere((register) => register.id == "PC");
    final pcValue = registers[pcIndex].value;

    // Store PC in Memory[address]
    highlightRegister("PC");
    selectMemoryAddress(address);
    setMemoryValue(address, pcValue);

    // After delay, increment address and load to PC
    Future.delayed(Duration(milliseconds: 300), () {
      int newAddress = address + 1;
      setRegisterValue("PC", newAddress);
      highlightRegister("PC");
    });
  }

  void _executeIsz(int address) {
    // Load Memory[address] into DR
    final memValue = getMemoryValue(address);
    setRegisterValue("DR", memValue);
    highlightRegister("DR");
    selectMemoryAddress(address);

    // After delay, increment DR
    Future.delayed(Duration(milliseconds: 300), () {
      final incrementedValue = (memValue + 1) & 0xFFFF; // Apply 16-bit mask
      setRegisterValue("DR", incrementedValue);

      // Store back to memory
      Future.delayed(Duration(milliseconds: 300), () {
        setMemoryValue(address, incrementedValue);

        // If zero, increment PC
        if (incrementedValue == 0) {
          Future.delayed(Duration(milliseconds: 300), () {
            final pcIndex =
                registers.indexWhere((register) => register.id == "PC");
            final pcValue = registers[pcIndex].value;
            setRegisterValue("PC", pcValue + 1);
            highlightRegister("PC");
          });
        }
      });
    });
  }

  // Register-reference instruction implementations

  void _executeSze() {
    if (simulationState.eBit == false) {
      // Skip next instruction by incrementing PC
      final pcIndex = registers.indexWhere((register) => register.id == "PC");
      final pcValue = registers[pcIndex].value;
      setRegisterValue("PC", pcValue + 1);
      highlightRegister("PC");
    }
  }

  void _executeSza() {
    final acIndex = registers.indexWhere((register) => register.id == "AC");
    final acValue = registers[acIndex].value;
    highlightRegister("AC");

    if (acValue == 0) {
      // Skip next instruction by incrementing PC
      Future.delayed(Duration(milliseconds: 300), () {
        final pcIndex = registers.indexWhere((register) => register.id == "PC");
        final pcValue = registers[pcIndex].value;
        setRegisterValue("PC", pcValue + 1);
        highlightRegister("PC");
      });
    }
  }

  void _executeSna() {
    final acIndex = registers.indexWhere((register) => register.id == "AC");
    final acValue = registers[acIndex].value;
    highlightRegister("AC");

    if ((acValue & 0x8000) != 0) {
      // Check if MSB is set (negative)
      // Skip next instruction by incrementing PC
      Future.delayed(Duration(milliseconds: 300), () {
        final pcIndex = registers.indexWhere((register) => register.id == "PC");
        final pcValue = registers[pcIndex].value;
        setRegisterValue("PC", pcValue + 1);
        highlightRegister("PC");
      });
    }
  }

  void _executeSpa() {
    final acIndex = registers.indexWhere((register) => register.id == "AC");
    final acValue = registers[acIndex].value;
    highlightRegister("AC");

    if ((acValue & 0x8000) == 0 && acValue != 0) {
      // Not negative and not zero
      // Skip next instruction by incrementing PC
      Future.delayed(Duration(milliseconds: 300), () {
        final pcIndex = registers.indexWhere((register) => register.id == "PC");
        final pcValue = registers[pcIndex].value;
        setRegisterValue("PC", pcValue + 1);
        highlightRegister("PC");
      });
    }
  }

  void _executeInc() {
    final acIndex = registers.indexWhere((register) => register.id == "AC");
    final acValue = registers[acIndex].value;
    highlightRegister("AC");

    // Increment AC
    Future.delayed(Duration(milliseconds: 300), () {
      setRegisterValue("AC", (acValue + 1) & 0xFFFF); // Apply 16-bit mask
    });
  }

  void _executeCil() {
    final acIndex = registers.indexWhere((register) => register.id == "AC");
    final acValue = registers[acIndex].value;
    highlightRegister("AC");

    // Get current E bit and MSB of AC
    final msb = (acValue & 0x8000) >> 15;
    final oldE = simulationState.eBit ? 1 : 0;

    // Shift left and place E into LSB
    final newValue = ((acValue << 1) & 0xFFFF) | oldE;
    simulationState.eBit = msb == 1;

    // Update AC
    Future.delayed(Duration(milliseconds: 300), () {
      setRegisterValue("AC", newValue);
    });
  }

  void _executeCir() {
    final acIndex = registers.indexWhere((register) => register.id == "AC");
    final acValue = registers[acIndex].value;
    highlightRegister("AC");

    // Get current E bit and LSB of AC
    final lsb = acValue & 0x0001;
    final oldE = simulationState.eBit ? 1 : 0;

    // Shift right and place E into MSB
    final newValue = (acValue >> 1) | (oldE << 15);
    simulationState.eBit = lsb == 1;

    // Update AC
    Future.delayed(Duration(milliseconds: 300), () {
      setRegisterValue("AC", newValue);
    });
  }

  void _executeCme() {
    highlightRegister("AC"); // Indicate operation is affecting E
    simulationState.eBit = !simulationState.eBit;
  }

  void _executeCma() {
    final acIndex = registers.indexWhere((register) => register.id == "AC");
    final acValue = registers[acIndex].value;
    highlightRegister("AC");

    // Complement AC
    Future.delayed(Duration(milliseconds: 300), () {
      setRegisterValue("AC", (~acValue) & 0xFFFF); // Apply 16-bit mask
    });
  }

  void _executeCle() {
    highlightRegister("AC"); // Indicate operation is affecting E
    simulationState.eBit = false;
  }

  void _executeCla() {
    highlightRegister("AC");

    // Clear AC
    Future.delayed(Duration(milliseconds: 300), () {
      setRegisterValue("AC", 0);
    });
  }
}
