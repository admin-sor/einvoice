import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/stock_take_repository.dart';
import '../stock_take_menu_screen/stock_take_get_provider.dart';

final stockTakeCloseProvider =
    StateNotifierProvider<StockTakeCloseNotifier, StockTakeCloseState>(
        (ref) => StockTakeCloseNotifier(ref: ref));

class StockTakeCloseNotifier extends StateNotifier<StockTakeCloseState> {
  final Ref ref;
  StockTakeCloseNotifier({
    required this.ref,
  }) : super(StockTakeCloseStateInit());

  void close(String eventID) async {
    state = StockTakeCloseStateLoading();
    final dio = ref.read(dioProvider);
    final loginModel = await ref.read(localAuthProvider.future);
    try {
      final token = (loginModel?.token ?? "");
      await StockTakeRepository(dio: dio).close(
        token: token,
        eventID: eventID,
      );
      ref.read(stockTakeGetProvider.notifier).getOpenEvent();
      state = StockTakeCloseStateDone();
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = StockTakeCloseStateError(message: e.message);
      } else {
        state = StockTakeCloseStateError(message: e.toString());
      }
    }
  }

  void reset() {
    state = StockTakeCloseStateInit();
  }
}

abstract class StockTakeCloseState extends Equatable {
  final DateTime date = DateTime.now();
  StockTakeCloseState();

  @override
  List<Object?> get props => [date];
}

class StockTakeCloseStateInit extends StockTakeCloseState {}

class StockTakeCloseStateLoading extends StockTakeCloseState {}

class StockTakeCloseStateError extends StockTakeCloseState {
  final String message;
  StockTakeCloseStateError({required this.message});
}

class StockTakeCloseStateDone extends StockTakeCloseState {
  StockTakeCloseStateDone();
}
