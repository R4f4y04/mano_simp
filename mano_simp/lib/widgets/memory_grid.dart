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

    // Highlight color - same amber color for consistency
    final highlightColor = Color(0xFFFFD54F);

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
          const SizedBox(height: 8),

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
      margin: EdgeInsets.symmetric(horizontal: 4),
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
                  blurRadius: 3,
                  spreadRadius: 1,
                  offset: Offset(0, 1),
                )
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Address and value in hex with improved visibility when selected
          Text(
            "${address.toRadixString(16).padLeft(2, '0').toUpperCase()}: ${value.toRadixString(16).padLeft(4, '0').toUpperCase()}",
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.black : Colors.black87,
              fontFamily: 'RobotoMono',
            ),
          ),
        ],
      ),
    );
  }
}
