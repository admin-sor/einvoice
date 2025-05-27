import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/repository/material_return_repository.dart';

import '../../model/tx_sum_model.dart';
import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/tx_sum_repository.dart';

final txSumListStateProvider =
    StateNotifierProvider<TxSumListStateNotifier, TxSumListState>(
  (ref) => TxSumListStateNotifier(ref: ref),
);

class TxSumListStateNotifier extends StateNotifier<TxSumListState> {
  final Ref ref;
  TxSumListStateNotifier({
    required this.ref,
  }) : super(TxSumListStateInit());

  void reset() {
    state = TxSumListStateInit();
  }

  void list() async {
    final dio = ref.read(dioProvider);
    final loginModel = await ref.read(localAuthProvider.future);
    state = TxSumListStateLoading();
    try {
      final token = (loginModel?.token ?? "");
      final resp = await TxSumRepository(dio: dio).list(token);
      state = TxSumListStateDone(list: resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = TxSumListStateError(message: e.message);
      } else {
        state = TxSumListStateError(message: e.toString());
      }
    }
  }
}

abstract class TxSumListState extends Equatable {
  final DateTime date;
  TxSumListState({required this.date});
  @override
  List<Object?> get props => [date];
}

class TxSumListStateInit extends TxSumListState {
  TxSumListStateInit() : super(date: DateTime.now());
}

class TxSumListStateLoading extends TxSumListState {
  TxSumListStateLoading() : super(date: DateTime.now());
}

class TxSumListStateToken extends TxSumListState {
  TxSumListStateToken() : super(date: DateTime.now());
}

class TxSumListStateNoToken extends TxSumListState {
  TxSumListStateNoToken() : super(date: DateTime.now());
}

class TxSumListStateError extends TxSumListState {
  final String message;
  TxSumListStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class TxSumListStateDone extends TxSumListState {
  final List<TxSumModel> list;
  TxSumListStateDone({
    required this.list,
  }) : super(date: DateTime.now());
}
