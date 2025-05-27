import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sor_inventory/model/checkout_model_v2.dart';
import 'package:sor_inventory/model/contractor_lookup_model.dart';
import 'package:sor_inventory/screen/checkout_summary/list_provider.dart';
import 'package:sor_inventory/widgets/fx_contractor_lk.dart';
import 'package:sor_inventory/widgets/fx_store_lk.dart';

import '../../app/app_route.dart';
import '../../app/constants.dart';
import '../../model/sor_user_model.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_black_text.dart';
import '../../widgets/fx_green_dark_text.dart';
import '../../widgets/fx_text_field.dart';
import '../login/login_provider.dart';

class CheckoutSummaryScreen extends HookConsumerWidget {
  const CheckoutSummaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginModel = useState<SorUser?>(null);
    final isInit = useState(true);
    final isInitLoading = useState(true);

    final ctrlDoNumber = useTextEditingController(text: "");
    final ctrlPoNumber = useTextEditingController(text: "");
    final isLoading = useState(false);
    final errorMessageLoadDo = useState("");
    final selectedContractor = useState<ContractorLookupModel?>(null);
    final selectedStore = useState<Map<String, dynamic>?>(null);
    final listCheckout = useState<List<CheckoutLisModel>>(List.empty());

    ref.listen(loginStateProvider, (prev, next) {
      if (next is LoginStateDone) {
        loginModel.value = next.loginModel;
        if (loginModel.value?.storeID != null) {
          selectedStore.value = {
            "id": loginModel.value!.storeID,
            "name": "User Store"
          };
        }
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
          Navigator.of(context)
              .pushNamedAndRemoveUntil(loginRoute, (args) => false);
        });
      }
      return Scaffold(
        body: Container(
          color: Colors.white,
        ),
      );
    }

    final ctrlScheme = useTextEditingController(text: "");
    const horiSpace = SizedBox(width: 10);
    if (isInitLoading.value) {
      isInitLoading.value = false;
      WidgetsBinding.instance.addPostFrameCallback((tmr) {
        ref.read(listCheckoutStateProvider.notifier).listV2(
              vendorID: "",
              isReturn: "Y",
              staffID: "",
              search: ctrlScheme.text,
            );
      });
    }
    ref.listen(listCheckoutStateProvider, (prev, next) {
      if (next is ListCheckoutStateLoading) {
        isLoading.value = true;
      } else if (next is ListCheckoutStateError) {
        isLoading.value = false;
        errorMessageLoadDo.value = next.message;
      } else if (next is ListCheckoutStateDone) {
        listCheckout.value = next.list;
        isLoading.value = false;
      }
    });
    double filterWidth = MediaQuery.of(context).size.width - 20;
    if (kIsWeb && MediaQuery.of(context).size.width > Constants.webWidth) {
      filterWidth = Constants.webWidth;
    }

    Timer? debounce;

    void onSchemeChanged() {
      if (debounce?.isActive ?? false) debounce!.cancel();
      // Start a new timer
      debounce = Timer(const Duration(milliseconds: 350), () {
        ref.read(listCheckoutStateProvider.notifier).listV2(
            vendorID: selectedContractor.value?.cpId ?? "0",
            isReturn: "Y",
            search: ctrlScheme.text,
            staffID: selectedContractor.value?.staffId ?? "0",
            storeID: selectedStore.value?["id"] ?? "0");
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          "Material Issue Summary",
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
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height,
          width: kIsWeb ? 1024 : MediaQuery.of(context).size.width - 20,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: Constants.paddingTopContent,
                ),
                SizedBox(
                  width: filterWidth,
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: FxTextField(
                            labelText: "Scheme/Project No",
                            hintText: "Scheme/Project No",
                            onChanged: (qry) {
                              onSchemeChanged();
                            },
                            prefix: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                "images/icon_search_70.png",
                                width: 20,
                              ),
                            ),
                            ctrl: ctrlScheme,
                            contentPadding: EdgeInsets.only(
                              top: 16,
                              bottom: 18,
                              left: 10,
                              right: 10,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: FxContractorLk(
                          labelText: "Contractor",
                          hintText: "Contractor",
                          withAll: true,
                          onChanged: (value) {
                            selectedContractor.value = value;
                            ref.read(listCheckoutStateProvider.notifier).listV2(
                                vendorID: value.cpId,
                                isReturn: "Y",
                                staffID: value.staffId,
                                storeID: selectedStore.value?["id"] ?? "0");
                          },
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: FxStoreLk(
                            withAll: true,
                            isGrey: false,
                            labelText: "Store Location",
                            hintText: "Store",
                            readOnly: false,
                            onChanged: (model) {
                              selectedStore.value = {
                                "id": model.storeID,
                                "name": model.storeName
                              };
                              ref
                                  .read(listCheckoutStateProvider.notifier)
                                  .listV2(
                                      vendorID:
                                          selectedContractor.value?.cpId ?? "0",
                                      isReturn: "Y",
                                      search: ctrlScheme.text,
                                      staffID:
                                          selectedContractor.value?.staffId ??
                                              "0",
                                      storeID: model.storeID ?? "0");
                            }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: 1000,
                      child: Column(
                        children: [
                          const _CheckoutHeader(),
                          const Divider(
                              color: Constants.greenDark, thickness: 1),
                          Expanded(
                            child: Stack(
                              children: [
                                ListView.builder(
                                  itemCount: listCheckout.value.length,
                                  itemBuilder: (context, idx) {
                                    final model = listCheckout.value[idx];
                                    return _CheckoutDisplay(
                                      model: model,
                                      isOdd: idx % 2 == 1,
                                      onTap: () {
                                        Navigator.of(context).pushNamed(
                                            checkoutRoute,
                                            arguments: model.checkoutSlipNo);
                                      },
                                    );
                                  },
                                ),
                                if (isLoading.value)
                                  const Center(
                                    child: SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckoutHeader extends StatelessWidget {
  const _CheckoutHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: const [
      Expanded(flex: 8, child: FxGreenDarkText(title: "Date")),
      SizedBox(width: 10),
      Expanded(flex: 12, child: FxGreenDarkText(title: "Project No")),
      SizedBox(width: 10),
      Expanded(flex: 23, child: FxGreenDarkText(title: "Scheme")),
      SizedBox(width: 10),
      Expanded(flex: 12, child: FxGreenDarkText(title: "Contractor")),
      SizedBox(width: 10),
      Expanded(flex: 10, child: FxGreenDarkText(title: "SO")),
      SizedBox(width: 10),
      Expanded(flex: 12, child: FxGreenDarkText(title: "Slip No")),
      SizedBox(width: 10),
      Expanded(flex: 16, child: FxGreenDarkText(title: "Store")),
      SizedBox(width: 15),
    ]);
  }
}

class _CheckoutDisplay extends StatelessWidget {
  const _CheckoutDisplay({
    Key? key,
    required this.model,
    required this.isOdd,
    this.onTap,
  }) : super(key: key);

  final CheckoutLisModel model;
  final bool isOdd;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final sdf = DateFormat("yyyy-MM-dd");
    String fdate = model.checkoutDate ?? "";
    try {
      fdate =
          DateFormat("dd/MM/yy").format(sdf.parse(model.checkoutDate ?? ""));
    } catch (_) {}
    return Container(
      color: isOdd ? null : Constants.greenLight.withOpacity(0.2),
      child: InkWell(
        onTap: () {
          if (onTap != null) onTap!();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(flex: 8, child: FxBlackText(title: fdate)),
              const SizedBox(width: 10),
              Expanded(
                  flex: 12, child: FxBlackText(title: model.projectNum ?? "")),
              const SizedBox(width: 10),
              Expanded(flex: 23, child: FxBlackText(title: model.scheme ?? "")),
              const SizedBox(width: 10),
              Expanded(
                  flex: 12,
                  child: FxBlackText(title: model.checkoutCpName ?? "")),
              const SizedBox(width: 10),
              Expanded(
                  flex: 10, child: FxBlackText(title: model.staffName ?? "")),
              const SizedBox(width: 10),
              Expanded(
                  flex: 12,
                  child: FxBlackText(title: model.checkoutSlipNo ?? "")),
              const SizedBox(width: 10),
              Expanded(
                  flex: 16, child: FxBlackText(title: model.storeName ?? "")),
              SizedBox(width: 15),
            ],
          ),
        ),
      ),
    );
  }
}
