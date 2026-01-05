import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app/constants.dart';
import '../../model/supplier_model.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_black_text.dart';
import '../../widgets/fx_text_field.dart';
import 'supplier_search_with_own_provider.dart';

const supplierEditRoute = "/supplierEditRoute";

class SupplierScreen extends HookConsumerWidget {
  const SupplierScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrlSearch = useTextEditingController(text: "");
    final errorMessage = useState("");
    final isLoading = useState(false);
    final isInitLoading = useState(true);

    final listSupplier = useState<List<SupplierModel>>(List.empty());

    if (isInitLoading.value) {
      isInitLoading.value = false;
      WidgetsBinding.instance.addPostFrameCallback((tmr) {
        ref
            .read(supplierSearchWithOwnProvider.notifier)
            .search(query: ctrlSearch.text);
      });
    }

    ref.listen(supplierSearchWithOwnProvider, (prev, next) {
      if (next is SupplierSearchWithOwnStateLoading) {
        isLoading.value = true;
      } else if (next is SupplierSearchWithOwnStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
        Timer(const Duration(seconds: 3), () {
          errorMessage.value = "";
        });
      } else if (next is SupplierSearchWithOwnStateDone) {
        isLoading.value = false;
        listSupplier.value = next.model;
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          "Supplier",
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Constants.grey,
        foregroundColor: Colors.white,
        shape: const CircleBorder(
          side: BorderSide(
            color: Constants.greenDark,
            width: 2.0,
          ),
        ),
        onPressed: () {
          Navigator.of(context).pushNamed(
            supplierEditRoute,
            arguments: {
              "query": ctrlSearch.text,
              "supplier": SupplierModel(evSupplierID: "0")
            },
          );
        },
        child: Image.asset(
          "images/icon_add_green.png",
          width: 32,
          height: 32,
        ),
      ),
      endDrawer: const EndDrawer(),
      body: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: Constants.paddingTopContent,
              ),
              FxTextField(
                ctrl: ctrlSearch,
                labelText: "Search Name",
                width: MediaQuery.of(context).size.width,
                suffix: InkWell(
                  onTap: () {
                    ref
                        .read(supplierSearchWithOwnProvider.notifier)
                        .search(query: ctrlSearch.text);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: 1300,
                    child: Column(
                      children: [
                        _Header(
                          model: listSupplier.value.isNotEmpty
                              ? listSupplier.value[0]
                              : null,
                        ),
                        const Divider(
                          color: Constants.greenDark,
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: listSupplier.value.length,
                            itemBuilder: (context, idx) {
                              final supplier = listSupplier.value[idx];
                              return InkWell(
                                onTap: () {
                                  final param = {
                                    "supplier": supplier,
                                    "query": ctrlSearch.text
                                  };
                                  Navigator.of(context).pushNamed(
                                    supplierEditRoute,
                                    arguments: param,
                                  );
                                },
                                child: _SupplierDetailRow(
                                  isOdd: (idx % 2 == 0),
                                  supplier: supplier,
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              if (errorMessage.value.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    errorMessage.value,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              if (isLoading.value)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final SupplierModel? model;
  _Header({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: FxBlackText(
          title: "Name",
          color: Constants.greenDark,
          isBold: false,
        )),
        SizedBox(
            width: 200,
            child: FxBlackText(
              title: "Address",
              color: Constants.greenDark,
              isBold: false,
            )),
        SizedBox(
            width: 150,
            child: FxBlackText(
              title: model?.evSupplierBusinessRegType ?? "BRN",
              color: Constants.greenDark,
              isBold: false,
            )),
        SizedBox(
            width: 150,
            child: FxBlackText(
              title: "SST No",
              color: Constants.greenDark,
              isBold: false,
            )),
        SizedBox(
            width: 150,
            child: FxBlackText(
              title: "TIN No",
              color: Constants.greenDark,
              isBold: false,
            )),
        SizedBox(
            width: 150,
            child: FxBlackText(
              title: "PIC",
              color: Constants.greenDark,
              isBold: false,
            )),
        SizedBox(
            width: 150,
            child: FxBlackText(
              title: "Phone",
              color: Constants.greenDark,
              isBold: false,
            )),
        SizedBox(
            width: 200,
            child: FxBlackText(
              title: "Email",
              color: Constants.greenDark,
              isBold: false,
            )),
      ],
    );
  }
}

class _SupplierDetailRow extends StatelessWidget {
  final SupplierModel supplier;
  final bool isOdd;
  const _SupplierDetailRow({
    Key? key,
    required this.supplier,
    required this.isOdd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String address = supplier.evSupplierAddr1 ?? "";
    address += " ";
    address += supplier.evSupplierAddr2 ?? "";
    address = "${address.trim()} ";
    address += supplier.evSupplierAddr3 ?? "";
    address = address.trim();
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Row(
          children: [
            Expanded(
                child: FxBlackText(
              title: supplier.evSupplierName ?? "",
              isBold: false,
            )),
            SizedBox(
                width: 200,
                child: FxBlackText(
                  title: address,
                  isBold: false,
                )),
            SizedBox(
                width: 150,
                child: FxBlackText(
                  title: supplier.evSupplierBusinessRegNo ?? "",
                  isBold: false,
                )),
            SizedBox(
                width: 150,
                child: FxBlackText(
                  title: supplier.evSupplierSstNo ?? "",
                  isBold: false,
                )),
            SizedBox(
                width: 150,
                child: FxBlackText(
                  title: supplier.evSupplierTinNo ?? "",
                  isBold: false,
                )),
            SizedBox(
                width: 150,
                child: FxBlackText(
                  title: supplier.evSupplierPic ?? "",
                  isBold: false,
                )),
            SizedBox(
                width: 150,
                child: FxBlackText(
                  title: supplier.evSupplierPhone ?? "",
                  isBold: false,
                )),
            SizedBox(
                width: 200,
                child: FxBlackText(
                  title: supplier.evSupplierEmail ?? "",
                  isBold: false,
                )),
          ],
        ),
      ),
    );
  }
}
