import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/repository/dispose_repository.dart';
import 'package:sor_inventory/screen/dispose/dispose_store_provider.dart';

import '../../model/scrap_model.dart';
import '../../provider/dio_provider.dart';
import '../../repository/base_repository.dart';

final disposeByNoStateProvider =
    StateNotifierProvider<DisposeByNoStateNotifier, DisposeByNoState>(
  (ref) => DisposeByNoStateNotifier(ref: ref),
);

class DisposeByNoStateNotifier extends StateNotifier<DisposeByNoState> {
  final Ref ref;
  DisposeByNoStateNotifier({
    required this.ref,
  }) : super(DisposeByNoStateInit());

  void reset() {
    state = DisposeByNoStateInit();
  }

  void byNo({
    required String slipNo,
  }) async {
    final dio = ref.read(dioProvider);
    state = DisposeByNoStateLoading();
    try {
      final resp = await DisposeRepository(dio: dio).getBySlip(
        slipNo,
      );
      ref.read(disposeSelectedStoreProvider.notifier).state = resp.store;
      state = DisposeByNoStateDone(
        list: resp.list,
      );
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = DisposeByNoStateError(message: e.message);
      } else {
        state = DisposeByNoStateError(message: e.toString());
      }
    }
  }
}

abstract class DisposeByNoState extends Equatable {
  final DateTime date;
  DisposeByNoState({required this.date});
  @override
  List<Object?> get props => [date];
}

class DisposeByNoStateInit extends DisposeByNoState {
  DisposeByNoStateInit() : super(date: DateTime.now());
}

class DisposeByNoStateLoading extends DisposeByNoState {
  DisposeByNoStateLoading() : super(date: DateTime.now());
}

class DisposeByNoStateToken extends DisposeByNoState {
  DisposeByNoStateToken() : super(date: DateTime.now());
}

class DisposeByNoStateNoToken extends DisposeByNoState {
  DisposeByNoStateNoToken() : super(date: DateTime.now());
}

class DisposeByNoStateError extends DisposeByNoState {
  final String message;
  DisposeByNoStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class DisposeByNoStateDone extends DisposeByNoState {
  final List<ScrapModel> list;
  DisposeByNoStateDone({
    required this.list,
  }) : super(date: DateTime.now());
}
