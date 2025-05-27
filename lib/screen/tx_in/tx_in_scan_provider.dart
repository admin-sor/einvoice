import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/tx_in_model.dart';
import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/tx_in_repository.dart';
import '../../repository/tx_out_repository.dart';
import 'tx_in_list_provider.dart';

final txInScanStateProvider =
    StateNotifierProvider<TxInScanStateNotifier, TxInScanState>(
  (ref) => TxInScanStateNotifier(ref: ref),
);

class TxInScanStateNotifier extends StateNotifier<TxInScanState> {
  final Ref ref;
  TxInScanStateNotifier({
    required this.ref,
  }) : super(TxInScanStateInit());

  void reset() {
    state = TxInScanStateInit();
  }

  void scan({
    required String barcode,
    required String slipNo,
    required String storeID,
    required String storeToID,
  }) async {
    final loginModel = await ref.read(localAuthProvider.future);
    if (loginModel?.token == null) {
      state = TxInScanStateError(message: "Invalid Token");
      return;
    }
    final dio = ref.read(dioProvider);
    state = TxInScanStateLoading();
    try {
      final resp = await TxInRepository(dio: dio).scan(
        barcode: barcode,
        storeID: storeID,
        storeToID: storeToID,
        slipNo: slipNo,
        token: loginModel!.token!,
      );
      state = TxInScanStateDone(
        model: resp,
      );
      var listSlipNo = slipNo;
      if (resp.slipNo != "") {
        listSlipNo = resp.slipNo!;
      }
      ref.read(txInListStateProvider.notifier).list(slipNo: listSlipNo);
    } catch (e) {
      if (slipNo != "") {
        ref.read(txInListStateProvider.notifier).list(slipNo: slipNo);
      }
      if (e is BaseRepositoryException) {
        state = TxInScanStateError(message: e.message);
      } else {
        state = TxInScanStateError(message: e.toString());
      }
    }
  }
}

abstract class TxInScanState extends Equatable {
  final DateTime date;
  TxInScanState({required this.date});
  @override
  List<Object?> get props => [date];
}

class TxInScanStateInit extends TxInScanState {
  TxInScanStateInit() : super(date: DateTime.now());
}

class TxInScanStateLoading extends TxInScanState {
  TxInScanStateLoading() : super(date: DateTime.now());
}

class TxInScanStateToken extends TxInScanState {
  TxInScanStateToken() : super(date: DateTime.now());
}

class TxInScanStateNoToken extends TxInScanState {
  TxInScanStateNoToken() : super(date: DateTime.now());
}

class TxInScanStateError extends TxInScanState {
  final String message;
  TxInScanStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class TxInScanStateDone extends TxInScanState {
  final TxInScanModel model;
  TxInScanStateDone({
    required this.model,
  }) : super(date: DateTime.now());
}
