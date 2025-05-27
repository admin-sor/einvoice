import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/screen/stock_take/stock_take_current_provider.dart';
import 'package:sor_inventory/screen/stock_take_menu_screen/stock_take_get_provider.dart';

import '../../model/stock_take_summary_model.dart';
import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/stock_take_repository.dart';

final stockTakeSaveProvider =
    StateNotifierProvider<StockTakeNotifier, StockTakeSaveState>(
        (ref) => StockTakeNotifier(ref: ref));

class StockTakeNotifier extends StateNotifier<StockTakeSaveState> {
  final Ref ref;
  StockTakeNotifier({
    required this.ref,
  }) : super(StockTakeSaveStateInit());

  void save({
    required String stockTakeID,
    required String stockTakeItemID,
    required String scanQty,
  }) async {
    state = StockTakeSaveStateLoading();
    final dio = ref.read(dioProvider);
    final loginModel = await ref.read(localAuthProvider.future);
    try {
      final token = (loginModel?.token ?? "");
      await StockTakeRepository(dio: dio).save(
          token: token,
          stockTakeItemID: stockTakeItemID,
          scanQty: scanQty);

      ref.read(stockTakeCurrentProvider.notifier).currentSummary(
          stockTakeID: stockTakeID );
      state = StockTakeSaveStateDone();
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = StockTakeSaveStateError(message: e.message);
      } else {
        state = StockTakeSaveStateError(message: e.toString());
      }
    }
  }

  void reset() {
    state = StockTakeSaveStateInit();
  }
}

abstract class StockTakeSaveState extends Equatable {
  final DateTime date = DateTime.now();
  StockTakeSaveState();

  @override
  List<Object?> get props => [date];
}

class StockTakeSaveStateInit extends StockTakeSaveState {}

class StockTakeSaveStateLoading extends StockTakeSaveState {}

class StockTakeSaveStateError extends StockTakeSaveState {
  final String message;
  StockTakeSaveStateError({required this.message});
}

class StockTakeSaveStateDone extends StockTakeSaveState {
  StockTakeSaveStateDone();
}
