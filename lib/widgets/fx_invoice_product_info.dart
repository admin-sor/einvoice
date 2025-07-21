import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sor_inventory/model/invoice_v2_model.dart';

import '../app/constants.dart';
import '../screen/invoice_v2/delete_detail_provider.dart';
import 'fx_button.dart';
import 'fx_gray_dark_text.dart';
import 'fx_green_dark_text.dart';

class FxInvoiceProductInfo extends HookConsumerWidget {
  final bool isFirst;
  final InvoiceDetailModel model;
  final VoidCallback? onDelete;
  const FxInvoiceProductInfo(
      {super.key, required this.model, this.isFirst = false, this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nbf = NumberFormat("#,###,##0");
    final nbfDec = NumberFormat("#,###,##0.00");
    final nbfDecThree = NumberFormat("#,###,##0.00");
    String itemQty = "-";
    try {
      itemQty = (double.parse(model.invoiceDetailQty)).round().toString();
    } catch (_) {}

    String price = "-";
    try {
      price = nbfDecThree.format(double.parse(model.invoiceDetailPrice));
    } catch (_) {}

    String totalPrice = "-";
    try {
      totalPrice = nbfDec.format(double.parse(model.invoiceDetailPrice) *
          double.parse(model.invoiceDetailQty));
    } catch (_) {}

    final inDeleteMode = useState(false);
    final errorMessage = useState("");
    final isLoading = useState(false);
    ref.listen(deleteDetailProvider, (prev, next) {
      if (next is DeleteDetailStateLoading) {
        isLoading.value = true;
      } else if (next is DeleteDetailStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
        Timer(const Duration(seconds: 3), () {
          //errorMessage.value = "";
        });
      } else if (next is DeleteDetailStateDone) {
        isLoading.value = false;
        inDeleteMode.value = false;
      }
    });
    return Card(
      color: isFirst ? Constants.firstYellow : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
            color: inDeleteMode.value
                ? Constants.red
                : isFirst
                    ? Colors.yellow.shade500.withOpacity(0.5)
                    : Constants.greenDark.withOpacity(0.5)),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: inDeleteMode.value
            ? Column(children: [
                const FxGrayDarkText(title: "Confirm Delete Product?"),
                const SizedBox(height: 10),
                FxGrayDarkText(title: model.evProductCode),
                const SizedBox(height: 5),
                FxGrayDarkText(title: model.evProductDescription),
                const SizedBox(height: 10),
                if (errorMessage.value != "")
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      errorMessage.value,
                      style: const TextStyle(
                        color: Constants.red,
                      ),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FxButton(
                      maxWidth: 150,
                      title: "Cancel",
                      onPress: isLoading.value
                          ? null
                          : () {
                              inDeleteMode.value = false;
                              errorMessage.value = "";
                            },
                    ),
                    if (isLoading.value)
                      const SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(),
                      ),
                    FxButton(
                      maxWidth: 150,
                      title: "Delete",
                      color: Constants.red,
                      onPress: isLoading.value ? null : onDelete,
                    )
                  ],
                ),
              ])
            : Stack(
                children: [
                  Column(
                    children: [
                      _LeftColumn(label: "Code", value: model.evProductCode),
                      _LeftColumn(
                          label: "Description",
                          value: model.evProductDescription),
                      _LeftColumn(label: "UOM", value: model.invoiceDetailUnit),
                      _QtyColumn(label: "Unit Price", value: "RM $price"),
                      _QtyColumn(
                        label: "Total Item",
                        value: itemQty,
                      ),
                      _QtyColumn(
                          label: "Total Amount", value: "RM $totalPrice"),
                    ],
                  ),
                  if (onDelete != null)
                    Positioned(
                      bottom: 3,
                      right: 3,
                      child: InkWell(
                        child: Image.asset(
                          "images/icon_delete.png",
                          height: 27,
                        ),
                        onTap: () async {
                          inDeleteMode.value = true;
                        },
                      ),
                    )
                ],
              ),
      ),
    );
  }
}

class _LeftColumn extends StatelessWidget {
  final String label;
  final String value;

  const _LeftColumn({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
            width: 100,
            child: FxGreenDarkText(
              title: label,
            )),
        const FxGreenDarkText(title: ":"),
        const SizedBox(width: 5),
        Expanded(
          child: FxGrayDarkText(
            title: value,
            maxLines: 2,
          ),
        ),
        const SizedBox(width: 30),
      ],
    );
  }
}

class _QtyColumn extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;

  const _QtyColumn({
    Key? key,
    required this.label,
    required this.value,
    this.unit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: FxGreenDarkText(
            title: label,
          ),
        ),
        const FxGreenDarkText(title: ":"),
        const SizedBox(width: 5),
        FxGrayDarkText(
          title: value,
        ),
        const SizedBox(width: 5),
        if (unit != null) FxGrayDarkText(title: unit ?? ""),
      ],
    );
  }
}
