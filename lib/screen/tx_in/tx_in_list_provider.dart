import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/tx_in_model.dart';
import '../../provider/dio_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/tx_in_repository.dart';

final txInListStateProvider =
    StateNotifierProvider<TxInListStateNotifier, TxInListState>(
  (ref) => TxInListStateNotifier(ref: ref),
);

class TxInListStateNotifier extends StateNotifier<TxInListState> {
  final Ref ref;
  TxInListStateNotifier({
    required this.ref,
  }) : super(TxInListStateInit());

  void reset() {
    state = TxInListStateInit();
  }

  void list({
    required String slipNo,
  }) async {
    final dio = ref.read(dioProvider);
    state = TxInListStateLoading();
    try {
      final resp = await TxInRepository(dio: dio).getBySlip(slipNo);
      state = TxInListStateDone(
        list: resp,
      );
      //TODO:
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = TxInListStateError(message: e.message);
      } else {
        state = TxInListStateError(message: e.toString());
      }
    }
  }
}

abstract class TxInListState extends Equatable {
  final DateTime date;
  TxInListState({required this.date});
  @override
  List<Object?> get props => [date];
}

class TxInListStateInit extends TxInListState {
  TxInListStateInit() : super(date: DateTime.now());
}

class TxInListStateLoading extends TxInListState {
  TxInListStateLoading() : super(date: DateTime.now());
}

class TxInListStateToken extends TxInListState {
  TxInListStateToken() : super(date: DateTime.now());
}

class TxInListStateNoToken extends TxInListState {
  TxInListStateNoToken() : super(date: DateTime.now());
}

class TxInListStateError extends TxInListState {
  final String message;
  TxInListStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class TxInListStateDone extends TxInListState {
  final List<TxInListModel> list;
  TxInListStateDone({
    required this.list,
  }) : super(date: DateTime.now());
}
