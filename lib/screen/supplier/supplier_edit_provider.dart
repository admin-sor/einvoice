import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/provider/dio_provider.dart';
import 'package:sor_inventory/repository/base_repository.dart';
import 'package:sor_inventory/repository/supplier_repository.dart';
import 'package:sor_inventory/screen/self_bill_screen/search_supplier_provider.dart';

import '../../provider/shared_preference_provider.dart';

final supplierEditProvider =
    StateNotifierProvider<SupplierEditNotifier, SupplierEditState>(
  (ref) => SupplierEditNotifier(ref: ref),
);

class SupplierEditNotifier extends StateNotifier<SupplierEditState> {
  Ref ref;
  SupplierEditNotifier({required this.ref}) : super(SupplierEditStateInit());

  void edit({
    required int evSupplierID,
    required String evSupplierType,
    required String evSupplierName,
    required String evSupplierBusinessRegNo,
    required String evSupplierBusinessRegType,
    required String evSupplierSstNo,
    required String evSupplierTinNo,
    required String evSupplierAddr1,
    required String evSupplierAddr2,
    required String evSupplierAddr3,
    required String evSupplierPic,
    required String evSupplierEmail,
    required String evSupplierPhone,
    required String query, // Parameter to refresh search results
  }) async {
    state = SupplierEditStateLoading();
    try {
      final loginModel = await ref.read(localAuthProvider.future);
      if (loginModel?.token == null) {
        state = SupplierEditStateError(message: "Invalid Token");
        return;
      }
      if (evSupplierID == 0) {
        await SupplierRepository(dio: ref.read(dioProvider)).add(
          token: loginModel!.token!,
          evSupplierType: evSupplierType,
          evSupplierName: evSupplierName,
          evSupplierBusinessRegNo: evSupplierBusinessRegNo,
          evSupplierBusinessRegType: evSupplierBusinessRegType,
          evSupplierSstNo: evSupplierSstNo,
          evSupplierTinNo: evSupplierTinNo,
          evSupplierAddr1: evSupplierAddr1,
          evSupplierAddr2: evSupplierAddr2,
          evSupplierAddr3: evSupplierAddr3,
          evSupplierPic: evSupplierPic,
          evSupplierEmail: evSupplierEmail,
          evSupplierPhone: evSupplierPhone,
        );
      } else {
        await SupplierRepository(dio: ref.read(dioProvider)).edit(
          token: loginModel!.token!,
          evSupplierID: evSupplierID,
          evSupplierType: evSupplierType,
          evSupplierName: evSupplierName,
          evSupplierBusinessRegNo: evSupplierBusinessRegNo,
          evSupplierBusinessRegType: evSupplierBusinessRegType,
          evSupplierSstNo: evSupplierSstNo,
          evSupplierTinNo: evSupplierTinNo,
          evSupplierAddr1: evSupplierAddr1,
          evSupplierAddr2: evSupplierAddr2,
          evSupplierAddr3: evSupplierAddr3,
          evSupplierPic: evSupplierPic,
          evSupplierEmail: evSupplierEmail,
          evSupplierPhone: evSupplierPhone,
        );
      }
      ref.read(supplierSearchProvider.notifier).search(query: query);
      state = SupplierEditStateDone();
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = SupplierEditStateError(message: e.message);
      } else {
        state = SupplierEditStateError(message: e.toString());
      }
    }
  }
}

abstract class SupplierEditState extends Equatable {
  final DateTime date;

  const SupplierEditState(this.date);
  @override
  List<Object?> get props => [date];
}

class SupplierEditStateInit extends SupplierEditState {
  SupplierEditStateInit() : super(DateTime.now());
}

class SupplierEditStateLoading extends SupplierEditState {
  SupplierEditStateLoading() : super(DateTime.now());
}

class SupplierEditStateError extends SupplierEditState {
  final String message;
  SupplierEditStateError({
    required this.message,
  }) : super(DateTime.now());
}

class SupplierEditStateDone extends SupplierEditState {
  SupplierEditStateDone() : super(DateTime.now());
}
