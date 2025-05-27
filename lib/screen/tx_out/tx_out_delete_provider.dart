import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/tx_out_model.dart';
import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/tx_out_repository.dart';
import 'tx_out_list_provider.dart';

final txOutDeleteStateProvider =
    StateNotifierProvider<TxOutDeleteStateNotifier, TxOutDeleteState>(
  (ref) => TxOutDeleteStateNotifier(ref: ref),
);

class TxOutDeleteStateNotifier extends StateNotifier<TxOutDeleteState> {
  final Ref ref;
  TxOutDeleteStateNotifier({
    required this.ref,
  }) : super(TxOutDeleteStateInit());

  void reset() {
    state = TxOutDeleteStateInit();
  }

  void delete({
    required String txOutID,
    required String slipNo,
  }) async {
    final loginModel = await ref.read(localAuthProvider.future);
    if (loginModel?.token == null) {
      state = TxOutDeleteStateError(message: "Invalid Token");
      return;
    }
    final dio = ref.read(dioProvider);
    state = TxOutDeleteStateLoading();
    try {
      await TxOutRepository(dio: dio).delete(
        slipNo: slipNo,
        txOutID: txOutID,
        token: loginModel!.token!,
      );
      state = TxOutDeleteStateDone();
      ref.read(txOutListStateProvider.notifier).list(slipNo: slipNo);
    } catch (e) {
      if (slipNo != "") {
        ref.read(txOutListStateProvider.notifier).list(slipNo: slipNo);
      }
      if (e is BaseRepositoryException) {
        state = TxOutDeleteStateError(message: e.message);
      } else {
        state = TxOutDeleteStateError(message: e.toString());
      }
    }
  }
}

abstract class TxOutDeleteState extends Equatable {
  final DateTime date;
  TxOutDeleteState({required this.date});
  @override
  List<Object?> get props => [date];
}

class TxOutDeleteStateInit extends TxOutDeleteState {
  TxOutDeleteStateInit() : super(date: DateTime.now());
}

class TxOutDeleteStateLoading extends TxOutDeleteState {
  TxOutDeleteStateLoading() : super(date: DateTime.now());
}

class TxOutDeleteStateToken extends TxOutDeleteState {
  TxOutDeleteStateToken() : super(date: DateTime.now());
}

class TxOutDeleteStateNoToken extends TxOutDeleteState {
  TxOutDeleteStateNoToken() : super(date: DateTime.now());
}

class TxOutDeleteStateError extends TxOutDeleteState {
  final String message;
  TxOutDeleteStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class TxOutDeleteStateDone extends TxOutDeleteState {
  TxOutDeleteStateDone() : super(date: DateTime.now());
}
