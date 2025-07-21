import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

// import '../../app/app_route.dart';
import '../../app/app_route.dart';
import '../../app/constants.dart';
import '../../model/invoice_model.dart'; // Import invoice model
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_black_text.dart';
import '../../widgets/fx_date_field.dart';
import '../../widgets/fx_text_field.dart';
import 'invoice_search_provider.dart';

class InvoiceScreen extends HookConsumerWidget {
  // Renamed class
  const InvoiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrlSearch = useTextEditingController(text: "");
    final errorMessage = useState("");
    final isLoading = useState(false);
    final isInitLoading = useState(true); // Added for initial search

    final searchDateFormat = DateFormat("yyyy-MM-dd");
    final searchEndDate = useState(DateTime.now());
    final searchStartDate =
        useState(DateTime(DateTime.now().year, DateTime.now().month, 1));

    final listInvoice =
        useState<List<InvoiceModel>>(List.empty()); // Use InvoiceModel

    // Perform initial search
    if (isInitLoading.value) {
      isInitLoading.value = false;

      WidgetsBinding.instance.addPostFrameCallback((tmr) {
        ref.read(invoiceSearchProvider.notifier).search(
              startDate: searchDateFormat.format(searchStartDate.value),
              endDate: searchDateFormat.format(searchEndDate.value),
              clientName: "",
              status: "A",
            );
      });
    }

