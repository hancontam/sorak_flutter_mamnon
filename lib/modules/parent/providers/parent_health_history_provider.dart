import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../models/parent_health_history.dart';
import '../repositories/parent_health_history_repository.dart';

class ParentHealthHistoryProvider extends ChangeNotifier {
  ParentHealthHistoryProvider({
    required ParentHealthHistoryRepository repository,
  }) : _repository = repository;

  final ParentHealthHistoryRepository _repository;
  ParentHealthHistory? _history;
  bool _isLoading = false;
  String? _errorMessage;

  ParentHealthHistory? get history => _history;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _history = await _repository.getHealthHistory();
      _history!.records.sort(
        (a, b) => b.assessmentDate.compareTo(a.assessmentDate),
      );
    } catch (error) {
      _errorMessage = apiErrorMessage(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
