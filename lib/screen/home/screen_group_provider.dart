import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/provider/shared_preference_provider.dart';
import 'package:sor_inventory/repository/auth_repository.dart';

import '../../model/screen_group_model.dart';
import '../../provider/dio_provider.dart';
import '../../repository/base_repository.dart';

final listScreenGroupStateProvider =
    StateNotifierProvider<ListScreenGroupStateNotifier, ListScreenGroupState>(
  (ref) => ListScreenGroupStateNotifier(ref: ref),
);

class ListScreenGroupStateNotifier extends StateNotifier<ListScreenGroupState> {
  final Ref ref;
  ListScreenGroupStateNotifier({
    required this.ref,
  }) : super(ListScreenGroupStateInit());

  void reset() {
    state = ListScreenGroupStateInit();
  }

  void list() async {
    final loginModel = await ref.read(localAuthProvider.future);
    if (loginModel?.token == null) {
      state = ListScreenGroupStateError(message: "Invalid Token");
      return;
    }

    final dio = ref.read(dioProvider);
    state = ListScreenGroupStateLoading();
    try {
      final resp =
          await AuthRepository(dio: dio).screenGroup(loginModel!.token!);
      state = ListScreenGroupStateDone(list: resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = ListScreenGroupStateError(message: e.message);
      } else {
        state = ListScreenGroupStateError(message: e.toString());
      }
    }
  }
}

abstract class ListScreenGroupState extends Equatable {
  final DateTime date;
  ListScreenGroupState({required this.date});
  @override
  List<Object?> get props => [date];
}

class ListScreenGroupStateInit extends ListScreenGroupState {
  ListScreenGroupStateInit() : super(date: DateTime.now());
}

class ListScreenGroupStateLoading extends ListScreenGroupState {
  ListScreenGroupStateLoading() : super(date: DateTime.now());
}

class ListScreenGroupStateToken extends ListScreenGroupState {
  ListScreenGroupStateToken() : super(date: DateTime.now());
}

class ListScreenGroupStateNoToken extends ListScreenGroupState {
  ListScreenGroupStateNoToken() : super(date: DateTime.now());
}

class ListScreenGroupStateError extends ListScreenGroupState {
  final String message;
  ListScreenGroupStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class ListScreenGroupStateDone extends ListScreenGroupState {
  final List<ScreenGroupModel> list;
  ListScreenGroupStateDone({
    required this.list,
  }) : super(date: DateTime.now());
}
