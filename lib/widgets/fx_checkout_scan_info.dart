import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../app/constants.dart';
import '../model/checkout_scan_response_model.dart';
import 'fx_gray_dark_text.dart';
import 'fx_green_dark_text.dart';

class FxCheckoutScanInfo extends StatelessWidget {
  final bool isFirst;
  final CheckoutScanResponseModel model;
  const FxCheckoutScanInfo({
    super.key,
    required this.model,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizeinfo) {
      String itemQty = "-";
      try {
        itemQty = (double.parse(model.doDetailQty)).round().toString();
      } catch (_) {}

      String totalQty = "-";
      try {
        totalQty = (double.parse(model.doDetailQty) *
                double.parse(model.doDetailPackQty))
            .round()
            .toString();
      } catch (e) {
        /* print(e.toString()); */
      }
      String packQty = "-";
      try {
        packQty = (double.parse(model.doDetailQty) *
                double.parse(model.doDetailPackQty))
            .round()
            .toString();
      } catch (_) {}
      return Card(
        color: isFirst ? Constants.firstYellow : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
              color: isFirst
                  ? Colors.yellow.shade500.withOpacity(0.5)
                  : Constants.greenDark.withOpacity(0.5)),
        ),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              _LeftColumn(label: "Barcode", value: model.doDetailBarcode),
              _LeftColumn(label: "Code", value: model.materialCode),
              _LeftColumn(label: "Material", value: model.description),
              if (model.isCable == "Y")
                _LeftColumn(
                    label: (model.isCable == "Y") ? "Drum No" : "Serial",
                    value: model.doDetailDrumNo),
              _QtyColumn(
                label: "Pack Size",
                value: packQty,
                unit: "${model.unit}/${model.packUnit}",
              ),
              _QtyColumn(
                  label: "Total Item", value: itemQty, unit: model.packUnit),
              _QtyColumn(label: "Total Qty", value: totalQty, unit: model.unit),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    });
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
            width: 80,
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
          width: 80,
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
