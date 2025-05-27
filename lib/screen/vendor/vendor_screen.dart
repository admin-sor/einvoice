import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sor_inventory/screen/vendor/vendor_delete_provider.dart';
import 'package:sor_inventory/screen/vendor/vendor_search_provider.dart';
import 'package:sor_inventory/screen/vendor_material/vendor_material_selected_provider.dart';
import 'package:sor_inventory/widgets/fx_black_text.dart';

import '../../app/app_route.dart';
import '../../app/constants.dart';
import '../../model/sor_user_model.dart';
import '../../model/vendor_model.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_text_field.dart';
import '../login/login_provider.dart';

class VendorScreen extends HookConsumerWidget {
  const VendorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginModel = useState<SorUser?>(null);
    final isInit = useState(true);
    final isInitLoading = useState(true);
    final ctrlSearch = useTextEditingController(text: "");
    final errorMessage = useState("");
    final isLoading = useState(false);

    ref.listen(loginStateProvider, (prev, next) {
      if (next is LoginStateDone) {
        loginModel.value = next.loginModel;
      }
    });
    //no login
    if (loginModel.value == null) {
      if (isInit.value) {
        isInit.value = false;
        Timer(const Duration(milliseconds: 500), () {
          ref.read(loginStateProvider.notifier).checkLocalToken();
        });
      } else {
        Timer(const Duration(milliseconds: 500), () {
          isInit.value = true;
          if (loginModel.value == null) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(loginRoute, (args) => false);
          }
        });
      }
      return Scaffold(
        body: Container(
          color: Colors.white,
        ),
      );
    }

    const horiSpace = SizedBox(width: 10);
    final listVendor = useState<List<VendorModel>>(List.empty());

    if (isInitLoading.value) {
      isInitLoading.value = false;
      WidgetsBinding.instance.addPostFrameCallback((tmr) {
        ref.read(vendorSearchProvider.notifier).search(query: ctrlSearch.text);
      });
    }
    ref.listen(vendorSearchProvider, (prev, next) {
      if (next is VendorSearchStateLoading) {
        isLoading.value = true;
      } else if (next is VendorSearchStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
      } else if (next is VendorSearchStateDone) {
        isLoading.value = false;
        listVendor.value = next.list;
      }
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          "Vendor",
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
            vendorEditRoute,
            arguments: {"query": ctrlSearch.text, "isNew": true},
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
              Stack(
                alignment: Alignment.center,
                children: [
                  FxTextField(
                    ctrl: ctrlSearch,
                    labelText: "Search Vendor",
                    width: MediaQuery.of(context).size.width,
                    suffix: InkWell(
                      onTap: () {
                        ref
                            .read(vendorSearchProvider.notifier)
                            .search(query: ctrlSearch.text);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.search),
                      ),
                    ),
                  ),
                  if (isLoading.value)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: const CircularProgressIndicator(),
                    )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: kIsWeb ? Constants.webWidth : 600,
                    child: Column(
                      children: [
                        const _VendorHeader(),
                        const Divider(
                          color: Constants.greenDark,
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: listVendor.value.length,
                            itemBuilder: (context, idx) {
                              final vendor = listVendor.value[idx];
                              return InkWell(
                                  onTap: () {
                                    final param = {
                                      "vendor": vendor,
                                      "query": ctrlSearch.text,
                                      "isNew": false,
                                    };
                                    Navigator.of(context).pushNamed(
                                        vendorEditRoute,
                                        arguments: param);
                                  },
                                  child: _VendorDetailRow(
                                    isOdd: (idx % 2 == 0),
                                    vendor: vendor,
                                    query: ctrlSearch.text,
                                  ));
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VendorDetailRow extends StatelessWidget {
  final VendorModel vendor;
  final String query;
  final bool isOdd;
  const _VendorDetailRow({
    Key? key,
    required this.vendor,
    required this.query,
    this.isOdd = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isOdd ? null : Constants.greenLight.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Row(children: [
          SizedBox(
              width: 220,
              child: FxBlackText(
                title: vendor.vendorName,
                isBold: false,
              )),
          const SizedBox(width: 10),
          Expanded(
              child: FxBlackText(
                  isBold: false,
                  title:
                      "${vendor.vendorAdd1} ${vendor.vendorAdd2}  ${vendor.vendorAdd3}")),
        ]),
      ),
    );
  }
}

class _VendorHeader extends StatelessWidget {
  const _VendorHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: const [
      SizedBox(
          width: 220,
          child: FxBlackText(
            title: "Name",
            color: Constants.greenDark,
            isBold: false,
          )),
      SizedBox(width: 10),
      Expanded(
          child: FxBlackText(
        title: "Address",
        color: Constants.greenDark,
        isBold: false,
      )),
    ]);
  }
}

class _VendorDetail extends HookConsumerWidget {
  const _VendorDetail({
    Key? key,
    required this.vendor,
    required this.query,
  }) : super(key: key);

  final VendorModel vendor;
  final String query;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final errorMessage = useState("");

    ref.listen(vendorDeleteProvider, (prev, next) {
      if (next is VendorDeleteStateLoading) {
        isLoading.value = true;
      } else if (next is VendorDeleteStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
      } else if (next is VendorDeleteStateDone) {
        isLoading.value = false;
      }
    });

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(10),
      ),
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 10.0,
              left: 10.0,
              bottom: 10.0,
              right: 60.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FxBlackText(
                  title: vendor.vendorName,
                  isBold: false,
                ),
                const SizedBox(
                  height: 10,
                ),
                FxBlackText(
                  title: '${vendor.vendorAdd1} ${vendor.vendorAdd2}',
                  isBold: false,
                ),
                const SizedBox(
                  height: 10,
                ),
                FxBlackText(
                  title: vendor.vendorAdd3,
                  isBold: false,
                ),
              ],
            ),
          ),
          Positioned(
            top: 10.0,
            right: 10.0,
            child: InkWell(
              onTap: () {
                final param = {
                  "vendor": vendor,
                  "query": query,
                  "isNew": false,
                };
                Navigator.of(context)
                    .pushNamed(vendorEditRoute, arguments: param);
              },
              child: Image.asset(
                "images/icon_edit.png",
                width: 24,
              ),
            ),
          ),
          Positioned(
            bottom: 10.0,
            right: 10.0,
            child: InkWell(
              onTap: () async {
                ref.read(vendorMaterialSelectedVendorProvider.notifier).state =
                    vendor;
                Navigator.of(context).pushNamed(vendorMaterialRoute);
              },
              child: Image.asset(
                "images/icon_material.png",
                width: 24,
              ),
            ),
          )
        ],
      ),
    );
  }
}
