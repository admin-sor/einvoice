import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/stock_take_model.dart';
import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/stock_take_repository.dart';
import '../stock_take/stock_take_current_provider.dart';

final stockTakeGetProvider =
    StateNotifierProvider<StockTakeGetNotifier, StockTakeGetState>(
        (ref) => StockTakeGetNotifier(ref: ref));

class StockTakeGetNotifier extends StateNotifier<StockTakeGetState> {
  final Ref ref;
  StockTakeGetNotifier({
    required this.ref,
  }) : super(StockTakeGetStateInit());

  void getOpenEvent({bool loadSummary = true}) async {
    state = StockTakeGetStateLoading();
    final dio = ref.read(dioProvider);
    final loginModel = await ref.read(localAuthProvider.future);
    try {
      final token = (loginModel?.token ?? "");
      final result = await StockTakeRepository(dio: dio).getEvent(
        token: token,
      );
      if (loadSummary) {
        ref
            .read(stockTakeCurrentProvider.notifier)
            .currentSummary(stockTakeID: result?.stockTakeID ?? "0");
      }
      state = StockTakeGetStateDone(event: result);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = StockTakeGetStateError(message: e.message);
      } else {
        state = StockTakeGetStateError(message: e.toString());
      }
    }
  }

  void reset() {
    state = StockTakeGetStateInit();
  }
}

abstract class StockTakeGetState extends Equatable {
  final DateTime date = DateTime.now();
  StockTakeGetState();

  @override
  List<Object?> get props => [date];
}

class StockTakeGetStateInit extends StockTakeGetState {}

class StockTakeGetStateLoading extends StockTakeGetState {}

class StockTakeGetStateError extends StockTakeGetState {
  final String message;
  StockTakeGetStateError({required this.message});
}

class StockTakeGetStateDone extends StockTakeGetState {
  final StockTakeModel? event;
  StockTakeGetStateDone({this.event});
}
