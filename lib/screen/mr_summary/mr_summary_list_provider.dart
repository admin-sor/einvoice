import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/model/checkout_model_v2.dart';
import 'package:sor_inventory/model/mr_model_v2.dart';
import 'package:sor_inventory/repository/checkout_repository.dart';
import 'package:sor_inventory/repository/material_return_repository.dart';

import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';

final mrListStateProvider =
    StateNotifierProvider<MrListStateNotifier, MrListState>(
  (ref) => MrListStateNotifier(ref: ref),
);

class MrListStateNotifier extends StateNotifier<MrListState> {
  final Ref ref;
  MrListStateNotifier({
    required this.ref,
  }) : super(MrListStateInit());

  void reset() {
    state = MrListStateInit();
  }

  void list({
    required String cpID,
    required String soID,
    String search = "",
    String storeID = "0",
  }) async {
    final dio = ref.read(dioProvider);
    final loginModel = await ref.read(localAuthProvider.future);
    state = MrListStateLoading();
    try {
      final token = (loginModel?.token ?? "");
      final resp = await MaterialReturnRepository(dio: dio).list(
        cpID: cpID,
        soID: soID,
        storeID: storeID,
        search:search,
        token: token,
      );
      state = MrListStateDone(list: resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = MrListStateError(message: e.message);
      } else {
        state = MrListStateError(message: e.toString());
      }
    }
  }
}

abstract class MrListState extends Equatable {
  final DateTime date;
  MrListState({required this.date});
  @override
  List<Object?> get props => [date];
}

class MrListStateInit extends MrListState {
  MrListStateInit() : super(date: DateTime.now());
}

class MrListStateLoading extends MrListState {
  MrListStateLoading() : super(date: DateTime.now());
}

class MrListStateToken extends MrListState {
  MrListStateToken() : super(date: DateTime.now());
}

class MrListStateNoToken extends MrListState {
  MrListStateNoToken() : super(date: DateTime.now());
}

class MrListStateError extends MrListState {
  final String message;
  MrListStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class MrListStateDone extends MrListState {
  final List<MrListModel> list;
  MrListStateDone({
    required this.list,
  }) : super(date: DateTime.now());
}
