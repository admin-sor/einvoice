
class GroupSummaryModelV2 {
  String? itemCode;
  String? stockTakeID;
  String? stockTakeItemID;
  String? itemName;
  String? scanQty;
  String? bookCount;
  String? storeQty;
  String? totCount;
  String? lastBarcode;

  GroupSummaryModelV2({
    this.itemCode,
    this.itemName,
    this.stockTakeItemID,
    this.stockTakeID,
    this.scanQty,
    this.bookCount,
    this.storeQty,
    this.lastBarcode,
    this.totCount,
  });

  GroupSummaryModelV2.fromJson(Map<String, dynamic> json) {
    itemCode = json['ItemCode'];
    itemName = json['ItemName'];
    stockTakeItemID = json['stockTakeItemID'];
    stockTakeID = json['stockTakeItemStockTakeID'];
    scanQty = json['scanQty'];
    lastBarcode = json['lastBarcode'];
    bookCount = json['bookCount'];
    storeQty = json['storeQty'];
    totCount = json['totCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ItemCode'] = itemCode;
    data['ItemName'] = itemName;
    data['stockTakeItemStockTakeID'] = stockTakeID;
    data['stockTakeItemID'] = stockTakeItemID;
    data['scanQty'] = scanQty;
    data['bookCount'] = bookCount;
    data['storeQty'] = storeQty;
    data['lastBarcode'] = lastBarcode;
    data['totCount'] = totCount;
    return data;
  }
}

class UnGroupSummaryModelV2 {
  String? itemCode;
  String? itemName;
  String? actualQty;
  String? barcode;
  String? bookCount;
  String? storeQty;
  String? totCount;
  String? xID;

  UnGroupSummaryModelV2(
      {this.itemCode,
      this.itemName,
      this.actualQty,
      this.barcode,
      this.bookCount,
      this.storeQty,
      this.totCount,
      this.xID});

  UnGroupSummaryModelV2.fromJson(Map<String, dynamic> json) {
    itemCode = json['ItemCode'];
    itemName = json['ItemName'];
    actualQty = json['actualQty'];
    barcode = json['barcode'];
    bookCount = json['bookCount'];
    storeQty = json['storeQty'];
    totCount = json['totCount'];
    xID = json['xID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ItemCode'] = itemCode;
    data['ItemName'] = itemName;
    data['actualQty'] = actualQty;
    data['barcode'] = barcode;
    data['bookCount'] = bookCount;
    data['storeQty'] = storeQty;
    data['totCount'] = totCount;
    data['xID'] = xID;
    return data;
  }
}

class StockTakeSummaryModel {
  String? itemName;
  String? itemCode;
  String? qty;
  String? bookQty;
  String? checkinAddOnSerialNo;
  String? stockTakeStatusCode;
  String? stockTakeItemPackQty;
  String? isCable;

  StockTakeSummaryModel({
    this.itemName,
    this.checkinAddOnSerialNo,
    this.stockTakeItemPackQty,
    this.stockTakeStatusCode,
    this.isCable,
    this.itemCode,
    this.qty,
    this.bookQty,
  });

  StockTakeSummaryModel.fromJson(Map<String, dynamic> json) {
    itemName = json['ItemName'];
    checkinAddOnSerialNo = json['checkinAddOnSerialNo'];
    stockTakeStatusCode = json['stockTakeStatusCode'];
    stockTakeItemPackQty = json['stockTakeItemPackQty'].toString();
    isCable = json['is_cable'];
    qty = json['qty'];
    itemCode = json['ItemCode'];
    bookQty = json['bookQty'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ItemName'] = itemName;
    data['checkinAddOnSerialNo'] = checkinAddOnSerialNo;
    data['stockTakeStatusCode'] = stockTakeStatusCode;
    data['stockTakeItemPackQty'] = stockTakeItemPackQty;
    return data;
  }
}
