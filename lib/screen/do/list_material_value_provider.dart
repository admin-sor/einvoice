import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReceivedMaterial {
  final String materialId;
  final String materialCode;
  final String poNum;
  final String description;
  final String unit;
  final double qty;

  ReceivedMaterial({
    required this.materialId,
    required this.materialCode,
    required this.poNum,
    required this.description,
    required this.unit,
    required this.qty,
  });
}

final listMaterialValueProvider =
    StateProvider<List<ReceivedMaterial>>((ref) => List.empty());
