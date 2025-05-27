import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/repository/merge_repository.dart';

import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';

final mergeScanStateProvider =
    StateNotifierProvider<MergeScanStateNotifier, MergeScanState>(
  (ref) => MergeScanStateNotifier(ref: ref),
);

class MergeScanStateNotifier extends StateNotifier<MergeScanState> {
  final Ref ref;
  MergeScanStateNotifier({
    required this.ref,
  }) : super(MergeScanStateInit());

  void reset() {
    state = MergeScanStateInit();
  }

  void scan({
    required String barcode,
    String storeID = "",
    String materialID = "",

  }) async {
    final loginModel = await ref.read(localAuthProvider.future);
    if (loginModel?.token == null) {
      state = MergeScanStateError(message: "Invalid Token");
      return;
    }
    final dio = ref.read(dioProvider);
    state = MergeScanStateLoading();
    try {
      final resp = await MergeRepository(dio: dio).scan(
        barcode: barcode,
        materialID: materialID,
        storeID: storeID,
        token: loginModel!.token!,
      );
      state = MergeScanStateDone(model: resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = MergeScanStateError(message: e.message);
      } else {
        state = MergeScanStateError(message: e.toString());
      }
    }
  }
}

abstract class MergeScanState extends Equatable {
  final DateTime date;
  const MergeScanState({required this.date});
  @override
  List<Object?> get props => [date];
}

class MergeScanStateInit extends MergeScanState {
  MergeScanStateInit() : super(date: DateTime.now());
}

class MergeScanStateLoading extends MergeScanState {
  MergeScanStateLoading() : super(date: DateTime.now());
}

class MergeScanStateToken extends MergeScanState {
  MergeScanStateToken() : super(date: DateTime.now());
}

class MergeScanStateNoToken extends MergeScanState {
  MergeScanStateNoToken() : super(date: DateTime.now());
}

class MergeScanStateError extends MergeScanState {
  final String message;
  MergeScanStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class MergeScanStateDone extends MergeScanState {
  final ResponseMergeScan model;
  MergeScanStateDone({required this.model}) : super(date: DateTime.now());
}
