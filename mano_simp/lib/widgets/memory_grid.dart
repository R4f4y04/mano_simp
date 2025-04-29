import 'package:flutter/material.dart';

class MemoryGrid extends StatelessWidget {
  final Map<String, dynamic> memoryConfig;
  final List<List<int>> memory;
  final int selectedAddress;

  const MemoryGrid({
    Key? key,
    required this.memoryConfig,
    required this.memory,
    required this.selectedAddress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use fewer memory cells - just 4 for demonstration
    const rows = 1;
    const cols = 4;
    const cellWidth = 60.0;
    const cellHeight = 30.0;

    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Memory label
          Text(
            'Memory',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),

          // Simple memory cells in a row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(cols, (col) {
              // Calculate memory address
              final address = col;
              final isSelected = address == selectedAddress;

              return _buildMemoryCell(
                context,
                0,
                col,
                address,
                isSelected,
                cellWidth,
                cellHeight,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryCell(
    BuildContext context,
    int row,
    int col,
    int address,
    bool isSelected,
    double width,
    double height,
  ) {
    // Get value from memory (safely)
    int value = 0;
    if (row < memory.length && col < memory[row].length) {
      value = memory[row][col];
    }

    return Container(
      width: width,
      height: height,
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black12 : Colors.white,
        border: Border.all(
          color: Colors.black,
          width: 1.0,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Address and value in hex
          Text(
            "${address.toRadixString(16).padLeft(2, '0').toUpperCase()}: ${value.toRadixString(16).padLeft(4, '0').toUpperCase()}",
            style: TextStyle(
              fontSize: 12,
              color: Colors.black,
              fontFamily: 'RobotoMono',
            ),
          ),
        ],
      ),
    );
  }
}
