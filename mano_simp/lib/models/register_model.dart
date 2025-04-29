class Register {
  final String id;
  final double x, y, w, h;
  int value;
  bool isHighlighted;

  Register({
    required this.id,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    this.value = 0,
    this.isHighlighted = false,
  });
}
