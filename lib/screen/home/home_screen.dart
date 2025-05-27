import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sor_inventory/model/stock_take_model.dart';
import 'package:sor_inventory/provider/screen_provider.dart';
import 'package:sor_inventory/screen/merge/merge_item_provider.dart';

import '../../app/constants.dart';
import '../../widgets/end_drawer.dart';
import '../list_do/selected_do_provider.dart';

class HomeScreen extends HookConsumerWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  HomeScreen({Key? key}) : super(key: key);
  final isDev = true;
  final isDev2 = false;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const cardBgColor = Colors.white;
    const cardLeftColor = Constants.greenDark;
    double width = 300;
    final stockTakeModel = useState<StockTakeModel?>(null);
    ref.read(mergeItemProvider.notifier).state = List.empty();
    final listScreen = ref.read(screenProvider);

    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        endDrawer: const EndDrawer(isHome: true),
        appBar: AppBar(
          backgroundColor: Constants.colorAppBarBg,
          centerTitle: true,
          title: Text(
            "${Constants.appTitle} ${Constants.appSubTitle}",
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Constants.colorAppBar,
            ),
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
          iconTheme: const IconThemeData(color: Constants.colorAppBar),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              if (listScreen.isEmpty)
                const SizedBox(
                    width: 40, height: 40, child: CircularProgressIndicator()),
              ...listScreen.map((s) {
                if (s.screenCode == "ST") {
                  if (stockTakeModel.value?.stockTakeID != null) {
                    return SizedBox.shrink();
                  }
                  return CardMenu(
                    cardBgColor: cardBgColor,
                    cardLeftColor: (s.screenColor == "0xff008a8d")
                        ? Constants.greenDark
                        : Constants.yellowDark,
                    width: width,
                    title: s.screenTitle ?? "",
                    image: s.screenImage ?? "",
                    onPress: (s.screenRoute == null || s.screenRoute == "")
                        ? null
                        : () {
                            ref.read(selectedDoProvider.notifier).state = null;
                            Navigator.of(context)
                                .pushNamed(s.screenRoute!, arguments: false);
                          },
                    description: s.screenDescription ?? "",
                  );
                }
                if (s.screenCode == "CST") {
                  if (stockTakeModel.value?.stockTakeID == null) {
                    return SizedBox.shrink();
                  }
                  return CardMenu(
                    cardBgColor: cardBgColor,
                    cardLeftColor: (s.screenColor == "0xff008a8d")
                        ? Constants.greenDark
                        : Constants.yellowDark,
                    width: width,
                    title: s.screenTitle ?? "",
                    image: s.screenImage ?? "",
                    onPress: (s.screenRoute == null || s.screenRoute == "")
                        ? null
                        : () {
                            ref.read(selectedDoProvider.notifier).state = null;
                            Navigator.of(context)
                                .pushNamed(s.screenRoute!, arguments: true);
                          },
                    description: s.screenDescription ?? "",
                  );
                }
                return CardMenu(
                  cardBgColor: cardBgColor,
                  cardLeftColor: (s.screenColor == "0xff008a8d")
                      ? Constants.greenDark
                      : Constants.yellowDark,
                  width: width,
                  title: s.screenTitle ?? "",
                  image: s.screenImage ?? "",
                  onPress: (s.screenRoute == null || s.screenRoute == "")
                      ? null
                      : () {
                          ref.read(selectedDoProvider.notifier).state = null;
                          Navigator.of(context).pushNamed(s.screenRoute!);
                        },
                  description: s.screenDescription ?? "",
                );
              }),
              // CardMenu(
              //   cardBgColor: cardBgColor,
              //   cardLeftColor: cardLeftColor,
              //   width: width,
              //   title: "Disposal Summary",
              //   image: "images/icon_stock.png",
              //   onPress: () {
              //     Navigator.of(context).pushNamed(disposeMaterialSummaryRoute);
              //   },
              //   description: "Dispose material",
              // ),
              // CardMenu(
              //   cardBgColor: cardBgColor,
              //   cardLeftColor: cardLeftColor,
              //   width: width,
              //   title: "DO Summary",
              //   image: "images/icon_summary.png",
              //   onPress: () {
              //     Navigator.of(context).pushNamed(doListRoute);
              //   },
              //   description: "List of goods received from vendors",
              // ),
              // if (isDev)
              //   CardMenu(
              //     cardBgColor: cardBgColor,
              //     cardLeftColor: cardLeftColor,
              //     width: width,
              //     title: "Material Issue",
              //     image: "images/mi.png",
              //     onPress: () {
              //       Navigator.of(context).pushNamed(checkoutRoute);
              //     },
              //     description: "Issue goods to contractor",
              //   ),
              // if (isDev)
              //   CardMenu(
              //     cardBgColor: cardBgColor,
              //     cardLeftColor: cardLeftColor,
              //     width: width,
              //     title: "Material Issue Summary",
              //     image: "images/mi_sum.png",
              //     onPress: () {
              //       Navigator.of(context).pushNamed(checkoutSummaryRoute);
              //     },
              //     description: "Issue goods to contractor",
              //   ),
              // if (isDev)
              //   CardMenu(
              //     cardBgColor: cardBgColor,
              //     cardLeftColor: cardLeftColor,
              //     width: width,
              //     title: "Material Return",
              //     image: "images/mr.png",
              //     onPress: () {
              //       Navigator.of(context).pushNamed(mrAutoRoute);
              //     },
              //     description: "Receive returned goods from contractor",
              //   ),
              // if (isDev)
              //   CardMenu(
              //     cardBgColor: cardBgColor,
              //     cardLeftColor: cardLeftColor,
              //     width: width,
              //     title: "Material Return Manual",
              //     image: "images/mr.png",
              //     onPress: () {
              //       Navigator.of(context).pushNamed(mrManualRoute);
              //     },
              //     description: "Receive returned goods from contractor",
              //   ),
              // if (isDev)
              //   CardMenu(
              //     cardBgColor: cardBgColor,
              //     cardLeftColor: cardLeftColor,
              //     width: width,
              //     title: "Material Return Summary",
              //     image: "images/mr_sum.png",
              //     onPress: () {
              //       Navigator.of(context).pushNamed(mrSummaryRoute);
              //     },
              //     description: "Receive returned goods from contractor",
              //   ),
              // CardMenu(
              //   cardBgColor: cardBgColor,
              //   cardLeftColor: cardLeftColor,
              //   width: width,
              //   title: "Material Return",
              //   image: "images/icon_return.png",
              //   onPress: () {
              //     Navigator.of(context).pushNamed(materialReturnRoute);
              //   },
              //   description: "Receive returned goods from contractor",
              // ),
              // CardMenu(
              //   cardBgColor: cardBgColor,
              //   cardLeftColor: cardLeftColor,
              //   width: width,
              //   title: "Material Return Summary",
              //   image: "images/icon_return.png",
              //   onPress: () {
              //     Navigator.of(context).pushNamed(mrSummaryRoute);
              //   },
              //   description: "Receive returned goods from contractor",
              // ),
              // CardMenu(
              //   cardBgColor: cardBgColor,
              //   cardLeftColor: cardLeftColor,
              //   width: width,
              //   title: "Material Status",
              //   image: "images/icon_status.png",
              //   onPress: () async {
              //     Navigator.of(context).pushNamed(materialStatusRoute);
              //   },
              //   description: "List of all materials and transaction figures",
              // ),
              // if (stockTakeModel.value?.stockTakeID == null)
              //   CardMenu(
              //       cardBgColor: cardBgColor,
              //       cardLeftColor: cardLeftColor,
              //       width: width,
              //       title: "Stock Take",
              //       image: "images/icon_stocktake.png",
              //       subTitle: "",
              //       onPress: () {
              //         Navigator.of(context)
              //             .pushNamed(stockTakeRoute, arguments: false);
              //       },
              //       description: "Physical count of materials in stores"),
              // if (stockTakeModel.value?.stockTakeID != null)
              //   CardMenu(
              //     cardBgColor: Constants.yellowLight,
              //     cardLeftColor: cardLeftColor,
              //     width: width,
              //     title: "Continue Stock Take",
              //     image: "images/icon_stocktake.png",
              //     subTitle:
              //         "Please complete current stock take to enable stock in & stock out",
              //     onPress: () {
              //       Navigator.of(context)
              //           .pushNamed(stockTakeRoute, arguments: true);
              //     },
              //     description: "",
              //   ),
              // CardMenu(
              //     cardBgColor: cardBgColor,
              //     cardLeftColor: cardLeftColor,
              //     width: width,
              //     title: "Stock History",
              //     image: "images/icon_history.png",
              //     subTitle: "",
              //     onPress: () {
              //       Navigator.of(context).pushNamed(stockTakeHistoryRoute);
              //     },
              //     description: "List of stock take"),
              // CardMenu(
              //   cardBgColor: cardBgColor,
              //   cardLeftColor: cardLeftColor,
              //   width: width,
              //   title: "Material Maintenance",
              //   image: "images/icon_maintenance.png",
              //   onPress: () {
              //     Navigator.of(context).pushNamed(materialMdRoute);
              //   },
              //   description: "Material information management",
              // ),
              // if (isDev)
              //   CardMenu(
              //     cardBgColor: cardBgColor,
              //     cardLeftColor: cardLeftColor,
              //     width: width,
              //     title: "Split Material",
              //     image: "images/split_icon.png",
              //     onPress: () {
              //       Navigator.of(context).pushNamed(splitMaterialRoute);
              //     },
              //     description: "Repack single material into multiple packs",
              //   ),
              // if (isDev)
              //   CardMenu(
              //     cardBgColor: cardBgColor,
              //     cardLeftColor: cardLeftColor,
              //     width: width,
              //     title: "Merge Materials",
              //     image: "images/merge_icon.png",
              //     onPress: () {
              //       Navigator.of(context).pushNamed(mergeMaterialRoute);
              //     },
              //     description: "Repack multiple materials into single pack",
              //   ),
              // if (isDev)
              //   CardMenu(
              //     cardBgColor: cardBgColor,
              //     cardLeftColor: cardLeftColor,
              //     width: width,
              //     title: "Split/Merge Summary",
              //     image: "images/icon_split_merge_sum.png",
              //     onPress: () {
              //       Navigator.of(context).pushNamed(listBarcodeRoute);
              //     },
              //     description: "List of split and merged materials",
              //   ),
              // CardMenu(
              //   cardBgColor: cardBgColor,
              //   cardLeftColor: Constants.yellowDark,
              //   width: width,
              //   title: "Purchase Order (PO)",
              //   image: "images/icon_do_list.png",
              //   onPress: () {
              //     Navigator.of(context).pushNamed(poRoute);
              //   },
              //   description: "Create PO to Vendor",
              // ),
              // CardMenu(
              //   cardBgColor: cardBgColor,
              //   cardLeftColor: Constants.yellowDark,
              //   width: width,
              //   title: "PO Summary",
              //   image: "images/icon_summary.png",
              //   onPress: () {
              //     Navigator.of(context).pushNamed(poSummaryRoute);
              //   },
              //   description: "List of PO",
              // ),
              // CardMenu(
              //   cardBgColor: cardBgColor,
              //   cardLeftColor: Constants.yellowDark,
              //   width: width,
              //   title: "Vendor Maintenance",
              //   image: "images/vendor.png",
              //   onPress: () async {
              //     Navigator.of(context).pushNamed(vendorRoute);
              //   },
              //   description: "Vendor Information Management",
              // ),
            ],
          ),
        ));
  }
}

