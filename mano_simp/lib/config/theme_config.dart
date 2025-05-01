import 'package:flutter/material.dart';

class ThemeConfig {
  // Single highlight color as a Flutter Color type
  static Color highlightColor = Colors.purple.shade300; // Amber accent color

  static const Map<String, dynamic> config = {
    "appName": "ManoSimP",
    "theme": {
      "primaryColor": "#2962FF",
      "backgroundColor": "#FFFFFF",
      "registerColor": "#F5F5F5",
      "busColor": "#E0E0E0",
      "errorColor": "#B00020",
      "fontFamilyMono": "RobotoMono"
    },
    "layout": {
      "navBar": {
        "tabs": ["Simulation", "Editor"],
        "activeIconSize": 24,
        "inactiveIconSize": 20,
        "height": 56
      },
      "screens": {
        "Simulation": {
          "registers": [
            {"id": "AR", "x": 32, "y": 80, "w": 64, "h": 40},
            {"id": "PC", "x": 120, "y": 80, "w": 64, "h": 40},
            {"id": "DR", "x": 208, "y": 80, "w": 64, "h": 40},
            {"id": "AC", "x": 296, "y": 80, "w": 64, "h": 40},
            {"id": "INPR", "x": 32, "y": 160, "w": 64, "h": 40},
            {"id": "IR", "x": 120, "y": 160, "w": 64, "h": 40},
            {"id": "TR", "x": 208, "y": 160, "w": 64, "h": 40},
            {"id": "OUTR", "x": 296, "y": 160, "w": 64, "h": 40}
          ],
          "alu": {"x": 160, "y": 240, "w": 80, "h": 80},
          "bus": {"x": 0, "y": 140, "h": 4, "paddingHorizontal": 16},
          "memory": {
            "x": 16,
            "y": 350,
            "cols": 8,
            "rows": 2,
            "cellW": 40,
            "cellH": 32
          },
          "valueText": {"fontSize": 14, "fontWeight": "bold"}
        },
        "Editor": {
          "console": {"x": 16, "y": 16, "w": 344, "h": 300, "fontSize": 14},
          "runButton": {"x": 16, "y": 330, "w": 344, "h": 48, "text": "Run"}
        }
      }
    },
    "animations": {"highlightDurationMs": 400, "fadeCurve": "easeInOut"}
  };

  // Helper methods to get variations of the highlight color
  static Color get highlightColorLight => highlightColor.withOpacity(0.2);
  static Color get highlightColorDark =>
      Colors.purple.shade600; // Slightly darker amber

  // Helper method to get highlight color with specific opacity
  static Color highlightWithOpacity(double opacity) {
    return highlightColor.withOpacity(opacity);
  }
}
