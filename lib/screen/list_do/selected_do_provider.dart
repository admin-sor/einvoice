import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/fx_auto_completion_vendor.dart';

class SelectedDoModel {
  final String doID;
  final String doNo;
  final VendorModel vendorModel;
  final String poNo;
  final String poID;
  final String? storeID;
  final String doDate;
  final String? storeName;
  SelectedDoModel({
    required this.doID,
    required this.doNo,
    required this.vendorModel,
    required this.poNo,
    required this.poID,
    required this.doDate,
    this.storeID = "0",
    this.storeName = "No Store"
  });
}

final selectedDoProvider = StateProvider<SelectedDoModel?>((ref) => null);
