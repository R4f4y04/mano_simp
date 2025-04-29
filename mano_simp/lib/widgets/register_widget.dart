import 'package:flutter/material.dart';
import 'package:mano_simp/models/register_model.dart';
import 'package:mano_simp/config/theme_config.dart';

class RegisterWidget extends StatelessWidget {
  final Register register;

  const RegisterWidget({Key? key, required this.register}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final animDuration = Duration(
      milliseconds: ThemeConfig.config['animations']['highlightDurationMs'],
    );

    final valueTextStyle = TextStyle(
      fontSize: ThemeConfig.config['layout']['screens']['Simulation']
              ['valueText']['fontSize']
          .toDouble(),
      fontWeight: FontWeight.bold,
      fontFamily: ThemeConfig.config['theme']['fontFamilyMono'],
    );

    return Positioned(
      left: register.x,
      top: register.y,
      child: Column(
        children: [
          // Register label
          Text(
            register.id,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          // Register box with value
          AnimatedContainer(
            duration: animDuration,
            curve: Curves.easeInOut,
            width: register.w,
            height: register.h,
            decoration: BoxDecoration(
              color: register.isHighlighted
                  ? ThemeConfig.getColorFromHex(
                      ThemeConfig.config['theme']['highlightColor'])
                  : ThemeConfig.getColorFromHex(
                      ThemeConfig.config['theme']['registerColor']),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black26),
            ),
            child: Center(
              child: Text(
                register.value.toRadixString(16).padLeft(4, '0').toUpperCase(),
                style: valueTextStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
