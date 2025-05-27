class MaterialStatusResponseModel {
  late String actualQty;
  late String actualAmount;
  late String bookAmount;
  late String bookQty;
  late String boqAmount;
  late String boqQty;
  late String code;
  late String description;
  late String doAmount;
  late String doQty;
  late String issueAmount;
  late String issueQty;
  late String poAmount;
  late String poQty;
  late String price;
  late String returnAmount;
  late String returnQty;

  MaterialStatusResponseModel(
      {required this.actualAmount,
      required this.actualQty,
      required this.bookAmount,
      required this.bookQty,
      required this.boqAmount,
      required this.boqQty,
      required this.code,
      required this.description,
      required this.doAmount,
      required this.doQty,
      required this.issueAmount,
      required this.issueQty,
      required this.poAmount,
      required this.poQty,
      required this.price,
      required this.returnAmount,
      required this.returnQty});

  MaterialStatusResponseModel.fromJson(Map<String, dynamic> json) {
    actualAmount = json['actual_amount'].toString();
    actualQty = json['actual_qty'].toString();
    bookAmount = json['book_amount'].toString();
    bookQty = json['book_qty'].toString();
    boqAmount = json['boq_amount'].toString();
    boqQty = json['boq_qty'].toString();
    code = json['code'].toString();
    description = json['description'];
    doAmount = json['do_amount'].toString();
    doQty = json['do_qty'].toString();
    issueAmount = json['issue_amount'].toString();
    issueQty = json['issue_qty'].toString();
    poAmount = json['po_amount'].toString();
    poQty = json['po_qty'].toString();
    price = json['price'].toString();
    returnAmount = json['return_amount'].toString();
    returnQty = json['return_qty'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['actual_amount'] = actualAmount;
    data['actual_qty'] = actualQty;
    data['book_amount'] = bookAmount;
    data['book_qty'] = bookQty;
    data['boq_amount'] = boqAmount;
    data['boq_qty'] = boqQty;
    data['code'] = code;
    data['description'] = description;
    data['do_amount'] = doAmount;
    data['do_qty'] = doQty;
    data['issue_amount'] = issueAmount;
    data['issue_qty'] = issueQty;
    data['po_amount'] = poAmount;
    data['po_qty'] = poQty;
    data['price'] = price;
    data['return_amount'] = returnAmount;
    data['return_qty'] = returnQty;
    return data;
  }
}
