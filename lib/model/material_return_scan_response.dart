import 'dart:convert';

import 'package:intl/intl.dart';

import 'contractor_lookup_model.dart';

class MaterialReturnScanResponseModelV2 {
  late String checkoutDate;
  late String checkoutID;
  late String checkoutIsPartial;
  late String checkoutIsReturn;
  late String description;
  late String doDetailDrumNo;
  late String doDetailID;
  late String doDetailQty;
  late String isCable;
  late String mrID;
  late String materialCode;
  late String materialId;
  late String packUnit;
  late String packsizeBarcode;
  late String packsizeCurrent;
  late String editQty;
  late String packsizeOriginal;
  late String unit;
  late ContractorLookupModel contractor;
  late String checkoutPackQty;
  late String isLessThan1Day;
  late String isScrap;

  MaterialReturnScanResponseModelV2({
    required this.checkoutDate,
    required this.checkoutID,
    required this.checkoutIsPartial,
    required this.checkoutIsReturn,
    required this.description,
    required this.doDetailDrumNo,
    required this.doDetailID,
    required this.doDetailQty,
    required this.isCable,
    required this.materialCode,
    required this.materialId,
    required this.packUnit,
    required this.packsizeBarcode,
    required this.packsizeCurrent,
    required this.packsizeOriginal,
    required this.unit,
    required this.editQty,
    required this.contractor,
    required this.isLessThan1Day,
    required this.checkoutPackQty,
    required this.isScrap,
  });

  MaterialReturnScanResponseModelV2.fromJson(Map<String, dynamic> json) {
    try {
      isScrap = "N";
      checkoutDate = json['checkoutDate'];
      checkoutID = json['checkoutID'];
      checkoutIsPartial = json['checkoutIsPartial'] ?? "N";
      checkoutIsReturn = json['checkoutIsReturn'];
      description = json['description'];
      doDetailDrumNo = json['doDetailDrumNo'];
      doDetailID = json['doDetailID'];
      doDetailQty = json['doDetailQty'];
      isCable = json['isCable'];
      isLessThan1Day = json['isLessThan1Day'];
      materialCode = json['material_code'];
      materialId = json['material_id'];
      packUnit = json['packUnit'];
      mrID = json['MrID'].toString();
      packsizeBarcode = json['packsizeBarcode'];
      packsizeCurrent = json['packsizeCurrent'] ?? "";
      packsizeOriginal = json['packsizeOriginal'] ??"";
      unit = json['unit'];
      contractor = ContractorLookupModel.fromJson(json);
      if (mrID == "null") {
        editQty = "";
        isScrap = "N";
      } else {
        editQty = json["MrPackQty"];
        final nbf = NumberFormat("##0", "en_US");
        try {
          editQty = nbf.format(double.parse(editQty));
        } catch (_) {}
      }
      if (json["checkoutIsReturn"] == "Y") {
        editQty = json["MrPackQty"];
        final nbf = NumberFormat("##0", "en_US");
        try {
          editQty = nbf.format(double.parse(editQty));
        } catch (_) {}
      }
      checkoutPackQty = json["checkoutPackQty"] ?? json["checkOutPackQty"];
      try {
        isScrap = json["MrIsScrap"] ?? "N";
      } catch(_) {
      }
    } catch (e) {
      print(e);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['checkoutDate'] = checkoutDate;
    data['checkoutID'] = checkoutID;
    data['checkoutIsPartial'] = checkoutIsPartial;
    data['checkoutIsReturn'] = checkoutIsReturn;
    data['description'] = description;
    data['doDetailDrumNo'] = doDetailDrumNo;
    data['doDetailID'] = doDetailID;
    data['doDetailQty'] = doDetailQty;
    data['isCable'] = isCable;
    data['isLessThan1Day'] = isLessThan1Day;
    data['material_code'] = materialCode;
    data['material_id'] = materialId;
    data['packUnit'] = packUnit;
    data['mrID'] = mrID;
    data['editQty'] = editQty;
    data['checkoutPackQty'] = checkoutPackQty;
    data['packsizeBarcode'] = packsizeBarcode;
    data['packsizeCurrent'] = packsizeCurrent;
    data['packsizeOriginal'] = packsizeOriginal;
    data['unit'] = unit;
    data['contractor'] = jsonEncode(contractor);
    data['MrIsScrap'] = isScrap;
    return data;
  }
}

class MaterialReturnScanResponseModel {
  late String checkoutDate;
  late String checkoutID;
  late String checkoutIsReturn;
  late String description;
  late String doDetailDrumNo;
  late String doDetailID;
  late String doDetailQty;
  late String isCable;
  late String mrID;
  late String materialCode;
  late String materialId;
  late String packUnit;
  late String packsizeBarcode;
  late String packsizeCurrent;
  late String editQty;
  late String packsizeOriginal;
  late String unit;

  MaterialReturnScanResponseModel({
    required this.checkoutDate,
    required this.checkoutID,
    required this.checkoutIsReturn,
    required this.description,
    required this.doDetailDrumNo,
    required this.doDetailID,
    required this.doDetailQty,
    required this.isCable,
    required this.materialCode,
    required this.materialId,
    required this.packUnit,
    required this.packsizeBarcode,
    required this.packsizeCurrent,
    required this.packsizeOriginal,
    required this.unit,
    required this.editQty,
  });

  MaterialReturnScanResponseModel.fromJson(Map<String, dynamic> json) {
    checkoutDate = json['checkoutDate'];
    checkoutID = json['checkoutID'];
    checkoutIsReturn = json['checkoutIsReturn'];
    description = json['description'];
    doDetailDrumNo = json['doDetailDrumNo'];
    doDetailID = json['doDetailID'];
    doDetailQty = json['doDetailQty'];
    isCable = json['isCable'];
    materialCode = json['material_code'];
    materialId = json['material_id'];
    packUnit = json['packUnit'];
    mrID = json['mrID'].toString();
    if (mrID == "null") {
      mrID = json['MrID'].toString();
      editQty = "";
    } else {
      editQty = json["packSizeCurrent"];
    }
    packsizeBarcode = json['packsizeBarcode'];
    packsizeCurrent = json['packsizeCurrent'];
    packsizeOriginal = json['packsizeOriginal'];
    unit = json['unit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['checkoutDate'] = checkoutDate;
    data['checkoutID'] = checkoutID;
    data['checkoutIsReturn'] = checkoutIsReturn;
    data['description'] = description;
    data['doDetailDrumNo'] = doDetailDrumNo;
    data['doDetailID'] = doDetailID;
    data['doDetailQty'] = doDetailQty;
    data['isCable'] = isCable;
    data['material_code'] = materialCode;
    data['material_id'] = materialId;
    data['packUnit'] = packUnit;
    data['mrID'] = mrID;
    data['packsizeBarcode'] = packsizeBarcode;
    data['packsizeCurrent'] = packsizeCurrent;
    data['packsizeOriginal'] = packsizeOriginal;
    data['unit'] = unit;
    return data;
  }
}
