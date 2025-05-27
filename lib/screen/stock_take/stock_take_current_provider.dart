import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/screen/stock_take_menu_screen/stock_take_get_provider.dart';

import '../../model/stock_take_summary_model.dart';
import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/stock_take_repository.dart';

final stockTakeCurrentProvider =
    StateNotifierProvider<StockTakeNotifier, StockTakeCurrentState>(
        (ref) => StockTakeNotifier(ref: ref));

class StockTakeNotifier extends StateNotifier<StockTakeCurrentState> {
  final Ref ref;
  StockTakeNotifier({
    required this.ref,
  }) : super(StockTakeCurrentStateInit());

  void currentSummary({
    required String stockTakeID,
  }) async {
    state = StockTakeCurrentStateLoading();
    final dio = ref.read(dioProvider);
    final loginModel = await ref.read(localAuthProvider.future);
    try {
      final token = (loginModel?.token ?? "");
      final result = await StockTakeRepository(dio: dio).currentSummary(
        token: token,
        stockTakeID: stockTakeID,
      );
      if (result.length == 1) {
        ref
            .read(stockTakeGetProvider.notifier)
            .getOpenEvent(loadSummary: false);
      }
      state = StockTakeCurrentStateDone(list: result);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = StockTakeCurrentStateError(message: e.message);
      } else {
        state = StockTakeCurrentStateError(message: e.toString());
      }
    }
  }

  void reset() {
    state = StockTakeCurrentStateInit();
  }
}

abstract class StockTakeCurrentState extends Equatable {
  final DateTime date = DateTime.now();
  StockTakeCurrentState();

  @override
  List<Object?> get props => [date];
}

class StockTakeCurrentStateInit extends StockTakeCurrentState {}

class StockTakeCurrentStateLoading extends StockTakeCurrentState {}

class StockTakeCurrentStateError extends StockTakeCurrentState {
  final String message;
  StockTakeCurrentStateError({required this.message});
}

class StockTakeCurrentStateDone extends StockTakeCurrentState {
  final List<GroupSummaryModelV2> list;
  StockTakeCurrentStateDone({required this.list});
}
