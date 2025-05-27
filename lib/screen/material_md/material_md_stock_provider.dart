import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/repository/material_md_repository.dart';

import '../../model/material_stock_model.dart';
import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';

final materialStockSearchProvider =
    StateNotifierProvider<MaterialStockNotifier, MaterialStockSearchState>(
        (ref) => MaterialStockNotifier(ref: ref));

class MaterialStockNotifier extends StateNotifier<MaterialStockSearchState> {
  final Ref ref;
  MaterialStockNotifier({required this.ref})
      : super(MaterialStockSearchStateInit());

  void search({required String materialID, String storeID = "0"}) async {
    state = MaterialStockSearchStateLoading();
    try {
      final loginModel = await ref.read(localAuthProvider.future);
      if (loginModel?.token == null) {
        state = MaterialStockSearchStateError(message: "Invalid Token");
      }

      print("searching here ");
      final resp = await MaterialMdRepository(dio: ref.read(dioProvider)).stock(
          materialID: materialID, storeID: storeID, token: loginModel!.token!);
      state = MaterialStockSearchStateDone(model: resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = MaterialStockSearchStateError(message: e.message);
      } else {
        state = MaterialStockSearchStateError(message: e.toString());
      }
    }
  }
}

abstract class MaterialStockSearchState extends Equatable {
  final DateTime date;

  const MaterialStockSearchState(this.date);
  @override
  List<Object?> get props => [date];
}

class MaterialStockSearchStateInit extends MaterialStockSearchState {
  MaterialStockSearchStateInit() : super(DateTime.now());
}

class MaterialStockSearchStateLoading extends MaterialStockSearchState {
  MaterialStockSearchStateLoading() : super(DateTime.now());
}

class MaterialStockSearchStateError extends MaterialStockSearchState {
  final String message;
  MaterialStockSearchStateError({
    required this.message,
  }) : super(DateTime.now());
}

class MaterialStockSearchStateDone extends MaterialStockSearchState {
  final List<MaterialStockModel> model;
  MaterialStockSearchStateDone({
    required this.model,
  }) : super(DateTime.now());
}
