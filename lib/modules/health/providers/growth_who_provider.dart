import 'package:flutter/material.dart';

import '../models/health_assessment.dart';
import '../models/who_curve_point.dart';
import '../repositories/growth_who_repository.dart';

class GrowthWhoProvider extends ChangeNotifier {
  GrowthWhoProvider({required GrowthWhoRepository growthWhoRepository})
    : _growthWhoRepository = growthWhoRepository;

  final GrowthWhoRepository _growthWhoRepository;

  List<HealthAssessment> _students = [];
  List<HealthAssessment> _history = [];
  List<WhoCurvePoint> _whoCurves = [];
  HealthAssessment? _selectedStudent;
  bool _isLoading = false;
  bool _isLoadingCurves = false;
  String? _errorMessage;
  String _indicator = 'bmi';

  List<HealthAssessment> get students => _students;
  List<HealthAssessment> get history => _history;
  List<WhoCurvePoint> get whoCurves => _whoCurves;
  HealthAssessment? get selectedStudent => _selectedStudent;
  bool get isLoading => _isLoading;
  bool get isLoadingCurves => _isLoadingCurves;
  String? get errorMessage => _errorMessage;
  String get indicator => _indicator;

  Future<void> load({required String role, int? academicYearId}) async {
    _setLoading(true);
    try {
      _students = await _growthWhoRepository.getLatest(
        role: role,
        schoolYearId: academicYearId,
      );
      _errorMessage = null;
      if (_students.isNotEmpty) {
        await selectStudent(
          _students.first.studentId,
          role: role,
          academicYearId: academicYearId,
        );
      } else {
        _history = [];
        _selectedStudent = null;
        _whoCurves = [];
      }
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> selectStudent(
    int studentId, {
    required String role,
    int? academicYearId,
    String gender = 'Nam',
  }) async {
    try {
      _selectedStudent = _students.firstWhere(
        (item) => item.studentId == studentId,
        orElse: () => _students.first,
      );
      _history = await _growthWhoRepository.getHistory(
        studentId: studentId,
        role: role,
        schoolYearId: academicYearId,
      );
      _errorMessage = null;
      notifyListeners();
      await loadWhoCurves(indicator: _indicator, gender: gender);
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> loadWhoCurves({
    required String indicator,
    required String gender,
  }) async {
    _indicator = indicator;
    _isLoadingCurves = true;
    notifyListeners();
    try {
      _whoCurves = await _growthWhoRepository.getWhoCurves(
        indicator: indicator,
        gender: gender,
      );
    } catch (error) {
      _whoCurves = [];
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingCurves = false;
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
