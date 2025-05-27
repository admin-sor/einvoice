import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/contractor_lookup_model.dart';
import '../../model/material_return_scan_response.dart';
import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/material_return_repository.dart';

final scanOnlyMaterialReturnStateProvider = StateNotifierProvider<
    ScanOnlyMaterialReturnStateNotifier, ScanOnlyMaterialReturnState>(
  (ref) => ScanOnlyMaterialReturnStateNotifier(ref: ref),
);

class ScanOnlyMaterialReturnStateNotifier
    extends StateNotifier<ScanOnlyMaterialReturnState> {
  final Ref ref;
  ScanOnlyMaterialReturnStateNotifier({
    required this.ref,
  }) : super(ScanOnlyMaterialReturnStateInit());

  void reset() {
    state = ScanOnlyMaterialReturnStateInit();
  }

  void scanOnlyV2({
    required String barcode,
  }) async {
    final loginModel = await ref.read(localAuthProvider.future);
    if (loginModel?.token == null) {
      state = ScanOnlyMaterialReturnStateError(message: "Invalid Token");
      return;
    }
    final dio = ref.read(dioProvider);
    state = ScanOnlyMaterialReturnStateLoading();
    try {
      final resp = await MaterialReturnRepository(dio: dio).scanOnlyV2(
        barcode: barcode,
        token: loginModel!.token!,
      );
      state = ScanOnlyMaterialReturnStateDone(
        list: resp.list,
        message: resp.message,
        scanBarcode: barcode,
        slipNo: resp.slipNo,
      );
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = ScanOnlyMaterialReturnStateError(message: e.message);
      } else {
        state = ScanOnlyMaterialReturnStateError(message: e.toString());
      }
    }
  }
  void scanOnly({
    required String barcode,
    required ContractorLookupModel? contractor,
    required String slipNo,
  }) async {
    final loginModel = await ref.read(localAuthProvider.future);
    if (loginModel?.token == null) {
      state = ScanOnlyMaterialReturnStateError(message: "Invalid Token");
      return;
    }
    final dio = ref.read(dioProvider);
    state = ScanOnlyMaterialReturnStateLoading();
    try {
      final resp = await MaterialReturnRepository(dio: dio).scanOnly(
        barcode: barcode,
        contractor: contractor,
        slipNo: slipNo,
        token: loginModel!.token!,
      );
      state = ScanOnlyMaterialReturnStateDoneOld(
        list: resp.list,
        message: resp.message,
        scanBarcode: barcode,
        slipNo: resp.slipNo,
      );
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = ScanOnlyMaterialReturnStateError(message: e.message);
      } else {
        state = ScanOnlyMaterialReturnStateError(message: e.toString());
      }
    }
  }
}

abstract class ScanOnlyMaterialReturnState extends Equatable {
  final DateTime date;
  const ScanOnlyMaterialReturnState({required this.date});
  @override
  List<Object?> get props => [date];
}

class ScanOnlyMaterialReturnStateInit extends ScanOnlyMaterialReturnState {
  ScanOnlyMaterialReturnStateInit() : super(date: DateTime.now());
}

class ScanOnlyMaterialReturnStateLoading extends ScanOnlyMaterialReturnState {
  ScanOnlyMaterialReturnStateLoading() : super(date: DateTime.now());
}

class ScanOnlyMaterialReturnStateToken extends ScanOnlyMaterialReturnState {
  ScanOnlyMaterialReturnStateToken() : super(date: DateTime.now());
}

class ScanOnlyMaterialReturnStateNoToken extends ScanOnlyMaterialReturnState {
  ScanOnlyMaterialReturnStateNoToken() : super(date: DateTime.now());
}

class ScanOnlyMaterialReturnStateError extends ScanOnlyMaterialReturnState {
  final String message;
  ScanOnlyMaterialReturnStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class ScanOnlyMaterialReturnStateDone extends ScanOnlyMaterialReturnState {
  final List<MaterialReturnScanResponseModelV2> list;
  final String message;
  final String slipNo;
  final String scanBarcode;
  ScanOnlyMaterialReturnStateDone({
    required this.list,
    required this.message,
    required this.scanBarcode,
    required this.slipNo,
  }) : super(date: DateTime.now());
}

class ScanOnlyMaterialReturnStateDoneOld extends ScanOnlyMaterialReturnState {
  final List<MaterialReturnScanResponseModel> list;
  final String message;
  final String slipNo;
  final String scanBarcode;
  ScanOnlyMaterialReturnStateDoneOld({
    required this.list,
    required this.message,
    required this.scanBarcode,
    required this.slipNo,
  }) : super(date: DateTime.now());
}
