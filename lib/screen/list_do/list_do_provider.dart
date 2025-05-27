import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/provider/shared_preference_provider.dart';

import '../../model/lis_do_response_model.dart';
import '../../provider/dio_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/do_repository.dart';

final listDoStateProvider =
    StateNotifierProvider<ListDoStateNotifier, ListDoState>(
  (ref) => ListDoStateNotifier(ref: ref),
);

class ListDoStateNotifier extends StateNotifier<ListDoState> {
  final Ref ref;
  ListDoStateNotifier({
    required this.ref,
  }) : super(ListDoStateInit());

  void reset() {
    state = ListDoStateInit();
  }

  void list({
    required String doNo,
    required String poNo,
    required String storeID,
    required String vendorID,
    String materialID = "0",
  }) async {
    final loginModel = await ref.read(localAuthProvider.future);
    if (loginModel?.token == null) {
      state = ListDoStateError(message: "Invalid Token");
      return;
    }
 
    final dio = ref.read(dioProvider);
    state = ListDoStateLoading();
    try {
      final resp = await DoRepository(dio: dio).list(
        doNo: doNo,
        poNo: poNo,
        vendorID: vendorID,
        storeID: storeID,
        materialID: materialID,
        token: loginModel!.token!,
      );
      state = ListDoStateDone(list: resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = ListDoStateError(message: e.message);
      } else {
        state = ListDoStateError(message: e.toString());
      }
    }
  }
}

abstract class ListDoState extends Equatable {
  final DateTime date;
  ListDoState({required this.date});
  @override
  List<Object?> get props => [date];
}

class ListDoStateInit extends ListDoState {
  ListDoStateInit() : super(date: DateTime.now());
}

class ListDoStateLoading extends ListDoState {
  ListDoStateLoading() : super(date: DateTime.now());
}

class ListDoStateToken extends ListDoState {
  ListDoStateToken() : super(date: DateTime.now());
}

class ListDoStateNoToken extends ListDoState {
  ListDoStateNoToken() : super(date: DateTime.now());
}

class ListDoStateError extends ListDoState {
  final String message;
  ListDoStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class ListDoStateDone extends ListDoState {
  final List<ListDoResponseModel> list;
  ListDoStateDone({
    required this.list,
  }) : super(date: DateTime.now());
}
