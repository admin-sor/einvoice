import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/provider/dio_provider.dart';
import 'package:sor_inventory/repository/base_repository.dart';
import 'package:sor_inventory/repository/material_md_repository.dart';
import 'package:sor_inventory/screen/material_md/material_md_edit_screen.dart';
import 'package:sor_inventory/screen/material_md/material_md_search_provider.dart';
import 'package:sor_inventory/screen/material_md/material_md_stock_provider.dart';

import '../../provider/shared_preference_provider.dart';

final materialMdEditPriceProvider = StateNotifierProvider<
    MaterialMdEditPriceNotifier, MaterialMdEditPriceState>(
  (ref) => MaterialMdEditPriceNotifier(ref: ref),
);

class MaterialMdEditPriceNotifier
    extends StateNotifier<MaterialMdEditPriceState> {
  Ref ref;
  MaterialMdEditPriceNotifier({required this.ref})
      : super(MaterialMdEditPriceStateInit());
  void edit({
    required String materialId,
    required String refType,
    required String refID,
    required String xID,
    required String price,
    required String query,
    required String isAll,
  }) async {
    state = MaterialMdEditPriceStateLoading();
    try {
      final loginModel = await ref.read(localAuthProvider.future);
      if (loginModel?.token == null) {
        state = MaterialMdEditPriceStateError(message: "Invalid Token");
        return;
      }
      String storeID = ref.read(mdStoreIDProvider);
      await MaterialMdRepository(dio: ref.read(dioProvider)).editPrice(
        token: loginModel!.token!,
        materialId: materialId,
        refType: refType,
        refID: refID,
        xID: xID,
        price: price,
        isAll: isAll,
        storeID: storeID,
      );
      ref
          .read(materialStockSearchProvider.notifier)
          .search(materialID: materialId, storeID: storeID);
      state = MaterialMdEditPriceStateDone(model: true);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = MaterialMdEditPriceStateError(message: e.message);
      } else {
        state = MaterialMdEditPriceStateError(message: e.toString());
      }
    }
  }
}

abstract class MaterialMdEditPriceState extends Equatable {
  final DateTime date;

  const MaterialMdEditPriceState(this.date);
  @override
  List<Object?> get props => [date];
}

class MaterialMdEditPriceStateInit extends MaterialMdEditPriceState {
  MaterialMdEditPriceStateInit() : super(DateTime.now());
}

class MaterialMdEditPriceStateLoading extends MaterialMdEditPriceState {
  MaterialMdEditPriceStateLoading() : super(DateTime.now());
}

class MaterialMdEditPriceStateError extends MaterialMdEditPriceState {
  final String message;
  MaterialMdEditPriceStateError({
    required this.message,
  }) : super(DateTime.now());
}

class MaterialMdEditPriceStateDone extends MaterialMdEditPriceState {
  bool model;
  MaterialMdEditPriceStateDone({required this.model}) : super(DateTime.now());
}
