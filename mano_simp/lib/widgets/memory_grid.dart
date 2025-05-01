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
    // Get memory grid config with 3 rows and 4 columns
    final rows = memoryConfig['rows'] ?? 3;
    final cols = memoryConfig['cols'] ?? 4;
    final cellWidth = memoryConfig['cellW'] ?? 50.0;
    final cellHeight = memoryConfig['cellH'] ?? 25.0;

    // Highlight color - same amber color for consistency
    final highlightColor = Colors.purple.shade300;

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
          const SizedBox(height: 5),

          // Memory grid - 3 rows x 4 columns
          for (int row = 0; row < rows; row++)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(cols, (col) {
                // Calculate memory address
                final address = (row * cols + col).toInt();
                final isSelected = address == selectedAddress;

                return _buildMemoryCell(
                  context,
                  row,
                  col,
                  address,
                  isSelected,
                  cellWidth,
                  cellHeight,
                  highlightColor,
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
    Color highlightColor,
  ) {
    // Get value from memory (safely)
    int value = 0;
    if (row < memory.length && col < memory[row].length) {
      value = memory[row][col];
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: 400),
      width: width,
      height: height,
      margin: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? highlightColor.withOpacity(0.2) : Colors.white,
        border: Border.all(
          color: isSelected ? highlightColor : Colors.black,
          width: isSelected ? 2.0 : 1.0,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: highlightColor.withOpacity(0.3),
                  blurRadius: 2,
                  spreadRadius: 0,
                  offset: Offset(0, 1),
                )
              ]
            : null,
      ),
      child: Center(
        child: Text(
          "${address.toRadixString(16).padLeft(2, '0').toUpperCase()}: ${value.toRadixString(16).padLeft(2, '0').toUpperCase()}",
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.black : Colors.black87,
            fontFamily: 'RobotoMono',
          ),
        ),
      ),
    );
  }
}
