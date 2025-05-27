import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/repository/dispose_repository.dart';
import 'package:sor_inventory/screen/dispose/dispose_byno_provider.dart';

import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';

final disposeSaveStateProvider =
    StateNotifierProvider<DisposeSaveStateNotifier, DisposeSaveState>(
  (ref) => DisposeSaveStateNotifier(ref: ref),
);

class DisposeSaveStateNotifier extends StateNotifier<DisposeSaveState> {
  final Ref ref;
  DisposeSaveStateNotifier({
    required this.ref,
  }) : super(DisposeSaveStateInit());

  void reset() {
    state = DisposeSaveStateInit();
  }

  void save({
    required String scrapID,
    String slipNo = "",
    String remark = ""
  }) async {
    final loginModel = await ref.read(localAuthProvider.future);
    if (loginModel?.token == null) {
      state = DisposeSaveStateError(message: "Invalid Token");
      return;
    }
    final dio = ref.read(dioProvider);
    state = DisposeSaveStateLoading();
    try {
      var resp = await DisposeRepository(dio: dio).save(
        scrapID,
        slipNo,
        loginModel!.token!,
        remark
      );
      state = DisposeSaveStateDone(slipNo: resp);
      if (resp != "") {
        ref.read(disposeByNoStateProvider.notifier).byNo(slipNo: resp);
      }
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = DisposeSaveStateError(message: e.message);
      } else {
        state = DisposeSaveStateError(message: e.toString());
      }
    }
  }
}

abstract class DisposeSaveState extends Equatable {
  final DateTime date;
  const DisposeSaveState({required this.date});
  @override
  List<Object?> get props => [date];
}

class DisposeSaveStateInit extends DisposeSaveState {
  DisposeSaveStateInit() : super(date: DateTime.now());
}

class DisposeSaveStateLoading extends DisposeSaveState {
  DisposeSaveStateLoading() : super(date: DateTime.now());
}

class DisposeSaveStateToken extends DisposeSaveState {
  DisposeSaveStateToken() : super(date: DateTime.now());
}

class DisposeSaveStateNoToken extends DisposeSaveState {
  DisposeSaveStateNoToken() : super(date: DateTime.now());
}

class DisposeSaveStateError extends DisposeSaveState {
  final String message;
  DisposeSaveStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class DisposeSaveStateDone extends DisposeSaveState {
  final String slipNo;
  DisposeSaveStateDone({required this.slipNo}) : super(date: DateTime.now());
}
