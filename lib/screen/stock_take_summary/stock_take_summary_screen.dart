import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/constants.dart';
import '../../model/stock_take_summary_model.dart';
import '../../model/stock_take_summary_status_model.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_text_field.dart';
import '../stock_take/stock_take_current_provider.dart';
import 'stock_take_summary_provider.dart';
import 'stock_take_summary_status_provider.dart';

class StockTakeSummaryScreen extends HookConsumerWidget {
  final String id;
  final String date;
  final bool isCurrent;

  const StockTakeSummaryScreen({
    Key? key,
    required this.id,
    required this.date,
    required this.isCurrent,
  }) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final errorMessage = useState("");
    final isInit = useState(true);
    final listSummaryMatCode =
        useState<List<GroupSummaryModelV2>>(List.empty());
    final listSummary = useState<List<StockTakeSummaryModel>>(List.empty());
    final listStatus = useState<List<StockTakeSummaryStatusModel>>([
      StockTakeSummaryStatusModel(id: 1, code: "0", name: "All"),
    ]);
    final isMaterialCodeSelected = useState<bool>(false);
    final isSerialNoSelected = useState<bool>(true);
    final selectedStatus = useState<StockTakeSummaryStatusModel>(
      StockTakeSummaryStatusModel(id: 1, code: "0", name: "All"),
    );

    if (isInit.value) {
      isInit.value = false;
      Timer(const Duration(milliseconds: 500), () {
        ref
            .read(stockTakeSummaryStatusProvider.notifier)
            .list(isCurrent: isCurrent);
      });
    }
    final ctrlSearch = useTextEditingController(text: "");

    ref.listen(stockTakeSummaryStatusProvider, (prev, next) {
      if (next is StockTakeSummaryStatusStateLoading) {
        isLoading.value = true;
      } else if (next is StockTakeSummaryStatusStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
        Timer(const Duration(seconds: 3), () {
          errorMessage.value = "";
        });
      } else if (next is StockTakeSummaryStatusStateDone) {
        isLoading.value = false;
        listStatus.value = next.list;
        if (next.list.isNotEmpty) {
          selectedStatus.value = next.list[0];
        } else {
          listStatus.value = [
            StockTakeSummaryStatusModel(id: 1, code: "0", name: "All")
          ].toList();
          selectedStatus.value =
              StockTakeSummaryStatusModel(id: 1, code: "0", name: "All");
        }
        ref.read(stockTakeSummaryProvider.notifier).summary(
              stockTakeID: isCurrent ? "0" : id,
              status: selectedStatus.value.code ?? "0",
              query: ctrlSearch.text,
            );
      }
    });

    ref.listen(stockTakeCurrentProvider, (prev, next) {
      if (next is StockTakeCurrentStateLoading) {
        isLoading.value = true;
      } else if (next is StockTakeCurrentStateError) {
        errorMessage.value = next.message;
        isLoading.value = false;
        Timer(const Duration(seconds: 3), () {
          errorMessage.value = "";
        });
      } else if (next is StockTakeCurrentStateDone) {
        isLoading.value = false;
        listSummaryMatCode.value = next.list;
      }
    });

