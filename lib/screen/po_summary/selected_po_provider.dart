import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/fx_auto_completion_vendor.dart';

class SelectedPoModel {
  final String poNo;
  final VendorModel vendorModel;
  final String paymentTermID;

  SelectedPoModel({
    required this.poNo,
    required this.vendorModel,
    this.paymentTermID = "0",
  });
}

final selectedPoProvider = StateProvider<SelectedPoModel?>((ref) => null);
