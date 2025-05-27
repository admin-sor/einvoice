
class LoginModel {
  Branch? branch;
  Company? company;
  User? user;
  String? token;

  LoginModel({
    this.branch,
    this.company,
    this.user,
    this.token,
  });

  LoginModel.fromJson(Map<String, dynamic> json) {
    branch = json['branch'] != null ? Branch.fromJson(json['branch']) : null;
    company =
        json['company'] != null ? Company.fromJson(json['company']) : null;
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    token = json["token"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (branch != null) {
      data['branch'] = branch!.toJson();
    }
    if (company != null) {
      data['company'] = company!.toJson();
    }
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (token != null) {
      data['token'] = token;
    }
    return data;
  }
}

class Branch {
  String? branchAddress;
  String? branchCompanyID;
  String? branchEmail;
  String? branchID;
  String? branchIsActive;
  String? branchName;
  String? branchPIC;
  String? branchPhone;

  Branch({
    this.branchAddress,
    this.branchCompanyID,
    this.branchEmail,
    this.branchID,
    this.branchIsActive,
    this.branchName,
    this.branchPIC,
    this.branchPhone,
  });

  Branch.fromJson(Map<String, dynamic> json) {
    branchAddress = json['branchAddress'];
    branchCompanyID = json['branchCompanyID'];
    branchEmail = json['branchEmail'];
    branchID = json['branchID'];
    branchIsActive = json['branchIsActive'];
    branchName = json['branchName'];
    branchPIC = json['branchPIC'];
    branchPhone = json['branchPhone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['branchAddress'] = branchAddress;
    data['branchCompanyID'] = branchCompanyID;
    data['branchEmail'] = branchEmail;
    data['branchID'] = branchID;
    data['branchIsActive'] = branchIsActive;
    data['branchName'] = branchName;
    data['branchPIC'] = branchPIC;
    data['branchPhone'] = branchPhone;
    return data;
  }
}

class Company {
  String? companyAddress;
  String? companyEmail;
  String? companyID;
  String? companyIsActive;
  String? companyName;
  String? companyNo;
  String? companyPIC;
  String? companyPhone;

  Company({
    this.companyAddress,
    this.companyEmail,
    this.companyID,
    this.companyIsActive,
    this.companyName,
    this.companyNo,
    this.companyPIC,
    this.companyPhone,
  });

  Company.fromJson(Map<String, dynamic> json) {
    companyAddress = json['companyAddress'];
    companyEmail = json['companyEmail'];
    companyID = json['companyID'];
    companyIsActive = json['companyIsActive'];
    companyName = json['companyName'];
    companyNo = json['companyNo'];
    companyPIC = json['companyPIC'];
    companyPhone = json['companyPhone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['companyAddress'] = companyAddress;
    data['companyEmail'] = companyEmail;
    data['companyID'] = companyID;
    data['companyIsActive'] = companyIsActive;
    data['companyName'] = companyName;
    data['companyNo'] = companyNo;
    data['companyPIC'] = companyPIC;
    data['companyPhone'] = companyPhone;
    return data;
  }
}

class User {
  String? userBranchID;
  String? userEmail;
  String? userID;
  String? userIsActive;
  String? userLogin;
  String? userName;
  String? userPhone;

  User({
    this.userBranchID,
    this.userEmail,
    this.userID,
    this.userIsActive,
    this.userLogin,
    this.userName,
    this.userPhone,
  });

  User.fromJson(Map<String, dynamic> json) {
    userBranchID = json['userBranchID'];
    userEmail = json['userEmail'];
    userID = json['userID'];
    userIsActive = json['userIsActive'];
    userLogin = json['userLogin'];
    userName = json['userName'];
    userPhone = json['userPhone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userBranchID'] = userBranchID;
    data['userEmail'] = userEmail;
    data['userID'] = userID;
    data['userIsActive'] = userIsActive;
    data['userLogin'] = userLogin;
    data['userName'] = userName;
    data['userPhone'] = userPhone;
    return data;
  }
}
