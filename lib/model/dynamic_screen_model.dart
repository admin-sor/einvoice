
class DynamicScreenModel {
  String? screenID;
  String? screenCode;
  String? screenTitle;
  String? screenImage;
  String? screenColor;
  String? screenBgColor;
  String? screenDescription;
  String? screenRoute;
  String? screenOrderNo;

  DynamicScreenModel(
      {this.screenID,
      this.screenCode,
      this.screenTitle,
      this.screenImage,
      this.screenColor,
      this.screenBgColor,
      this.screenDescription,
      this.screenRoute,
      this.screenOrderNo});

  DynamicScreenModel.fromJson(Map<String, dynamic> json) {
    screenID = json['screenID'];
    screenCode = json['screenCode'];
    screenTitle = json['screenTitle'];
    screenImage = json['screenImage'];
    screenColor = json['screenColor'];
    screenBgColor = json['screenBgColor'];
    screenDescription = json['screenDescription'];
    screenRoute = json['screenRoute'];
    screenOrderNo = json['screenOrderNo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['screenID'] = screenID;
    data['screenCode'] = screenCode;
    data['screenTitle'] = screenTitle;
    data['screenImage'] = screenImage;
    data['screenColor'] = screenColor;
    data['screenBgColor'] = screenBgColor;
    data['screenDescription'] = screenDescription;
    data['screenRoute'] = screenRoute;
    data['screenOrderNo'] = screenOrderNo;
    return data;
  }
}
