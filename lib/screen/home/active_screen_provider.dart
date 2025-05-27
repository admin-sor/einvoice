import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/provider/shared_preference_provider.dart';
import 'package:sor_inventory/repository/auth_repository.dart';

import '../../model/dynamic_screen_model.dart';
import '../../provider/dio_provider.dart';
import '../../repository/base_repository.dart';

final activeScreenStateProvider =
    StateNotifierProvider<ActiveScreenStateNotifier, ActiveScreenState>(
  (ref) => ActiveScreenStateNotifier(ref: ref),
);

class ActiveScreenStateNotifier extends StateNotifier<ActiveScreenState> {
  final Ref ref;
  ActiveScreenStateNotifier({
    required this.ref,
  }) : super(ActiveScreenStateInit());

  void reset() {
    state = ActiveScreenStateInit();
  }

  void active(String screenGroupID) async {
    final loginModel = await ref.read(localAuthProvider.future);
    if (loginModel?.token == null) {
      state = ActiveScreenStateError(message: "Invalid Token");
      return;
    }

    final dio = ref.read(dioProvider);
    state = ActiveScreenStateLoading();
    try {
      final resp = await AuthRepository(dio: dio)
          .groupScreen(loginModel!.token!, screenGroupID);
      state = ActiveScreenStateDone(active: resp.active);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = ActiveScreenStateError(message: e.message);
      } else {
        state = ActiveScreenStateError(message: e.toString());
      }
    }
  }
}

abstract class ActiveScreenState extends Equatable {
  final DateTime date;
  ActiveScreenState({required this.date});
  @override
  List<Object?> get props => [date];
}

class ActiveScreenStateInit extends ActiveScreenState {
  ActiveScreenStateInit() : super(date: DateTime.now());
}

class ActiveScreenStateLoading extends ActiveScreenState {
  ActiveScreenStateLoading() : super(date: DateTime.now());
}

class ActiveScreenStateToken extends ActiveScreenState {
  ActiveScreenStateToken() : super(date: DateTime.now());
}

class ActiveScreenStateNoToken extends ActiveScreenState {
  ActiveScreenStateNoToken() : super(date: DateTime.now());
}

class ActiveScreenStateError extends ActiveScreenState {
  final String message;
  ActiveScreenStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class ActiveScreenStateDone extends ActiveScreenState {
  final List<DynamicScreenModel> active;
  ActiveScreenStateDone({
    required this.active,
  }) : super(date: DateTime.now());
}
