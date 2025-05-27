import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/tx_out_model.dart';
import '../../provider/dio_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/tx_out_repository.dart';

final txOutListStateProvider =
    StateNotifierProvider<TxOutListStateNotifier, TxOutListState>(
  (ref) => TxOutListStateNotifier(ref: ref),
);

class TxOutListStateNotifier extends StateNotifier<TxOutListState> {
  final Ref ref;
  TxOutListStateNotifier({
    required this.ref,
  }) : super(TxOutListStateInit());

  void reset() {
    state = TxOutListStateInit();
  }

  void list({
    required String slipNo,
  }) async {
    final dio = ref.read(dioProvider);
    state = TxOutListStateLoading();
    try {
      final resp = await TxOutRepository(dio: dio).getBySlip(slipNo);
      state = TxOutListStateDone(
        list: resp,
      );
      //TODO:
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = TxOutListStateError(message: e.message);
      } else {
        state = TxOutListStateError(message: e.toString());
      }
    }
  }
}

abstract class TxOutListState extends Equatable {
  final DateTime date;
  TxOutListState({required this.date});
  @override
  List<Object?> get props => [date];
}

class TxOutListStateInit extends TxOutListState {
  TxOutListStateInit() : super(date: DateTime.now());
}

class TxOutListStateLoading extends TxOutListState {
  TxOutListStateLoading() : super(date: DateTime.now());
}

class TxOutListStateToken extends TxOutListState {
  TxOutListStateToken() : super(date: DateTime.now());
}

class TxOutListStateNoToken extends TxOutListState {
  TxOutListStateNoToken() : super(date: DateTime.now());
}

class TxOutListStateError extends TxOutListState {
  final String message;
  TxOutListStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class TxOutListStateDone extends TxOutListState {
  final List<TxOutListModel> list;
  TxOutListStateDone({
    required this.list,
  }) : super(date: DateTime.now());
}
