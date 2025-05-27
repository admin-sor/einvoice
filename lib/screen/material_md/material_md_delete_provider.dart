import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/provider/dio_provider.dart';
import 'package:sor_inventory/repository/base_repository.dart';
import 'package:sor_inventory/repository/material_md_repository.dart';
import 'package:sor_inventory/screen/material_md/material_md_search_provider.dart';

import '../../provider/shared_preference_provider.dart';

final materialMdDeleteProvider =
    StateNotifierProvider<MaterialMdDeleteNotifier, MaterialMdDeleteState>(
  (ref) => MaterialMdDeleteNotifier(ref: ref),
);

class MaterialMdDeleteNotifier extends StateNotifier<MaterialMdDeleteState> {
  Ref ref;
  MaterialMdDeleteNotifier({required this.ref})
      : super(MaterialMdDeleteStateInit());
  void delete({
    required String materialId,
    required String query,
  }) async {
    state = MaterialMdDeleteStateLoading();
    try {
      final loginModel = await ref.read(localAuthProvider.future);
      if (loginModel?.token == null) {
        state = MaterialMdDeleteStateError(message: "Invalid Token");
        return;
      }
      await MaterialMdRepository(dio: ref.read(dioProvider)).delete(
        token: loginModel!.token!,
        materialId: materialId,
      );
      ref.read(materialMdSearchProvider.notifier).search(query: query);
      state = MaterialMdDeleteStateDone();
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = MaterialMdDeleteStateError(message: e.message);
      } else {
        state = MaterialMdDeleteStateError(message: e.toString());
      }
    }
  }
}

abstract class MaterialMdDeleteState extends Equatable {
  final DateTime date;

  const MaterialMdDeleteState(this.date);
  @override
  List<Object?> get props => [date];
}

class MaterialMdDeleteStateInit extends MaterialMdDeleteState {
  MaterialMdDeleteStateInit() : super(DateTime.now());
}

class MaterialMdDeleteStateLoading extends MaterialMdDeleteState {
  MaterialMdDeleteStateLoading() : super(DateTime.now());
}

class MaterialMdDeleteStateError extends MaterialMdDeleteState {
  final String message;
  MaterialMdDeleteStateError({
    required this.message,
  }) : super(DateTime.now());
}

class MaterialMdDeleteStateDone extends MaterialMdDeleteState {
  MaterialMdDeleteStateDone() : super(DateTime.now());
}
