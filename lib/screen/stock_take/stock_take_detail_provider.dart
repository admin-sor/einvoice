import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/model/stock_take_detail_model.dart';

import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/stock_take_repository.dart';

final stockTakeDetailProvider =
    StateNotifierProvider<StockTakeDetailNotifier, StockTakeDetailState>(
        (ref) => StockTakeDetailNotifier(ref: ref));

class StockTakeDetailNotifier extends StateNotifier<StockTakeDetailState> {
  final Ref ref;
  StockTakeDetailNotifier({
    required this.ref,
  }) : super(StockTakeDetailStateInit());

  void currentDetail({
    required String stockTakeID,
    required String code,
  }) async {
    state = StockTakeDetailStateLoading();
    final dio = ref.read(dioProvider);
    final loginModel = await ref.read(localAuthProvider.future);
    try {
      final token = (loginModel?.token ?? "");
      final result = await StockTakeRepository(dio: dio).currentDetail(
        token: token,
        code: code,
        stockTakeID: stockTakeID,
      );
      state = StockTakeDetailStateDone(list: result);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = StockTakeDetailStateError(message: e.message);
      } else {
        state = StockTakeDetailStateError(message: e.toString());
      }
    }
  }

  void reset() {
    state = StockTakeDetailStateInit();
  }
}

abstract class StockTakeDetailState extends Equatable {
  final DateTime date = DateTime.now();
  StockTakeDetailState();

  @override
  List<Object?> get props => [date];
}

class StockTakeDetailStateInit extends StockTakeDetailState {}

class StockTakeDetailStateLoading extends StockTakeDetailState {}

class StockTakeDetailStateError extends StockTakeDetailState {
  final String message;
  StockTakeDetailStateError({required this.message});
}

class StockTakeDetailStateDone extends StockTakeDetailState {
  final List<StockTakeDetailModel> list;
  StockTakeDetailStateDone({required this.list});
}
