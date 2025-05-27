import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/stock_take_summary_status_model.dart';
import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/stock_take_repository.dart';

final stockTakeSummaryStatusProvider =
    StateNotifierProvider<StockTakeNotifier, StockTakeSummaryStatusState>(
        (ref) => StockTakeNotifier(ref: ref));

class StockTakeNotifier extends StateNotifier<StockTakeSummaryStatusState> {
  final Ref ref;
  StockTakeNotifier({
    required this.ref,
  }) : super(StockTakeSummaryStatusStateInit());

  void list({
    isCurrent: bool,
  }) async {
    state = StockTakeSummaryStatusStateLoading();
    final dio = ref.read(dioProvider);
    final loginModel = await ref.read(localAuthProvider.future);
    try {
      final token = (loginModel?.token ?? "");
      final result = await StockTakeRepository(dio: dio).listStatus(
        isCurrent: isCurrent,
        token: token,
      );
      state = StockTakeSummaryStatusStateDone(list: result);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = StockTakeSummaryStatusStateError(message: e.message);
      } else {
        state = StockTakeSummaryStatusStateError(message: e.toString());
      }
    }
  }

  void reset() {
    state = StockTakeSummaryStatusStateInit();
  }
}

abstract class StockTakeSummaryStatusState extends Equatable {
  final DateTime date = DateTime.now();
  StockTakeSummaryStatusState();

  @override
  List<Object?> get props => [date];
}

class StockTakeSummaryStatusStateInit extends StockTakeSummaryStatusState {}

class StockTakeSummaryStatusStateLoading extends StockTakeSummaryStatusState {}

class StockTakeSummaryStatusStateError extends StockTakeSummaryStatusState {
  final String message;
  StockTakeSummaryStatusStateError({required this.message});
}

class StockTakeSummaryStatusStateDone extends StockTakeSummaryStatusState {
  final List<StockTakeSummaryStatusModel> list;
  StockTakeSummaryStatusStateDone({required this.list});
}
