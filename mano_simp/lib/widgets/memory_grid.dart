import 'package:flutter/material.dart';
import 'package:mano_simp/config/theme_config.dart';

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
    final cols = memoryConfig['cols'];
    final rows = memoryConfig['rows'];
    final cellW = memoryConfig['cellW'].toDouble();
    final cellH = memoryConfig['cellH'].toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Memory',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: List.generate(rows, (row) {
              return Row(
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
                    cellW,
                    cellH,
                  );
                }),
              );
            }),
          ),
        ),
      ],
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
    final animDuration = Duration(
      milliseconds: ThemeConfig.config['animations']['highlightDurationMs'],
    );

    // Get value from memory (safely)
    int value = 0;
    if (row < memory.length && col < memory[row].length) {
      value = memory[row][col];
    }

    return AnimatedContainer(
      duration: animDuration,
      curve: Curves.easeInOut,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isSelected
            ? ThemeConfig.getColorFromHex(
                ThemeConfig.config['theme']['highlightColor'])
            : ThemeConfig.getColorFromHex(
                ThemeConfig.config['theme']['registerColor']),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Address in hex
          Text(
            address.toRadixString(16).padLeft(2, '0').toUpperCase(),
            style: TextStyle(
              fontSize: 8,
              color: Colors.black54,
            ),
          ),
          // Value in hex
          Text(
            value.toRadixString(16).padLeft(4, '0').toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: ThemeConfig.config['theme']['fontFamilyMono'],
            ),
          ),
        ],
      ),
    );
  }
}