    // Listen to invoice search provider
    ref.listen(invoiceSearchProvider, (prev, next) {
      if (next is InvoiceSearchStateLoading) {
        isLoading.value = true;
      } else if (next is InvoiceSearchStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
        Timer(const Duration(seconds: 3), () {
          errorMessage.value = "";
        });
      } else if (next is InvoiceSearchStateDone) {
        isLoading.value = false;
        listInvoice.value = next.model;
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          "Invoice", // Changed title
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
          // Navigate to invoice edit route
          // Navigator.of(context).pushNamed(
          //   invoiceEditRoute, // Assuming invoiceEditRoute exists
          //   arguments: {
          //     "query": ctrlSearch.text,
          //     "invoice": InvoiceModel(evInvoiceID: "0")
          //   },
          // );
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
              Row(
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 1,
                    child: FxDateField(
                        labelText: "Start Date",
                        dateValue: searchStartDate.value,
                        firstDate: searchStartDate.value
                            .subtract(const Duration(days: 100)),
                        lastDate: DateTime.now(),
                        onDateChange: (dt) {
                          searchStartDate.value = dt;
                          ref.read(invoiceSearchProvider.notifier).search(
                                clientName: ctrlSearch.text,
                                startDate: searchDateFormat.format(dt),
                                endDate: searchDateFormat
                                    .format(searchEndDate.value),
                                status: "A",
                              );
                        }),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 1,
                    child: FxDateField(
                        labelText: "End Date",
                        dateValue: searchEndDate.value,
                        firstDate: searchEndDate.value
                            .subtract(const Duration(days: 100)),
                        lastDate: DateTime.now(),
                        onDateChange: (dt) {
                          searchEndDate.value = dt;
                          ref.read(invoiceSearchProvider.notifier).search(
                                clientName: ctrlSearch.text,
                                startDate: searchDateFormat
                                    .format(searchStartDate.value),
                                endDate: searchDateFormat.format(dt),
                                status: "A",
                              );
                        }),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 3,
                    child: FxTextField(
                      ctrl: ctrlSearch,
                      labelText: "Customer", // Changed label
                      width: MediaQuery.of(context).size.width,
                      suffix: InkWell(
                        onTap: () {
                          ref.read(invoiceSearchProvider.notifier).search(
                                clientName: ctrlSearch.text,
                                startDate: searchDateFormat
                                    .format(searchStartDate.value),
                                endDate: searchDateFormat
                                    .format(searchEndDate.value),
                                status: "A",
                              );
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.search),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: 1500, // Adjust width as needed
                    child: Column(
                      children: [
                        const _Header(), // Keep _Header structure, will modify below
                        const Divider(
                          color: Constants.greenDark,
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: listInvoice.value.length,
                            itemBuilder: (context, idx) {
                              final invoice =
                                  listInvoice.value[idx]; // Use invoice
                              return InkWell(
                                  // Added InkWell for tapping rows
                                  onTap: () {
                                    final param = {
                                      "invoice": invoice, // Pass invoice
                                      "query": ctrlSearch.text
                                    };
                                    Navigator.of(context).pushNamed(
                                        invoiceEditRoute, // Navigate to invoice edit
                                        arguments: param);
                                  },
                                  child: _InvoiceDetailRow(
                                    // Use _InvoiceDetailRow
                                    isOdd: (idx % 2 == 0),
                                    invoice: invoice, // Pass invoice
                                  ));
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              // Display error message if not empty
              if (errorMessage.value.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    errorMessage.value,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              // Show loading indicator
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

// Helper widget for header row
class _Header extends StatelessWidget {
  const _Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(
          width: 120,
          child: FxBlackText(
            title: "Date",
            color: Constants.greenDark,
            isBold: false,
          ),
        ),
        SizedBox(
          width: 200,
          child: FxBlackText(
            title: "Invoice No.",
            color: Constants.greenDark,
            isBold: false,
          ),
        ),
        SizedBox(
            width: 300,
            child: FxBlackText(
              title: "Customer",
              color: Constants.greenDark,
              isBold: false,
            )),
        // "evInvoiceTaxTotalAmount": "8.00",
        // "evInvoiceTaxTotalTaxable": "100.00",
        // "evInvoiceTaxTotalCategoryID": "02",
        // "evInvoiceMonetaryExclusive": "100.00",
        // "evInvoiceMonetaryInclusive": "108.00",
        // "evInvoiceMonetaryPayable": "108.00"
        SizedBox(
            width: 120,
            child: FxBlackText(
              title: "Currency",
              color: Constants.greenDark,
              isBold: false,
            )),
        SizedBox(
            width: 150,
            child: FxBlackText(
              title: "Tax Amt",
              color: Constants.greenDark,
              isBold: false,
            )),
        SizedBox(
            width: 150,
            child: FxBlackText(
              title: "Taxable Amt",
              color: Constants.greenDark,
              isBold: false,
            )),
        SizedBox(
            width: 150,
            child: FxBlackText(
              title: "Payable",
              color: Constants.greenDark,
              isBold: false,
            )),
        SizedBox(
            width: 150,
            child: FxBlackText(
              title: "Status",
              color: Constants.greenDark,
              isBold: false,
            )),
      ],
    );
  }
}

// Helper widget for invoice detail row
class _InvoiceDetailRow extends StatelessWidget {
  final InvoiceModel invoice; // Use InvoiceModel
  final bool isOdd;
  const _InvoiceDetailRow({
    Key? key,
    required this.invoice,
    required this.isOdd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var sdfMy = DateFormat("yyyy-MM-dd");
    var sdfMan = DateFormat("dd MMM yyyy");

    var invDate = "";
    try {
      invDate = sdfMan.format(sdfMy.parse(invoice.evInvoiceIssueDate));
    } catch (_) {}
    return Container(
      color: isOdd ? null : Constants.greenLight.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Row(
          children: [
            SizedBox(
              width: 120,
              child: FxBlackText(
                title: invDate,
                isBold: false,
              ),
            ),
            SizedBox(
              width: 200,
              child: FxBlackText(
                title: invoice.evInvoiceNo,
                isBold: false,
              ),
            ),
            SizedBox(
                width: 300,
                child: FxBlackText(
                  title: invoice.evInvoiceCustomerName,
                  isBold: false,
                )),
            SizedBox(
                width: 120,
                child: FxBlackText(
                  title: invoice.evInvoiceCurrency,
                  isBold: false,
                )),
            SizedBox(
                width: 150,
                child: FxBlackText(
                  title: invoice.evInvoiceTaxTotalAmount ?? "",
                  isBold: false,
                )),
            SizedBox(
                width: 150,
                child: FxBlackText(
                  title: invoice.evInvoiceTaxTotalTaxable ?? "",
                  isBold: false,
                )),
            SizedBox(
                width: 150,
                child: FxBlackText(
                  title: invoice.evInvoiceMonetaryInclusive ?? "",
                  isBold: false,
                )),
            SizedBox(
                width: 150,
                child: FxBlackText(
                  title: invoice.evInvoiceStatus ?? "",
                  isBold: false,
                )),
          ],
        ),
      ),
    );
  }
}

// Removed _MaterialMdDetail and _RoField widgets
