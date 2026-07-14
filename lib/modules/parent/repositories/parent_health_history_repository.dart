import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../models/parent_health_history.dart';

class ParentHealthHistoryRepository {
  ParentHealthHistoryRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<ParentHealthHistory> getHealthHistory() async {
    final response = await _apiClient.dio.get(ApiEndpoints.parentHealthHistory);
    return ParentHealthHistory.fromJson(ApiResponse.object(response.data));
  }
}
