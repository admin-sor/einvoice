import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/screen/material_return/mr_by_no_provider.dart';

import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/material_return_repository.dart';
import '../material_return/req_reload_material.dart';

final saveMaterialReturnStateProvider = StateNotifierProvider<
    SaveMaterialReturnStateNotifier, SaveMaterialReturnState>(
  (ref) => SaveMaterialReturnStateNotifier(ref: ref),
);

class SaveMaterialReturnStateNotifier
    extends StateNotifier<SaveMaterialReturnState> {
  final Ref ref;
  SaveMaterialReturnStateNotifier({
    required this.ref,
  }) : super(SaveMaterialReturnStateInit());

  void reset() {
    state = SaveMaterialReturnStateInit();
  }

  void save(
      {required String barcode,
      required String mrID,
      required String packQty,
      required String storeID,
      String slipNo = ""}) async {
    final loginModel = await ref.read(localAuthProvider.future);
    if (loginModel?.token == null) {
      state = SaveMaterialReturnStateError(message: "Invalid Token");
      return;
    }
    final dio = ref.read(dioProvider);
    state = SaveMaterialReturnStateLoading();
    try {
      await MaterialReturnRepository(dio: dio).save(
          barcode: barcode,
          mrID: mrID,
          packQty: packQty,
          token: loginModel!.token!,
          storeID: storeID,
          slipNo: slipNo,
          isScrap: "");
      state = SaveMaterialReturnStateDone(packQty: packQty);
      if (slipNo != "") {
        ref.read(mrMrByNoStateProvider.notifier).byNo(slipNo: slipNo);
      }
      var xState = ref.read(reqReloadMaterial);
      xState = xState + 1;
      ref.read(reqReloadMaterial.notifier).state = xState;
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = SaveMaterialReturnStateError(message: e.message);
      } else {
        state = SaveMaterialReturnStateError(message: e.toString());
      }
    }
  }
}

abstract class SaveMaterialReturnState extends Equatable {
  final DateTime date;
  const SaveMaterialReturnState({required this.date});
  @override
  List<Object?> get props => [date];
}

class SaveMaterialReturnStateInit extends SaveMaterialReturnState {
  SaveMaterialReturnStateInit() : super(date: DateTime.now());
}

class SaveMaterialReturnStateLoading extends SaveMaterialReturnState {
  SaveMaterialReturnStateLoading() : super(date: DateTime.now());
}

class SaveMaterialReturnStateToken extends SaveMaterialReturnState {
  SaveMaterialReturnStateToken() : super(date: DateTime.now());
}

class SaveMaterialReturnStateNoToken extends SaveMaterialReturnState {
  SaveMaterialReturnStateNoToken() : super(date: DateTime.now());
}

class SaveMaterialReturnStateError extends SaveMaterialReturnState {
  final String message;
  SaveMaterialReturnStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class SaveMaterialReturnStateDone extends SaveMaterialReturnState {
  final String packQty;
  SaveMaterialReturnStateDone({
    required this.packQty,
  }) : super(date: DateTime.now());
}
