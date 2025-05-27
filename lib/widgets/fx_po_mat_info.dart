import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../app/constants.dart';
import '../model/po_response_model.dart';
import '../screen/po/delete_po_provider.dart';
import 'fx_button.dart';
import 'fx_gray_dark_text.dart';
import 'fx_green_dark_text.dart';

class FxPoMaterialInfo extends HookConsumerWidget {
  final bool isFirst;
  final PoDetailResponseModel model;
  final VoidCallback? onDelete;
  const FxPoMaterialInfo(
      {super.key, required this.model, this.isFirst = false, this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String itemQty = "-";
    try {
      itemQty = (double.parse(model.poDetailQty)).round().toString();
    } catch (_) {}

    String totalQty = "-";
    final nbf = NumberFormat("#,###,##0");
    final nbfDec = NumberFormat("#,###,##0.00");
    final nbfDecThree = NumberFormat("#,###,##0.000");
    try {
      totalQty = nbf.format(double.parse(model.poDetailQty) *
          double.parse(model.poDetailPackQty));
    } catch (e) {
      /* print(e.toString()); */
    }
    String packQty = "-";
    try {
      packQty = nbf.format(double.parse(model.poDetailPackQty));
    } catch (_) {}
    String price = "-";
    try {
      price = nbfDecThree.format(double.parse(model.poDetailPrice));
    } catch (_) {}

    String totalPrice = "-";
    try {
      totalPrice = nbfDec.format(double.parse(model.poDetailPrice) *
          double.parse(model.poDetailQty) *
          double.parse(model.poDetailPackQty));
    } catch (_) {}

    final inDeleteMode = useState(false);
    final errorMessage = useState("");
    final isLoading = useState(false);
    ref.listen(deletePoProvider, (prev, next) {
      if (next is DeletePoStateLoading) {
        isLoading.value = true;
      } else if (next is DeletePoStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
        Timer(const Duration(seconds: 3), () {
          //errorMessage.value = "";
        });
      } else if (next is DeletePoStateDone) {
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
                const FxGrayDarkText(title: "Confirm Delete Material ?"),
                const SizedBox(height: 10),
                FxGrayDarkText(title: model.materialCode),
                const SizedBox(height: 5),
                FxGrayDarkText(title: model.description),
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
                      _LeftColumn(label: "Code", value: model.materialCode),
                      _LeftColumn(label: "Material", value: model.description),
                      _QtyColumn(
                        label: "Pack Size",
                        value: packQty,
                        unit: "${model.unit}/${model.packUnit}",
                      ),
                      _QtyColumn(
                          label: "Total Item",
                          value: itemQty,
                          unit: model.packUnit),
                      _QtyColumn(
                          label: "Total Qty",
                          value: totalQty,
                          unit: model.unit),
                      _QtyColumn(label: "Unit Price", value: "RM $price"),
                      _QtyColumn(label: "Total Price", value: "RM $totalPrice"),
                      // _QtyColumn(
                      //   label: "Delivery Time",
                      //   value: model.leadTime,
                      //   unit: model.leadTime != "" ? " days" : "",
                      // ),
                    ],
                  ),
                  if (model.isReceived == "P")
                    Positioned(
                      bottom: 3,
                      right: 3,
                      child: FxGreenDarkText(
                          title: "Material is partially received"),
                    ),
                  if (model.isReceived == "F")
                    Positioned(
                      bottom: 3,
                      right: 3,
                      child:
                          FxGreenDarkText(title: "Material is fully received"),
                    ),
                  if (model.isReceived == "N")
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
                    ),
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
