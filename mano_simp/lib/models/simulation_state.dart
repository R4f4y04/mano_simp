class SimulationState {
  // Highlighted bus segments
  bool isHighlightedBus = false;
  String? sourceRegister;
  String? destinationRegister;

  // Memory state
  List<List<int>> memory = List.generate(32, (_) => List.filled(8, 0));
  int selectedMemoryAddress = 0;

  // Current step in simulation
  int currentStep = 0;

  // Simulation status
  bool isRunning = false;
}
