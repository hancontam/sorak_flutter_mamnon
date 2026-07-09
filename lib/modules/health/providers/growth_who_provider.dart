import 'package:flutter/material.dart';

import '../models/health_assessment.dart';
import '../repositories/growth_who_repository.dart';

class GrowthWhoProvider extends ChangeNotifier {
  GrowthWhoProvider({required GrowthWhoRepository growthWhoRepository})
    : _growthWhoRepository = growthWhoRepository;

  final GrowthWhoRepository _growthWhoRepository;

  List<HealthAssessment> _students = [];
  List<HealthAssessment> _history = [];
  HealthAssessment? _selectedStudent;
  bool _isLoading = false;
  String? _errorMessage;

  List<HealthAssessment> get students => _students;
  List<HealthAssessment> get history => _history;
  HealthAssessment? get selectedStudent => _selectedStudent;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load({required String role}) async {
    _setLoading(true);
    try {
      _students = await _growthWhoRepository.getLatest(role: role);
      _errorMessage = null;
      if (_students.isNotEmpty) {
        await selectStudent(_students.first.studentId, role: role);
      }
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> selectStudent(int studentId, {required String role}) async {
    try {
      _selectedStudent = _students.firstWhere(
        (item) => item.studentId == studentId,
        orElse: () => _students.first,
      );
      _history = await _growthWhoRepository.getHistory(
        studentId: studentId,
        role: role,
      );
      _errorMessage = null;
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
