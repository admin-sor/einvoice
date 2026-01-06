import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/provider/current_host_provider.dart';
import 'package:sor_inventory/provider/screen_provider.dart';

import '../../model/sor_user_model.dart';
import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/auth_repository.dart';
import '../../repository/base_repository.dart';
import '../home/screen_group_provider.dart';

final selectedHostProvider = StateProvider<String>((ref) => "");
final loginStateProvider =
    StateNotifierProvider<LoginStateNotifier, LoginState>(
  (ref) => LoginStateNotifier(ref: ref),
);

class LoginStateNotifier extends StateNotifier<LoginState> {
  final Ref ref;
  LoginStateNotifier({
    required this.ref,
  }) : super(LoginStateInit());

  void reset() {
    state = LoginStateInit();
  }

  void logout() async {
    state = LoginStateInit();
    final sp = await ref.read(sharedPrefenceProvider.future);
    ref.read(currentConfigProvider.notifier).state = CurrentConfig(
      host: "tkdev.sor.my",
      user: null,
      clientName: "Client not Configured",
    );
    await sp.remove("token");
  }

  void checkLocalToken() async {
    state = LoginStateInit();
    final loginModel = await ref.read(localAuthProvider.future);
    if (loginModel == null) {
      state = LoginStateNoToken();
      return;
    }
    if (loginModel.screen != null) {
      ref.read(screenProvider.notifier).state = loginModel.screen!;
    }
    state = LoginStateDone(loginModel: loginModel);
    ref.read(listScreenGroupStateProvider.notifier).list();
  }

  void login({
    required String username,
    required String password,
  }) async {
    state = LoginStateLoading();
    // ref.read(changePasswordProvider.notifier).retry();
    try {
      if (!username.contains("@")) {
        username = "username@tkdev";
      }
      final res = await AuthRepository(dio: ref.read(dioProvider))
          .loginV2(username: username, password: password);
      final sp = await ref.read(sharedPrefenceProvider.future);
      final jToken = jsonEncode(res);
      await sp.setString("token", jToken);
      ref.read(currentConfigProvider.notifier).state = CurrentConfig(
        host: res.host ?? "tkdev.sor.my",
        user: res,
        clientName: res.clientName ?? "Client not Configured",
      );
      state = LoginStateDone(loginModel: res);
      if (res.screen != null)
        ref.read(screenProvider.notifier).state = res.screen!;
      ref.read(selectedHostProvider.notifier).state = res.host ?? "";
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = LoginStateError(message: e.message);
      } else {
        state = LoginStateError(message: e.toString());
      }
    }
  }
}

abstract class LoginState extends Equatable {
  final DateTime date;
  LoginState({required this.date});
  @override
  List<Object?> get props => [date];
}

class LoginStateInit extends LoginState {
  LoginStateInit() : super(date: DateTime.now());
}

class LoginStateLoading extends LoginState {
  LoginStateLoading() : super(date: DateTime.now());
}

class LoginStateToken extends LoginState {
  LoginStateToken() : super(date: DateTime.now());
}

class LoginStateNoToken extends LoginState {
  LoginStateNoToken() : super(date: DateTime.now());
}

class LoginStateError extends LoginState {
  final String message;
  LoginStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class LoginStateDone extends LoginState {
  final SorUser loginModel;
  LoginStateDone({
    required this.loginModel,
  }) : super(date: DateTime.now());
}
