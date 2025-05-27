import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/model/barcode_scan_response.dart';

import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/do_repository.dart';

final scanBarcodeStateProvider =
    StateNotifierProvider<ScanBarcodeStateNotifier, ScanBarcodeState>(
  (ref) => ScanBarcodeStateNotifier(ref: ref),
);

class ScanBarcodeStateNotifier extends StateNotifier<ScanBarcodeState> {
  final Ref ref;
  ScanBarcodeStateNotifier({
    required this.ref,
  }) : super(ScanBarcodeStateInit());

  void reset() {
    state = ScanBarcodeStateInit();
  }

  void scan({
    required List<String> barcode,
  }) async {
    final loginModel = await ref.read(localAuthProvider.future);
    if (loginModel?.token == null) {
      state = ScanBarcodeStateError(message: "Invalid Token");
      return;
    }
    final dio = ref.read(dioProvider);
    state = ScanBarcodeStateLoading();
    final String storeID = loginModel!.storeID;
    try {
      final resp = await DoRepository(dio: dio).barcodeScan(
        barcode: barcode,
        token: loginModel.token!,
        storeID: storeID,
      );
      state = ScanBarcodeStateDone(
        list: resp.list,
        message: resp.message,
        scanBarcode: barcode,
      );
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = ScanBarcodeStateError(message: e.message);
      } else {
        state = ScanBarcodeStateError(message: e.toString());
      }
    }
  }
}

abstract class ScanBarcodeState extends Equatable {
  final DateTime date;
  ScanBarcodeState({required this.date});
  @override
  List<Object?> get props => [date];
}

class ScanBarcodeStateInit extends ScanBarcodeState {
  ScanBarcodeStateInit() : super(date: DateTime.now());
}

class ScanBarcodeStateLoading extends ScanBarcodeState {
  ScanBarcodeStateLoading() : super(date: DateTime.now());
}

class ScanBarcodeStateToken extends ScanBarcodeState {
  ScanBarcodeStateToken() : super(date: DateTime.now());
}

class ScanBarcodeStateNoToken extends ScanBarcodeState {
  ScanBarcodeStateNoToken() : super(date: DateTime.now());
}

class ScanBarcodeStateError extends ScanBarcodeState {
  final String message;
  ScanBarcodeStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class ScanBarcodeStateDone extends ScanBarcodeState {
  final List<BarcodeScanResponseModel> list;
  final String message;
  final List<String> scanBarcode;
  ScanBarcodeStateDone({
    required this.list,
    required this.message,
    required this.scanBarcode,
  }) : super(date: DateTime.now());
}
