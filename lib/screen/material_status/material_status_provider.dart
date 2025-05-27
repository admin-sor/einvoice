import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/material_status_response_model.dart';
import '../../provider/dio_provider.dart';
import '../../repository/base_repository.dart';
import '../../repository/material_status_repository.dart';

final materialStatusProvider =
    StateNotifierProvider<MaterialStatusStateNotifier, MaterialStatusState>(
  (ref) => MaterialStatusStateNotifier(ref: ref),
);

class MaterialStatusStateNotifier extends StateNotifier<MaterialStatusState> {
  final Ref ref;
  MaterialStatusStateNotifier({
    required this.ref,
  }) : super(MaterialStatusStateInit());

  void reset() {
    state = MaterialStatusStateInit();
  }

  void list() async {
    final dio = ref.read(dioProvider);
    state = MaterialStatusStateLoading();
    try {
      final resp = await MaterialStatusRepository(dio: dio).list();
      state = MaterialStatusStateDone(
        list: resp,
      );
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = MaterialStatusStateError(message: e.message);
      } else {
        state = MaterialStatusStateError(message: e.toString());
      }
    }
  }
}

abstract class MaterialStatusState extends Equatable {
  final DateTime date;
  const MaterialStatusState({required this.date});
  @override
  List<Object?> get props => [date];
}

class MaterialStatusStateInit extends MaterialStatusState {
  MaterialStatusStateInit() : super(date: DateTime.now());
}

class MaterialStatusStateLoading extends MaterialStatusState {
  MaterialStatusStateLoading() : super(date: DateTime.now());
}

class MaterialStatusStateToken extends MaterialStatusState {
  MaterialStatusStateToken() : super(date: DateTime.now());
}

class MaterialStatusStateNoToken extends MaterialStatusState {
  MaterialStatusStateNoToken() : super(date: DateTime.now());
}

class MaterialStatusStateError extends MaterialStatusState {
  final String message;
  MaterialStatusStateError({
    required this.message,
  }) : super(date: DateTime.now());
}

class MaterialStatusStateDone extends MaterialStatusState {
  final List<MaterialStatusResponseModel> list;
  MaterialStatusStateDone({
    required this.list,
  }) : super(date: DateTime.now());
}
