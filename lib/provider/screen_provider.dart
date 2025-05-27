import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sor_inventory/model/dynamic_screen_model.dart';

final screenProvider = StateProvider<List<DynamicScreenModel>>((ref)=>[]);
