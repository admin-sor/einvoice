import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/stock_take_model.dart';
import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/stock_take_repository.dart';
import 'stock_take_current_provider.dart';

final stockTakeProvider =
    StateNotifierProvider<StockTakeNotifier, StockTakeState>(
        (ref) => StockTakeNotifier(ref: ref));

class StockTakeNotifier extends StateNotifier<StockTakeState> {
  final Ref ref;
  StockTakeNotifier({
    required this.ref,
  }) : super(StockTakeStateInit());

  void create() async {
    state = StockTakeStateLoading();
    final dio = ref.read(dioProvider);
    final loginModel = await ref.read(localAuthProvider.future);
    try {
      final token = (loginModel?.token ?? "");
      final result = await StockTakeRepository(dio: dio).create(
        token: token,
      );
      ref.read(stockTakeCurrentProvider.notifier).currentSummary(
          stockTakeID: result.stockTakeID ?? "0");
      state = StockTakeStateDone(event: result);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = StockTakeStateError(message: e.message);
      } else {
        state = StockTakeStateError(message: e.toString());
      }
    }
  }

  void reset() {
    state = StockTakeStateInit();
  }
}

abstract class StockTakeState extends Equatable {
  final DateTime date = DateTime.now();
  StockTakeState();

  @override
  List<Object?> get props => [date];
}

class StockTakeStateInit extends StockTakeState {}

class StockTakeStateLoading extends StockTakeState {}

class StockTakeStateError extends StockTakeState {
  final String message;
  StockTakeStateError({required this.message});
}

class StockTakeStateDone extends StockTakeState {
  final StockTakeModel event;
  StockTakeStateDone({required this.event});
}
