import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sor_inventory/model/invoice_model.dart';
import 'package:sor_inventory/widgets/network_image.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../app/constants.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_button.dart';
import '../../widgets/fx_gray_dark_text.dart';
import '../../widgets/fx_text_field.dart';

class InvoiceEditScreen extends HookConsumerWidget {
  final InvoiceModel invoice;
  final String query; // Used to refresh the list after saving
  const InvoiceEditScreen({
    Key? key,
    required this.invoice,
    this.query = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final errorMessage = useState("");

    final ctrlInvoiceNo = useTextEditingController(text: invoice.evInvoiceNo);
    final ctrlSupplierName =
        useTextEditingController(text: invoice.evInvoiceSupplierName);
    final ctrlCustomerName =
        useTextEditingController(text: invoice.evInvoiceCustomerName);
    final ctrlDate = useTextEditingController(text: invoice.evInvoiceIssueDate);
    final ctrlTaxAmount =
        useTextEditingController(text: invoice.evInvoiceTaxTotalAmount);
    final ctrlTaxableAmount =
        useTextEditingController(text: invoice.evInvoiceTaxTotalTaxable);
    final ctrlSubmittedDate = useTextEditingController(
        text: invoice.evInvoiceLastSubmissionDate ?? "");

    // ref.listen(invoiceEditProvider, (prev, next) {
    //   if (next is InvoiceEditStateLoading) {
    //     isLoading.value = true;
    //   } else if (next is InvoiceEditStateError) {
    //     errorMessage.value = next.message;
    //     isLoading.value = false;
    //   } else if (next is InvoiceEditStateDone) {
    //     isLoading.value = false;
    //     Navigator.of(context).pop(); // Pop screen on successful save
    //   }
    // });

    final imageUrl = useState(invoice.evInvoiceStatus == "S"
        ? "${Constants.baseUrl}ev_invoice/qrcode/${invoice.evInvoiceID}"
        : "");
    final isSubmitted = useState(invoice.evInvoiceStatus == "S");
    final taxUrl = useState(invoice.evInvoiceStatus == "S"
        ? "${Constants.taxPortalUrl}${invoice.evInvoiceUUID}/share/${invoice.evInvoiceLongID}"
        : "");

    var sdfMy = DateFormat("yyyy-MM-dd");
    var sdfMan = DateFormat("dd MMM yyyy");
    var sdfMyHour = DateFormat("yyyy-MM-dd HH:mm:ss");
    var sdfManHour = DateFormat("dd MMM yyyy HH:mm:ss");

    var invDate = "";
    var submissionDate = "";
    try {
      invDate = sdfMan.format(sdfMy.parse(invoice.evInvoiceIssueDate));
      submissionDate = sdfManHour
          .format(sdfMyHour.parse(invoice.evInvoiceLastSubmissionDate ?? ""));
    } catch (_) {}
    if (invoice.evInvoiceStatus == "S") {
      ctrlDate.text = invDate;
      ctrlSubmittedDate.text = submissionDate;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text(
          invoice.evInvoiceID == "0" ? "New Invoice" : "Edit Invoice",
          style: const TextStyle(
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
                  "images/icon_menu.png", // Placeholder, replace if necessary
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
      endDrawer: const EndDrawer(), // Assuming EndDrawer is a common widget
      body: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            // Use SingleChildScrollView for long forms
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: Constants.paddingTopContent),
                if (isSubmitted.value)
                  Column(
                    children: [
                      FxTextField(
                        ctrl: ctrlInvoiceNo,
                        labelText: "Invoice No.",
                        width: double.infinity,
                        readOnly: true,
                        // Add validation indicator if needed
                      ),
                      const SizedBox(height: 10),
                      FxTextField(
                        ctrl: ctrlDate,
                        labelText: "Date",
                        width: double.infinity,
                        readOnly: true,
                        // Add validation indicator if needed
                      ),
                      const SizedBox(height: 10),
                      FxTextField(
                        ctrl: ctrlSupplierName,
                        labelText: "Supplier ",
                        width: double.infinity,
                        readOnly: true,
                        // Add validation indicator if needed
                      ),
                      const SizedBox(height: 10),
                      FxTextField(
                        ctrl: ctrlCustomerName,
                        labelText: "Client",
                        width: double.infinity,
                        readOnly: true,
                        // Add validation indicator if needed
                      ),
                      const SizedBox(height: 10),
                      FxTextField(
                        ctrl: ctrlTaxableAmount,
                        labelText: "Taxable Amount",
                        width: double.infinity,
                        readOnly: true,
                        // Add validation indicator if needed
                      ),
                      const SizedBox(height: 10),
                      FxTextField(
                        ctrl: ctrlTaxAmount,
                        labelText: "Tax Amount",
                        width: double.infinity,
                        readOnly: true,
                        // Add validation indicator if needed
                      ),
                      const SizedBox(height: 10),
                      FxTextField(
                        ctrl: ctrlSubmittedDate,
                        labelText: "Submission Date",
                        width: double.infinity,
                        readOnly: true,
                        // Add validation indicator if needed
                      ),
                      // image qrcode
                      Align(
                        alignment: Alignment.centerLeft,
                        child: InkWell(
                          onTap: () {
                            launchUrlString(taxUrl.value);
                          },
                          child: NetworkImageWidget(
                            imageUrl: imageUrl.value,
                            width: 200,
                            height: 200,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),

                if (errorMessage.value != "")
                  FxGrayDarkText(
                    color: Constants.red,
                    title: errorMessage.value,
                  ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: FxButton(
                        title: "Cancel",
                        color: Constants.red,
                        onPress: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    if (!isSubmitted.value)
                      Expanded(
                        flex: 1,
                        child: FxButton(
                          title: "Save",
                          color: Constants.greenDark,
                          isLoading: isLoading.value,
                          onPress: () {
                            // Basic validation
                            if (ctrlSupplierName.text.trim().isEmpty) {
                              errorMessage.value = "Supplier Name is mandatory";
                              return;
                            }
                            // More validation can be added here for other fields

                            // Clear previous error message on attempting save
                            errorMessage.value = "";

                            // ref.read(invoiceEditProvider.notifier).edit(
                            //       evInvoiceID:
                            //           int.tryParse(invoice.evInvoiceID ?? "0") ??
                            //               0, // Convert ID to int
                            //       evInvoiceName: ctrlName.text.trim(),
                            //       evInvoiceBusinessRegNo:
                            //           ctrlBusinessRegNo.text.trim(),
                            //       evInvoiceSstNo: ctrlSstNo.text.trim(),
                            //       evInvoiceTinNo: ctrlTinNo.text.trim(),
                            //       evInvoiceAddr1: ctrlAddr1.text.trim(),
                            //       evInvoiceAddr2: ctrlAddr2.text.trim(),
                            //       evInvoiceAddr3: ctrlAddr3.text.trim(),
                            //       evInvoicePic: ctrlPic.text.trim(),
                            //       evInvoiceEmail: ctrlEmail.text.trim(),
                            //       evInvoicePhone: ctrlPhone.text.trim(),
                            //       query: query, // Pass the original search query
                            //     );
                          },
                        ),
                      ),
                    const SizedBox(width: 20),
                    if (isSubmitted.value)
                      const Expanded(
                          flex: 2,
                          child: SizedBox(
                            width: 20,
                          )),
                    if (invoice.evInvoiceID != "0" && !isSubmitted.value)
                      Expanded(
                        flex: 1,
                        child: FxButton(
                          title: "Delete",
                          color: Constants.red,
                          onPress: () {
                            // ref.read(invoiceDeleteProvider.notifier).delete(
                            //       invoiceId: int.parse(invoice.evInvoiceID!),
                            //       query: query,
                            //     );
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    if (invoice.evInvoiceID != "0") const SizedBox(width: 20),
                  ],
                ),
                const SizedBox(height: 20), // Add some space at the bottom
              ],
            ),
          ),
        ),
      ),
    );
  }
}
