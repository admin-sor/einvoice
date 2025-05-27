import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../model/mobile_config_model.dart';
import '../repository/mobile_config_repository.dart';

final settingUpdateProvider =
    StateNotifierProvider<SettingUpdateStateNotifier, SettingUpdateState>(
  (ref) => SettingUpdateStateNotifier(ref: ref),
);

class SettingUpdateStateNotifier extends StateNotifier<SettingUpdateState> {
  final Ref ref;
  SettingUpdateStateNotifier({
    required this.ref,
  }) : super(SettingUpdateStateInit());

  void reset() {
    state = SettingUpdateStateInit();
  }

  void update({
    required MobileConfigModel model,
  }) async {
    final loginModel = await ref.read(localAuthProvider.future);
    if (loginModel?.token == null) {
      state = SettingUpdateStateError(message: "Invalid Token");
    }
    final dio = ref.read(dioProvider);
    state = SettingUpdateStateLoading();
    try {
      final resp = await MobileConfigRepository(dio: dio)
          .update(token: loginModel!.token!, model: model);
      state = SettingUpdateStateDone(model: resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = SettingUpdateStateError(message: e.message);
      } else {
        state = SettingUpdateStateError(message: e.toString());
      }
    }
  }
}

abstract class SettingUpdateState extends Equatable {
  final DateTime date;
  const SettingUpdateState({required this.date});
  @override
  List<Object?> get props => [date];
}

class SettingUpdateStateInit extends SettingUpdateState {
  SettingUpdateStateInit() : super(date: DateTime.now());
}

class SettingUpdateStateLoading extends SettingUpdateState {
  SettingUpdateStateLoading() : super(date: DateTime.now());
}

class SettingUpdateStateToken extends SettingUpdateState {
  SettingUpdateStateToken() : super(date: DateTime.now());
}

class SettingUpdateStateNoToken extends SettingUpdateState {
  SettingUpdateStateNoToken() : super(date: DateTime.now());
}

class SettingUpdateStateError extends SettingUpdateState {
  final String message;
  SettingUpdateStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class SettingUpdateStateDone extends SettingUpdateState {
  final MobileConfigModel model;
  SettingUpdateStateDone({
    required this.model,
  }) : super(date: DateTime.now());
}
