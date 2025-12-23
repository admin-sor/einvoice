import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/app_route.dart';
import '../../app/constants.dart';
import '../../model/invoice_model.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_ac_supplier_v2.dart';
import '../../widgets/fx_button.dart';
import '../../widgets/fx_date_field.dart';
import '../../widgets/fx_gray_dark_text.dart';
import '../../widgets/fx_green_dark_text.dart';
import '../../widgets/fx_invoice_status_lk.dart';
import '../invoice_v2/submit_lhdn_provider.dart';
import '../invoice_v2/get_detail_provider.dart';
import 'self_bill_search_provider.dart';
import 'self_bill_id_provider.dart';

class SelfBillSummaryScreen extends HookConsumerWidget {
  const SelfBillSummaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errorMessage = useState("");
    final isLoading = useState(false);
    final isInitLoading = useState(true);
    final selectedStatus = useState<String>("A");
    final selectedSupplierName = useState<String>("");
    final submittingInvoiceId = useState<String?>(null);
    final selectedInvoice = useState<InvoiceModel?>(null);

    final searchDateFormat = DateFormat("yyyy-MM-dd");
    final searchEndDate = useState(DateTime.now());
    final searchStartDate =
        useState(DateTime(DateTime.now().year, DateTime.now().month, 1));

    final listSelfBill = useState<List<InvoiceModel>>(List.empty());

