
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/tx_out_model.dart';
import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/tx_out_repository.dart';
import 'tx_out_list_provider.dart';

final txOutSaveStateProvider =
    StateNotifierProvider<TxOutSaveStateNotifier, TxOutSaveState>(
  (ref) => TxOutSaveStateNotifier(ref: ref),
);

class TxOutSaveStateNotifier extends StateNotifier<TxOutSaveState> {
  final Ref ref;
  TxOutSaveStateNotifier({
    required this.ref,
  }) : super(TxOutSaveStateInit());

  void reset() {
    state = TxOutSaveStateInit();
  }

  void save({
    required List<TxOutListModel> list,
    required String slipNo,
  }) async {
    final loginModel = await ref.read(localAuthProvider.future);
    if (loginModel?.token == null) {
      state = TxOutSaveStateError(message: "Invalid Token");
      return;
    }
    final dio = ref.read(dioProvider);
    state = TxOutSaveStateLoading();
    try {
      final resp = await TxOutRepository(dio: dio).save(
        slipNo:slipNo,
        data: list,
        token: loginModel!.token!,
      );
      state = TxOutSaveStateDone(
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
        state = TxOutSaveStateError(message: e.message);
      } else {
        state = TxOutSaveStateError(message: e.toString());
      }
    }
  }
}

abstract class TxOutSaveState extends Equatable {
  final DateTime date;
  TxOutSaveState({required this.date});
  @override
  List<Object?> get props => [date];
}

class TxOutSaveStateInit extends TxOutSaveState {
  TxOutSaveStateInit() : super(date: DateTime.now());
}

class TxOutSaveStateLoading extends TxOutSaveState {
  TxOutSaveStateLoading() : super(date: DateTime.now());
}

class TxOutSaveStateToken extends TxOutSaveState {
  TxOutSaveStateToken() : super(date: DateTime.now());
}

class TxOutSaveStateNoToken extends TxOutSaveState {
  TxOutSaveStateNoToken() : super(date: DateTime.now());
}

class TxOutSaveStateError extends TxOutSaveState {
  final String message;
  TxOutSaveStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class TxOutSaveStateDone extends TxOutSaveState {
  final TxOutScanResponseModel model;
  TxOutSaveStateDone({
    required this.model,
  }) : super(date: DateTime.now());
}
