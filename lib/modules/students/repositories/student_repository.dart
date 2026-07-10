import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_page.dart';
import '../../../core/network/api_response.dart';
import '../../../core/repositories/crud_repository.dart';
import '../models/student.dart';

class StudentRepository implements CrudRepository<Student> {
  StudentRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<Student>> getAll({int? schoolYearId, int? classId}) async {
    return (await getPage(
      query: const ApiListQuery(pageSize: 500),
      schoolYearId: schoolYearId,
      classId: classId,
    )).items;
  }

  Future<ApiPage<Student>> getPage({
    ApiListQuery query = const ApiListQuery(),
    int? schoolYearId,
    int? classId,
    String? gradeLevel,
    bool? isActive,
    String? studentStatus,
  }) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.students,
      queryParameters: query.toQueryParameters(
        filters: {
          'school_year_id': ?schoolYearId,
          'class_id': ?classId,
          if (gradeLevel != null && gradeLevel.isNotEmpty)
            'grade_level': gradeLevel,
          if (isActive != null) 'is_active': '$isActive',
          if (studentStatus != null && studentStatus.isNotEmpty)
            'student_status': studentStatus,
        },
      ),
    );
    return ApiResponse.page(response.data, Student.fromJson);
  }

  @override
  Future<Student?> getById(int id) async {
    final response = await _apiClient.dio.get('${ApiEndpoints.students}/$id');
    return Student.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<Student> create(Map<String, dynamic> data) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.students,
      data: _createPayload(data),
    );
    return Student.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<Student> update(int id, Map<String, dynamic> data) async {
    final response = await _apiClient.dio.patch(
      '${ApiEndpoints.students}/$id',
      data: _updatePayload(data),
    );
    return Student.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<void> archive(int id) async {
    await _apiClient.dio.delete('${ApiEndpoints.students}/$id');
  }

  @override
  Future<void> restore(int id) async {
    await _apiClient.dio.patch('${ApiEndpoints.students}/$id/restore');
  }

  static const _createFields = {
    'full_name',
    'date_of_birth',
    'gender',
    'grade_level',
    'enrollment_date',
    'ethnicity',
    'nationality',
    'religion',
    'blood_type',
    'birth_place',
    'contact_phone',
    'permanent_province',
    'permanent_ward',
    'permanent_address_detail',
    'current_address',
    'hometown_province',
    'hometown_ward',
    'photo_url',
    'class_id',
    'parents',
  };

  static const _updateFields = {
    'full_name',
    'student_status',
    'date_of_birth',
    'gender',
    'enrollment_date',
    'ethnicity',
    'nationality',
    'religion',
    'area_type',
    'blood_type',
    'contact_phone',
    'birth_place',
    'permanent_province',
    'permanent_ward',
    'permanent_address_detail',
    'current_address',
    'hometown_province',
    'hometown_ward',
    'photo_url',
  };

  Map<String, dynamic> _createPayload(Map<String, dynamic> data) {
    return _pick(data, _createFields, integerFields: const {'class_id'});
  }

  Map<String, dynamic> _updatePayload(Map<String, dynamic> data) {
    return _pick(data, _updateFields);
  }

  Map<String, dynamic> _pick(
    Map<String, dynamic> data,
    Set<String> fields, {
    Set<String> integerFields = const {},
  }) {
    return {
      for (final entry in data.entries)
        if (fields.contains(entry.key) && entry.value != null)
          entry.key: integerFields.contains(entry.key)
              ? int.tryParse('${entry.value}')
              : entry.value,
    };
  }
}
