import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/contractor_lookup_model.dart';
import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/checkout_repository.dart';
import 'list_c1_provider.dart';

final looseQtySaveStateProvider =
    StateNotifierProvider<LooseQtySaveStateNotifier, LooseQtySaveState>(
  (ref) => LooseQtySaveStateNotifier(ref: ref),
);

class LooseQtySaveStateNotifier extends StateNotifier<LooseQtySaveState> {
  final Ref ref;
  LooseQtySaveStateNotifier({
    required this.ref,
  }) : super(LooseQtySaveStateInit());

  void reset() {
    state = LooseQtySaveStateInit();
  }

  void looseQtySave({
    required String checkoutID,
    required String barcode,
    required String qty,
    required String oldQty,
    required String fileNum,
    required String slipNo,
  }) async {
    final dio = ref.read(dioProvider);
    state = LooseQtySaveStateLoading();
    try {
      final loginModel = await ref.read(localAuthProvider.future);
      if (loginModel?.token == null) {
        state = LooseQtySaveStateError(message: "Invalid Token");
        return;
      }
      await CheckoutRepository(dio: dio).looseQtySave(
        barcode: barcode,
        qty: qty,
        oldQty: oldQty,
        token: loginModel!.token!,
        checkoutID: checkoutID,
      );
      ref
          .read(listC1StateProvider.notifier)
          .listC1(fileNum: fileNum, slipNo: slipNo);
      state = LooseQtySaveStateDone(barcode: barcode);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = LooseQtySaveStateError(message: e.message);
      } else {
        state = LooseQtySaveStateError(message: e.toString());
      }
    }
  }
}

abstract class LooseQtySaveState extends Equatable {
  final DateTime date;
  LooseQtySaveState({required this.date});
  @override
  List<Object?> get props => [date];
}

class LooseQtySaveStateInit extends LooseQtySaveState {
  LooseQtySaveStateInit() : super(date: DateTime.now());
}

class LooseQtySaveStateLoading extends LooseQtySaveState {
  LooseQtySaveStateLoading() : super(date: DateTime.now());
}

class LooseQtySaveStateToken extends LooseQtySaveState {
  LooseQtySaveStateToken() : super(date: DateTime.now());
}

class LooseQtySaveStateNoToken extends LooseQtySaveState {
  LooseQtySaveStateNoToken() : super(date: DateTime.now());
}

class LooseQtySaveStateError extends LooseQtySaveState {
  final String message;
  LooseQtySaveStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class LooseQtySaveStateDone extends LooseQtySaveState {
  final String barcode;
  LooseQtySaveStateDone({required this.barcode}) : super(date: DateTime.now());
}
