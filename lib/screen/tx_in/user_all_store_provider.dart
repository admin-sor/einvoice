import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../model/store_model.dart';

final userAllStoreProvider =
    StateProvider<List<StoreModel>>((ref) => List<StoreModel>.empty());

final userAclStoreProvider =
    StateProvider<List<StoreModel>>((ref) => List<StoreModel>.empty());
