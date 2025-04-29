class AssemblyCode {
  final String code;
  final List<String> errors;
  final bool isValid;

  AssemblyCode({
    required this.code,
    this.errors = const [],
    this.isValid = true,
  });

  AssemblyCode copyWith({
    String? code,
    List<String>? errors,
    bool? isValid,
  }) {
    return AssemblyCode(
      code: code ?? this.code,
      errors: errors ?? this.errors,
      isValid: isValid ?? this.isValid,
    );
  }
}
