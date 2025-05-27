import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:pdf/pdf.dart';
import 'dart:html' as html;

import '../app/constants.dart';
import '../model/do_model.dart';
import '../screen/do/delete_detail_provider.dart';
import 'fx_button.dart';
import 'fx_gray_dark_text.dart';
import 'fx_green_dark_text.dart';

class FxDoDetail extends HookConsumerWidget {
  final DoDetailModel model;
  final VoidCallback? onDelete;
  final bool isFirst;
  const FxDoDetail({
    super.key,
    required this.model,
    this.onDelete,
    this.isFirst = false,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inDeleteMode = useState(false);
    final isLoading = useState(false);
    final errorMessage = useState("");
    ref.listen(deleteDetailProvider, (prev, next) {
      if (next is DeleteDetailStateLoading) {
        isLoading.value = true;
      } else if (next is DeleteDetailStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
        Timer(const Duration(seconds: 3), () {
          errorMessage.value = "";
        });
      } else if (next is DeleteDetailStateDone) {
        inDeleteMode.value = false;
      }
    });
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
        packQty = double.parse(model.doDetailPackQty).round().toString();
      } catch (_) {}
      return MediaQuery.removePadding(
        context: context,
        removeLeft: true,
        removeRight: true,
        removeTop: true,
        removeBottom: true,
        child: Card(
          color: isFirst ? Constants.firstYellow : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: inDeleteMode.value
                  ? Colors.red.shade500.withOpacity(0.5)
                  : Constants.greenDark.withOpacity(0.5),
            ),
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
                          maxWidth: 100,
                          title: "Cancel",
                          onPress: isLoading.value
                              ? null
                              : () {
                                  inDeleteMode.value = false;
                                },
                        ),
                        if (isLoading.value)
                          const SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(),
                          ),
                        FxButton(
                          maxWidth: 100,
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
                          _LeftColumn(label: "PO", value: model.doDetailPoNo),
                          _LeftColumn(label: "Name", value: model.description),
                          _LeftColumn(
                              label: "Mat Code", value: model.materialCode),
                          if (model.isCable == "Y")
                            _LeftColumn(
                                label:
                                    model.isCable == "Y" ? "Drum No" : "Serial",
                                value: model.doDetailDrumNo),
                          _QtyColumn(
                            label: "Pack Size",
                            value: packQty,
                            unit: "${model.unit}/${model.packUnit}",
                          ),
                          _QtyColumn(
                            label: "Total Item",
                            value: itemQty,
                            unit: model.packUnit,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _QtyColumn(
                                  label: "Total Qty",
                                  value: totalQty,
                                  unit: model.unit,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Positioned(
                        top: 3,
                        right: 3,
                        child: InkWell(
                          child: Image.asset(
                            "images/icon_printer.png",
                            height: 27,
                          ),
                          onTap: () async {
                            final snow =
                                "&t=${DateTime.now().toIso8601String()}";
                            final url =
                                "https://${Constants.host}/reports/sor_inv_material.php?x=${model.doDetailEntryID}$snow";
                            if (kIsWeb) {
                              html.window.open(url, "rpttab");
                              return;
                            }
                            await Printing.layoutPdf(
                              format: const PdfPageFormat(
                                  60 * PdfPageFormat.mm, 29 * PdfPageFormat.mm),
                              name: "Material Barcode",
                              onLayout: (fmt) async {
                                final response = await Dio().get(
                                  url,
                                  options:
                                      Options(responseType: ResponseType.bytes),
                                );
                                return response.data;
                              },
                            );
                          },
                        ),
                      ),
                      if (model.isAllowDelete != "Y")
                        Positioned(
                          bottom: 3,
                          right: 3,
                          child: Text(textFromDeleteFlag(model.isAllowDelete)),
                        ),
                      if (model.isAllowDelete == "Y")
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
        ),
      );
    });
  }

  String textFromDeleteFlag(String flag) {
    String sflag = "";
    if (flag.contains("M")) {
      if (sflag != "") sflag += "/";
      sflag += "merged";
    }
    if (flag.contains("S")) {
      if (sflag != "") sflag += "/";
      sflag += "splitted";
    }
    if (flag.contains("I")) {
      if (sflag != "") sflag += "/";
      sflag += "issued";
    }
    return "Material already $sflag";
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
