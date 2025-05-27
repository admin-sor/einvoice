import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sor_inventory/repository/merge_repository.dart';

import '../../app/constants.dart';
import '../../widgets/fx_gray_dark_text.dart';
import '../../widgets/fx_green_dark_text.dart';

import 'dart:html' as html;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class FxMergeInfo extends StatelessWidget {
  final bool isFirst;
  final ResponseMergeSave model;
  const FxMergeInfo({
    super.key,
    required this.model,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizeinfo) {
      String packQty = "-";
      try {
        packQty = (double.parse(model.mergeMaterialPackQty)).round().toString();
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
              Row(
                children: [
                  Expanded(
                      child: _LeftColumn(label: "Code", value: model.code)),
                  SizedBox(
                    width: 20,
                  ),
                  InkWell(
                    onTap: () async {
                      final snow = "&t=${DateTime.now().toIso8601String()}";
                      String jSplit;
                      jSplit = model.mergeMaterialID;
                      final url =
                          "https://${Constants.host}/reports/merge_material.php?c=$jSplit$snow";
                      if (kIsWeb) {
                        html.window.open(url, "rpttab");
                        return;
                      }
                      // await Printing.layoutPdf(
                      //   format: const PdfPageFormat(
                      //       60 * PdfPageFormat.mm, 29 * PdfPageFormat.mm),
                      //   name: "Material Barcode",
                      //   onLayout: (fmt) async {
                      //     final response = await Dio().get(
                      //       url,
                      //       options: Options(responseType: ResponseType.bytes),
                      //     );
                      //     return response.data;
                      //   },
                      // );
                    },
                    child: Image.asset(
                      "images/icon_printer.png",
                      height: 27,
                    ),
                  ),
                  SizedBox(width: 20)
                ],
              ),
              _LeftColumn(label: "Barcode", value: model.mergeMaterialBarcode),
              _LeftColumn(label: "Material", value: model.description),
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
