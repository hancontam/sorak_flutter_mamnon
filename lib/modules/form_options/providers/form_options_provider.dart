import 'package:flutter/foundation.dart';

import '../../../core/constants/app_options.dart';
import '../../academic_years/models/academic_year.dart';
import '../../classes/models/school_class.dart';
import '../../students/models/student.dart';
import '../../teachers/models/teacher.dart';
import '../repositories/form_options_repository.dart';

class FormOptionsProvider extends ChangeNotifier {
  FormOptionsProvider({required FormOptionsRepository formOptionsRepository})
    : _formOptionsRepository = formOptionsRepository;

  final FormOptionsRepository _formOptionsRepository;

  final List<AcademicYear> _academicYears = [];
  final List<SchoolClass> _classes = [];
  final List<Teacher> _workingTeachers = [];
  final List<Student> _allStudents = [];
  final List<Student> _students = [];

  bool _isLoading = false;
  String? _errorMessage;
  int? _selectedAcademicYearId;
  int? _selectedClassId;

  List<AcademicYear> get academicYears => List.unmodifiable(_academicYears);
  List<SchoolClass> get classes => List.unmodifiable(_classes);
  List<Teacher> get workingTeachers => List.unmodifiable(_workingTeachers);
  List<Student> get allStudents => List.unmodifiable(_allStudents);
  List<Student> get students => List.unmodifiable(_students);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get selectedAcademicYearId => _selectedAcademicYearId;
  int? get selectedClassId => _selectedClassId;

  List<AppOption<int>> get academicYearOptions {
    return _academicYears
        .map((year) => AppOption(value: year.id, label: year.name))
        .toList();
  }

  List<AppOption<int>> get classOptions {
    return _classes.map((schoolClass) {
      final label = schoolClass.room.isEmpty
          ? schoolClass.className
          : '${schoolClass.className} - ${schoolClass.room}';
      return AppOption(value: schoolClass.id, label: label);
    }).toList();
  }

  List<AppOption<int>> get workingTeacherOptions {
    return _workingTeachers
        .map((teacher) => AppOption(value: teacher.id, label: teacher.fullName))
        .toList();
  }

  List<AppOption<int>> get studentOptions {
    return _students
        .map((student) => AppOption(value: student.id, label: student.fullName))
        .toList();
  }

  AcademicYear? get selectedAcademicYear {
    for (final year in _academicYears) {
      if (year.id == _selectedAcademicYearId) {
        return year;
      }
    }
    return null;
  }

  SchoolClass? get selectedClass {
    for (final schoolClass in _classes) {
      if (schoolClass.id == _selectedClassId) {
        return schoolClass;
      }
    }
    return null;
  }

  Future<void> loadInitialOptions() async {
    if (_isLoading || _academicYears.isNotEmpty) {
      return;
    }

    _setLoading(true);
    try {
      final years = await _formOptionsRepository.getAcademicYears();
      _academicYears
        ..clear()
        ..addAll(years);

      _selectedAcademicYearId ??= _defaultAcademicYearId(years);
      await _loadClassesForSelectedYear();
      await _loadWorkingTeachers();
      await _loadAllStudents();
      await _loadStudentsForSelectedClass();

      _errorMessage = null;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshOptions() async {
    _academicYears.clear();
    _classes.clear();
    _workingTeachers.clear();
    _allStudents.clear();
    _students.clear();
    _selectedAcademicYearId = null;
    _selectedClassId = null;
    await loadInitialOptions();
  }

  Future<void> selectAcademicYear(int? academicYearId) async {
    if (_selectedAcademicYearId == academicYearId) {
      return;
    }

    _selectedAcademicYearId = academicYearId;
    _selectedClassId = null;
    _setLoading(true);

    try {
      await _loadClassesForSelectedYear();
      await _loadStudentsForSelectedClass();
      _errorMessage = null;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> selectClass(int? classId) async {
    if (_selectedClassId == classId) {
      return;
    }

    _selectedClassId = classId;
    _setLoading(true);

    try {
      await _loadStudentsForSelectedClass();
      _errorMessage = null;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadClassesForSelectedYear() async {
    final classes = await _formOptionsRepository.getClassesByYear(
      _selectedAcademicYearId,
    );
    _classes
      ..clear()
      ..addAll(classes);

    if (!_classes.any((schoolClass) => schoolClass.id == _selectedClassId)) {
      _selectedClassId = _classes.isEmpty ? null : _classes.first.id;
    }
  }

  Future<void> _loadWorkingTeachers() async {
    final teachers = await _formOptionsRepository.getWorkingTeachers();
    _workingTeachers
      ..clear()
      ..addAll(teachers);
  }

  Future<void> _loadStudentsForSelectedClass() async {
    if (_allStudents.isEmpty) {
      await _loadAllStudents();
    }

    final students = _selectedClassId == null
        ? _allStudents
        : _allStudents
              .where((student) => student.classId == _selectedClassId)
              .toList();
    _students
      ..clear()
      ..addAll(students);
  }

  Future<void> _loadAllStudents() async {
    final students = await _formOptionsRepository.getStudentsByClass(null);
    _allStudents
      ..clear()
      ..addAll(students);
  }

  int? _defaultAcademicYearId(List<AcademicYear> years) {
    if (years.isEmpty) {
      return null;
    }

    final active = years.where((year) => year.status.toLowerCase() == 'active');
    if (active.isNotEmpty) {
      return active.first.id;
    }

    return years.first.id;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
