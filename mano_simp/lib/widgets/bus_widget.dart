import 'package:flutter/material.dart';
import 'package:mano_simp/config/theme_config.dart';
import 'package:provider/provider.dart';
import 'package:mano_simp/providers/simulation_provider.dart';

class BusWidget extends StatelessWidget {
  final Map<String, dynamic> busConfig;

  const BusWidget({Key? key, required this.busConfig}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final simulationProvider = Provider.of<SimulationProvider>(context);
    final simulationState = simulationProvider.simulationState;
    final registers = simulationProvider.registers;
    final screenWidth = MediaQuery.of(context).size.width;

    // Position the bus in the middle between top and bottom registers
    final double busY =
        120; // Fixed position to be in the middle between registers
    final double busHeight = 6.0; // Make the bus more prominent
    final double busWidth = screenWidth - 40; // Width with padding

    final animDuration = Duration(
      milliseconds: ThemeConfig.config['animations']['highlightDurationMs'],
    );

    // Highlight color - subtle amber for better visibility
    final highlightColor = Color(0xFFFFD54F);

    // Calculate connection lines for each register to the bus
    final List<Widget> connectionLines = [];
    for (var register in registers) {
      final double registerCenterX = register.x + (register.w / 2);
      final bool isAboveBus = register.y < busY;
      final double connectionStartY =
          isAboveBus ? register.y + register.h : register.y;
      final double connectionEndY = busY + (isAboveBus ? 0 : busHeight);
      final bool isHighlighted =
          simulationState.sourceRegister == register.id ||
              simulationState.destinationRegister == register.id;

      connectionLines.add(Positioned(
        left: registerCenterX,
        top: isAboveBus ? connectionStartY : busY + busHeight,
        child: AnimatedContainer(
          duration: animDuration,
          width: 1.5, // Slightly thicker line for better visibility
          height: isAboveBus
              ? busY - connectionStartY
              : connectionStartY - (busY + busHeight),
          color: isHighlighted ? highlightColor : Colors.grey.shade400,
        ),
      ));
    }

    return Stack(
      children: [
        // Main horizontal bus - positioned in the middle between the registers
        Positioned(
          left: 20,
          top: busY,
          child: AnimatedContainer(
            duration: animDuration,
            width: busWidth,
            height: busHeight,
            decoration: BoxDecoration(
              color: simulationState.isHighlightedBus
                  ? highlightColor
                  : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(1),
            ),
            child: simulationState.isHighlightedBus
                ? DataFlowAnimation(width: busWidth, height: busHeight)
                : null,
          ),
        ),

        // Connection lines from registers to bus
        ...connectionLines,
      ],
    );
  }
}

// Animated dots flowing through the bus when active
class DataFlowAnimation extends StatefulWidget {
  final double width;
  final double height;

  const DataFlowAnimation({required this.width, required this.height});

  @override
  State<DataFlowAnimation> createState() => _DataFlowAnimationState();
}

class _DataFlowAnimationState extends State<DataFlowAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: DataFlowPainter(progress: _controller.value),
        );
      },
    );
  }
}

class DataFlowPainter extends CustomPainter {
  final double progress;

  DataFlowPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Draw flowing dots - minimalist approach
    final int dotCount = 12;
    final double spacing = size.width / dotCount;

    for (int i = 0; i < dotCount; i++) {
      // Calculate dot position with animation
      double x = (i * spacing + progress * size.width) % size.width;
      canvas.drawCircle(Offset(x, size.height / 2), 1.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant DataFlowPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
