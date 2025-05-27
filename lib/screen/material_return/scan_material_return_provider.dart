import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/contractor_lookup_model.dart';
import '../../model/material_return_scan_response.dart';
import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/material_return_repository.dart';

final scanMaterialReturnStateProvider = StateNotifierProvider<
    ScanMaterialReturnStateNotifier, ScanMaterialReturnState>(
  (ref) => ScanMaterialReturnStateNotifier(ref: ref),
);

class ScanMaterialReturnStateNotifier
    extends StateNotifier<ScanMaterialReturnState> {
  final Ref ref;
  ScanMaterialReturnStateNotifier({
    required this.ref,
  }) : super(ScanMaterialReturnStateInit());

  void reset() {
    state = ScanMaterialReturnStateInit();
  }

  void scan({
    required List<String> barcode,
    required ContractorLookupModel contractor,
    required String slipNo,
  }) async {
    final loginModel = await ref.read(localAuthProvider.future);
    if (loginModel?.token == null) {
      state = ScanMaterialReturnStateError(message: "Invalid Token");
      return;
    }
    final dio = ref.read(dioProvider);
    state = ScanMaterialReturnStateLoading();
    try {
      final resp = await MaterialReturnRepository(dio: dio).scan(
        barcode: barcode,
        contractor: contractor,
        slipNo: slipNo,
        token: loginModel!.token!,
      );
      state = ScanMaterialReturnStateDone(
        list: resp.list,
        message: resp.message,
        scanBarcode: barcode,
        slipNo: resp.slipNo,
      );
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = ScanMaterialReturnStateError(message: e.message);
      } else {
        state = ScanMaterialReturnStateError(message: e.toString());
      }
    }
  }
}

abstract class ScanMaterialReturnState extends Equatable {
  final DateTime date;
  const ScanMaterialReturnState({required this.date});
  @override
  List<Object?> get props => [date];
}

class ScanMaterialReturnStateInit extends ScanMaterialReturnState {
  ScanMaterialReturnStateInit() : super(date: DateTime.now());
}

class ScanMaterialReturnStateLoading extends ScanMaterialReturnState {
  ScanMaterialReturnStateLoading() : super(date: DateTime.now());
}

class ScanMaterialReturnStateToken extends ScanMaterialReturnState {
  ScanMaterialReturnStateToken() : super(date: DateTime.now());
}

class ScanMaterialReturnStateNoToken extends ScanMaterialReturnState {
  ScanMaterialReturnStateNoToken() : super(date: DateTime.now());
}

class ScanMaterialReturnStateError extends ScanMaterialReturnState {
  final String message;
  ScanMaterialReturnStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class ScanMaterialReturnStateDone extends ScanMaterialReturnState {
  final List<MaterialReturnScanResponseModel> list;
  final String message;
  final String slipNo;
  final List<String> scanBarcode;
  ScanMaterialReturnStateDone({
    required this.list,
    required this.message,
    required this.scanBarcode,
    required this.slipNo,
  }) : super(date: DateTime.now());
}
