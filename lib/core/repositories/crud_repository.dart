abstract class CrudRepository<T> {
  Future<List<T>> getAll();

  Future<T?> getById(int id);

  Future<T> create(Map<String, dynamic> data);

  Future<T> update(int id, Map<String, dynamic> data);

  Future<void> archive(int id);

  Future<void> restore(int id);
}
