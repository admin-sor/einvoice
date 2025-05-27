import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/screen/material_return/mr_by_no_provider.dart';

import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/material_return_repository.dart';

final addMaterialReturnStateProvider = StateNotifierProvider<
    AddMaterialReturnStateNotifier, AddMaterialReturnState>(
  (ref) => AddMaterialReturnStateNotifier(ref: ref),
);

class AddMaterialReturnStateNotifier
    extends StateNotifier<AddMaterialReturnState> {
  final Ref ref;
  AddMaterialReturnStateNotifier({
    required this.ref,
  }) : super(AddMaterialReturnStateInit());

  void reset() {
    state = AddMaterialReturnStateInit();
  }

  void add(
      {required String barcode,
      required String mrID,
      required String packQty,
      String slipNo = ""}) async {
    final loginModel = await ref.read(localAuthProvider.future);
    if (loginModel?.token == null) {
      state = AddMaterialReturnStateError(message: "Invalid Token");
      return;
    }
    final dio = ref.read(dioProvider);
    state = AddMaterialReturnStateLoading();
    try {
      await MaterialReturnRepository(dio: dio).save(
        slipNo:"",
        barcode: barcode,
        storeID: "",
        isScrap: "N",
        mrID: mrID,
        packQty: packQty,
        token: loginModel!.token!,
      );
      state = AddMaterialReturnStateDone(packQty: packQty);
      if (slipNo != "") {
        ref.read(mrMrByNoStateProvider.notifier).byNo(slipNo: slipNo);
      }
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = AddMaterialReturnStateError(message: e.message);
      } else {
        state = AddMaterialReturnStateError(message: e.toString());
      }
    }
  }
}

abstract class AddMaterialReturnState extends Equatable {
  final DateTime date;
  const AddMaterialReturnState({required this.date});
  @override
  List<Object?> get props => [date];
}

class AddMaterialReturnStateInit extends AddMaterialReturnState {
  AddMaterialReturnStateInit() : super(date: DateTime.now());
}

class AddMaterialReturnStateLoading extends AddMaterialReturnState {
  AddMaterialReturnStateLoading() : super(date: DateTime.now());
}

class AddMaterialReturnStateToken extends AddMaterialReturnState {
  AddMaterialReturnStateToken() : super(date: DateTime.now());
}

class AddMaterialReturnStateNoToken extends AddMaterialReturnState {
  AddMaterialReturnStateNoToken() : super(date: DateTime.now());
}

class AddMaterialReturnStateError extends AddMaterialReturnState {
  final String message;
  AddMaterialReturnStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class AddMaterialReturnStateDone extends AddMaterialReturnState {
  final String packQty;
  AddMaterialReturnStateDone({
    required this.packQty,
  }) : super(date: DateTime.now());
}
