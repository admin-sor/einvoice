import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../app/app_route.dart';
import '../../app/constants.dart';
import '../../model/stock_take_model.dart';
import '../../widgets/end_drawer.dart';
import '../home/home_screen.dart';
import 'stock_take_get_provider.dart';

class StockTakeMenuScreen extends HookConsumerWidget {
  const StockTakeMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final errorMessage = useState("");
    final isInit = useState(true);
    final stockTakeModel = useState<StockTakeModel?>(null);
    const cardLeftColor = Constants.greenDark;
    const cardBgColor = Colors.white;
    double width = 300;

    if (isInit.value) {
      isInit.value = false;
      Timer(const Duration(milliseconds: 500), () {
        ref.read(stockTakeGetProvider.notifier).getOpenEvent();
      });
    }
    ref.listen(stockTakeGetProvider, (prev, next) {
      if (next is StockTakeGetStateLoading) {
        isLoading.value = true;
      } else if (next is StockTakeGetStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
      } else if (next is StockTakeGetStateDone) {
        isLoading.value = false;
        if (next.event != null) {
          stockTakeModel.value = next.event;
        } else {
          stockTakeModel.value = null;
        }
      }
    });
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          "Stock Take",
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
      endDrawer: EndDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: ResponsiveBuilder(
                builder: (context, sizeInfo) {
                  double screenWidth = MediaQuery.of(context).size.width;
                  if (sizeInfo.isDesktop || sizeInfo.isTablet) {
                    //screenWidth = screenWidth / 2;
                  }
                  String currentStockTake = "";
                  if (stockTakeModel.value != null) {
                    DateFormat sdf = DateFormat("d MMM yyyy h:ma");
                    DateFormat mysdf = DateFormat("yyyy-MM-dd HH:mm:ss");
                    currentStockTake =
                        "Created by ${stockTakeModel.value?.userName ?? " unknown "}";
                    currentStockTake += " on ";
                    if (stockTakeModel.value?.stockTakeDate != null) {
                      currentStockTake +=
                          " ${sdf.format(mysdf.parse(stockTakeModel.value!.stockTakeDate!))}";
                    }
                  }
                  return SizedBox(
                    width: screenWidth,
                    height: MediaQuery.of(context).size.height,
                    child: SingleChildScrollView(
                      child: (isLoading.value)
                          ? const Center(
                              child: SizedBox(
                                width: 32,
                                height: 32,
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : Column(
                              children: [
                                const SizedBox(height: 40),
                                if (stockTakeModel.value?.stockTakeID == null)
                                  CardMenu(
                                      cardBgColor: cardBgColor,
                                      cardLeftColor: cardLeftColor,
                                      width: width,
                                      title: "NEW STOCK TAKE",
                                      image: "images/stock_out.png",
                                      subTitle: "",
                                      onPress: () {
                                        Navigator.of(context).pushNamed(
                                            stockTakeRoute,
                                            arguments: false);
                                      },
                                      description: ""),
                                if (stockTakeModel.value?.stockTakeID == null)
                                  const SizedBox(height: 20),
                                if (stockTakeModel.value?.stockTakeID != null)
                                  CardMenu(
                                    cardBgColor: Constants.yellowLight,
                                    cardLeftColor: cardLeftColor,
                                    width: width,
                                    title: "CONTINUE STOCK TAKE",
                                    image: "images/stock_in.png",
                                    subTitle:
                                        "Please complete current stock take to enable stock in & stock out",
                                    onPress: () {
                                      Navigator.of(context).pushNamed(
                                          stockTakeRoute,
                                          arguments: true);
                                    },
                                    description: "",
                                  ),
                                if (stockTakeModel.value?.stockTakeID != null)
                                  const SizedBox(height: 20),
                                CardMenu(
                                    cardBgColor: cardBgColor,
                                    cardLeftColor: cardLeftColor,
                                    width: width,
                                    title: "STOCK HISTORY",
                                    image: "images/new_stock.png",
                                    subTitle: "",
                                    onPress: () {
                                      Navigator.of(context)
                                          .pushNamed(stockTakeHistoryRoute);
                                    },
                                    description: ""),
                                const SizedBox(height: 20),
                              ],
                            ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
