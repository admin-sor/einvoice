import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/model/checkout_model_v2.dart';
import 'package:sor_inventory/repository/checkout_repository.dart';

import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';

final listCheckoutStateProvider =
    StateNotifierProvider<ListCheckoutStateNotifier, ListCheckoutState>(
  (ref) => ListCheckoutStateNotifier(ref: ref),
);

class ListCheckoutStateNotifier extends StateNotifier<ListCheckoutState> {
  final Ref ref;
  ListCheckoutStateNotifier({
    required this.ref,
  }) : super(ListCheckoutStateInit());

  void reset() {
    state = ListCheckoutStateInit();
  }

  void listV2({
    String isReturn = "N",
    required String vendorID,
    required String staffID,
    String search = "",
    String storeID = "0",
  }) async {
    final dio = ref.read(dioProvider);
    final loginModel = await ref.read(localAuthProvider.future);
    try {
      final token = (loginModel?.token ?? "");
      state = ListCheckoutStateLoading();
      final resp = await CheckoutRepository(dio: dio).listV2(
          vendorID: vendorID,
          isReturn: isReturn,
          staffId: staffID,
          storeID: storeID,
          search: search,
          token: token);
      state = ListCheckoutStateDone(list: resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = ListCheckoutStateError(message: e.message);
      } else {
        state = ListCheckoutStateError(message: e.toString());
      }
    }
  }

  void list({
    String isReturn = "N",
    required String vendorID,
  }) async {
    final dio = ref.read(dioProvider);
    state = ListCheckoutStateLoading();
    try {
      final resp = await CheckoutRepository(dio: dio).list(
        vendorID: vendorID,
        isReturn: isReturn,
      );
      state = ListCheckoutStateDone(list: resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = ListCheckoutStateError(message: e.message);
      } else {
        state = ListCheckoutStateError(message: e.toString());
      }
    }
  }
}

abstract class ListCheckoutState extends Equatable {
  final DateTime date;
  ListCheckoutState({required this.date});
  @override
  List<Object?> get props => [date];
}

class ListCheckoutStateInit extends ListCheckoutState {
  ListCheckoutStateInit() : super(date: DateTime.now());
}

class ListCheckoutStateLoading extends ListCheckoutState {
  ListCheckoutStateLoading() : super(date: DateTime.now());
}

class ListCheckoutStateToken extends ListCheckoutState {
  ListCheckoutStateToken() : super(date: DateTime.now());
}

class ListCheckoutStateNoToken extends ListCheckoutState {
  ListCheckoutStateNoToken() : super(date: DateTime.now());
}

class ListCheckoutStateError extends ListCheckoutState {
  final String message;
  ListCheckoutStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class ListCheckoutStateDone extends ListCheckoutState {
  final List<CheckoutLisModel> list;
  ListCheckoutStateDone({
    required this.list,
  }) : super(date: DateTime.now());
}
