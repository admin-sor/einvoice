import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sor_inventory/provider/dio_provider.dart';
import 'package:sor_inventory/repository/base_repository.dart';
import 'package:sor_inventory/repository/product_repository.dart'; // Use ProductRepository
import 'package:sor_inventory/screen/product/product_search_provider.dart'; // Assuming this exists
import '../../provider/shared_preference_provider.dart';

// Define the StateNotifierProvider
final productDeleteProvider =
    StateNotifierProvider<ProductDeleteNotifier, ProductDeleteState>(
  (ref) => ProductDeleteNotifier(ref: ref),
);

// Define the StateNotifier
class ProductDeleteNotifier extends StateNotifier<ProductDeleteState> {
  Ref ref;
  ProductDeleteNotifier({required this.ref}) : super(ProductDeleteStateInit());

  // Delete method
  void delete({
    required int productId, // Use int based on ProductRepository
    required String query, // For refreshing the list after deletion
  }) async {
    state = ProductDeleteStateLoading();
    try {
      final loginModel = await ref.read(localAuthProvider.future);
      if (loginModel?.token == null) {
        state = ProductDeleteStateError(message: "Invalid Token");
        return;
      }

      await ProductRepository(dio: ref.read(dioProvider)).delete(
        // Use ProductRepository
        token: loginModel!.token!,
        evProductID: productId, // Use evProductID based on ProductRepository
      );

      // Refresh the product search results after successful deletion
      ref
          .read(productSearchProvider.notifier)
          .search(query: query); // Assuming productSearchProvider

      state = ProductDeleteStateDone();
    } catch (e) {
      if (e is BaseRepositoryException) {
        state = ProductDeleteStateError(message: e.message);
      } else {
        state = ProductDeleteStateError(message: e.toString());
      }
    }
  }
}

// Abstract base state class
abstract class ProductDeleteState extends Equatable {
  final DateTime date;
  const ProductDeleteState(this.date);

  @override
  List<Object?> get props => [date];
}

// Initial state
class ProductDeleteStateInit extends ProductDeleteState {
  ProductDeleteStateInit() : super(DateTime.now());
}

// Loading state
class ProductDeleteStateLoading extends ProductDeleteState {
  ProductDeleteStateLoading() : super(DateTime.now());
}

// Error state
class ProductDeleteStateError extends ProductDeleteState {
  final String message;
  ProductDeleteStateError({
    required this.message,
  }) : super(DateTime.now());

  @override
  List<Object?> get props => [date, message]; // Include message in props
}

// Done state
class ProductDeleteStateDone extends ProductDeleteState {
  ProductDeleteStateDone() : super(DateTime.now());
}
