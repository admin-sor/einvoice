import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/repository/split_repository.dart';

import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';

final splitScanStateProvider =
    StateNotifierProvider<SplitScanStateNotifier, SplitScanState>(
  (ref) => SplitScanStateNotifier(ref: ref),
);

class SplitScanStateNotifier extends StateNotifier<SplitScanState> {
  final Ref ref;
  SplitScanStateNotifier({
    required this.ref,
  }) : super(SplitScanStateInit());

  void reset() {
    state = SplitScanStateInit();
  }

  void scan({
    required String barcode,
    required String storeID,
  }) async {
    final loginModel = await ref.read(localAuthProvider.future);
    if (loginModel?.token == null) {
      state = SplitScanStateError(message: "Invalid Token");
      return;
    }
    final dio = ref.read(dioProvider);
    state = SplitScanStateLoading();
    try {
      final resp = await SplitRepository(dio: dio).scan(
        barcode: barcode,
        storeID: storeID,
        token: loginModel!.token!,
      );
      state = SplitScanStateDone(model: resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = SplitScanStateError(message: e.message);
      } else {
        state = SplitScanStateError(message: e.toString());
      }
    }
  }
}

abstract class SplitScanState extends Equatable {
  final DateTime date;
  const SplitScanState({required this.date});
  @override
  List<Object?> get props => [date];
}

class SplitScanStateInit extends SplitScanState {
  SplitScanStateInit() : super(date: DateTime.now());
}

class SplitScanStateLoading extends SplitScanState {
  SplitScanStateLoading() : super(date: DateTime.now());
}

class SplitScanStateToken extends SplitScanState {
  SplitScanStateToken() : super(date: DateTime.now());
}

class SplitScanStateNoToken extends SplitScanState {
  SplitScanStateNoToken() : super(date: DateTime.now());
}

class SplitScanStateError extends SplitScanState {
  final String message;
  SplitScanStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class SplitScanStateDone extends SplitScanState {
  final ResponseSplitScan model;
  SplitScanStateDone({required this.model}) : super(date: DateTime.now());
}