    if (isInitLoading.value) {
      isInitLoading.value = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selfBillSearchProvider.notifier).search(
              startDate: searchDateFormat.format(searchStartDate.value),
              endDate: searchDateFormat.format(searchEndDate.value),
              supplierName: selectedSupplierName.value,
              status: selectedStatus.value,
            );
      });
    }

    ref.listen(selfBillSearchProvider, (prev, next) {
      if (next is SelfBillSearchStateLoading) {
        isLoading.value = true;
      } else if (next is SelfBillSearchStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
        Timer(const Duration(seconds: 3), () {
          errorMessage.value = "";
        });
      } else if (next is SelfBillSearchStateDone) {
        isLoading.value = false;
        listSelfBill.value = next.model;
      }
    });
    ref.listen(getDetailProvider, (prev, next) {
      if (next is GetDetailStateLoading) {
        isLoading.value = true;
      } else if (next is GetDetailStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
        Timer(const Duration(seconds: 3), () {
          if (errorMessage.value == next.message) {
            errorMessage.value = "";
          }
        });
      } else if (next is GetDetailStateDone) {
        isLoading.value = false;
        final selected = selectedInvoice.value;
        if (selected != null) {
          ref.read(selfBillIDProvider.notifier).state = selected.evInvoiceID;
        }
        Navigator.of(context).pushNamed(
          selfBillRoute,
          arguments: {
            "fromSummary": true,
            "invoiceModel": selectedInvoice.value,
            "detail": next.model,
          },
        );
      }
    });
    ref.listen(submitLhdnProvider, (prev, next) {
      if (next is SubmitLHDNStateLoading) {
        return;
      }
      if (next is SubmitLHDNStateError) {
        errorMessage.value = next.message;
        Timer(const Duration(seconds: 3), () {
          if (errorMessage.value == next.message) {
            errorMessage.value = "";
          }
        });
      }
      if (next is SubmitLHDNStateDone) {
        if (next.model.getError() != "") {
          errorMessage.value = next.model.getError();
          Timer(const Duration(seconds: 3), () {
            if (errorMessage.value == next.model.getError()) {
              errorMessage.value = "";
            }
          });
        }
      }
      if (next is SubmitLHDNStateError || next is SubmitLHDNStateDone) {
        ref.read(selfBillSearchProvider.notifier).search(
              startDate: searchDateFormat.format(searchStartDate.value),
              endDate: searchDateFormat.format(searchEndDate.value),
              supplierName: selectedSupplierName.value,
              status: selectedStatus.value,
            );
      }
      submittingInvoiceId.value = null;
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          "Self Bill Summary",
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
                children: [
                  Expanded(
                    child: FxAcSupplierV2(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 19,
                      ),
                      labelText: "Supplier",
                      hintText: "Supplier",
                      value: "",
                      onSelected: (model) {
                        selectedSupplierName.value = model.evSupplierName ?? "";
                        ref.read(selfBillSearchProvider.notifier).search(
                              supplierName: selectedSupplierName.value,
                              startDate: searchDateFormat
                                  .format(searchStartDate.value),
                              endDate:
                                  searchDateFormat.format(searchEndDate.value),
                              status: selectedStatus.value,
                            );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FxInvoiceStatusLk(
                      labelText: "Status",
                      initialValueId: "A",
                      onChanged: (value) {
                        selectedStatus.value = value.code;
                        ref.read(selfBillSearchProvider.notifier).search(
                              supplierName: selectedSupplierName.value,
                              startDate: searchDateFormat
                                  .format(searchStartDate.value),
                              endDate:
                                  searchDateFormat.format(searchEndDate.value),
                              status: value.code,
                            );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: FxDateField(
                      labelText: "Start Date",
                      dateValue: searchStartDate.value,
                      firstDate: searchStartDate.value
                          .subtract(const Duration(days: 31 * 12)),
                      lastDate: DateTime.now(),
                      onDateChange: (dt) {
                        searchStartDate.value = dt;
                        ref.read(selfBillSearchProvider.notifier).search(
                              supplierName: selectedSupplierName.value,
                              startDate: searchDateFormat.format(dt),
                              endDate:
                                  searchDateFormat.format(searchEndDate.value),
                              status: selectedStatus.value,
                            );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FxDateField(
                      labelText: "End Date",
                      dateValue: searchEndDate.value,
                      firstDate: searchEndDate.value
                          .subtract(const Duration(days: 31)),
                      lastDate: DateTime.now(),
                      onDateChange: (dt) {
                        searchEndDate.value = dt;
                        ref.read(selfBillSearchProvider.notifier).search(
                              supplierName: selectedSupplierName.value,
                              startDate: searchDateFormat
                                  .format(searchStartDate.value),
                              endDate: searchDateFormat.format(dt),
                              status: selectedStatus.value,
                            );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: 1000,
                    child: Column(
                      children: [
                        const _SelfBillHeader(),
                        const Divider(color: Constants.greenDark, thickness: 1),
                        Expanded(
                          child: Stack(
                            children: [
                              ListView.builder(
                                itemCount: listSelfBill.value.length,
                                itemBuilder: (context, idx) {
                                  final item = listSelfBill.value[idx];
                                  return _SelfBillDisplay(
                                    invoice: item,
                                    isOdd: idx == 0,
                                    submittingInvoiceId:
                                        submittingInvoiceId.value,
                                    onTap: () {
                                      selectedInvoice.value = item;
                                      ref
                                          .read(getDetailProvider.notifier)
                                          .get(invoiceID: item.evInvoiceID);
                                    },
                                    onSubmit: (invoice) {
                                      submittingInvoiceId.value =
                                          invoice.evInvoiceID;
                                      ref
                                          .read(submitLhdnProvider.notifier)
                                          .submit(
                                              invoiceID: invoice.evInvoiceID);
                                    },
                                  );
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
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 700),
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 8),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: Colors.red.shade200,
                                        ),
                                      ),
                                      child: Text(
                                        "Error: ${errorMessage.value}",
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Constants.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
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
    );
  }
}

class _SelfBillHeader extends StatelessWidget {
  const _SelfBillHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Row(children: [
      SizedBox(width: 80, child: FxGreenDarkText(title: "Date")),
      SizedBox(width: 10),
      SizedBox(width: 90, child: FxGreenDarkText(title: "Invoice No.")),
      SizedBox(width: 10),
      SizedBox(width: 200, child: FxGreenDarkText(title: "Supplier")),
      SizedBox(width: 10),
      SizedBox(width: 190, child: FxGreenDarkText(title: "Status")),
      SizedBox(width: 10),
      SizedBox(width: 180, child: FxGreenDarkText(title: "Action")),
    ]);
  }
}

class _SelfBillDisplay extends StatelessWidget {
  const _SelfBillDisplay({
    Key? key,
    required this.invoice,
    required this.isOdd,
    this.onTap,
    this.onSubmit,
    this.submittingInvoiceId,
  }) : super(key: key);

  final InvoiceModel invoice;
  final bool isOdd;
  final void Function()? onTap;
  final void Function(InvoiceModel invoice)? onSubmit;
  final String? submittingInvoiceId;

  @override
  Widget build(BuildContext context) {
    final sdf = DateFormat("yyyy-MM-dd");
    final sdfMan = DateFormat("dd MMM yyyy");
    String fdate = invoice.evInvoiceIssueDate;
    try {
      fdate =
          DateFormat("dd/MM/yy").format(sdf.parse(invoice.evInvoiceIssueDate));
    } catch (_) {}

    final status = invoice.evInvoiceStatus;
    final validationDate = invoice.evInvoiceValidationDate ?? "";
    String submittedText = "";
    if (validationDate.isNotEmpty) {
      try {
        submittedText = "Submitted ${sdfMan.format(sdf.parse(validationDate))}";
      } catch (_) {
        submittedText = "Submitted $validationDate";
      }
    }

    return Container(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 80, child: FxGrayDarkText(title: fdate)),
              const SizedBox(width: 10),
              SizedBox(
                  width: 90, child: FxGrayDarkText(title: invoice.evInvoiceNo)),
              const SizedBox(width: 10),
              SizedBox(
                width: 200,
                child: FxGrayDarkText(title: invoice.evInvoiceSupplierName),
              ),
              if (status == "N")
                const SizedBox(
                  width: 190,
                  child: FxGrayDarkText(title: "Ready to Submit"),
                ),
              if (status == "E")
                const SizedBox(
                  width: 190,
                  child: FxGrayDarkText(
                    title: "Failed",
                    color: Constants.red,
                  ),
                ),
              if (status == "Y" && submittedText.isEmpty)
                const SizedBox(
                  width: 190,
                  child: FxGrayDarkText(title: "Pending LHDN"),
                ),
              if (status == "Y" && submittedText.isNotEmpty)
                SizedBox(
                  width: 190,
                  child: FxGrayDarkText(title: submittedText),
                ),
              const SizedBox(width: 10),
              if (status == "N")
                FxButton(
                  onPress: submittingInvoiceId == null && onSubmit != null
                      ? () => onSubmit!(invoice)
                      : null,
                  isLoading: submittingInvoiceId == invoice.evInvoiceID,
                  maxWidth: 190,
                  insidePadding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 0.0),
                  title: "Submit to LHDN",
                  color: Colors.purple,
                ),
              if (status == "E")
                FxButton(
                  onPress: submittingInvoiceId == null && onSubmit != null
                      ? () => onSubmit!(invoice)
                      : null,
                  isLoading: submittingInvoiceId == invoice.evInvoiceID,
                  maxWidth: 190,
                  insidePadding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 0.0),
                  title: "Resubmit to LHDN",
                  color: Colors.purple,
                ),
              if (status != "N" && status != "E")
                const SizedBox(
                  width: 190,
                )
            ],
          ),
        ),
      ),
    );
  }
}
