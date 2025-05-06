import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mano_simp/providers/simulation_provider.dart';

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

    return GestureDetector(
      onTap: () {
        _showMemoryEditDialog(context, row, col, value, address);
      },
      child: AnimatedContainer(
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
            "${address.toRadixString(16).padLeft(2, '0').toUpperCase()}: ${value.toRadixString(16).padLeft(4, '0').toUpperCase()}",
            style: TextStyle(
              fontSize: 12, // Increased from 10 to 12
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.black : Colors.black87,
              fontFamily: 'RobotoMono',
            ),
          ),
        ),
      ),
    );
  }

  void _showMemoryEditDialog(
      BuildContext context, int row, int col, int currentValue, int address) {
    final TextEditingController controller = TextEditingController();
    String inputType = 'dec'; // Default to decimal input
    String valuePreview = '0x${currentValue.toRadixString(16).toUpperCase()}';

    // Show dialog to edit memory value
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void updatePreview(String input) {
              try {
                int value;
                if (inputType == 'dec') {
                  value = int.parse(input);
                } else if (inputType == 'bin') {
                  value = int.parse(input, radix: 2);
                } else {
                  value = int.parse(input, radix: 16);
                }
                setState(() {
                  valuePreview = '0x${value.toRadixString(16).toUpperCase()}';
                });
              } catch (e) {
                setState(() {
                  valuePreview = 'Invalid input';
                });
              }
            }

            return AlertDialog(
              title: Text(
                  'Edit Memory Address ${address.toRadixString(16).toUpperCase()}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Radio<String>(
                        value: 'dec',
                        groupValue: inputType,
                        onChanged: (value) {
                          setState(() {
                            inputType = value!;
                            controller.clear();
                            valuePreview = '0x0';
                          });
                        },
                      ),
                      Text('Decimal'),
                      Radio<String>(
                        value: 'bin',
                        groupValue: inputType,
                        onChanged: (value) {
                          setState(() {
                            inputType = value!;
                            controller.clear();
                            valuePreview = '0x0';
                          });
                        },
                      ),
                      Text('Binary'),
                    ],
                  ),
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: inputType == 'dec'
                          ? 'Enter decimal value'
                          : inputType == 'bin'
                              ? 'Enter binary value'
                              : 'Enter hex value',
                      hintText: inputType == 'dec'
                          ? 'e.g., 255'
                          : inputType == 'bin'
                              ? 'e.g., 11111111'
                              : 'e.g., FF',
                    ),
                    keyboardType: TextInputType.text,
                    onChanged: updatePreview,
                  ),
                  SizedBox(height: 10),
                  Text('Hex value: $valuePreview'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    try {
                      int value;
                      if (inputType == 'dec') {
                        value = int.parse(controller.text);
                      } else if (inputType == 'bin') {
                        value = int.parse(controller.text, radix: 2);
                      } else {
                        value = int.parse(controller.text, radix: 16);
                      }

                      // Update the memory value through the provider
                      final provider = Provider.of<SimulationProvider>(context,
                          listen: false);
                      provider.setMemoryValue(address, value);
                      Navigator.pop(context);
                    } catch (e) {
                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Invalid input: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
