import 'package:flutter/foundation.dart';

import '../network/api_exception.dart';
import '../repositories/crud_repository.dart';

class CrudProvider<T> extends ChangeNotifier {
  CrudProvider({required CrudRepository<T> repository})
    : _repository = repository;

  final CrudRepository<T> _repository;

  List<T> _items = [];
  T? _selectedItem;
  bool _isLoading = false;
  String? _errorMessage;
  int _loadRevision = 0;

  List<T> get items => _items;
  T? get selectedItem => _selectedItem;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadItems() async {
    await loadItemsWith(_repository.getAll);
  }

  Future<void> loadItemsWith(Future<List<T>> Function() loader) async {
    final revision = ++_loadRevision;
    _setLoading(true);
    try {
      final items = await loader();
      if (revision != _loadRevision) return;
      _items = items;
      _errorMessage = null;
    } catch (error) {
      if (revision != _loadRevision) return;
      _errorMessage = apiErrorMessage(error);
    } finally {
      if (revision == _loadRevision) {
        _setLoading(false);
      }
    }
  }

  Future<void> loadDetail(int id) async {
    _setLoading(true);
    try {
      _selectedItem = await _repository.getById(id);
      _errorMessage = null;
    } catch (error) {
      _errorMessage = apiErrorMessage(error);
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createItem(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      await _repository.create(data);
      await loadItems();
      return true;
    } catch (error) {
      _errorMessage = apiErrorMessage(error);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateItem(int id, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      await _repository.update(id, data);
      await loadItems();
      return true;
    } catch (error) {
      _errorMessage = apiErrorMessage(error);
      _setLoading(false);
      return false;
    }
  }

  Future<void> archiveItem(int id) async {
    _setLoading(true);
    try {
      await _repository.archive(id);
      await loadItems();
    } catch (error) {
      _errorMessage = apiErrorMessage(error);
      _setLoading(false);
    }
  }

  Future<void> restoreItem(int id) async {
    _setLoading(true);
    try {
      await _repository.restore(id);
      await loadItems();
    } catch (error) {
      _errorMessage = apiErrorMessage(error);
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
