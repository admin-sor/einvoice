import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/stock_take_history_model.dart';
import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/stock_take_repository.dart';

final stockTakeHistoryProvider =
    StateNotifierProvider<StockTakeNotifier, StockTakeHistoryState>(
        (ref) => StockTakeNotifier(ref: ref));

class StockTakeNotifier extends StateNotifier<StockTakeHistoryState> {
  final Ref ref;
  StockTakeNotifier({
    required this.ref,
  }) : super(StockTakeHistoryStateInit());

  void history({
    required int start,
    required int limit,
    required String query,
    required String queryDate,
  }) async {
    state = StockTakeHistoryStateLoading();
    final dio = ref.read(dioProvider);
    final loginModel = await ref.read(localAuthProvider.future);
    try {
      final token = (loginModel?.token ?? "");
      final result = await StockTakeRepository(dio: dio).history(
        token: token,
        start: start,
        limit: limit,
        query: query,
        queryDate: queryDate,
      );
      state = StockTakeHistoryStateDone(list: result);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = StockTakeHistoryStateError(message: e.message);
      } else {
        state = StockTakeHistoryStateError(message: e.toString());
      }
    }
  }

  void reset() {
    state = StockTakeHistoryStateInit();
  }
}

abstract class StockTakeHistoryState extends Equatable {
  final DateTime date = DateTime.now();
  StockTakeHistoryState();

  @override
  List<Object?> get props => [date];
}

class StockTakeHistoryStateInit extends StockTakeHistoryState {}

class StockTakeHistoryStateLoading extends StockTakeHistoryState {}

class StockTakeHistoryStateError extends StockTakeHistoryState {
  final String message;
  StockTakeHistoryStateError({required this.message});
}

class StockTakeHistoryStateDone extends StockTakeHistoryState {
  final List<StockTakeHistoryModel> list;
  StockTakeHistoryStateDone({required this.list});
}
