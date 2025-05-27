import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../model/screen_group_model.dart';

final selectScreenGroupProvider =
    StateProvider<ScreenGroupModel?>((ref) => null);

final quickScreenGroupProvider =
    StateProvider<List<ScreenGroupModel>?>((ref) => null);
final allScreenGroupProvider =
    StateProvider<List<ScreenGroupModel>?>((ref) => null);
