import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sor_inventory/model/client_model.dart';
import 'package:sor_inventory/model/invoice_v2_model.dart';
import 'package:sor_inventory/screen/invoice_v2/search_invoice_v2_provider.dart';
import 'package:sor_inventory/screen/invoice_v2/set_client_provider.dart';
import 'package:sor_inventory/widgets/fx_ac_client.dart';
import 'package:sor_inventory/widgets/fx_date_field.dart';
import 'package:sor_inventory/widgets/fx_gray_dark_text.dart';

import '../../app/app_route.dart';
import '../../app/constants.dart';
import '../../model/sor_user_model.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_green_dark_text.dart';
import '../../widgets/fx_invoice_status_lk.dart';
import '../login/login_provider.dart';
import 'get_detail_provider.dart';
import 'invoice_id_provider.dart';

class InvoiceSummaryScreen extends HookConsumerWidget {
  const InvoiceSummaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginModel = useState<SorUser?>(null);
    final isInit = useState(true);
    final isInitLoading = useState(true);

    // final ctrlInvoiceNumber = useTextEditingController(text: "");
    final selectedStatus = useState<String>("A");
    final selectedInvoice = useState<InvoiceV2Model?>(null);
    final isLoading = useState(false);
    final errorMessage = useState("");

    final listInvoice = useState<List<InvoiceV2Model>>(List.empty());
    final startDate =
        useState(DateTime(DateTime.now().year, DateTime.now().month, 1));
    final endDate = useState(DateTime.now());

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
        // ref
        //     .read(searchInvoiceV2Provider.notifier)
        //     .search(startDate: "", endDate: "", client: "", status: "A");
      });
    }
    ref.listen(searchInvoiceV2Provider, (prev, next) {
      if (next is SearchInvoiceV2StateLoading) {
        isLoading.value = true;
      } else if (next is SearchInvoiceV2StateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
      } else if (next is SearchInvoiceV2StateDone) {
        isLoading.value = false;
        listInvoice.value = next.model;
      }
    });
    final selectedClient = useState<ClientModel?>(null);
    final ctrlClient = useTextEditingController(text: "");
    const horiSpace = SizedBox(width: 10);

    final detailClient = useState<ClientModel?>(null);
    ref.listen(getDetailProvider, (prev, next) {
      if (next is GetDetailStateLoading) {
        isLoading.value = true;
      } else if (next is GetClientStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
      } else if (next is GetDetailStateDone) {
        isLoading.value = false;
        Navigator.of(context).pushNamed(invoiceRoute, arguments: {
          "fromSummary": true,
          "startDate": startDate.value.toString(),
          "endDate": endDate.value.toString(),
          "client": detailClient.value,
          "status": selectedStatus.value,
          "model": selectedInvoice.value,
          "detail": next.model
        });
      }
    });
    ref.listen(getClientProvider, (prev, next) {
      if (next is GetClientStateLoading) {
        isLoading.value = true;
        errorMessage.value = "";
      } else if (next is GetClientStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
      } else if (next is GetClientStateDone) {
        errorMessage.value = "";

        ref.read(invoiceIDProvider.notifier).state =
            selectedInvoice.value?.invoiceID ?? "0";
        detailClient.value = next.model;
        ref.read(getDetailProvider.notifier).reset();
        isLoading.value = false;
        ref
            .read(getDetailProvider.notifier)
            .get(invoiceID: selectedInvoice.value?.invoiceID ?? "0");
      }
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          "Invoice Summary",
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
                    child: FxAcClient(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 19,
                      ),
                      ctrl: ctrlClient,
                      initialValue: const TextEditingValue(text: ""),
                      labelText: "Client",
                      hintText: "Client",
                      value: selectedClient.value?.evClientName ?? "",
                      onSelected: (model) {
                        selectedClient.value = model;
                        ref.read(searchInvoiceV2Provider.notifier).search(
                              startDate: startDate.value.toString(),
                              endDate: endDate.value.toString(),
                              client: selectedClient.value?.evClientName ?? "",
                              status: selectedStatus.value,
                            );
                      },
                      withAll: true,
                    ),
                  ),
                  horiSpace,
                  Expanded(
                      child: FxInvoiceStatusLk(
                    labelText: "Status",
                    initialValueId: "A",
                    onChanged: (value) {
                      selectedStatus.value = value.code;
                      ref.read(searchInvoiceV2Provider.notifier).search(
                            startDate: startDate.value.toString(),
                            endDate: endDate.value.toString(),
                            client: selectedClient.value?.evClientName ?? "",
                            status: value.code,
                          );
                    },
                  ))
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: FxDateField(
                      labelText: "Start Date",
                      hintText: "Start Date",
                      dateValue: startDate.value,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 31)),
                      lastDate: DateTime.now(),
                      onDateChange: (val) {
                        startDate.value = val;
                        ref.read(searchInvoiceV2Provider.notifier).search(
                              startDate: val.toString(),
                              endDate: endDate.value.toString(),
                              client: selectedClient.value?.evClientName ?? "",
                              status: selectedStatus.value,
                            );
                      },
                    ),
                  ),
                  horiSpace,
                  Expanded(
                    child: FxDateField(
                      labelText: "End Date",
                      hintText: "End Date",
                      dateValue: endDate.value,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 31)),
                      lastDate: DateTime.now(),
                      onDateChange: (val) {
                        endDate.value = val;
                        ref.read(searchInvoiceV2Provider.notifier).search(
                              startDate: startDate.value.toString(),
                              endDate: val.toString(),
                              client: selectedClient.value?.evClientName ?? "",
                              status: selectedStatus.value,
                            );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const _InvoiceHeader(),
              const Divider(color: Constants.greenDark, thickness: 1),
              Expanded(
                child: Stack(
                  children: [
                    ListView.builder(
                      itemCount: listInvoice.value.length,
                      itemBuilder: (context, idx) {
                        final model = listInvoice.value[idx];
                        return _InvoiceDisplay(
                            model: model,
                            isOdd: idx == 0,
                            onTap: () {
                              selectedInvoice.value = model;
                              ref
                                  .read(getClientProvider.notifier)
                                  .get(clientID: model.invoiceEvClientID);
                            });
                      },
                    ),
                    if (isLoading.value)
                      const SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    if (errorMessage.value != "")
                      Text(
                        "Error ${errorMessage.value}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Constants.red,
                        ),
                      )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _InvoiceHeader extends StatelessWidget {
  const _InvoiceHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Row(children: [
      SizedBox(width: 80, child: FxGreenDarkText(title: "Date")),
      SizedBox(width: 10),
      SizedBox(width: 140, child: FxGreenDarkText(title: "Invoice No.")),
      SizedBox(width: 10),
      Expanded(child: FxGreenDarkText(title: "Client")),
      SizedBox(width: 10),
      SizedBox(width: 140, child: FxGreenDarkText(title: "Status")),
    ]);
  }
}

class _InvoiceDisplay extends StatelessWidget {
  const _InvoiceDisplay({
    Key? key,
    required this.model,
    required this.isOdd,
    this.onTap,
  }) : super(key: key);

  final InvoiceV2Model model;
  final bool isOdd;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final sdf = DateFormat("yyyy-MM-dd");
    final sdfMan = DateFormat("dd/MM/yy");
    String fdate = model.invoiceDate;
    try {
      fdate = DateFormat("dd/MM/yy").format(sdf.parse(model.invoiceDate));
    } catch (_) {}

    return Container(
      // ignore: deprecated_member_use
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
              SizedBox(
                  width: 140, child: FxGrayDarkText(title: model.invoiceNo)),
              const SizedBox(width: 10),
              Expanded(
                child: FxGrayDarkText(title: model.evClientName),
              ),
              if (model.invoiceLHDNStatus == "N")
                const SizedBox(
                  width: 140,
                  child: FxGrayDarkText(
                    title: "Not submitted",
                    color: Constants.red,
                  ),
                ),
              if (model.invoiceLHDNStatus == "E")
                const SizedBox(
                  width: 140,
                  child: FxGrayDarkText(
                    title: "Error submission",
                  ),
                ),
              if (model.invoiceLHDNStatus == "Y")
                SizedBox(
                  width: 140,
                  child: FxGrayDarkText(
                    title:
                        "Submitted at ${sdfMan.format(sdf.parse(model.invoiceLHDNLastUpdated))}",
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
