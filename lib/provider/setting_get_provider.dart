import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../model/mobile_config_model.dart';
import '../repository/mobile_config_repository.dart';

final settingGetProvider =
    StateNotifierProvider<SettingGetStateNotifier, SettingGetState>(
  (ref) => SettingGetStateNotifier(ref: ref),
);

class SettingGetStateNotifier extends StateNotifier<SettingGetState> {
  final Ref ref;
  SettingGetStateNotifier({
    required this.ref,
  }) : super(SettingGetStateInit());

  void reset() {
    state = SettingGetStateInit();
  }

  void get() async {
    final loginModel = await ref.read(localAuthProvider.future);
    if (loginModel?.token == null) {
      state = SettingGetStateError(message: "Invalid Token");
    }
    final dio = ref.read(dioProvider);
    state = SettingGetStateLoading();
    try {
      final resp = await MobileConfigRepository(dio: dio).get(
        token: loginModel!.token!,
      );
      state = SettingGetStateDone(model: resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = SettingGetStateError(message: e.message);
      } else {
        state = SettingGetStateError(message: e.toString());
      }
    }
  }
}

abstract class SettingGetState extends Equatable {
  final DateTime date;
  const SettingGetState({required this.date});
  @override
  List<Object?> get props => [date];
}

class SettingGetStateInit extends SettingGetState {
  SettingGetStateInit() : super(date: DateTime.now());
}

class SettingGetStateLoading extends SettingGetState {
  SettingGetStateLoading() : super(date: DateTime.now());
}

class SettingGetStateToken extends SettingGetState {
  SettingGetStateToken() : super(date: DateTime.now());
}

class SettingGetStateNoToken extends SettingGetState {
  SettingGetStateNoToken() : super(date: DateTime.now());
}

class SettingGetStateError extends SettingGetState {
  final String message;
  SettingGetStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class SettingGetStateDone extends SettingGetState {
  final MobileConfigModel model;
  SettingGetStateDone({
    required this.model,
  }) : super(date: DateTime.now());
}
