/*
{
  "submissionUid": "E3BNZRC5GBKWJ19H91XBJZYJ10",
  "acceptedDocuments": [
    {
      "uuid": "NYEA8PYC59ED2WJB91XBJZYJ10",
      "invoiceCodeNumber": "Inv-6862160103749"
    }
  ],
  "rejectedDocuments": []
}
*/
import 'package:flutter/cupertino.dart';

class LhdnSubmitResponseModel {
  final String submissionUid;
  final String invoiceNo;
  final String invoiceDate;
  final List<AcceptedDocument> acceptedDocuments;
  final List<RejectedDocument> rejectedDocuments;

  LhdnSubmitResponseModel({
    required this.submissionUid,
    required this.acceptedDocuments,
    required this.rejectedDocuments,
    required this.invoiceNo,
    required this.invoiceDate,
  });

  factory LhdnSubmitResponseModel.fromJson(Map<String, dynamic> json) {
    debugPrint(json.toString());
    return LhdnSubmitResponseModel(
      invoiceNo: json["invoiceNo"],
      invoiceDate: json["invoiceDate"],
      submissionUid: json['submissionUid'] as String,
      acceptedDocuments: (json["data"]['acceptedDocuments'] as List<dynamic>)
          .map((e) => AcceptedDocument.fromJson(e as Map<String, dynamic>))
          .toList(),
      rejectedDocuments: (json["data"]['rejectedDocuments'] as List<dynamic>)
          .map((e) => RejectedDocument.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'submissionUid': submissionUid,
      'invoiceDate': invoiceDate,
      'invoiceNo': invoiceNo,
      'acceptedDocuments': acceptedDocuments.map((e) => e.toJson()).toList(),
      'rejectedDocuments': rejectedDocuments.map((e) => e.toJson()).toList(),
    };
  }
}

class AcceptedDocument {
  final String uuid;
  final String invoiceCodeNumber;

  AcceptedDocument({
    required this.uuid,
    required this.invoiceCodeNumber,
  });

  factory AcceptedDocument.fromJson(Map<String, dynamic> json) {
    return AcceptedDocument(
      uuid: json['uuid'] as String,
      invoiceCodeNumber: json['invoiceCodeNumber'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'invoiceCodeNumber': invoiceCodeNumber,
    };
  }
}

class RejectedDocument {
  RejectedDocument();

  factory RejectedDocument.fromJson(Map<String, dynamic> json) {
    return RejectedDocument();
  }

  Map<String, dynamic> toJson() {
    return {};
  }
}
