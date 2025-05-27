
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/tx_in_model.dart';
import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/tx_in_repository.dart';
import '../../repository/tx_out_repository.dart';
import 'tx_in_list_provider.dart';

final txInDeleteStateProvider =
    StateNotifierProvider<TxInDeleteStateNotifier, TxInDeleteState>(
  (ref) => TxInDeleteStateNotifier(ref: ref),
);

class TxInDeleteStateNotifier extends StateNotifier<TxInDeleteState> {
  final Ref ref;
  TxInDeleteStateNotifier({
    required this.ref,
  }) : super(TxInDeleteStateInit());

  void reset() {
    state = TxInDeleteStateInit();
  }

  void delete({
    required String txInID,
    required String slipNo,
  }) async {
    final loginModel = await ref.read(localAuthProvider.future);
    if (loginModel?.token == null) {
      state = TxInDeleteStateError(message: "Invalid Token");
      return;
    }
    final dio = ref.read(dioProvider);
    state = TxInDeleteStateLoading();
    try {
      await TxInRepository(dio: dio).delete(
        txInID: txInID,
        slipNo: slipNo,
        token: loginModel!.token!,
      );
      ref.read(txInListStateProvider.notifier).list(slipNo: slipNo);
    } catch (e) {
      if (slipNo != "") {
        ref.read(txInListStateProvider.notifier).list(slipNo: slipNo);
      }
      if (e is BaseRepositoryException) {
        state = TxInDeleteStateError(message: e.message);
      } else {
        state = TxInDeleteStateError(message: e.toString());
      }
    }
  }
}

abstract class TxInDeleteState extends Equatable {
  final DateTime date;
  TxInDeleteState({required this.date});
  @override
  List<Object?> get props => [date];
}

class TxInDeleteStateInit extends TxInDeleteState {
  TxInDeleteStateInit() : super(date: DateTime.now());
}

class TxInDeleteStateLoading extends TxInDeleteState {
  TxInDeleteStateLoading() : super(date: DateTime.now());
}

class TxInDeleteStateToken extends TxInDeleteState {
  TxInDeleteStateToken() : super(date: DateTime.now());
}

class TxInDeleteStateNoToken extends TxInDeleteState {
  TxInDeleteStateNoToken() : super(date: DateTime.now());
}

class TxInDeleteStateError extends TxInDeleteState {
  final String message;
  TxInDeleteStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class TxInDeleteStateDone extends TxInDeleteState {
  TxInDeleteStateDone() : super(date: DateTime.now());
}
