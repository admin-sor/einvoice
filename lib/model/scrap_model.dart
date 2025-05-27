class ScrapModel {
  String? description;
  String? isCable;
  String? materialCode;
  String? materialId;
  String? packUnit;
  String? scrapBarcode;
  String? scrapDate;
  String? scrapDisposeRemark;
  String? scrapDisposeSlipNo;
  String? scrapDrumNo;
  String? scrapID;
  String? scrapIsDisposed;
  String? scrapPackQty;
  String? unit;

  ScrapModel(
      {this.description,
      this.isCable,
      this.materialCode,
      this.materialId,
      this.packUnit,
      this.scrapBarcode,
      this.scrapDate,
      this.scrapDisposeRemark,
      this.scrapDisposeSlipNo,
      this.scrapDrumNo,
      this.scrapID,
      this.scrapIsDisposed,
      this.scrapPackQty,
      this.unit});

  ScrapModel.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    isCable = json['isCable'];
    materialCode = json['material_code'];
    materialId = json['material_id'];
    packUnit = json['packUnit'];
    scrapBarcode = json['scrapBarcode'];
    scrapDate = json['scrapDate'];
    scrapDisposeRemark = json['scrapDisposeRemark'];
    scrapDisposeSlipNo = json['scrapDisposeSlipNo'];
    scrapDrumNo = json['scrapDrumNo'];
    scrapID = json['scrapID'];
    scrapIsDisposed = json['scrapIsDisposed'];
    scrapPackQty = json['scrapPackQty'];
    unit = json['unit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['description'] = description;
    data['isCable'] = isCable;
    data['material_code'] = materialCode;
    data['material_id'] = materialId;
    data['packUnit'] = packUnit;
    data['scrapBarcode'] = scrapBarcode;
    data['scrapDate'] = scrapDate;
    data['scrapDisposeRemark'] = scrapDisposeRemark;
    data['scrapDisposeSlipNo'] = scrapDisposeSlipNo;
    data['scrapDrumNo'] = scrapDrumNo;
    data['scrapID'] = scrapID;
    data['scrapIsDisposed'] = scrapIsDisposed;
    data['scrapPackQty'] = scrapPackQty;
    data['unit'] = unit;
    return data;
  }
}

