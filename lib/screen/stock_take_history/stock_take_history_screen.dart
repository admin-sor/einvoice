// ignore_for_file: use_key_in_widget_constructors

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sor_inventory/widgets/fx_date_field.dart';

import '../../app/app_route.dart';
import '../../app/constants.dart';
import '../../model/stock_take_history_model.dart';
import '../../model/stock_take_model.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_text_field.dart';
import 'stock_take_history_provider.dart';

class StockTakeHistoryScreen extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final errorMessage = useState("");
    final isInit = useState(true);
    final stockTakeModel = useState<StockTakeModel?>(null);
    final start = useState(0);
    final query = useState("");
    final listHistory = useState<List<StockTakeHistoryModel>>(List.empty());

    if (isInit.value) {
      isInit.value = false;
      Timer(const Duration(milliseconds: 500), () {
        ref.read(stockTakeHistoryProvider.notifier).history(
              start: start.value,
              limit: 100,
              query: query.value,
              queryDate: "",
            );
      });
    }
    final ctrlSearch = useTextEditingController(text: "");
    //final searchDate = useState("");

    ref.listen(stockTakeHistoryProvider, (prev, next) {
      if (next is StockTakeHistoryStateLoading) {
        isLoading.value = true;
        stockTakeModel.value = null;
      } else if (next is StockTakeHistoryStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
        Timer(const Duration(seconds: 3), () {
          errorMessage.value = "";
        });
      } else if (next is StockTakeHistoryStateDone) {
        isLoading.value = false;
        listHistory.value = next.list;
      }
    });
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          "Stock Take History",
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
      body: Column(
        children: [
          const SizedBox(height: Constants.paddingTopContent),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Center(
                child: ResponsiveBuilder(
                  builder: (context, sizeInfo) {
                    double screenWidth = MediaQuery.of(context).size.width;
                    if (sizeInfo.isDesktop || sizeInfo.isTablet) {
                      //screenWidth = screenWidth / 2;
                    }
                    //screenWidth = 600;
                    return SizedBox(
                      width: screenWidth,
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          _SearchNameDateWidget(ctrlSearch: ctrlSearch),
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
                          Expanded(
                            child: SizedBox(
                              child: ListView.builder(
                                itemCount: listHistory.value.length,
                                itemBuilder: (context, idx) {
                                  final StockTakeHistoryModel history =
                                      listHistory.value[idx];
                                  Color color =
                                      Constants.greenLight.withOpacity(0.4);
                                  if (idx % 2 == 0) {
                                    color = Colors.white;
                                  }
                                  String latestMark = "";
                                  if (idx == 0) {
                                    color = Colors.yellow.withOpacity(0.2);
                                    latestMark = " (latest)";
                                  }
                                  return InkWell(
                                    onTap: () {
                                      final args = {
                                        "id": history.stockTakeID,
                                        "date": history.stockTakeDate,
                                        "isCurrent":
                                            history.stockTakeIsOpen == "Y",
                                      };
                                      Navigator.of(context).pushNamed(
                                          stockTakeSummaryRoute,
                                          arguments: args);
                                    },
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 20),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: color,
                                          border: Border.all(
                                            color: Constants.greenDark,
                                          ),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(5)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Started : ${(history.stockTakeDate ?? "").formatDate()}$latestMark",
                                                      style: const TextStyle(
                                                        color:
                                                            Constants.greenDark,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                      "Ended : ${(history.stockTakeCloseDate ?? "").formatDate()}",
                                                      style: const TextStyle(
                                                        color:
                                                            Constants.greenDark,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                      "Created by : ${history.userName ?? ""}",
                                                      style: const TextStyle(
                                                        color:
                                                            Constants.greenDark,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  const Text(
                                                    "Discrepancy",
                                                    style: TextStyle(
                                                      color:
                                                          Constants.greenDark,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        history.diff ?? "",
                                                        style: TextStyle(
                                                          color: (history
                                                                      .diff !=
                                                                  "0")
                                                              ? Constants.red
                                                              : Constants
                                                                  .greenDark,
                                                          fontSize: 40,
                                                        ),
                                                      ),
                                                      Text(
                                                        " count",
                                                        style: TextStyle(
                                                          color: Constants
                                                              .greyDark,
                                                          fontSize: 18,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchNameDateWidget extends HookConsumerWidget {
  const _SearchNameDateWidget({
    Key? key,
    required this.ctrlSearch,
    //required this.searchDate,
  }) : super(key: key);

  final TextEditingController ctrlSearch;
  //final ValueNotifier<String> searchDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double width = (MediaQuery.of(context).size.width - 100) / 2;
    if (width < 300) {
      if (MediaQuery.of(context).size.width < 600) {
        width = (MediaQuery.of(context).size.width - 10) / 2;
      }
    }
    final searchDate = useState(DateTime.now());

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: FxTextField(
            ctrl: ctrlSearch,
            hintText: "Name",
            onSubmitted: (val) {
              String paramDate = "";
              try {
                /* DateTime xDate = */
                /*     DateFormat("dd MMM yyyy").parse(searchDate.value); */
                paramDate = DateFormat("yyyy-MM-dd").format(searchDate.value);
              } catch (_) {}
              ref.read(stockTakeHistoryProvider.notifier).history(
                    start: 0,
                    limit: 100,
                    query: ctrlSearch.text,
                    queryDate: paramDate,
                  );
            },
            width: width,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FxDateField(
              dateValue: searchDate.value,
              firstDate: searchDate.value.subtract(const Duration(days: 100)),
              lastDate: DateTime.now(),
              onDateChange: (dt) {
                searchDate.value = dt;
                String paramDate = "";
                try {
                  /* DateTime xDate = */
                  /*     DateFormat("dd MMM yyyy").parse(searchDate.value); */
                  paramDate = DateFormat("yyyy-MM-dd").format(searchDate.value);
                } catch (_) {}
                ref.read(stockTakeHistoryProvider.notifier).history(
                      start: 0,
                      limit: 100,
                      query: ctrlSearch.text,
                      queryDate: paramDate,
                    );
              }),
        ),

        /* Expanded( */
        /*   child: Container( */
        /*     height: 40, */
        /*     width: width, */
        /*     decoration: BoxDecoration( */
        /*       border: Border.all( */
        /*         color: Constants.greenDark, */
        /*       ), */
        /*       borderRadius: const BorderRadius.all( */
        /*         Radius.circular(10), */
        /*       ), */
        /*     ), */
        /*     child: Row( */
        /*       mainAxisAlignment: MainAxisAlignment.center, */
        /*       crossAxisAlignment: CrossAxisAlignment.center, */
        /*       children: [ */
        /*         const SizedBox( */
        /*           width: 10, */
        /*         ), */
        /*         Expanded( */
        /*           child: Text( */
        /*             searchDate.value, */
        /*             style: const TextStyle(color: Constants.greenDark), */
        /*           ), */
        /*         ), */
        /*         const SizedBox( */
        /*           width: 10, */
        /*         ), */
        /*         InkWell( */
        /*           child: Image.asset( */
        /*             "images/icon_calendar.png", */
        /*             width: 32, */
        /*             height: 32, */
        /*           ), */
        /*           onTap: () async { */
        /*             DateTime initialDate = DateTime.now(); */
        /*             if (searchDate.value != "") { */
        /*               try { */
        /*                 initialDate = */
        /*                     DateFormat("d MMM yyyy").parse(searchDate.value); */
        /*               } catch (_) {} */
        /*             } */
        /*             DateTime firstDate = */
        /*                 initialDate.subtract(const Duration(days: 100)); */
        /*             final choosenDate = await showDatePicker( */
        /*               context: context, */
        /*               initialDate: initialDate, */
        /*               firstDate: firstDate, */
        /*               lastDate: DateTime.now(), */
        /*             ); */
        /*             if (choosenDate != null) { */
        /*               searchDate.value = */
        /*                   DateFormat("dd MMM yyyy").format(choosenDate); */
        /*               final paramSearchDate = */
        /*                   DateFormat("yyyy-MM-dd").format(choosenDate); */
        /*               ref.read(stockTakeHistoryProvider.notifier).history( */
        /*                     start: 0, */
        /*                     limit: 100, */
        /*                     query: ctrlSearch.text, */
        /*                     queryDate: paramSearchDate, */
        /*                   ); */
        /*             } */
        /*           }, */
        /*         ), */
        /*         const SizedBox( */
        /*           width: 10, */
        /*         ), */
        /*       ], */
        /*     ), */
        /*   ), */
        /* ) */
      ],
    );
  }
}

extension on String {
  String formatDate() {
    if (this == "") return "";
    final mydf = DateFormat("yyyy-MM-dd HH:mm:ss");
    final sdf = DateFormat("dd MMM yyy hh:mm a");
    try {
      return sdf.format(mydf.parse(this));
    } catch (_) {
      return this;
    }
  }
}
