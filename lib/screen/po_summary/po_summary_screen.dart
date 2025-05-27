import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sor_inventory/screen/po_summary/po_summary_provider.dart';
import 'package:sor_inventory/widgets/fx_gray_dark_text.dart';

import '../../app/app_route.dart';
import '../../app/constants.dart';
import '../../model/po_summary_response_model.dart';
import '../../model/sor_user_model.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_auto_completion_vendor.dart';
import '../../widgets/fx_green_dark_text.dart';
import '../../widgets/fx_po_status_lk.dart';
import '../../widgets/fx_text_field.dart';
import '../login/login_provider.dart';
import 'selected_po_provider.dart';

class PoSummaryScreen extends HookConsumerWidget {
  const PoSummaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginModel = useState<SorUser?>(null);
    final isInit = useState(true);
    final isInitLoading = useState(true);

    final ctrlPoNumber = useTextEditingController(text: "");
    final selectedVendor = useState<VendorModel?>(null);
    final selectedStatus = useState<String>("A");
    final isLoading = useState(false);
    final errorMessageLoadDo = useState("");

    final selectedStore = useState<Map<String, dynamic>?>(null);
    final listDo = useState<List<PoSummaryResponseModel>>(List.empty());

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

    if (isInitLoading.value) {
      isInitLoading.value = false;
      WidgetsBinding.instance.addPostFrameCallback((tmr) {
        ref.read(poSummaryProvider.notifier).list(
              search: "",
              vendorID: "0",
              status: "A",
            );
      });
    }
    ref.listen(poSummaryProvider, (prev, next) {
      if (next is PoSummaryStateLoading) {
        isLoading.value = true;
      } else if (next is PoSummaryStateError) {
        isLoading.value = false;
        errorMessageLoadDo.value = next.message;
      } else if (next is PoSummaryStateDone) {
        listDo.value = next.list;
      }
    });
    const horiSpace = SizedBox(width: 10);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          "PO Summary",
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
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: FxAutoCompletionVendor(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 19,
                      ),
                      initialValue: const TextEditingValue(text: ""),
                      labelText: "Vendor",
                      hintText: "Vendor",
                      value: selectedVendor.value?.vendorName ?? "",
                      onSelected: (model) {
                        selectedVendor.value = model;
                        ref.read(poSummaryProvider.notifier).list(
                            vendorID: model.vendorID,
                            status: selectedStatus.value,
                            search: ctrlPoNumber.text);
                      },
                      withAll: true,
                    ),
                  ),
                  horiSpace,
                  Expanded(
                    child: FxTextField(
                      ctrl: ctrlPoNumber,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 19,
                      ),
                      labelText: "PO Number",
                      hintText: "PO Number",
                      textCapitalization: TextCapitalization.characters,
                      onEditingComplete: () {
                        ref.read(poSummaryProvider.notifier).list(
                              vendorID: selectedVendor.value?.vendorID ?? "0",
                              search: ctrlPoNumber.text,
                              status: selectedStatus.value,
                            );
                      },
                    ),
                  ),
                  horiSpace,
                  Expanded(
                      child: FxPoStatusLk(
                    labelText: "Status",
                    initialValueId: "A",
                    onChanged: (value) {
                      selectedStatus.value = value.code;
                      ref.read(poSummaryProvider.notifier).list(
                            vendorID: selectedVendor.value?.vendorID ?? "0",
                            search: ctrlPoNumber.text,
                            status: value.code,
                          );
                    },
                  ))
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const SizedBox(
                height: 10,
              ),
              const _PoHeader(),
              const Divider(color: Constants.greenDark, thickness: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: listDo.value.length,
                  itemBuilder: (context, idx) {
                    final model = listDo.value[idx];
                    return _PoDisplay(
                        model: model,
                        isOdd: idx == 0,
                        onTap: () {
                          ref.read(selectedPoProvider.notifier).state =
                              SelectedPoModel(
                            poNo: model.poNo,
                            paymentTermID: model.poPaymentTermID,
                            vendorModel: VendorModel(
                              vendorID: model.poVendorID,
                              vendorName: model.vendorName,
                              paymentTermID: model.poPaymentTermID,
                            ),
                          );
                          Navigator.of(context)
                              .pushNamed(poRoute, arguments: true);
                        });
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _PoHeader extends StatelessWidget {
  const _PoHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: const [
      SizedBox(width: 80, child: FxGreenDarkText(title: "Date")),
      SizedBox(width: 10),
      SizedBox(width: 140, child: FxGreenDarkText(title: "PO No.")),
      SizedBox(width: 10),
      Expanded(child: FxGreenDarkText(title: "Vendor")),
      SizedBox(width: 10),
      SizedBox(width: 140, child: FxGreenDarkText(title: "Status")),
    ]);
  }
}

class _PoDisplay extends StatelessWidget {
  const _PoDisplay({
    Key? key,
    required this.model,
    required this.isOdd,
    this.onTap,
  }) : super(key: key);

  final PoSummaryResponseModel model;
  final bool isOdd;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final sdf = DateFormat("yyyy-MM-dd");
    String fdate = model.poDate;
    try {
      fdate = DateFormat("dd/MM/yy").format(sdf.parse(model.poDate));
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
              SizedBox(width: 80, child: FxGrayDarkText(title: fdate)),
              const SizedBox(width: 10),
              SizedBox(width: 140, child: FxGrayDarkText(title: model.poNo)),
              const SizedBox(width: 10),
              Expanded(
                child: FxGrayDarkText(title: model.vendorName),
              ),
              const SizedBox(width: 10),
              if (model.poIsReceived == "N")
                SizedBox(
                  width: 140,
                  child: FxGrayDarkText(
                    title: "To Receive",
                    color: Constants.red,
                  ),
                ),
              if (model.poIsReceived == "F")
                SizedBox(
                  width: 140,
                  child: Row(
                    children: [
                      FxGrayDarkText(
                        title: "Fulfilled",
                      ),
                      SizedBox(width: 20),
                      Image.asset(
                        "images/tick.png",
                        height: 20,
                      ),
                    ],
                  ),
                ),
              if (model.poIsReceived == "P")
                SizedBox(
                  width: 140,
                  child: FxGrayDarkText(
                    title: "Partial",
                    color: Constants.red,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
