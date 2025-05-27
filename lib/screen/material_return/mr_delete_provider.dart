import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/material_return_repository.dart';
import 'mr_by_no_provider.dart';

final mrDeleteStateProvider = StateNotifierProvider<
    DeleteMaterialReturnStateNotifier, DeleteMaterialReturnState>(
  (ref) => DeleteMaterialReturnStateNotifier(ref: ref),
);

class DeleteMaterialReturnStateNotifier
    extends StateNotifier<DeleteMaterialReturnState> {
  final Ref ref;
  DeleteMaterialReturnStateNotifier({
    required this.ref,
  }) : super(DeleteMaterialReturnStateInit());

  void reset() {
    state = DeleteMaterialReturnStateInit();
  }

  void delete({
    required String checkoutID,
    required String mrID,
    required String slipNo,
  }) async {
    final loginModel = await ref.read(localAuthProvider.future);
    if (loginModel?.token == null) {
      state = DeleteMaterialReturnStateError(message: "Invalid Token");
      return;
    }
    final dio = ref.read(dioProvider);
    state = DeleteMaterialReturnStateLoading();
    try {
      await MaterialReturnRepository(dio: dio).delete(
        checkoutID: checkoutID,
        mrID: mrID,
        token: loginModel!.token!,
      );
      state = DeleteMaterialReturnStateDone(checkoutID: checkoutID);
      ref.read(mrMrByNoStateProvider.notifier).byNo(slipNo: slipNo);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = DeleteMaterialReturnStateError(message: e.message);
      } else {
        state = DeleteMaterialReturnStateError(message: e.toString());
      }
    }
  }
}

abstract class DeleteMaterialReturnState extends Equatable {
  final DateTime date;
  const DeleteMaterialReturnState({required this.date});
  @override
  List<Object?> get props => [date];
}

class DeleteMaterialReturnStateInit extends DeleteMaterialReturnState {
  DeleteMaterialReturnStateInit() : super(date: DateTime.now());
}

class DeleteMaterialReturnStateLoading extends DeleteMaterialReturnState {
  DeleteMaterialReturnStateLoading() : super(date: DateTime.now());
}

class DeleteMaterialReturnStateToken extends DeleteMaterialReturnState {
  DeleteMaterialReturnStateToken() : super(date: DateTime.now());
}

class DeleteMaterialReturnStateNoToken extends DeleteMaterialReturnState {
  DeleteMaterialReturnStateNoToken() : super(date: DateTime.now());
}

class DeleteMaterialReturnStateError extends DeleteMaterialReturnState {
  final String message;
  DeleteMaterialReturnStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class DeleteMaterialReturnStateDone extends DeleteMaterialReturnState {
  final String checkoutID;
  DeleteMaterialReturnStateDone({
    required this.checkoutID,
  }) : super(date: DateTime.now());
}
