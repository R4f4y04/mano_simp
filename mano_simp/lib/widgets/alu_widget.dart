import 'package:flutter/material.dart';
import 'package:mano_simp/config/theme_config.dart';

class ALUWidget extends StatelessWidget {
  final Map<String, dynamic> aluConfig;

  const ALUWidget({Key? key, required this.aluConfig}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double x = aluConfig['x'].toDouble();
    final double y = aluConfig['y'].toDouble();
    final double w = aluConfig['w'].toDouble();
    final double h = aluConfig['h'].toDouble();

    return Positioned(
      left: x,
      top: y,
      child: Column(
        children: [
          // ALU Label
          const Text(
            'ALU',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          // ALU shape (pentagon-like)
          CustomPaint(
            size: Size(w, h),
            painter: ALUPainter(
              color: ThemeConfig.getColorFromHex(
                  ThemeConfig.config['theme']['registerColor']),
              borderColor: Colors.black26,
            ),
          ),
        ],
      ),
    );
  }
}

class ALUPainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  ALUPainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path();

    // Drawing a pentagon-like shape for ALU
    path.moveTo(size.width / 2, 0); // Top center
    path.lineTo(size.width, size.height * 0.3); // Top right
    path.lineTo(size.width, size.height * 0.7); // Bottom right
    path.lineTo(size.width / 2, size.height); // Bottom center
    path.lineTo(0, size.height * 0.7); // Bottom left
    path.lineTo(0, size.height * 0.3); // Top left
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
