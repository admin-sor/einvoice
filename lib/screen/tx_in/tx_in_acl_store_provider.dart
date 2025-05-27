import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/store_model.dart';
import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/store_repository.dart';
import '../../repository/tx_in_repository.dart';

final txInAclStoreStateProvider =
    StateNotifierProvider<TxInAclStoreStateNotifier, TxInAclStoreState>(
  (ref) => TxInAclStoreStateNotifier(ref: ref),
);

class TxInAclStoreStateNotifier extends StateNotifier<TxInAclStoreState> {
  final Ref ref;
  TxInAclStoreStateNotifier({
    required this.ref,
  }) : super(TxInAclStoreStateInit());

  void reset() {
    state = TxInAclStoreStateInit();
  }

  void list() async {
    final loginModel = await ref.read(localAuthProvider.future);
    if (loginModel?.token == null) {
      state = TxInAclStoreStateError(message: "Invalid Token");
      return;
    }
    final dio = ref.read(dioProvider);
    state = TxInAclStoreStateLoading();
    try {
      final resp = await StoreRepository(dio: dio)
          .getStoreByUser(token: loginModel!.token!);
      state = TxInAclStoreStateDone(
        list: resp,
      );
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = TxInAclStoreStateError(message: e.message);
      } else {
        state = TxInAclStoreStateError(message: e.toString());
      }
    }
  }
}

abstract class TxInAclStoreState extends Equatable {
  final DateTime date;
  TxInAclStoreState({required this.date});
  @override
  List<Object?> get props => [date];
}

class TxInAclStoreStateInit extends TxInAclStoreState {
  TxInAclStoreStateInit() : super(date: DateTime.now());
}

class TxInAclStoreStateLoading extends TxInAclStoreState {
  TxInAclStoreStateLoading() : super(date: DateTime.now());
}

class TxInAclStoreStateToken extends TxInAclStoreState {
  TxInAclStoreStateToken() : super(date: DateTime.now());
}

class TxInAclStoreStateNoToken extends TxInAclStoreState {
  TxInAclStoreStateNoToken() : super(date: DateTime.now());
}

class TxInAclStoreStateError extends TxInAclStoreState {
  final String message;
  TxInAclStoreStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class TxInAclStoreStateDone extends TxInAclStoreState {
  final List<StoreModel> list;
  TxInAclStoreStateDone({
    required this.list,
  }) : super(date: DateTime.now());
}
