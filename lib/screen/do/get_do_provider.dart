import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/do_model.dart';
import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/do_repository.dart';

final getDoDetailStateProvider =
    StateNotifierProvider<GetDoStateNotifier, GetDoState>(
  (ref) => GetDoStateNotifier(ref: ref),
);

class GetDoStateNotifier extends StateNotifier<GetDoState> {
  final Ref ref;
  GetDoStateNotifier({
    required this.ref,
  }) : super(GetDoStateInit());

  void reset() {
    state = GetDoStateInit();
  }

  void get({
    required String doNo,
    required String storeID,
    required String vendorID,
  }) async {
    final loginModel = await ref.read(localAuthProvider.future);
    if (loginModel?.token == null) {
      state = GetDoStateError(message: "Invalid Token");
    }
    final dio = ref.read(dioProvider);
    state = GetDoStateLoading();
    try {
      final resp = await DoRepository(dio: dio).get(
          doNo: doNo,
          vendorID: vendorID,
          storeID: storeID,
          token: loginModel!.token!);
      state = GetDoStateDone(doResponseModel: resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = GetDoStateError(message: e.message);
      } else {
        state = GetDoStateError(message: e.toString());
      }
    }
  }
}

abstract class GetDoState extends Equatable {
  final DateTime date;
  GetDoState({required this.date});
  @override
  List<Object?> get props => [date];
}

class GetDoStateInit extends GetDoState {
  GetDoStateInit() : super(date: DateTime.now());
}

class GetDoStateLoading extends GetDoState {
  GetDoStateLoading() : super(date: DateTime.now());
}

class GetDoStateToken extends GetDoState {
  GetDoStateToken() : super(date: DateTime.now());
}

class GetDoStateNoToken extends GetDoState {
  GetDoStateNoToken() : super(date: DateTime.now());
}

class GetDoStateError extends GetDoState {
  final String message;
  GetDoStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class GetDoStateDone extends GetDoState {
  final DoResponseModel doResponseModel;
  GetDoStateDone({
    required this.doResponseModel,
  }) : super(date: DateTime.now());
}
