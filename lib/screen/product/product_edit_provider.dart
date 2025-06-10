import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/provider/dio_provider.dart';
import 'package:sor_inventory/repository/base_repository.dart';
import 'package:sor_inventory/repository/product_repository.dart';
import 'package:sor_inventory/screen/product/product_search_provider.dart';

import '../../provider/shared_preference_provider.dart';

final productEditProvider =
    StateNotifierProvider<ProductEditNotifier, ProductEditState>(
  (ref) => ProductEditNotifier(ref: ref),
);

class ProductEditNotifier extends StateNotifier<ProductEditState> {
  Ref ref;
  ProductEditNotifier({required this.ref}) : super(ProductEditStateInit());

  void edit({
    required String evProductID,
    required String evProductDescription,
    required String evProductUnit,
    required String evProductPrice,
    required String query, // Parameter to refresh search results
  }) async {
    state = ProductEditStateLoading();
    try {
      final loginModel = await ref.read(localAuthProvider.future);
      if (loginModel?.token == null) {
        state = ProductEditStateError(message: "Invalid Token");
        return;
      }
      await ProductRepository(dio: ref.read(dioProvider)).edit(
        token: loginModel!.token!,
        evProductID: evProductID,
        evProductDescription: evProductDescription,
        evProductUnit: evProductUnit,
        evProductPrice: evProductPrice,
      );
      ref.read(productSearchProvider.notifier).search(query: query);
      state = ProductEditStateDone();
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = ProductEditStateError(message: e.message);
      } else {
        state = ProductEditStateError(message: e.toString());
      }
    }
  }
}

abstract class ProductEditState extends Equatable {
  final DateTime date;

  const ProductEditState(this.date);
  @override
  List<Object?> get props => [date];
}

class ProductEditStateInit extends ProductEditState {
  ProductEditStateInit() : super(DateTime.now());
}

class ProductEditStateLoading extends ProductEditState {
  ProductEditStateLoading() : super(DateTime.now());
}

class ProductEditStateError extends ProductEditState {
  final String message;
  ProductEditStateError({
    required this.message,
  }) : super(DateTime.now());
}

class ProductEditStateDone extends ProductEditState {
  ProductEditStateDone() : super(DateTime.now());
}
