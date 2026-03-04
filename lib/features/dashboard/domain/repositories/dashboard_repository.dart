import '../entities/dashboard_summary.dart';

abstract class DashboardRepository {
  Future<DashboardSummary> fetchSummary();
}
