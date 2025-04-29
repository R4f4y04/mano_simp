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

    final double x = busConfig['x'].toDouble();
    final double y = busConfig['y'].toDouble();
    final double h = busConfig['h'].toDouble();
    final double paddingHorizontal = busConfig['paddingHorizontal'].toDouble();

    final screenWidth = MediaQuery.of(context).size.width;
    final busWidth = screenWidth - (paddingHorizontal * 2);

    final animDuration = Duration(
      milliseconds: ThemeConfig.config['animations']['highlightDurationMs'],
    );

    return Positioned(
      left: x + paddingHorizontal,
      top: y,
      child: AnimatedContainer(
        duration: animDuration,
        curve: Curves.easeInOut,
        width: busWidth,
        height: h,
        decoration: BoxDecoration(
          color: simulationState.isHighlightedBus
              ? ThemeConfig.getColorFromHex(
                  ThemeConfig.config['theme']['highlightColor'])
              : ThemeConfig.getColorFromHex(
                  ThemeConfig.config['theme']['busColor']),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