    ref.listen(stockTakeSummaryProvider, (prev, next) {
      if (next is StockTakeSummaryStateLoading) {
        isLoading.value = true;
      } else if (next is StockTakeSummaryStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
        Timer(const Duration(seconds: 3), () {
          errorMessage.value = "";
        });
      } else if (next is StockTakeSummaryStateDone) {
        isLoading.value = false;
        listSummary.value = next.list;
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          "Stock Take Summary",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Constants.colorAppBar,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Constants.colorAppBar,
        ),
        leading: InkWell(
          child: const Icon(Icons.arrow_back),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          Builder(
            builder: (context) => InkWell(
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Image.asset(
                  "images/icon_menu.png",
                  width: 36,
                  height: 36,
                ),
              ),
              onTap: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: const EndDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        child: Center(
          child: ResponsiveBuilder(
            builder: (context, sizeInfo) {
              double screenWidth = MediaQuery.of(context).size.width;
              if (sizeInfo.isDesktop || sizeInfo.isTablet) {
                //screenWidth = screenWidth / 2;
              }
              //screenWidth = 700;
              return SizedBox(
                width: screenWidth,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    _TabButton(
                      isMaterialCode: isMaterialCodeSelected.value,
                      isSerialNo: isSerialNoSelected.value,
                      onChange: (val) {
                        if (val == "SerialNo") {
                          isMaterialCodeSelected.value = false;
                          isSerialNoSelected.value = true;
                        } else {
                          isSerialNoSelected.value = false;
                          isMaterialCodeSelected.value = true;
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    if (isMaterialCodeSelected.value)
                      _ListItemHeaderMatCode(
                        listSummary: listSummaryMatCode,
                      ),
                    if (isMaterialCodeSelected.value)
                      const Divider(
                        color: Constants.greenDark,
                      ),
                    if (isMaterialCodeSelected.value)
                      Expanded(
                        child: _ListItemSummaryMatCode(
                          listSummary: listSummaryMatCode,
                        ),
                      ),
                    if (isSerialNoSelected.value)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: FxTextField(
                              ctrl: ctrlSearch,
                              hintText: "Item / Serial No.",
                              onSubmitted: (val) {
                                ref
                                    .read(stockTakeSummaryProvider.notifier)
                                    .summary(
                                        query: ctrlSearch.text,
                                        status:
                                            selectedStatus.value.code ?? "0",
                                        stockTakeID: id);
                              },
                              width: 300,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: _DropDownStatus(
                              isReady: listStatus.value.isNotEmpty,
                              list: listStatus.value,
                              selected: selectedStatus.value,
                              onChange: (status) {
                                selectedStatus.value = status!;
                                ref
                                    .read(stockTakeSummaryProvider.notifier)
                                    .summary(
                                        stockTakeID: id,
                                        status: status.code ?? "0",
                                        query: ctrlSearch.text);
                              },
                              width: 290,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 10),
                    if (errorMessage.value != "")
                      Text(
                        errorMessage.value,
                        style: const TextStyle(color: Constants.red),
                      ),
                    if (isLoading.value)
                      const Center(
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    if (isSerialNoSelected.value)
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              "Item (${listSummary.value.length})",
                              style: const TextStyle(
                                fontSize: Constants.fontMediumSize,
                                color: Constants.greenDark,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          const Expanded(
                            flex: 3,
                            child: Text(
                              "Serial No.",
                              style: TextStyle(
                                fontSize: Constants.fontMediumSize,
                                color: Constants.greenDark,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const Expanded(
                            child: Text(
                              "Scan Qty",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: Constants.fontMediumSize,
                                color: Constants.greenDark,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const Expanded(
                            child: Text(
                              "Store Qty",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: Constants.fontMediumSize,
                                color: Constants.greenDark,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const Expanded(
                            flex: 2,
                            child: Text(
                              "Discrepancy",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: Constants.fontMediumSize,
                                color: Constants.greenDark,
                              ),
                            ),
                          )
                        ],
                      ),
                    if (isSerialNoSelected.value)
                      const Divider(
                        color: Constants.greenDark,
                      ),
                    if (isSerialNoSelected.value)
                      Expanded(
                        child: _ListItemSummary(listSummary: listSummary),
                      ),
                    const SizedBox(
                      height: 10,
                    ),
                    // _ReportButton(
                    //   title: "Print",
                    //   color: Constants.greenDark,
                    //   maxWidth: 400,
                    //   press: () async {
                    //     String url =
                    //         ("${Constants.reportUrl}stock_take.php?id=$id&status=${selectedStatus.value.code ?? "0"}&qry=${Uri.encodeFull(ctrlSearch.text)}");
                    //     try {
                    //       await Printing.layoutPdf(
                    //         name: "Material Issue",
                    //         onLayout: (fmt) async {
                    //           final response = await Dio().get(
                    //             url,
                    //             options:
                    //                 Options(responseType: ResponseType.bytes),
                    //           );
                    //           return response.data;
                    //         },
                    //       );
                    //     } catch (e) {
                    //       errorMessage.value = "Error printing StockTake";
                    //       Timer(Duration(seconds: 3), () {
                    //         errorMessage.value = "";
                    //       });
                    //     }
                    //   },
                    // )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ListItemSummary extends StatelessWidget {
  const _ListItemSummary({
    Key? key,
    required this.listSummary,
  }) : super(key: key);

  final ValueNotifier<List<StockTakeSummaryModel>> listSummary;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: listSummary.value.length,
      itemBuilder: (context, idx) {
        final item = listSummary.value[idx];
        Color color = Constants.greenLight;
        if (idx % 2 == 0) {
          color = Colors.white;
        }
        Color textColor = Colors.black;
        double bookQty = 0;
        double actualQty = 0;
        double discrepency = 0;

        switch (item.stockTakeStatusCode) {
          case "2":
            textColor = Constants.greenDark;
            bookQty = 1;
            actualQty = 0;
            discrepency = -1;
            break;
          case "1.2":
            textColor = Colors.red;
            bookQty = 0;
            actualQty = 1;
            discrepency = 1;
            break;
          case "1":
            bookQty = 1;
            actualQty = 1;
            discrepency = 0;
            break;
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  item.itemName ?? " --- ",
                  style: TextStyle(
                    color: textColor,
                    fontSize: Constants.fontMediumSize,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                flex: 3,
                child: Text(
                  item.checkinAddOnSerialNo ?? " -- ",
                  style: TextStyle(
                    color: textColor,
                    fontSize: Constants.fontMediumSize,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: Text(
                  actualQty.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: Constants.fontMediumSize,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: Text(
                  bookQty.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: Constants.fontMediumSize,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                flex: 2,
                child: Text(
                  discrepency.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: Constants.fontMediumSize,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

extension on String? {
  String formatDate() {
    if (this == "") return "";
    final mydf = DateFormat("yyyy-MM-dd HH:mm:ss");
    final sdf = DateFormat("ddMMMyyy");
    try {
      return "${" (" + sdf.format(mydf.parse(this ?? ""))})";
    } catch (_) {
      return this ?? "";
    }
  }
}

class _DropDownStatus extends StatelessWidget {
  final double? width;
  final bool isReady;
  final List<StockTakeSummaryStatusModel> list;
  final StockTakeSummaryStatusModel? selected;
  final void Function(StockTakeSummaryStatusModel?)? onChange;

  const _DropDownStatus({
    Key? key,
    this.width,
    required this.isReady,
    required this.list,
    required this.selected,
    required this.onChange,
  }) : super(key: key);

  Color getColor(StockTakeSummaryStatusModel item) {
    if (item.code == "0") return Colors.blue;
    if (item.code == "2") return Constants.greenDark; //Constants.red;
    if (item.code == "1") return Colors.black; // Constants.greenDark;
    if (item.code == "1.2") return Colors.red;
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 400,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
        border: Border.all(
          color: Constants.greenDark,
        ),
      ),
      child: (isReady && selected != null && list.isNotEmpty)
          ? DropdownButton<StockTakeSummaryStatusModel>(
              icon: Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Image.asset(
                  "images/icon_triangle_down.png",
                  height: 24,
                ),
              ),
              hint: const Center(
                child: Text(
                  "Status",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                  ),
                ),
              ),
              value: selected,
              underline: const SizedBox.shrink(),
              isExpanded: true,
              onChanged: onChange,
              items: list
                  .map<DropdownMenuItem<StockTakeSummaryStatusModel>>((item) =>
                      DropdownMenuItem<StockTakeSummaryStatusModel>(
                        value: item,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Center(
                            child: Text(
                              item.name ?? "-",
                              style: TextStyle(
                                color: getColor(item),
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            )
          : Padding(
              padding: const EdgeInsets.all(
                10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(),
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Loading Status",
                    style: TextStyle(
                      fontSize: 20,
                      color: Constants.greenDark,
                    ),
                  )
                ],
              ),
            ),
    );
  }
}

class _ReportButton extends StatelessWidget {
  final VoidCallback? press;
  final String title;
  final Color color;
  final double maxWidth;
  const _ReportButton(
      {Key? key,
      required this.press,
      this.title = 'Print Report',
      this.color = Colors.orange,
      this.maxWidth = 200.0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.loose(Size(maxWidth, 200)),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: OutlinedButton(
            style: ButtonStyle(
              alignment: Alignment.center,
              backgroundColor: MaterialStateColor.resolveWith(
                (states) {
                  Color resultColor = color;
                  for (var element in states) {
                    if (element == MaterialState.disabled) {
                      resultColor = Colors.grey.shade400;
                    }
                  }
                  return resultColor;
                },
              ),
            ),
            onPressed: press,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            )),
      ),
    );
  }
}

class _TabButton extends HookWidget {
  final bool isSerialNo;
  final bool isMaterialCode;
  final void Function(String)? onChange;

  const _TabButton(
      {this.isSerialNo = false, required this.isMaterialCode, this.onChange});

  @override
  Widget build(BuildContext context) {
    final isLoading = useState(false);
    return Container(
      color: Colors.grey.shade300,
      height: 40,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onChange == null
                  ? null
                  : () {
                      if (onChange != null) onChange!("SerialNo");
                    },
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color:
                          isMaterialCode ? Colors.grey.shade300 : Colors.white,
                      border: isSerialNo
                          ? Border.all(color: Constants.greenDark)
                          : null,
                      borderRadius: isMaterialCode
                          ? null
                          : const BorderRadius.only(
                              /* bottomRight: Radius.circular(10), */
                              topRight: Radius.circular(10),
                              topLeft: Radius.circular(10),
                            ),
                    ),
                    child: Center(
                      child: Text(
                        "List by serial no",
                        style: TextStyle(
                          fontSize: 16,
                          color: isMaterialCode
                              ? Constants.greyDark
                              : Constants.greenDark,
                          fontWeight:
                              isSerialNo ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  isMaterialCode
                      ? Container(
                          height: 0.4,
                          width: double.infinity,
                          color: Constants.greenDark,
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1.0),
                          child: Container(
                            height: 10,
                            width: double.infinity,
                            color: Colors.white,
                          ),
                        ),
                ],
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: onChange == null
                  ? null
                  : () {
                      if (onChange != null) onChange!("MaterialCode");
                    },
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSerialNo
                            ? Colors.grey.shade300
                            : isMaterialCode
                                ? Colors.white
                                : Constants.greenLight,
                        border: isMaterialCode
                            ? Border.all(color: Constants.greenDark)
                            : null,
                        borderRadius: isMaterialCode
                            ? const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              )
                            : null,
                      ),
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              "List by material code",
                              style: TextStyle(
                                fontSize: 16,
                                color: isMaterialCode
                                    ? Constants.greenDark
                                    : Constants.greyDark,
                                fontWeight: isSerialNo
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                            if (isLoading.value)
                              const Positioned(
                                right: 20,
                                child: SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  isSerialNo
                      ? Container(
                          height: 0.4,
                          width: double.infinity,
                          color: Constants.greenDark,
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1.0),
                          child: Container(
                            height: 10,
                            width: double.infinity,
                            color: Colors.white,
                          ),
                        ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _ListItemHeaderMatCode extends StatelessWidget {
  const _ListItemHeaderMatCode({
    super.key,
    required this.listSummary,
  });

  final ValueNotifier<List<GroupSummaryModelV2>> listSummary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            "Item (${listSummary.value.length})",
            style: const TextStyle(
              fontSize: Constants.fontMediumSize,
              color: Constants.greenDark,
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        const Expanded(
          flex: 2,
          child: Text(
            "Mat Code",
            style: TextStyle(
              fontSize: Constants.fontMediumSize,
              color: Constants.greenDark,
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        const SizedBox(
          width: 50,
          child: Text(
            "Scan Qty",
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: Constants.fontMediumSize,
              color: Constants.greenDark,
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        // const SizedBox(
        //   width: 50,
        //   child: Text(
        //     "Book Count",
        //     textAlign: TextAlign.right,
        //     style: TextStyle(
        //       fontSize: Constants.fontMediumSize,
        //       color: Constants.greenDark,
        //     ),
        //   ),
        // ),
        // const SizedBox(
        //   width: 10,
        // ),
        // const SizedBox(
        //   width: 50,
        //   child: Text(
        //     "Tot Count",
        //     textAlign: TextAlign.right,
        //     style: TextStyle(
        //       fontSize: Constants.fontMediumSize,
        //       color: Constants.greenDark,
        //     ),
        //   ),
        // ),
        // SizedBox(
        //   width: 10,
        // ),
        const SizedBox(
          width: 50,
          child: Text(
            "Store Qty",
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: Constants.fontMediumSize,
              color: Constants.greenDark,
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        const SizedBox(
          width: 50,
          child: Text(
            "Diff",
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: Constants.fontMediumSize,
              color: Constants.greenDark,
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        const Expanded(
          child: Text(
            "Adjustment",
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: Constants.fontMediumSize,
              color: Constants.greenDark,
            ),
          ),
        ),
      ],
    );
  }
}

class _ListItemSummaryMatCode extends HookConsumerWidget {
  const _ListItemSummaryMatCode({
    Key? key,
    required this.listSummary,
  }) : super(key: key);

  final ValueNotifier<List<GroupSummaryModelV2>> listSummary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: listSummary.value.length,
      itemBuilder: (context, idx) {
        final item = listSummary.value[idx];
        Color color = Constants.greenLight.withOpacity(0.2);
        if (idx % 2 == 0) {
          color = Colors.white;
        }
        if (idx == 0) {
          color = Constants.firstYellow;
        }
        Color textColor = Colors.black;

        double storeQty = double.parse(item.storeQty ?? "0");
        double bookCount = double.parse(item.bookCount ?? "0");
        double totCount = double.parse(item.totCount ?? "0");
        double scannedQty = double.parse(item.scanQty ?? "0");
        double diffQty = scannedQty - storeQty;
        final nbf = NumberFormat("##0");
        return Container(
          color: color,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        item.itemName ?? " --- ",
                        style: TextStyle(
                          color: textColor,
                          fontSize: Constants.fontMediumSize,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        item.itemCode ?? "",
                        style: TextStyle(
                          color: textColor,
                          fontSize: Constants.fontMediumSize,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      width: 50,
                      child: Text(
                        nbf.format(scannedQty),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: textColor,
                          fontSize: Constants.fontMediumSize,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    // SizedBox(
                    //   width: 50,
                    //   child: Text(
                    //     nbf.format(bookCount),
                    //     textAlign: TextAlign.right,
                    //     style: TextStyle(
                    //       color: textColor,
                    //       fontSize: Constants.fontMediumSize,
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(
                    //   width: 10,
                    // ),
                    // SizedBox(
                    //   width: 50,
                    //   child: Text(
                    //     nbf.format(totCount),
                    //     textAlign: TextAlign.right,
                    //     style: TextStyle(
                    //       color: textColor,
                    //       fontSize: Constants.fontMediumSize,
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(
                    //   width: 10,
                    // ),
                    SizedBox(
                      width: 50,
                      child: Text(
                        nbf.format(storeQty),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: textColor,
                          fontSize: Constants.fontMediumSize,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      width: 50,
                      child: Text(
                        nbf.format(diffQty),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: textColor,
                          fontSize: Constants.fontMediumSize,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        "",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Constants.red,
                          fontSize: Constants.fontMediumSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
