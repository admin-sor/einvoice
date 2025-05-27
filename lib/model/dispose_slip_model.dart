class DisposeSlipModel {
  String? scrapDisposeDate;
  String? scrapDisposeRemark;
  String? scrapDisposeSlipNo;
  String? storeName;

  DisposeSlipModel(
      {this.scrapDisposeDate,
      this.scrapDisposeRemark,
      this.scrapDisposeSlipNo,
      this.storeName});

  DisposeSlipModel.fromJson(Map<String, dynamic> json) {
    scrapDisposeDate = json['scrapDisposeDate'];
    scrapDisposeRemark = json['scrapDisposeRemark'];
    scrapDisposeSlipNo = json['scrapDisposeSlipNo'];
    storeName = json['storeName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['scrapDisposeDate'] = scrapDisposeDate;
    data['scrapDisposeRemark'] = scrapDisposeRemark;
    data['scrapDisposeSlipNo'] = scrapDisposeSlipNo;
    data['storeName'] = storeName;
    return data;
  }
}
