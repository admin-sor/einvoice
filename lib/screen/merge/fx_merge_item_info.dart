import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sor_inventory/repository/merge_repository.dart';

import '../../app/constants.dart';
import '../../widgets/fx_gray_dark_text.dart';
import '../../widgets/fx_green_dark_text.dart';

class FxMergeItemInfo extends StatelessWidget {
  final bool isFirst;
  final ResponseMergeScan model;
  const FxMergeItemInfo({
    super.key,
    required this.model,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizeinfo) {
      String packQty = "-";
      try {
        packQty = (double.parse(model.packSizeCurrent)).round().toString();
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
              _LeftColumn(label: "Code", value: model.code),
              _LeftColumn(label: "Barcode", value: model.barcode),
              _LeftColumn(label: "Material", value: model.description),
              _LeftColumn(
                  label: (model.isCable == "Y") ? "Drum No" : "Serial",
                  value: model.drumNo),
              _QtyColumn(
                label: "Pack Size",
                value: packQty,
                unit: "${model.unit}/${model.packUnit}",
              ),
              // _QtyColumn( label: "Total Item", value: "1.00", unit: model.packUnit),
              _QtyColumn(label: "Total Qty", value: packQty, unit: model.unit),
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
