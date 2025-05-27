import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/do_model.dart';
import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/do_repository.dart';

final checkDoNoProvider = StateNotifierProvider<CheckDoNoStateNotifier, CheckDoNoState>(
  (ref) => CheckDoNoStateNotifier(ref: ref),
);

class CheckDoNoStateNotifier extends StateNotifier<CheckDoNoState> {
  final Ref ref;
  CheckDoNoStateNotifier({
    required this.ref,
  }) : super(CheckDoNoStateInit());

  void reset() {
    state = CheckDoNoStateInit();
  }

  void check({
    required String doNo,
  }) async {
    state = CheckDoNoStateLoading();
    final dio = ref.read(dioProvider);
    try {
      await DoRepository(dio: dio).checkDoNo(
        doNo: doNo,
      );
      state = CheckDoNoStateDone();
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = CheckDoNoStateError(message: e.message);
      } else {
        state = CheckDoNoStateError(message: e.toString());
      }
    }
  }
}

abstract class CheckDoNoState extends Equatable {
  final DateTime date;
  CheckDoNoState({required this.date});
  @override
  List<Object?> get props => [date];
}

class CheckDoNoStateInit extends CheckDoNoState {
  CheckDoNoStateInit() : super(date: DateTime.now());
}

class CheckDoNoStateLoading extends CheckDoNoState {
  CheckDoNoStateLoading() : super(date: DateTime.now());
}

class CheckDoNoStateToken extends CheckDoNoState {
  CheckDoNoStateToken() : super(date: DateTime.now());
}

class CheckDoNoStateNoToken extends CheckDoNoState {
  CheckDoNoStateNoToken() : super(date: DateTime.now());
}

class CheckDoNoStateError extends CheckDoNoState {
  final String message;
  CheckDoNoStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class CheckDoNoStateDone extends CheckDoNoState {
  CheckDoNoStateDone() : super(date: DateTime.now());
}
