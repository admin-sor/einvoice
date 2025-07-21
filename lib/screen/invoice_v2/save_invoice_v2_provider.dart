import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/po_response_model.dart';
import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/po_repository.dart';
import 'get_po_provider.dart';

final savePoProvider = StateNotifierProvider<SavePoStateNotifier, SavePoState>(
  (ref) => SavePoStateNotifier(ref: ref),
);

class SavePoStateNotifier extends StateNotifier<SavePoState> {
  final Ref ref;
  SavePoStateNotifier({
    required this.ref,
  }) : super(SavePoStateInit());

  void reset() {
    state = SavePoStateInit();
  }

  void save({
    required DateTime date,
    required String poNo,
    required String storeID,
    required String vendorID,
    required DateTime deliveryDate,
    required String paymentTermID,
    required String paymentTermName,
    required String materialID,
    required String qty,
    required String packUnitID,
    required String price,
    required String packQty,
    required String fromVendor,
    String poID = "0",
  }) async {
    final loginModel = await ref.read(localAuthProvider.future);
    if (loginModel?.token == null) {
      state = SavePoStateError(message: "Invalid Token");
      return;
    }
    final dio = ref.read(dioProvider);
    state = SavePoStateLoading();
    try {
      final resp = await PoRepository(dio: dio).save(
        date: date,
        poNo: poNo,
        poID: poID,
        storeID: storeID,
        vendorID: vendorID,
        deliveryDate: deliveryDate,
        paymentTermID: paymentTermID,
        paymentTermName: paymentTermName,
        materialID: materialID,
        qty: qty,
        packUnitID: packUnitID,
        price: price,
        packQty: packQty,
        fromVendor: fromVendor,
        token: loginModel!.token!,
      );
      state = SavePoStateDone(model: resp);
      // call after state mark as done
      ref.read(getPoProvider.notifier).get(
            poNo: poNo,
            vendorID: vendorID,
          );
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = SavePoStateError(message: e.message);
      } else {
        state = SavePoStateError(message: e.toString());
      }
    }
  }
}

abstract class SavePoState extends Equatable {
  final DateTime date;
  const SavePoState({required this.date});
  @override
  List<Object?> get props => [date];
}

class SavePoStateInit extends SavePoState {
  SavePoStateInit() : super(date: DateTime.now());
}

class SavePoStateLoading extends SavePoState {
  SavePoStateLoading() : super(date: DateTime.now());
}

class SavePoStateToken extends SavePoState {
  SavePoStateToken() : super(date: DateTime.now());
}

class SavePoStateNoToken extends SavePoState {
  SavePoStateNoToken() : super(date: DateTime.now());
}

class SavePoStateError extends SavePoState {
  final String message;
  SavePoStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class SavePoStateDone extends SavePoState {
  final PoSaveResponseModel model;
  SavePoStateDone({
    required this.model,
  }) : super(date: DateTime.now());
}
