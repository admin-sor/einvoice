class TxInScanModel {
  String? txOutID;
  String? txOutSlipNo;
  String? txOutBarcode;
  String? materialCode;
  String? description;
  String? txOutPackQty;
  String? txOutStoreID;
  String? txOutToStoreID;
  String? txOutAvailablePackQty;
  String? txOutRef;
  String? txOutMaterialID;
  String? txOutRefID;
  String? slipNo;

  TxInScanModel(
      {this.txOutID,
      this.txOutSlipNo,
      this.txOutBarcode,
      this.materialCode,
      this.description,
      this.txOutPackQty,
      this.txOutStoreID,
      this.txOutToStoreID,
      this.txOutAvailablePackQty,
      this.txOutRef,
      this.txOutMaterialID,
      this.txOutRefID,
      this.slipNo});

  TxInScanModel.fromJson(Map<String, dynamic> json) {
    txOutID = json['txOutID'];
    txOutSlipNo = json['txOutSlipNo'];
    txOutBarcode = json['txOutBarcode'];
    materialCode = json['material_code'];
    description = json['description'];
    txOutPackQty = json['txOutPackQty'];
    txOutStoreID = json['txOutStoreID'];
    txOutToStoreID = json['txOutToStoreID'];
    txOutAvailablePackQty = json['txOutAvailablePackQty'];
    txOutRef = json['txOutRef'];
    txOutMaterialID = json['txOutMaterialID'];
    txOutRefID = json['txOutRefID'];
    slipNo = json['slipNo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['txOutID'] = txOutID;
    data['txOutSlipNo'] = txOutSlipNo;
    data['txOutBarcode'] = txOutBarcode;
    data['material_code'] = materialCode;
    data['description'] = description;
    data['txOutPackQty'] = txOutPackQty;
    data['txOutStoreID'] = txOutStoreID;
    data['txOutToStoreID'] = txOutToStoreID;
    data['txOutAvailablePackQty'] = txOutAvailablePackQty;
    data['txOutRef'] = txOutRef;
    data['txOutMaterialID'] = txOutMaterialID;
    data['txOutRefID'] = txOutRefID;
    data['slipNo'] = slipNo;
    return data;
  }
}

class TxInListModel {
  String? materialCode;
  String? description;
  String? txInID;
  String? txInPackQty;
  String? txOutStoreID;
  String? txOutToStoreID;
  String? txInBarcode;
  String? txOutIsReceived;
  String? txOutPackQty;
  String? haveTransaction;
  String? isDeleted;

  TxInListModel(
      {this.materialCode,
      this.description,
      this.txInPackQty,
      this.txInID,
      this.haveTransaction,
      this.txInBarcode,
      this.txOutIsReceived,
      this.txOutStoreID,
      this.txOutToStoreID,
      this.txOutPackQty,
  this.isDeleted = 'N'});

  TxInListModel.fromJson(Map<String, dynamic> json) {
    materialCode = json['material_code'];
    description = json['description'];
    txInID = json['txInID'];
    haveTransaction = json['haveTransaction'];
    txInPackQty = json['txInPackQty'];
    txInBarcode = json['txInBarcode'];
    txOutIsReceived = json['txOutIsReceived'];
    txOutStoreID = json['txOutStoreID'];
    txOutToStoreID = json['txOutToStoreID'];
    txOutPackQty = json['txOutPackQty'];
    isDeleted = json['isDeleted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['material_code'] = materialCode;
    data['description'] = description;
    data['txInPackQty'] = txInPackQty;
    data['txInBarcode'] = txInBarcode;
    data['txOutIsReceived'] = txOutIsReceived;
    data['txOutToStoreID'] = txOutToStoreID;
    data['txOutStoreID'] = txOutStoreID;
    data['txOutPackQty'] = txOutPackQty;
    data['isDeleted'] = isDeleted;
    data['txInID'] = txInID;
    data['haveTransaction'] = haveTransaction;
    return data;
  }
}
