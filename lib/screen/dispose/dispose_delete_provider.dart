import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/repository/dispose_repository.dart';
import 'package:sor_inventory/screen/dispose/dispose_byno_provider.dart';
import 'package:sor_inventory/screen/dispose/dispose_store_provider.dart';
import 'package:sor_inventory/screen/dispose_summary/dispose_list_param_provider.dart';

import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../dispose_summary/dispose_list_slip_provider.dart';
import 'req_reload_dispose_material.dart';

final disposeDeleteStateProvider =
    StateNotifierProvider<DisposeDeleteStateNotifier, DisposeDeleteState>(
  (ref) => DisposeDeleteStateNotifier(ref: ref),
);

class DisposeDeleteStateNotifier extends StateNotifier<DisposeDeleteState> {
  final Ref ref;
  DisposeDeleteStateNotifier({
    required this.ref,
  }) : super(DisposeDeleteStateInit());

  void reset() {
    state = DisposeDeleteStateInit();
  }

  void delete({
    required String scrapID,
    required String slipNo,
  }) async {
    final loginModel = await ref.read(localAuthProvider.future);
    if (loginModel?.token == null) {
      state = DisposeDeleteStateError(message: "Invalid Token");
      return;
    }
    final dio = ref.read(dioProvider);
    state = DisposeDeleteStateLoading();
    try {
      await DisposeRepository(dio: dio).delete(
        scrapID: scrapID,
        slipNo: slipNo,
        token: loginModel!.token!,
      );
      ref.read(disposeByNoStateProvider.notifier).byNo(slipNo: slipNo);
      ref.read(reqReloadDisposeMaterial.notifier).update((state) => state + 1);
      var searchModel = ref.read(disposeListParamSearchProvider);
      ref.read(disposeListSlipStateProvider.notifier).list(
            storeID: searchModel.storeID,
            search: searchModel.search,
          );

      state = DisposeDeleteStateDone();
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = DisposeDeleteStateError(message: e.message);
      } else {
        state = DisposeDeleteStateError(message: e.toString());
      }
    }
  }
}

abstract class DisposeDeleteState extends Equatable {
  final DateTime date;
  const DisposeDeleteState({required this.date});
  @override
  List<Object?> get props => [date];
}

class DisposeDeleteStateInit extends DisposeDeleteState {
  DisposeDeleteStateInit() : super(date: DateTime.now());
}

class DisposeDeleteStateLoading extends DisposeDeleteState {
  DisposeDeleteStateLoading() : super(date: DateTime.now());
}

class DisposeDeleteStateToken extends DisposeDeleteState {
  DisposeDeleteStateToken() : super(date: DateTime.now());
}

class DisposeDeleteStateNoToken extends DisposeDeleteState {
  DisposeDeleteStateNoToken() : super(date: DateTime.now());
}

class DisposeDeleteStateError extends DisposeDeleteState {
  final String message;
  DisposeDeleteStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class DisposeDeleteStateDone extends DisposeDeleteState {
  DisposeDeleteStateDone() : super(date: DateTime.now());
}
