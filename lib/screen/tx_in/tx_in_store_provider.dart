import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/store_model.dart';
import '../../provider/dio_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/store_repository.dart';
import '../../repository/tx_in_repository.dart';

final txInStoreStateProvider =
    StateNotifierProvider<TxInStoreStateNotifier, TxInStoreState>(
  (ref) => TxInStoreStateNotifier(ref: ref),
);

class TxInStoreStateNotifier extends StateNotifier<TxInStoreState> {
  final Ref ref;
  TxInStoreStateNotifier({
    required this.ref,
  }) : super(TxInStoreStateInit());

  void reset() {
    state = TxInStoreStateInit();
  }

  void list() async {
    final dio = ref.read(dioProvider);
    state = TxInStoreStateLoading();
    try {
      final resp = await StoreRepository(dio: dio).search(query: "");
      state = TxInStoreStateDone(
        list: resp,
      );
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = TxInStoreStateError(message: e.message);
      } else {
        state = TxInStoreStateError(message: e.toString());
      }
    }
  }
}

abstract class TxInStoreState extends Equatable {
  final DateTime date;
  TxInStoreState({required this.date});
  @override
  List<Object?> get props => [date];
}

class TxInStoreStateInit extends TxInStoreState {
  TxInStoreStateInit() : super(date: DateTime.now());
}

class TxInStoreStateLoading extends TxInStoreState {
  TxInStoreStateLoading() : super(date: DateTime.now());
}

class TxInStoreStateToken extends TxInStoreState {
  TxInStoreStateToken() : super(date: DateTime.now());
}

class TxInStoreStateNoToken extends TxInStoreState {
  TxInStoreStateNoToken() : super(date: DateTime.now());
}

class TxInStoreStateError extends TxInStoreState {
  final String message;
  TxInStoreStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class TxInStoreStateDone extends TxInStoreState {
  final List<StoreModel> list;
  TxInStoreStateDone({
    required this.list,
  }) : super(date: DateTime.now());
}
