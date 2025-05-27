class ScreenGroupModel {
  String? screenGroupID;
  String? screenGroupIcon;
  String? screenGroupIsActive;
  String? screenGroupName;
  String? screenGroupOrder;
  String? screenGroupRoute;

  ScreenGroupModel({
    this.screenGroupID,
    this.screenGroupIcon,
    this.screenGroupIsActive,
    this.screenGroupName,
    this.screenGroupOrder,
    this.screenGroupRoute,
  });

  ScreenGroupModel.fromJson(Map<String, dynamic> json) {
    screenGroupID = json['ScreenGroupID'];
    screenGroupIcon = json['ScreenGroupIcon'];
    screenGroupIsActive = json['ScreenGroupIsActive'];
    screenGroupName = json['ScreenGroupName'];
    screenGroupOrder = json['ScreenGroupOrder'];
    screenGroupRoute = json['ScreenGroupRoute'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ScreenGroupID'] = this.screenGroupID;
    data['ScreenGroupIcon'] = this.screenGroupIcon;
    data['ScreenGroupIsActive'] = this.screenGroupIsActive;
    data['ScreenGroupName'] = this.screenGroupName;
    data['ScreenGroupOrder'] = this.screenGroupOrder;
    data['ScreenGroupRoute'] = this.screenGroupRoute;
    return data;
  }
}
