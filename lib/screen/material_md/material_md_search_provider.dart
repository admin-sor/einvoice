import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/repository/material_md_repository.dart';

import '../../model/materialmd_model.dart';
import '../../provider/dio_provider.dart';
import '../../provider/shared_preference_provider.dart';
import '../../repository/base_repository.dart';

final materialMdSearchProvider =
    StateNotifierProvider<MaterialMdNotifier, MaterialMdSearchState>(
        (ref) => MaterialMdNotifier(ref: ref));

class MaterialMdNotifier extends StateNotifier<MaterialMdSearchState> {
  final Ref ref;
  MaterialMdNotifier({required this.ref}) : super(MaterialMdSearchStateInit());

  void search({required String query}) async {
    state = MaterialMdSearchStateLoading();
    try {
      final loginModel = await ref.read(localAuthProvider.future);
      if (loginModel?.token == null) {
        state = MaterialMdSearchStateError(message: "Invalid Token");
      }
      final resp = await MaterialMdRepository(dio: ref.read(dioProvider))
          .search(query: query, token: loginModel!.token!);
      state = MaterialMdSearchStateDone(model: resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = MaterialMdSearchStateError(message: e.message);
      } else {
        state = MaterialMdSearchStateError(message: e.toString());
      }
    }
  }
}

abstract class MaterialMdSearchState extends Equatable {
  final DateTime date;

  const MaterialMdSearchState(this.date);
  @override
  List<Object?> get props => [date];
}

class MaterialMdSearchStateInit extends MaterialMdSearchState {
  MaterialMdSearchStateInit() : super(DateTime.now());
}

class MaterialMdSearchStateLoading extends MaterialMdSearchState {
  MaterialMdSearchStateLoading() : super(DateTime.now());
}

class MaterialMdSearchStateError extends MaterialMdSearchState {
  final String message;
  MaterialMdSearchStateError({
    required this.message,
  }) : super(DateTime.now());
}

class MaterialMdSearchStateDone extends MaterialMdSearchState {
  final List<MaterialMdModel> model;
  MaterialMdSearchStateDone({
    required this.model,
  }) : super(DateTime.now());
}
