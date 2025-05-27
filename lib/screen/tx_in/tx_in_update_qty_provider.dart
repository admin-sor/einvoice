import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/tx_in_repository.dart';
import 'tx_in_list_provider.dart';

final txInUpdateQtyStateProvider =
    StateNotifierProvider<TxInUpdateQtyStateNotifier, TxInUpdateQtyState>(
  (ref) => TxInUpdateQtyStateNotifier(ref: ref),
);

class TxInUpdateQtyStateNotifier extends StateNotifier<TxInUpdateQtyState> {
  final Ref ref;
  TxInUpdateQtyStateNotifier({
    required this.ref,
  }) : super(TxInUpdateQtyStateInit());

  void reset() {
    state = TxInUpdateQtyStateInit();
  }

  void update({
    required String txInID,
    required String slipNo,
    required String qty,
    required String barcode,
  }) async {
    final loginModel = await ref.read(localAuthProvider.future);
    if (loginModel?.token == null) {
      state = TxInUpdateQtyStateError(message: "Invalid Token");
      return;
    }
    final dio = ref.read(dioProvider);
    state = TxInUpdateQtyStateLoading();
    try {
      await TxInRepository(dio: dio).updateQty(
        barcode: barcode,
        txInID: txInID,
        slipNo: slipNo,
        qty: qty,
        token: loginModel!.token!,
      );
      state = TxInUpdateQtyStateDone();
      ref.read(txInListStateProvider.notifier).list(slipNo: slipNo);
    } catch (e) {
      if (slipNo != "") {
        ref.read(txInListStateProvider.notifier).list(slipNo: slipNo);
      }
      if (e is BaseRepositoryException) {
        state = TxInUpdateQtyStateError(message: e.message);
      } else {
        state = TxInUpdateQtyStateError(message: e.toString());
      }
    }
  }
}

abstract class TxInUpdateQtyState extends Equatable {
  final DateTime date;
  TxInUpdateQtyState({required this.date});
  @override
  List<Object?> get props => [date];
}

class TxInUpdateQtyStateInit extends TxInUpdateQtyState {
  TxInUpdateQtyStateInit() : super(date: DateTime.now());
}

class TxInUpdateQtyStateLoading extends TxInUpdateQtyState {
  TxInUpdateQtyStateLoading() : super(date: DateTime.now());
}

class TxInUpdateQtyStateToken extends TxInUpdateQtyState {
  TxInUpdateQtyStateToken() : super(date: DateTime.now());
}

class TxInUpdateQtyStateNoToken extends TxInUpdateQtyState {
  TxInUpdateQtyStateNoToken() : super(date: DateTime.now());
}

class TxInUpdateQtyStateError extends TxInUpdateQtyState {
  final String message;
  TxInUpdateQtyStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class TxInUpdateQtyStateDone extends TxInUpdateQtyState {
  TxInUpdateQtyStateDone() : super(date: DateTime.now());
}
