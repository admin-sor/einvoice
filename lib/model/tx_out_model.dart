class TxOutListModel {
  String? txOutID;
  String? code;
  String? description;
  String? qty;
  String? originQty;
  String? barcode;
  String? isReceived;
  String? storeID;
  String? storeToID;
  String? isDeleted;
  String? isLess1Day;

  TxOutListModel({
    this.txOutID,
    this.code,
    this.description,
    this.qty,
    this.originQty,
    this.barcode,
    this.isReceived,
    this.storeID,
    this.storeToID,
    this.isDeleted = "N",
    this.isLess1Day = "N"
  });

  factory TxOutListModel.fromJson(Map<String, dynamic> json) {
    return TxOutListModel(
      txOutID: json['txOutID'],
      code: json['material_code'],
      description: json['description'],
      qty: json['txOutPackQty'],
      originQty: json['txOutPackQty'],
      barcode: json['txOutBarcode'],
      isReceived: json['txOutIsReceived'],
      storeID: json['txOutStoreID'],
      storeToID: json['txOutToStoreID'],
      isDeleted: json['isDeleted'],
      isLess1Day: json['isLess1Day'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'txOutID': txOutID,
      'material_code': code,
      'description': description,
      'txOutPackQty': qty,
      'originQty': originQty,
      'txOutBarcode': barcode,
      'txOutIsReceived': isReceived,
      'txOutStoreID': storeID,
      'txOutToStoreID': storeToID,
      'isDeleted': isDeleted,
      'isLess1Day': isLess1Day,
    };
  }
}

class TxOutScanResponseModel {
  String? slipNo;
  String? message;
  String? storeID;
}
