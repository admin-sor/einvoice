import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/repository/base_repository.dart';

import '../../model/vendor_model.dart';
import '../../provider/dio_provider.dart';
import '../../repository/vendor_repository.dart';

final vendorSearchProvider =
    StateNotifierProvider<VendorSearchStateNotifier, VendorSearchState>(
  (ref) => VendorSearchStateNotifier(ref: ref),
);

class VendorSearchStateNotifier extends StateNotifier<VendorSearchState> {
  final Ref ref;
  VendorSearchStateNotifier({required this.ref})
      : super(VendorSearchStateInit());
  void search({required String query}) async {
    state = VendorSearchStateLoading();
    try {
      final resp = await VendorRepository(dio: ref.read(dioProvider))
          .search(query: query);
      state = VendorSearchStateDone(resp);
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = VendorSearchStateError(e.message);
      } else {
        state = VendorSearchStateError(e.toString());
      }
    }
  }
}

abstract class VendorSearchState extends Equatable {
  final DateTime date;

  const VendorSearchState(this.date);

  @override
  List<Object?> get props => [date];
}

class VendorSearchStateInit extends VendorSearchState {
  VendorSearchStateInit() : super(DateTime.now());
}

class VendorSearchStateLoading extends VendorSearchState {
  VendorSearchStateLoading() : super(DateTime.now());
}

class VendorSearchStateError extends VendorSearchState {
  final String message;
  VendorSearchStateError(this.message) : super(DateTime.now());
}

class VendorSearchStateDone extends VendorSearchState {
  final List<VendorModel> list;
  VendorSearchStateDone(this.list) : super(DateTime.now());
}
