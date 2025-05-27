import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/model/materialmd_model.dart';
import 'package:sor_inventory/provider/dio_provider.dart';
import 'package:sor_inventory/repository/base_repository.dart';
import 'package:sor_inventory/repository/material_md_repository.dart';
import 'package:sor_inventory/screen/material_md/material_md_search_provider.dart';

import '../../provider/shared_preference_provider.dart';

final materialMdSaveProvider =
    StateNotifierProvider<MaterialMdSaveNotifier, MaterialMdSaveState>(
  (ref) => MaterialMdSaveNotifier(ref: ref),
);

class MaterialMdSaveNotifier extends StateNotifier<MaterialMdSaveState> {
  Ref ref;
  MaterialMdSaveNotifier({required this.ref})
      : super(MaterialMdSaveStateInit());
  void edit({
    required String materialId,
    required String description,
    required String isCable,
    required String materialCode,
    required String packQty,
    required String packUnitId,
    required String unitId,
    required String query,
  }) async {
    state = MaterialMdSaveStateLoading();
    try {
      final loginModel = await ref.read(localAuthProvider.future);
      if (loginModel?.token == null) {
        state = MaterialMdSaveStateError(message: "Invalid Token");
        return;
      }
      final resp = await MaterialMdRepository(dio: ref.read(dioProvider)).edit(
        token: loginModel!.token!,
        description: description,
        isCable: isCable,
        materialId: materialId,
        materialCode: materialCode,
        packQty: packQty,
        packUnitId: packUnitId,
        unitId: unitId,
      );
      ref.read(materialMdSearchProvider.notifier).search(query: query);
      state = MaterialMdSaveStateDone(model: resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = MaterialMdSaveStateError(message: e.message);
      } else {
        state = MaterialMdSaveStateError(message: e.toString());
      }
    }
  }
}

abstract class MaterialMdSaveState extends Equatable {
  final DateTime date;

  const MaterialMdSaveState(this.date);
  @override
  List<Object?> get props => [date];
}

class MaterialMdSaveStateInit extends MaterialMdSaveState {
  MaterialMdSaveStateInit() : super(DateTime.now());
}

class MaterialMdSaveStateLoading extends MaterialMdSaveState {
  MaterialMdSaveStateLoading() : super(DateTime.now());
}

class MaterialMdSaveStateError extends MaterialMdSaveState {
  final String message;
  MaterialMdSaveStateError({
    required this.message,
  }) : super(DateTime.now());
}

class MaterialMdSaveStateDone extends MaterialMdSaveState {
  MaterialMdModel model;
  MaterialMdSaveStateDone({required this.model}) : super(DateTime.now());
}
