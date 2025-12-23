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
    // debugPrint(json.toString());
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

  String getError() {
    final messages = rejectedDocuments
        .map((e) => e.getError())
        .where((message) => message.isNotEmpty)
        .toList();

    if (messages.isEmpty) {
      return '';
    }

    return messages.join(', ');
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
  final String? invoiceCodeNumber;
  final RejectedDocumentError? error;

  RejectedDocument({
    required this.invoiceCodeNumber,
    required this.error,
  });

  factory RejectedDocument.fromJson(Map<String, dynamic> json) {
    return RejectedDocument(
      invoiceCodeNumber: json['invoiceCodeNumber']?.toString(),
      error: json['error'] != null
          ? RejectedDocumentError.fromJson(
              json['error'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoiceCodeNumber': invoiceCodeNumber,
      'error': error?.toJson(),
    };
  }

  String getError() {
    if (error == null) {
      return '';
    }

    return error?.message ?? '';
  }
}

class RejectedDocumentError {
  final int? code;
  final String? message;
  final String? target;
  final String? propertyPath;
  final List<RejectedDocumentErrorDetail> details;

  RejectedDocumentError({
    required this.code,
    required this.message,
    required this.target,
    required this.propertyPath,
    required this.details,
  });

  factory RejectedDocumentError.fromJson(Map<String, dynamic> json) {
    final codeValue = json['code'];
    final detailsList = (json['details'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((e) => RejectedDocumentErrorDetail.fromJson(e))
        .toList();
    final detailsMessage = detailsList
        .map((detail) => detail.message)
        .where((message) => message != null && message.isNotEmpty)
        .map((message) => message!)
        .join(', ');
    return RejectedDocumentError(
      code: codeValue is int
          ? codeValue
          : int.tryParse(codeValue?.toString() ?? ''),
      message: detailsMessage.isNotEmpty
          ? detailsMessage
          : json['message']?.toString(),
      target: json['target']?.toString(),
      propertyPath: json['propertyPath']?.toString(),
      details: detailsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'target': target,
      'propertyPath': propertyPath,
      'details': details.map((e) => e.toJson()).toList(),
    };
  }
}

class RejectedDocumentErrorDetail {
  final String? code;
  final String? message;
  final String? target;
  final String? propertyPath;
  final dynamic details;

  RejectedDocumentErrorDetail({
    required this.code,
    required this.message,
    required this.target,
    required this.propertyPath,
    required this.details,
  });

  factory RejectedDocumentErrorDetail.fromJson(Map<String, dynamic> json) {
    return RejectedDocumentErrorDetail(
      code: json['code']?.toString(),
      message: json['message']?.toString(),
      target: json['target']?.toString(),
      propertyPath: json['propertyPath']?.toString(),
      details: json['details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'target': target,
      'propertyPath': propertyPath,
      'details': details,
    };
  }
}
