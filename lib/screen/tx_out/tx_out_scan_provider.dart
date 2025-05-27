import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/tx_out_model.dart';
import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/tx_out_repository.dart';
import 'tx_out_list_provider.dart';

final txOutScanStateProvider =
    StateNotifierProvider<TxOutScanStateNotifier, TxOutScanState>(
  (ref) => TxOutScanStateNotifier(ref: ref),
);

class TxOutScanStateNotifier extends StateNotifier<TxOutScanState> {
  final Ref ref;
  TxOutScanStateNotifier({
    required this.ref,
  }) : super(TxOutScanStateInit());

  void reset() {
    state = TxOutScanStateInit();
  }

  void scan({
    required String barcode,
    required String slipNo,
    required String storeID,
    required String storeToID,
  }) async {
    final loginModel = await ref.read(localAuthProvider.future);
    if (loginModel?.token == null) {
      state = TxOutScanStateError(message: "Invalid Token");
      return;
    }
    final dio = ref.read(dioProvider);
    state = TxOutScanStateLoading();
    try {
      final resp = await TxOutRepository(dio: dio).scan(
        barcode: barcode,
        storeID: storeID,
        storeToID: storeToID,
        slipNo: slipNo,
        token: loginModel!.token!,
      );
      state = TxOutScanStateDone(
        model: resp,
      );
      var listSlipNo = slipNo;
      if (resp.slipNo != "") {
        listSlipNo = resp.slipNo!;
      }
      ref.read(txOutListStateProvider.notifier).list(slipNo: listSlipNo);
    } catch (e) {
      if (slipNo != "") {
        ref.read(txOutListStateProvider.notifier).list(slipNo: slipNo);
      }
      if (e is BaseRepositoryException) {
        state = TxOutScanStateError(message: e.message);
      } else {
        state = TxOutScanStateError(message: e.toString());
      }
    }
  }
}

abstract class TxOutScanState extends Equatable {
  final DateTime date;
  TxOutScanState({required this.date});
  @override
  List<Object?> get props => [date];
}

class TxOutScanStateInit extends TxOutScanState {
  TxOutScanStateInit() : super(date: DateTime.now());
}

class TxOutScanStateLoading extends TxOutScanState {
  TxOutScanStateLoading() : super(date: DateTime.now());
}

class TxOutScanStateToken extends TxOutScanState {
  TxOutScanStateToken() : super(date: DateTime.now());
}

class TxOutScanStateNoToken extends TxOutScanState {
  TxOutScanStateNoToken() : super(date: DateTime.now());
}

class TxOutScanStateError extends TxOutScanState {
  final String message;
  TxOutScanStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class TxOutScanStateDone extends TxOutScanState {
  final TxOutScanResponseModel model;
  TxOutScanStateDone({
    required this.model,
  }) : super(date: DateTime.now());
}
