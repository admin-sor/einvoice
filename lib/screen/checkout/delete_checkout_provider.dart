import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/screen/checkout/list_c1_provider.dart';

import '../../model/contractor_lookup_model.dart';
import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/checkout_repository.dart';

final deleteCheckoutStateProvider =
    StateNotifierProvider<DeleteCheckoutStateNotifier, DeleteCheckoutState>(
  (ref) => DeleteCheckoutStateNotifier(ref: ref),
);

class DeleteCheckoutStateNotifier extends StateNotifier<DeleteCheckoutState> {
  final Ref ref;
  DeleteCheckoutStateNotifier({
    required this.ref,
  }) : super(DeleteCheckoutStateInit());

  void reset() {
    state = DeleteCheckoutStateInit();
  }

  void deleteCheckout({
    required String checkoutID,
    required String fileNum,
    required String slipNo,
  }) async {
    final dio = ref.read(dioProvider);
    state = DeleteCheckoutStateLoading();
    try {
      final loginModel = await ref.read(localAuthProvider.future);
      if (loginModel?.token == null) {
        state = DeleteCheckoutStateError(message: "Invalid Token");
        return;
      }
      await CheckoutRepository(dio: dio).delete(
        checkoutID: checkoutID,
        token: loginModel!.token!
      );
      ref.read(listC1StateProvider.notifier).listC1(fileNum: fileNum, slipNo: slipNo);
      state = DeleteCheckoutStateDone();
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = DeleteCheckoutStateError(message: e.message);
      } else {
        state = DeleteCheckoutStateError(message: e.toString());
      }
    }
  }
}

abstract class DeleteCheckoutState extends Equatable {
  final DateTime date;
  DeleteCheckoutState({required this.date});
  @override
  List<Object?> get props => [date];
}

class DeleteCheckoutStateInit extends DeleteCheckoutState {
  DeleteCheckoutStateInit() : super(date: DateTime.now());
}

class DeleteCheckoutStateLoading extends DeleteCheckoutState {
  DeleteCheckoutStateLoading() : super(date: DateTime.now());
}

class DeleteCheckoutStateToken extends DeleteCheckoutState {
  DeleteCheckoutStateToken() : super(date: DateTime.now());
}

class DeleteCheckoutStateNoToken extends DeleteCheckoutState {
  DeleteCheckoutStateNoToken() : super(date: DateTime.now());
}

class DeleteCheckoutStateError extends DeleteCheckoutState {
  final String message;
  DeleteCheckoutStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class DeleteCheckoutStateDone extends DeleteCheckoutState {
  DeleteCheckoutStateDone() : super(date: DateTime.now());
}
