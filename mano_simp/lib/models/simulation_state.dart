class SimulationState {
  // Highlighted bus segments
  bool isHighlightedBus = false;
  String? sourceRegister;
  String? destinationRegister;
  bool isAluActive = false;

  // Memory state
  List<List<int>> memory = List.generate(32, (_) => List.filled(8, 0));
  int selectedMemoryAddress = 0;

  // Current step in simulation
  int currentStep = 0;

  // Simulation status
  bool isRunning = false;

  // Instruction mode state
  bool isInstructionMode = false;
  String? decodedInstructionText;
  int currentPhase = 0; // 0: None, 1: Fetch, 2: Decode, 3: Execute

  // E-bit for register reference operations
  bool eBit = false;
}
