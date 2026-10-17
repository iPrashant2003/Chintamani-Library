import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../domain/search_result_model.dart';

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepository(ref.read(apiClientProvider));
});

class SearchRepository {
  final ApiClient _apiClient;
  CancelToken? _cancelToken;

  SearchRepository(this._apiClient);

  Future<SearchResultGroup> search(String query, {String? branchId}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const SearchResultGroup(query: '');
    }

    // Cancel any in-flight previous request to prevent race conditions & stale results
    _cancelToken?.cancel('New search query submitted');
    _cancelToken = CancelToken();

    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.search,
        queryParameters: {
          'q': trimmed,
          if (branchId != null && branchId.isNotEmpty) 'branchId': branchId,
        },
        cancelToken: _cancelToken,
      );

      final Map<String, dynamic> data = response.data is Map<String, dynamic>
          ? (response.data['data'] is Map<String, dynamic>
              ? response.data['data'] as Map<String, dynamic>
              : response.data as Map<String, dynamic>)
          : <String, dynamic>{};

      return SearchResultGroup.fromJson(data);
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        return SearchResultGroup(query: trimmed);
      }
      rethrow;
    }
  }
}
