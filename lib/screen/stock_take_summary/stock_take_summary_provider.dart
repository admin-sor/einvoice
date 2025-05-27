import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/screen/stock_take/stock_take_current_provider.dart';

import '../../model/stock_take_summary_model.dart';
import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/stock_take_repository.dart';

final stockTakeSummaryProvider =
    StateNotifierProvider<StockTakeNotifier, StockTakeSummaryState>(
        (ref) => StockTakeNotifier(ref: ref));

class StockTakeNotifier extends StateNotifier<StockTakeSummaryState> {
  final Ref ref;
  StockTakeNotifier({
    required this.ref,
  }) : super(StockTakeSummaryStateInit());

  void summary({
    required String query,
    required String stockTakeID,
    required String status,
    bool isReload = true,
  }) async {
    state = StockTakeSummaryStateLoading();
    final dio = ref.read(dioProvider);
    final loginModel = await ref.read(localAuthProvider.future);
    try {
      final token = (loginModel?.token ?? "");
      final result = await StockTakeRepository(dio: dio).summary(
        token: token,
        query: query,
        status: status,
        stockTakeID: stockTakeID,
      );
      if (isReload) {
        ref.read(stockTakeCurrentProvider.notifier).currentSummary(stockTakeID: stockTakeID);
      }
      state = StockTakeSummaryStateDone(list: result);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = StockTakeSummaryStateError(message: e.message);
      } else {
        state = StockTakeSummaryStateError(message: e.toString());
      }
    }
  }

  void reset() {
    state = StockTakeSummaryStateInit();
  }
}

abstract class StockTakeSummaryState extends Equatable {
  final DateTime date = DateTime.now();
  StockTakeSummaryState();

  @override
  List<Object?> get props => [date];
}

class StockTakeSummaryStateInit extends StockTakeSummaryState {}

class StockTakeSummaryStateLoading extends StockTakeSummaryState {}

class StockTakeSummaryStateError extends StockTakeSummaryState {
  final String message;
  StockTakeSummaryStateError({required this.message});
}

class StockTakeSummaryStateDone extends StockTakeSummaryState {
  final List<StockTakeSummaryModel> list;
  StockTakeSummaryStateDone({required this.list});
}
