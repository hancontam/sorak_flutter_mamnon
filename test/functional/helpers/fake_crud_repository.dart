import 'package:sorak_flutter_mamnon/core/repositories/crud_repository.dart';

typedef TestIdReader<T> = int Function(T item);
typedef TestCreateItem<T> = T Function(Map<String, dynamic> data, int id);
typedef TestUpdateItem<T> = T Function(T current, Map<String, dynamic> data);
typedef TestArchiveItem<T> = T Function(T current, bool isDeleted);

class FakeCrudRepository<T> implements CrudRepository<T> {
  FakeCrudRepository({
    required List<T> initialItems,
    required TestIdReader<T> readId,
    required TestCreateItem<T> createItem,
    required TestUpdateItem<T> updateItem,
    TestArchiveItem<T>? archiveItem,
  }) : _items = List<T>.from(initialItems),
       _readId = readId,
       _createItem = createItem,
       _updateItem = updateItem,
       _archiveItem = archiveItem;

  final List<T> _items;
  final TestIdReader<T> _readId;
  final TestCreateItem<T> _createItem;
  final TestUpdateItem<T> _updateItem;
  final TestArchiveItem<T>? _archiveItem;

  bool shouldThrow = false;
  int archiveCallCount = 0;
  int? lastArchivedId;

  List<T> get currentItems => List<T>.unmodifiable(_items);

  @override
  Future<List<T>> getAll() async {
    _throwIfNeeded();
    return List<T>.unmodifiable(_items);
  }

  @override
  Future<T?> getById(int id) async {
    _throwIfNeeded();
    for (final item in _items) {
      if (_readId(item) == id) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<T> create(Map<String, dynamic> data) async {
    _throwIfNeeded();
    final item = _createItem(data, _nextId());
    _items.add(item);
    return item;
  }

  @override
  Future<T> update(int id, Map<String, dynamic> data) async {
    _throwIfNeeded();
    final index = _indexOf(id);
    final item = _updateItem(_items[index], data);
    _items[index] = item;
    return item;
  }

  @override
  Future<void> archive(int id) async {
    _throwIfNeeded();
    archiveCallCount++;
    lastArchivedId = id;

    final index = _indexOf(id);
    final archiveItem = _archiveItem;
    if (archiveItem == null) {
      _items.removeAt(index);
      return;
    }

    _items[index] = archiveItem(_items[index], true);
  }

  @override
  Future<void> restore(int id) async {
    _throwIfNeeded();
    final archiveItem = _archiveItem;
    if (archiveItem == null) {
      return;
    }

    final index = _indexOf(id);
    _items[index] = archiveItem(_items[index], false);
  }

  int _indexOf(int id) {
    final index = _items.indexWhere((item) => _readId(item) == id);
    if (index < 0) {
      throw Exception('Item not found');
    }
    return index;
  }

  int _nextId() {
    if (_items.isEmpty) {
      return 1;
    }

    return _items
            .map(_readId)
            .reduce((current, next) => current > next ? current : next) +
        1;
  }

  void _throwIfNeeded() {
    if (shouldThrow) {
      throw Exception('Mock repository error');
    }
  }
}
