import 'package:flutter/material.dart';
import 'package:mano_simp/models/assembly_code.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditorProvider extends ChangeNotifier {
  // Text editing controller for the code editor
  final TextEditingController codeController = TextEditingController();

  // Assembly code model
  AssemblyCode _assemblyCode = AssemblyCode(code: '');

  // Getters
  AssemblyCode get assemblyCode => _assemblyCode;
  String get code => codeController.text;
  List<String> get errors => _assemblyCode.errors;
  bool get isValid => _assemblyCode.isValid;

  // Update code from text controller
  void updateCode() {
    _assemblyCode = _assemblyCode.copyWith(code: codeController.text);
    notifyListeners();
  }

  // Clear errors
  void clearErrors() {
    _assemblyCode = _assemblyCode.copyWith(errors: [], isValid: true);
    notifyListeners();
  }

  // Set errors
  void setErrors(List<String> errors) {
    _assemblyCode =
        _assemblyCode.copyWith(errors: errors, isValid: errors.isEmpty);
    notifyListeners();
  }

  // Run code - this will eventually connect to the backend
  // For now it will just simulate a response
  Future<void> runCode(BuildContext context) async {
    // Clear any previous errors
    clearErrors();

    try {
      // In a real implementation, this would call the backend API
      // For now, we'll just simulate validating the code locally
      await Future.delayed(
          Duration(milliseconds: 500)); // Simulate network delay

      // For demonstration only - validate that code isn't empty
      if (codeController.text.trim().isEmpty) {
        setErrors(['Code cannot be empty']);
        return;
      }

      // Simple validation - check if code has at least some basic Mano assembly instructions
      final lowerCode = codeController.text.toLowerCase();
      if (!lowerCode.contains('org') &&
          !lowerCode.contains('and') &&
          !lowerCode.contains('add') &&
          !lowerCode.contains('lda') &&
          !lowerCode.contains('sta')) {
        setErrors(['Code should contain valid Mano assembly instructions']);
      } else {
        // Notify success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Code validated successfully')),
        );
      }
    } catch (e) {
      setErrors(['Error: ${e.toString()}']);
    }
  }

  // Real implementation would look something like this:
  Future<void> _validateWithBackend() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/validate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': codeController.text}),
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        // Handle successful validation
        clearErrors();
        // Process simulation trace
        // simulationProvider.processSimulationTrace(data['simulation_trace']);
      } else {
        // Handle validation errors
        setErrors(List<String>.from(data['errors']));
      }
    } catch (e) {
      setErrors(['Connection error: ${e.toString()}']);
    }
  }
}
