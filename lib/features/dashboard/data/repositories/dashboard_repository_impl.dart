import 'dart:convert';

import '../../../../core/services/api_service.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../models/dashboard_summary_model.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._api);

  final ApiService _api;

  /// Attempts to fetch the dashboard summary from the backend. The
  /// returned JSON is parsed into a [DashboardSummaryModel].
  ///
  /// If the request fails, an exception is propagated up so the caller can
  /// show an error state. In a production app you might wrap this in
  /// a `Result` type or use `dartz`/`fpdart` to avoid throwing.
  @override
  Future<DashboardSummary> fetchSummary() async {
    final response = await _api.get('/dashboard/summary');

    if (response.statusCode == 200) {
      final map = jsonDecode(response.body) as Map<String, dynamic>;
      return DashboardSummaryModel.fromJson(map);
    } else {
      // fallback or error handling
      throw Exception('Failed to load dashboard summary');
    }
  }
}
