import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/do_model.dart';
import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/do_repository.dart';

final saveDoProvider = StateNotifierProvider<SaveDoStateNotifier, SaveDoState>(
  (ref) => SaveDoStateNotifier(ref: ref),
);

class SaveDoStateNotifier extends StateNotifier<SaveDoState> {
  final Ref ref;
  SaveDoStateNotifier({
    required this.ref,
  }) : super(SaveDoStateInit());

  void reset() {
    state = SaveDoStateInit();
  }

  void save({
    required DateTime date,
    required String storeID,
    required String doNo,
    required String poNo,
    required String poID,
    required String materialID,
    required String qty,
    required String drumNo,
    required String vendorID,
    required String packUnitID,
    required String packQty,
    required String doID,
    String poPackQty = "",
  }) async {
    final loginModel = await ref.read(localAuthProvider.future);
    if (loginModel?.token == null) {
      state = SaveDoStateError(message: "Invalid Token");
    }
    final dio = ref.read(dioProvider);
    state = SaveDoStateLoading();
    if (poPackQty == "") {
      poPackQty = packQty;
    }
    try {
      final resp = await DoRepository(dio: dio).save(
        date: date,
        storeID: storeID,
        doID: doID,
        doNo: doNo,
        poID: poID,
        poNo: poNo,
        materialID: materialID,
        drumNo: drumNo,
        qty: qty,
        token: loginModel!.token!,
        vendorID: vendorID,
        packQty: packQty,
        packUnitID: packUnitID,
        poPackQty: poPackQty,
      );
      state = SaveDoStateDone(doResponseModel: resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = SaveDoStateError(message: e.message);
      } else {
        state = SaveDoStateError(message: e.toString());
      }
    }
  }
}

abstract class SaveDoState extends Equatable {
  final DateTime date;
  SaveDoState({required this.date});
  @override
  List<Object?> get props => [date];
}

class SaveDoStateInit extends SaveDoState {
  SaveDoStateInit() : super(date: DateTime.now());
}

class SaveDoStateLoading extends SaveDoState {
  SaveDoStateLoading() : super(date: DateTime.now());
}

class SaveDoStateToken extends SaveDoState {
  SaveDoStateToken() : super(date: DateTime.now());
}

class SaveDoStateNoToken extends SaveDoState {
  SaveDoStateNoToken() : super(date: DateTime.now());
}

class SaveDoStateError extends SaveDoState {
  final String message;
  SaveDoStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class SaveDoStateDone extends SaveDoState {
  final DoResponseModel doResponseModel;
  SaveDoStateDone({
    required this.doResponseModel,
  }) : super(date: DateTime.now());
}
