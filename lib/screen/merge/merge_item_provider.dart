import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/model/store_model.dart';
import 'package:sor_inventory/repository/merge_repository.dart';

final mergeItemProvider = StateProvider<List<ResponseMergeScan>>((ref) {
  return List.empty();
});

final mergeStoreIDProvider = StateProvider<StoreModel?>((ref) {
  return null;
});
