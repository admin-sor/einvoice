// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:html' as html;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:pdf/pdf.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:sor_inventory/repository/merge_repository.dart';
import 'package:sor_inventory/screen/merge/merge_item_provider.dart';
import 'package:sor_inventory/screen/merge/merge_save_provider.dart';
import 'package:sor_inventory/widgets/fx_button.dart';

import '../../app/constants.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_gray_dark_text.dart';
import '../../widgets/fx_green_dark_text.dart';

class MergeListScreen extends HookConsumerWidget {
  const MergeListScreen({super.key, this.mergeMaterialID});
  final String? mergeMaterialID;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ResponseMergeScan? firstItem;
    if (ref.read(mergeItemProvider).isNotEmpty) {
      firstItem = ref.read(mergeItemProvider)[0];
    }
    final isLoading = useState(false);
    final errorMessage = useState("");
    final mergeItem = useState<ResponseMergeSave?>(null);
    ref.listen(mergeSaveStateProvider, (prev, next) {
      if (next is MergeSaveStateLoading) {
        isLoading.value = true;
      } else if (next is MergeSaveStateError) {
        errorMessage.value = next.message;
        isLoading.value = false;
      } else if (next is MergeSaveStateDone) {
        isLoading.value = false;
        errorMessage.value = "";
        mergeItem.value = next.model;
        // ref.read(mergeItemProvider.notifier).state = List.empty();
      }
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          "Merge Materials",
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
            ref.read(mergeItemProvider.notifier).state = List.empty();
            Navigator.of(context).pop();
            if (mergeMaterialID != null) {
              Navigator.of(context).pop();
            }
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
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 80,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _LeftColumn(
                    label: "Store",
                    value: ref.read(mergeStoreIDProvider)?.storeName ??
                        " No Store"),
                SizedBox(
                  height: 10,
                ),
                _LeftColumn(label: "Code", value: firstItem?.code ?? " -"),
                SizedBox(
                  height: 10,
                ),
                _LeftColumn(
                    label: "Description", value: firstItem?.description ?? "-"),
                SizedBox(
                  height: 5,
                ),
                if (errorMessage.value != "")
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(errorMessage.value),
                      ),
                    ),
                  ),
                Row(
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(child: FxGreenDarkText(title: "No")),
                    Expanded(flex: 2, child: FxGreenDarkText(title: "Barcode")),
                    Expanded(
                        child: FxGreenDarkText(
                      title: "U/P",
                      align: TextAlign.end,
                    )),
                    Expanded(
                        child: FxGreenDarkText(
                      title: "Qty",
                      align: TextAlign.end,
                    )),
                    Expanded(
                        child: SizedBox(
                      width: 20,
                    )),
                  ],
                ),
                Divider(
                  height: 2,
                ),
                if (ref.watch(mergeItemProvider).isNotEmpty)
                  SizedBox(
                    height: 5,
                  ),
                if (ref.watch(mergeItemProvider).isNotEmpty)
                  Expanded(
                      child: ListView.builder(
                          itemCount: ref.watch(mergeItemProvider).length,
                          itemBuilder: (context, idx) {
                            var arrItem = ref.watch(mergeItemProvider);
                            var rIdx = arrItem.length - 1 - idx;
                            var item = ref.read(mergeItemProvider)[rIdx];
                            var val = double.parse(item.packSizeCurrent);
                            var qtyText = val.toStringAsFixed(0);
                            var counter = idx + 1;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                      child: FxGrayDarkText(
                                          title: counter.toString())),
                                  Expanded(
                                    flex: 2,
                                    child: FxGrayDarkText(
                                      title: item.barcode,
                                    ),
                                  ),
                                  Expanded(
                                    child: FxGrayDarkText(
                                      title: item.price,
                                      align: TextAlign.end,
                                    ),
                                  ),
                                  Expanded(
                                      child: FxGrayDarkText(
                                    title: qtyText,
                                    align: TextAlign.end,
                                  )),
                                  Expanded(
                                    child: (mergeMaterialID == null)
                                        ? SizedBox(
                                            width: 100,
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: InkWell(
                                                  child: Image.asset(
                                                    "images/icon_delete.png",
                                                    height: 18,
                                                  ),
                                                  onTap: () {
                                                    var items = ref
                                                        .read(mergeItemProvider)
                                                        .toList();
                                                    items.removeAt(rIdx);
                                                    ref
                                                        .read(mergeItemProvider
                                                            .notifier)
                                                        .state = items;
                                                  }),
                                            ))
                                        : SizedBox(width: 20),
                                  )
                                ],
                              ),
                            );
                          })),
                Spacer(),
                Row(
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: FxButton(
                        isLoading: isLoading.value,
                        title: "Merge",
                        color: Constants.orange,
                        onPress: (ref.read(mergeItemProvider).length > 1 &&
                                ref.read(mergeStoreIDProvider)?.storeID !=
                                    null &&
                                mergeItem.value == null)
                            ? () {
                                List<ParamMergeSave> merge =
                                    List.empty(growable: true);
                                for (var item in ref.read(mergeItemProvider)) {
                                  final prm = ParamMergeSave(item.barcode,
                                      item.ref, item.refID, item.storeID);
                                  merge.add(prm);
                                }
                                if (merge.isNotEmpty) {
                                  ref
                                      .read(mergeSaveStateProvider.notifier)
                                      .save(
                                          merge: merge,
                                          storeID: ref
                                                  .read(mergeStoreIDProvider)
                                                  ?.storeID ??
                                              "0");
                                }
                              }
                            : null,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: FxButton(
                        isLoading: isLoading.value,
                        title: mergeItem.value == null ? "Cancel" : "Done",
                        color: mergeItem.value == null ? Constants.red : Constants.greenDark,
                        onPress: () {
                          if (mergeItem.value != null) {
                            ref.read(mergeItemProvider.notifier).state =
                                List.empty();
                          }
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: FxButton(
                      title: "Print Label",
                      color: Constants.blue,
                      onPress: (mergeItem.value == null)
                          ? null
                          : () async {
                              final snow =
                                  "&t=${DateTime.now().toIso8601String()}";
                              String jSplit;
                              if (mergeMaterialID != null) {
                                jSplit = mergeMaterialID!;
                              } else {
                                jSplit = mergeItem.value!.mergeMaterialID;
                              }
                              final url =
                                  "https://${Constants.host}/reports/merge_material.php?c=$jSplit$snow";
                              if (kIsWeb) {
                                html.window.open(url, 'rpttab');
                                return;
                              }
                              await Printing.layoutPdf(
                                format: const PdfPageFormat(
                                    60 * PdfPageFormat.mm,
                                    29 * PdfPageFormat.mm),
                                name: "Split Material Barcode",
                                onLayout: (fmt) async {
                                  final response = await Dio().get(
                                    url,
                                    options: Options(
                                        responseType: ResponseType.bytes),
                                  );
                                  return response.data;
                                },
                              );
                            },
                    )),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                )
              ],
            ),
          ),
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
            width: 90,
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
