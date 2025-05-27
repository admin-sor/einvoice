import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/screen/material_return/mr_by_no_provider.dart';

import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/material_return_repository.dart';
import 'req_reload_material.dart';

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

  void save({
    required String barcode,
    required String mrID,
    required String storeID,
    required String packQty,
    required String isScrap,
    String slipNo = "",
  }) async {
    final loginModel = await ref.read(localAuthProvider.future);
    if (loginModel?.token == null) {
      state = SaveMaterialReturnStateError(message: "Invalid Token");
      return;
    }
    final dio = ref.read(dioProvider);
    state = SaveMaterialReturnStateLoading();
    try {
      var resp = await MaterialReturnRepository(dio: dio).save(
        slipNo: slipNo,
        barcode: barcode,
        mrID: mrID,
        storeID: storeID,
        packQty: packQty,
        isScrap: isScrap,
        token: loginModel!.token!,
      );
      state = SaveMaterialReturnStateDone(slipNo: resp, packQty: packQty);
      ref.read(reqReloadMaterial.notifier).state = ref.read(reqReloadMaterial) + 1; 

      if (resp != "") {
        ref.read(mrMrByNoStateProvider.notifier).byNo(slipNo: resp);
      }
    } catch (e) {
      if (slipNo != "") {
        ref.read(mrMrByNoStateProvider.notifier).byNo(slipNo: slipNo);
      }
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
  final String slipNo;
  final String packQty;
  SaveMaterialReturnStateDone({required this.slipNo, required this.packQty})
      : super(date: DateTime.now());
}
