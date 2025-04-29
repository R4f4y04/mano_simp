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

    // Highlight color - subtle amber for better visibility while keeping minimalist design
    final highlightColor = Color(0xFFFFD54F);

    return Positioned(
      left: register.x,
      top: register.y,
      child: Column(
        children: [
          // Register label
          Text(
            register.id,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: register.isHighlighted ? highlightColor : Colors.black,
            ),
          ),
          const SizedBox(height: 2),

          // Register box with value
          AnimatedContainer(
            duration: animDuration,
            curve: Curves.easeInOut,
            width: register.w,
            height: register.h,
            decoration: BoxDecoration(
              color: register.isHighlighted
                  ? highlightColor.withOpacity(0.2)
                  : Colors.white,
              border: Border.all(
                color: register.isHighlighted ? highlightColor : Colors.black,
                width: register.isHighlighted ? 2.0 : 1.0,
              ),
              boxShadow: register.isHighlighted
                  ? [
                      BoxShadow(
                        color: highlightColor.withOpacity(0.4),
                        blurRadius: 4,
                        spreadRadius: 1,
                        offset: Offset(0, 1),
                      )
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                register.value.toRadixString(16).padLeft(4, '0').toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: register.isHighlighted ? Colors.black : Colors.black87,
                  fontFamily: 'RobotoMono',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
