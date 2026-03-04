import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/api_provider.dart';
import '../repositories/dashboard_repository_impl.dart';

final dashboardRepositoryProvider = Provider((ref) {
  final api = ref.watch(apiServiceProvider);
  return DashboardRepositoryImpl(api);
});
