import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/screen/checkout/list_c1_provider.dart';

import '../../model/checkout_scan_response_model.dart';
import '../../model/contractor_lookup_model.dart';
import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/checkout_repository.dart';

final scanCheckoutStateProvider =
    StateNotifierProvider<ScanCheckoutStateNotifier, ScanCheckoutState>(
  (ref) => ScanCheckoutStateNotifier(ref: ref),
);

class ScanCheckoutStateNotifier extends StateNotifier<ScanCheckoutState> {
  final Ref ref;
  ScanCheckoutStateNotifier({
    required this.ref,
  }) : super(ScanCheckoutStateInit());

  void reset() {
    state = ScanCheckoutStateInit();
  }

  void scan({
    required List<String> barcode,
    required ContractorLookupModel contractor,
    required String slipNo,
    required String fileNum,
    required String storeID,
  }) async {
    final loginModel = await ref.read(localAuthProvider.future);
    if (loginModel?.token == null) {
      state = ScanCheckoutStateError(message: "Invalid Token");
      return;
    }
    final dio = ref.read(dioProvider);
    state = ScanCheckoutStateLoading();
    try {
      final resp = await CheckoutRepository(dio: dio).scanV2(
        barcode: barcode,
        contractor: contractor,
        slipNo: slipNo,
        token: loginModel!.token!,
        fileNum: fileNum,
        storeID: storeID,
      );
      state = ScanCheckoutStateDone(
        list: resp.list,
        message: resp.message,
        scanBarcode: barcode,
        slipNo: resp.slipNo,
      );
      ref.read(listC1StateProvider.notifier).listC1(
          fileNum: fileNum, slipNo: slipNo != "" ? slipNo : resp.slipNo);
    } catch (e) {
      if (slipNo != "") {
        ref
            .read(listC1StateProvider.notifier)
            .listC1(fileNum: fileNum, slipNo: slipNo);
      }
      if (e is BaseRepositoryException) {
        state = ScanCheckoutStateError(message: e.message);
      } else {
        state = ScanCheckoutStateError(message: e.toString());
      }
    }
  }
}

abstract class ScanCheckoutState extends Equatable {
  final DateTime date;
  ScanCheckoutState({required this.date});
  @override
  List<Object?> get props => [date];
}

class ScanCheckoutStateInit extends ScanCheckoutState {
  ScanCheckoutStateInit() : super(date: DateTime.now());
}

class ScanCheckoutStateLoading extends ScanCheckoutState {
  ScanCheckoutStateLoading() : super(date: DateTime.now());
}

class ScanCheckoutStateToken extends ScanCheckoutState {
  ScanCheckoutStateToken() : super(date: DateTime.now());
}

class ScanCheckoutStateNoToken extends ScanCheckoutState {
  ScanCheckoutStateNoToken() : super(date: DateTime.now());
}

class ScanCheckoutStateError extends ScanCheckoutState {
  final String message;
  ScanCheckoutStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class ScanCheckoutStateDone extends ScanCheckoutState {
  final List<CheckoutScanResponseModel> list;
  final String message;
  final String slipNo;
  final List<String> scanBarcode;
  ScanCheckoutStateDone({
    required this.list,
    required this.message,
    required this.scanBarcode,
    required this.slipNo,
  }) : super(date: DateTime.now());
}
