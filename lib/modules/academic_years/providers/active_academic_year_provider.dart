import 'package:flutter/foundation.dart';

import '../../../core/storage/local_storage.dart';
import '../models/academic_year.dart';
import '../repositories/academic_year_repository.dart';

class ActiveAcademicYearProvider extends ChangeNotifier {
  ActiveAcademicYearProvider({
    required AcademicYearRepository academicYearRepository,
    required LocalStorage localStorage,
  }) : _academicYearRepository = academicYearRepository,
       _localStorage = localStorage;

  final AcademicYearRepository _academicYearRepository;
  final LocalStorage _localStorage;

  final List<AcademicYear> _years = [];
  bool _isLoading = false;
  String? _errorMessage;
  int? _selectedYearId;

  List<AcademicYear> get years => List.unmodifiable(_years);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get selectedYearId => _selectedYearId;

  AcademicYear? get selectedYear {
    for (final year in _years) {
      if (year.id == _selectedYearId) {
        return year;
      }
    }
    return null;
  }

  Future<void> loadYears() async {
    if (_isLoading || _years.isNotEmpty) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final items = await _academicYearRepository.getAll();
      _years
        ..clear()
        ..addAll(items);
      _years.sort((a, b) => b.name.compareTo(a.name));

      final savedYearId = _localStorage.getSelectedAcademicYearId();
      _selectedYearId = _isAvailableYearId(savedYearId)
          ? savedYearId
          : _defaultYearId(_years);
      final selectedYearId = _selectedYearId;
      if (selectedYearId != null) {
        await _localStorage.saveSelectedAcademicYearId(selectedYearId);
      }
    } catch (_) {
      _errorMessage = 'Chưa tải được danh sách năm học';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectYear(int yearId) async {
    if (_selectedYearId == yearId) {
      return;
    }
    _selectedYearId = yearId;
    await _localStorage.saveSelectedAcademicYearId(yearId);
    notifyListeners();
  }

  bool _isAvailableYearId(int? yearId) {
    if (yearId == null) {
      return false;
    }
    return _years.any((year) => year.id == yearId);
  }

  int? _defaultYearId(List<AcademicYear> years) {
    if (years.isEmpty) {
      return null;
    }

    final active = years.where((year) => year.status.toLowerCase() == 'active');
    if (active.isNotEmpty) {
      return active.first.id;
    }

    return years.first.id;
  }
}