class CardMenu extends StatelessWidget {
  const CardMenu({
    Key? key,
    required this.cardBgColor,
    required this.cardLeftColor,
    required this.width,
    required this.title,
    this.subTitle,
    this.titleColor,
    required this.description,
    required this.image,
    this.onPress,
  }) : super(key: key);

  final Color cardBgColor;
  final Color cardLeftColor;
  final double width;
  final String title;
  final Color? titleColor;
  final String? subTitle;
  final String description;
  final String image;
  final VoidCallback? onPress;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(
          boxShadow: defaultBoxShadow(),
          borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onPress,
        child: Card(
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          color: cardBgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                color: cardLeftColor,
                width: 10,
                height: 100,
              ),
              const SizedBox(width: 10),
              Image.asset(image, height: 80),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: menuTextStyle(),
                      ),
                      /* if (subTitle != null) */
                      /*   Text( */
                      /*     subTitle!, */
                      /*     style: menuSubTextStyle(), */
                      /*   ), */
                      Text(description,
                          overflow: TextOverflow.ellipsis,
                          style: menuLongTextStyle(),
                          maxLines: 2),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Widget defaultImage(BuildContext ctx, String name) {
  return Image.asset(name);
}

List<BoxShadow> defaultBoxShadow({
  Color? shadowColor = Colors.grey,
  double? blurRadius = 2,
  double? spreadRadius = 0,
  Offset offset = const Offset(0.0, 0.0),
}) {
  return [
    BoxShadow(
      color: Colors.grey.shade300,
      blurRadius: blurRadius!,
      spreadRadius: spreadRadius!,
      offset: offset,
    )
  ];
}

TextStyle menuTextStyle() {
  return const TextStyle(
    fontSize: 18,
    color: Constants.greenDark,
  );
}

TextStyle menuSubTextStyle() {
  return const TextStyle(
    fontSize: 16,
    color: Constants.greenDark,
  );
}

TextStyle menuLongTextStyle() {
  return const TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );
}

extension ColorExtension on String {
  toColor() {
    var hexColor = replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
  }
}
