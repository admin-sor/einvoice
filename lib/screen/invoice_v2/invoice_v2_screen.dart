import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sor_inventory/screen/invoice_v2/lhdn_validation.dart';
import 'package:sor_inventory/screen/invoice_v2/submit_lhdn_provider.dart';
import 'package:sor_inventory/widgets/fx_text_area_field.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../model/client_model.dart';
import '../../model/product_model.dart';
import '../../screen/invoice_v2/edit_invoice_v2_provider.dart';
import '../../screen/invoice_v2/get_detail_provider.dart';
import '../../screen/invoice_v2/invoice_id_provider.dart';
import '../../widgets/fx_ac_client.dart';
import '../../widgets/fx_invoice_product_info.dart';
import '../../widgets/fx_multiline_text_field.dart';

import '../../app/constants.dart';
import '../../model/invoice_v2_model.dart';
import '../../model/payment_term_response_model.dart';
import '../../model/sor_user_model.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_auto_completion_product.dart';
import '../../widgets/fx_button.dart';
import '../../widgets/fx_date_field.dart';
import '../../widgets/fx_payment_term_lk.dart';
import '../../widgets/fx_tab_button.dart';
import '../../widgets/fx_text_field.dart';
import '../login/login_provider.dart';
import 'add_detail_provider.dart';
import 'delete_detail_provider.dart';
import 'get_header_provider.dart';
import 'save_term_provider.dart';

class InvoiceV2Screen extends HookConsumerWidget {
  final bool fromSummary;
  final InvoiceV2Model? invoiceModel;
  final ClientModel? client;
  final String startDate;
  final String endDate;
  final String status;
  final List<InvoiceDetailModel>? detail;

  InvoiceV2Screen({
    Key? key,
    this.fromSummary = false,
    this.invoiceModel,
    this.startDate = "",
    this.endDate = "",
    this.client,
    this.status = "A",
    this.detail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginModel = useState<SorUser?>(null);
    final isInit = useState(true);
    final selectedTabIndex = useState<int>(0);

    final isInEditMode = useState(!fromSummary);
    double screenWidth = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      screenWidth = Constants.webWidth - 20;
    }

    final nbf = NumberFormat("###,##0", "en_US");
    final nbfDec = NumberFormat("###,##0.00", "en_US");
    final nbfDecThree = NumberFormat("###,##0.000", "en_US");

    ref.listen(loginStateProvider, (prev, next) {
      if (next is LoginStateDone) {
        loginModel.value = next.loginModel;
      }
    });

    //client

    final selectedClient = useState<ClientModel?>(fromSummary ? client : null);
    final errorMessageClient = useState<String>("");
    //invoice date
    final invoiceDate = useState<DateTime>(DateTime.now());
    final fromDate = useState<DateTime>(DateTime.now());
    final toDate = useState<DateTime>(DateTime.now());
    //invoice no
    final invoiceID = ref.watch(invoiceIDProvider);
    final ctrlInvoiceNo = useTextEditingController(
        text: fromSummary ? invoiceModel?.invoiceNo : "");
    final ctrlInvoiceDate = useTextEditingController(
        text: fromSummary ? invoiceModel?.invoiceDate : "");
    final errorMessageInvoiceV2 = useState("");
    //payment term
    final selectedPaymentTerm = useState<PaymentTermResponseModel?>(null);
    final ctrlPaymentTerm = useTextEditingController(
        text: fromSummary ? invoiceModel?.invoiceTerm : "");

    final lastLhdnStatus = useState(invoiceModel?.invoiceLHDNStatus ?? "N");
    final lastLhdnStatusUpdated =
        useState<String?>(invoiceModel?.invoiceLHDNLastUpdated);

    final errorMessageSave = useState("");
    final isLoadingEdit = useState(false);

    //Terms & Conditions
    final isLoadingClientTerm = useState(false);
    final lastClientTerm = useState("");

    //no login
    if (loginModel.value == null) {
      if (isInit.value) {
        isInit.value = false;
        Timer(const Duration(milliseconds: 500), () {
          ref.read(loginStateProvider.notifier).checkLocalToken();
        });
      }
      return Scaffold(
        body: Container(
          color: Colors.white,
        ),
      );
    }

    final validationDate = useState("");
    final sdf = DateFormat("y-M-d");
    final sdfMan = DateFormat("d MMM y");
    try {
      invoiceDate.value = sdf.parse(invoiceModel?.invoiceDate ?? "");
    } catch (_) {}
    const horiSpace = SizedBox(width: 10);
    const materialCodeWidth = 115.0;

    double pageWidth = MediaQuery.of(context).size.width - 45;
    if (kIsWeb) {
      pageWidth = Constants.webWidth - 45;
    }
    double width25 = (pageWidth - materialCodeWidth - 30) / 3;
    double width50 = width25 * 2 + 10;

    //invoice detail
    final listInvoiceDetail = useState<List<InvoiceDetailModel>>(
        fromSummary ? (detail ?? List.empty()) : List.empty());

    //list invoiceDetail
    final isLoadingDetail = useState(false);
    ref.listen(getDetailProvider, (prev, next) {
      if (next is GetDetailStateLoading) {
        isLoadingDetail.value = true;
      } else if (next is GetDetailStateError) {
        errorMessageSave.value = next.message;
        Timer(Duration(seconds: 3), () {
          errorMessageSave.value = "";
        });
        isLoadingDetail.value = false;
      } else if (next is GetDetailStateDone) {
        isLoadingDetail.value = false;
        listInvoiceDetail.value = next.model;
      }
    });
    ref.listen(getInvoiceHeaderProvider, (prev, next) {
      if (next is GetInvoiceHeaderStateLoading) {
        isLoadingDetail.value = true;
        errorMessageSave.value = "";
      } else if (next is GetInvoiceHeaderStateError) {
        errorMessageSave.value = next.message;
        isLoadingDetail.value = false;
      } else if (next is GetInvoiceHeaderStateDone) {
        errorMessageSave.value = "";
        isLoadingDetail.value = false;
        try {
          validationDate.value =
              sdfMan.format(sdf.parse(next.model.validationDate));
        } catch (_) {}
      }
    });
    // add Product
    final addProductReady = useState(false);
    final showAddProduct = useState(false);
    final selectedProduct = useState<ProductModel?>(null);
    final ctrlProduct = useTextEditingController(text: "");
    final ctrlProductDesc = useTextEditingController(text: "");
    final errorMessageProduct = useState("");
    final fcProduct = useFocusNode();
    //Total Item
    final errorMessageQty = useState("");
    final ctrlTotalItem = useTextEditingController(text: "1");
    final fcTotalItem = useFocusNode();
    final showTotalQtyAmount = useState(false);
    //price
    final ctrlPrice = useTextEditingController(text: "");
    final fcPrice = useFocusNode();
    final errorMessagePrice = useState("");
    //uom
    final ctrlUom = useTextEditingController(text: "");
    final fcUom = useFocusNode();

    //total amount
    final isLoading = useState(false);
    final ctrlTotalAmount = useTextEditingController(text: "");

    ref.listen(invoiceIDProvider, (prev, next) {
      if (next.toString() != "0") {
        addProductReady.value = true;
        // isInEditMode.value = false;
        // showAddProduct.value = true;
      }
    });
    void doCalcTotal(String price, String qty) {
      ctrlTotalAmount.text = "0.00";
      try {
        ctrlTotalAmount.text =
            nbfDec.format(nbfDec.parse(price) * nbf.parse(qty));
      } catch (_) {}
    }

    bool isDetailValid({withMessage = false}) {
      bool result = true;
      if (ctrlUom.text == "") {
        if (withMessage) errorMessageSave.value = "UOM is Mandatory";
        result = false;
      }
      try {
        nbfDec.parse(ctrlPrice.text);
      } catch (_) {
        if (withMessage) errorMessageSave.value = "Invalid Price";
        result = false;
      }
      try {
        nbfDec.parse(ctrlTotalItem.text);
      } catch (_) {
        if (withMessage) errorMessageSave.value = "Invalid Total Item";
        result = false;
      }
      if (!result && withMessage) {
        Timer(const Duration(seconds: 3), () {
          errorMessageSave.value = "";
        });
      }
      return result;
    }

    //listen save Header
    final isLoadingSave = useState(false);
    ref.listen(editInvoiceProvider, (prev, next) {
      if (next is EditInvoiceStateLoading) {
        isLoadingSave.value = true;
      } else if (next is EditInvoiceStateError) {
        isLoadingSave.value = false;
        errorMessageSave.value = next.message;
        Timer(const Duration(seconds: 3), () {
          errorMessageSave.value = "";
        });
      } else if (next is EditInvoiceStateDone) {
        isLoadingSave.value = false;
      }
    });
    ref.listen(addDetailProvider, (prev, next) {
      if (next is AddDetailStateLoading) {
        isLoadingSave.value = true;
      } else if (next is AddDetailStateError) {
        isLoadingSave.value = false;
        errorMessageSave.value = next.message;
        Timer(const Duration(seconds: 3), () {
          errorMessageSave.value = "";
        });
      } else if (next is AddDetailStateDone) {
        isLoadingSave.value = false;
        showAddProduct.value = false;
        addProductReady.value = true;
        selectedProduct.value = null;
        ctrlProduct.text = "";
        ctrlProductDesc.text = "";
      }
    });
    final isLoadingSubmitLhdn = useState(false);
    ref.listen(submitLhdnProvider, (prev, next) {
      if (next is SubmitLHDNStateLoading) {
        isLoadingSubmitLhdn.value = true;
      } else if (next is SubmitLHDNStateError) {
        isLoadingSubmitLhdn.value = false;
        errorMessageSave.value = next.message;
        Timer(const Duration(seconds: 3), () {
          errorMessageSave.value = "";
        });
      } else if (next is SubmitLHDNStateDone) {
        isLoadingSubmitLhdn.value = false;
        if (next.model.rejectedDocuments.isNotEmpty) {
          // error submission
          lastLhdnStatus.value = "E";
          lastLhdnStatusUpdated.value = sdf.format(DateTime.now());
        } else if (next.model.acceptedDocuments.isNotEmpty) {
          lastLhdnStatus.value = "Y";
          ctrlInvoiceDate.text = next.model.invoiceDate;
          ctrlInvoiceNo.text = next.model.invoiceNo;

          lastLhdnStatusUpdated.value = sdf.format(DateTime.now());
          Timer(const Duration(seconds: 5), () {
            ref
                .read(lhdnValidationProvider.notifier)
                .validate(invoiceID: invoiceID);
          });
        }
      }
    });

    String submittedDate = "";
    try {
      if (invoiceModel != null) {
        submittedDate = sdfMan
            .format(sdf.parse(invoiceModel?.invoiceLHDNLastUpdated ?? ""));
      }
      if (lastLhdnStatusUpdated.value != "") {
        submittedDate = sdfMan.format(sdf.parse(lastLhdnStatusUpdated.value!));
      }
    } catch (_) {}
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          "Invoice",
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
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: Constants.paddingTopContent),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: FxAcClient(
                        initialValue: TextEditingValue(
                            text: selectedClient.value?.evClientName ?? ""),
                        contentPadding: const EdgeInsets.all(14),
                        labelText: "Client",
                        hintText: "Client",
                        readOnly: !isInEditMode.value,
                        value: selectedClient.value?.evClientName ?? "",
                        onSelected: (model) {
                          selectedClient.value = model;
                          if (true || ctrlInvoiceNo.text != "") {
                            showAddProduct.value = true;
                          }
                        },
                        errorMessage: errorMessageClient.value,
                      ),
                    ),
                    horiSpace,
                    Expanded(
                      child: FxTextField(
                        labelText: "Invoice Date",
                        readOnly: true,
                        enabled: false,
                        ctrl: ctrlInvoiceDate,
                      ),
                      // FxDateField(
                      //   hintText: "Invoice Date",
                      //   labelText: "Invoice Date",
                      //   dateValue: invoiceDate.value,
                      //   readOnly: !isInEditMode.value,
                      //   firstDate: DateTime.now().subtract(
                      //     const Duration(
                      //       days: 365 * 2,
                      //     ),
                      //   ),
                      //   lastDate: DateTime.now().add(
                      //     const Duration(
                      //       days: 365 * 2,
                      //     ),
                      //   ),
                      //   onDateChange: (dt) {
                      //     invoiceDate.value = dt;
                      //   },
                      // ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                if (selectedClient.value != null)
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: FxTextField(
                          errorMessage: errorMessageInvoiceV2.value,
                          ctrl: ctrlInvoiceNo,
                          hintText: "Invoice No.",
                          labelText: "Invoice No.",
                          readOnly: true, // !isInEditMode.value,
                          enabled: false,
                          onChanged: (v) {
                            // if (selectedClient.value != null && v != "") {
                            //   showAddProduct.value = true;
                            // } else {
                            //   showAddProduct.value = false;
                            // }
                          },
                        ),
                      ),
                      horiSpace,
                      Expanded(
                        child: FxPaymentTermLk(
                            hintText: "Payment Term",
                            labelText: "Payment Term",
                            initialValue: selectedPaymentTerm.value,
                            readOnly: !isInEditMode.value,
                            vendorID: selectedClient.value!.evClientID ?? "0",
                            onChanged: (val) {
                              selectedPaymentTerm.value = val;
                              ctrlPaymentTerm.text = val.paymentTermName;
                            }),
                      ),
                    ],
                  ),
                if (selectedClient.value != null)
                  const SizedBox(
                    height: 10,
                  ),
                if (fromSummary && isInEditMode.value)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: FxButton(
                            title: "Cancel",
                            color: Constants.red,
                            isLoading: isLoadingEdit.value,
                            onPress: (selectedClient.value == null)
                                ? null
                                : () {
                                    isInEditMode.value = false;
                                  },
                          ),
                        ),
                        horiSpace,
                        Expanded(
                          child: FxButton(
                            title: "Save",
                            isLoading: isLoadingSave.value,
                            color: Constants.greenDark,
                            onPress: (selectedClient.value == null ||
                                    ctrlInvoiceNo.text == "")
                                ? null
                                : () {
                                    ref
                                        .read(editInvoiceProvider.notifier)
                                        .saveHeader(
                                          date: invoiceDate.value,
                                          clientID: selectedClient
                                                  .value?.evClientID ??
                                              "0",
                                          invoiceNo: ctrlInvoiceNo.text,
                                          paymentTermID: selectedPaymentTerm
                                              .value!.paymentTermID,
                                          invoiceID: invoiceID,
                                        );
                                  },
                          ),
                        ),
                      ],
                    ),
                  ),
                if (selectedClient.value != null)
                  FxTabButton(
                      tabs: const ["List of Product", "Terms & Conditions"],
                      selectedIndex: selectedTabIndex.value,
                      onSelectedTab: (tabIndex) {
                        selectedTabIndex.value = tabIndex;
                      }),
                if (invoiceID != "0")
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      if (isInEditMode.value)
                        Expanded(
                          child: FxButton(
                            // prefix: Padding(
                            //   padding: const EdgeInsets.only(right: 10.0),
                            //   child: Image.asset(
                            //     "images/add_icon.png",
                            //     width: 18,
                            //     height: 18,
                            //   ),
                            // ),
                            title: "Add Product",
                            color: Constants.orange,
                            onPress: addProductReady.value
                                ? () {
                                    showAddProduct.value = true;
                                  }
                                : null,
                          ),
                        ),
                      if (!isInEditMode.value &&
                          lastLhdnStatus.value == "Y" &&
                          validationDate.value == "")
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text("LHDN Submission on " + submittedDate),
                        )),
                      if (validationDate.value != "")
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                              "LHDN Validation on " + validationDate.value),
                        )),
                      if (!isInEditMode.value && lastLhdnStatus.value != "Y")
                        Expanded(
                          child: FxButton(
                            // prefix: Padding(
                            //   padding: const EdgeInsets.only(right: 10.0),
                            //   child: Image.asset(
                            //     "images/submission_icon.png",
                            //     width: 18,
                            //     height: 18,
                            //   ),
                            // ),
                            isLoading: isLoadingSubmitLhdn.value,
                            title: "Submit to LHDN",
                            color: Constants.colorPurple,
                            onPress: () {
                              ref
                                  .read(submitLhdnProvider.notifier)
                                  .submit(invoiceID: invoiceID);
                            },
                          ),
                        ),
                      horiSpace,
                      if (!isInEditMode.value)
                        Expanded(
                          child: FxButton(
                            title: "Edit Invoice",
                            color: Constants.greenDark,
                            isLoading: isLoadingEdit.value,
                            onPress: lastLhdnStatus.value == "N"
                                ? () {
                                    isInEditMode.value = true;
                                  }
                                : null,
                          ),
                        ),
                      if (!fromSummary && isInEditMode.value)
                        Expanded(
                          child: FxButton(
                            // prefix: Padding(
                            //   padding: const EdgeInsets.only(right: 10.0),
                            //   child: Image.asset(
                            //     "images/tick_icon.png",
                            //     width: 18,
                            //     height: 18,
                            //   ),
                            // ),
                            title: "Done",
                            color: Constants.greenDark,
                            onPress: () {
                              isInEditMode.value = false;
                              showAddProduct.value = false;
                            },
                            // onPress: listInvoiceDetail.value.isNotEmpty
                            //     ? () {
                            //         Navigator.of(context).pop();
                            //       }
                            //     : null,
                          ),
                        ),
                      if (listInvoiceDetail.value.isNotEmpty) horiSpace,
                      if (listInvoiceDetail.value.isNotEmpty)
                        Expanded(
                          child: FxButton(
                            title: "Print Invoice",
                            color: Constants.buttonBlue,
                            onPress: () {
                              final snow =
                                  "&t=${DateTime.now().toIso8601String()}";
                              final preUrl =
                                  "https://${Constants.host}/reports/einvoice.php?id=$invoiceID";
                              final url = "$preUrl$snow";
                              launchUrlString(url);
                              if (lastLhdnStatus.value == "Y") {
                                ref
                                    .read(getInvoiceHeaderProvider.notifier)
                                    .get(invoiceID: invoiceID);
                              }
                              // if (kIsWeb) {
                              //   html.window.open(url, "rpttab");
                              //   return;
                              // }
                            },
                          ),
                        ),
                    ],
                  ),
                if (errorMessageSave.value != "")
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        errorMessageSave.value,
                        style:
                            const TextStyle(color: Constants.red, fontSize: 16),
                      ),
                    ),
                  ),
                const SizedBox(
                  height: 10,
                ),
                if (showAddProduct.value)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Constants.greenDark),
                      borderRadius: BorderRadius.circular(10),
                      color: Constants.greenLight.withOpacity(0.01),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: screenWidth ,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // selectedProduct.value == null
                                  FxAutoCompletionProduct(
                                    width: 120,
                                    ctrl: ctrlProduct,
                                    fc: fcProduct,
                                    errorMessage: errorMessageProduct.value,
                                    invoiceID: invoiceID,
                                    labelText: "Product",
                                    hintText: "Search",
                                    value:
                                        selectedProduct.value?.evProductCode ??
                                            "",
                                    onSelectedProduct: (model) {
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
                                      ctrlProductDesc.text =
                                          model?.evProductDescription ?? "";

                                      if (model == null) {
                                        ctrlUom.text = "";
                                        selectedProduct.value = null;
                                        ctrlTotalItem.text = "0";
                                        ctrlPrice.text = "0.00";
                                        ctrlTotalAmount.text = "0.00";
                                      } else {
                                        selectedProduct.value = model;
                                        ctrlUom.text =
                                            model.evProductUnit ?? "";
                                        ctrlTotalItem.text = "1";
                                        ctrlPrice.text = nbfDec.format(
                                            nbfDec.parse(model.evProductPrice ??
                                                "0.00"));

                                        doCalcTotal(
                                            model.evProductPrice ?? "0.00",
                                            "1");
                                        showTotalQtyAmount.value = true;

                                        if (model.evProductPrice == null ||
                                            model.evProductPrice == "0.00") {
                                          errorMessagePrice.value =
                                              "Price not set";
                                          Timer(const Duration(seconds: 3), () {
                                            errorMessagePrice.value = "";
                                          });
                                        } else {
                                          errorMessagePrice.value = "";
                                        }
                                      }
                                      // checkIsConfirmValid();
                                    },
                                  ),
                                  horiSpace,
                                  if (selectedProduct.value != null) Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: FxTextField(
                                      width: 80,
                                      focusNode: fcTotalItem,
                                      textAlign: TextAlign.end,
                                      onChanged: (val) {
                                        try {
                                          num xval =
                                              nbf.parse(ctrlTotalItem.text);
                                          if (xval > 0.0) {
                                            showTotalQtyAmount.value = true;
                                          } else {
                                            showTotalQtyAmount.value = false;
                                          }
                                        } catch (e) {
                                          showTotalQtyAmount.value = false;
                                        }
                                        doCalcTotal(ctrlPrice.text, val);
                                      },
                                      errorMessage: errorMessageQty.value,
                                      showErrorMessage: true,
                                      ctrl: ctrlTotalItem,
                                      hintText: "Total Item",
                                      labelText: "Total Item",
                                      textInputType: TextInputType.number,
                                    ),
                                  ),
                                  horiSpace,
                                  if (selectedProduct.value != null)Padding(
                                    padding: const EdgeInsets.only(top: 5.0),
                                    child: FxTextField(
                                      focusNode: fcPrice,
                                      textAlign: TextAlign.end,
                                      width: 100,
                                      ctrl: ctrlPrice,
                                      enabled: true,
                                      hintText: "Unit Price",
                                      labelText: "Unit Price",
                                      onChanged: (val) {
                                        doCalcTotal(val, ctrlTotalItem.text);
                                      },
                                      readOnly: false,
                                      errorMessage: errorMessagePrice.value,
                                    ),
                                  ),
                                  horiSpace,
                                  (!showTotalQtyAmount.value)
                                      ? SizedBox(width:120)
                                      : Padding(
                                        padding:
                                            const EdgeInsets.only(top: 5.0),
                                        child: FxTextField(
                                          width: 130,
                                          textAlign: TextAlign.end,
                                          ctrl: ctrlTotalAmount,
                                          readOnly: true,
                                          enabled: false,
                                          hintText: "Total Amount(RM)",
                                          labelText: "Total Amount(RM)",
                                        ),
                                      ),
                                  if (selectedProduct.value != null) horiSpace,
                                  if (selectedProduct.value != null)
                                    Expanded(
                                      child: FxTextAreaField(
                                        hintText: "Description",
                                        labelText: "Description",
                                        ctrl: ctrlProductDesc,
                                        readOnly: false,
                                        enabled: true,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              FxButton(
                                maxWidth: screenWidth,
                                isLoading: isLoading.value,
                                title: "Save",
                                onPress: !isDetailValid()
                                    ? null
                                    : () {
                                        ref
                                            .read(addDetailProvider.notifier)
                                            .add(
                                              invoiceID: invoiceID,
                                              clientID: selectedClient
                                                      .value?.evClientID ??
                                                  "0",
                                              invoiceNo: ctrlInvoiceNo.text,
                                              invoiceTerm: selectedPaymentTerm
                                                      .value?.paymentTermName ??
                                                  "",
                                              paymentTermID: selectedPaymentTerm
                                                      .value?.paymentTermID ??
                                                  "0",
                                              invoiceDate: invoiceDate.value,
                                              dateFrom: fromDate.value,
                                              dateTo: toDate.value,
                                              productDescription:
                                                  ctrlProductDesc.text,
                                              productID: selectedProduct
                                                      .value?.evProductID ??
                                                  "0",
                                              taxPercent: selectedProduct.value
                                                      ?.evProductTaxPercent ??
                                                  "0",
                                              uom: ctrlUom.text,
                                              qty: ctrlTotalItem.text,
                                              price: ctrlPrice.text,
                                            );
                                      },
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (selectedTabIndex.value == 1)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: 10.0,
                      ),
                      child: FxButton(
                        title: "Save",
                        color: Constants.greenDark,
                        isLoading: isLoadingClientTerm.value,
                        onPress: invoiceID == "0"
                            ? null
                            : () {
                                ref.read(saveTermProvider.notifier).save(
                                      term: lastClientTerm.value,
                                      invoiceID: invoiceID,
                                    );
                              },
                      ),
                    ),
                  ),
                if (selectedTabIndex.value == 1)
                  FxMultilineTextField(
                    initialValue: lastClientTerm.value,
                    onChange: (val) {
                      lastClientTerm.value = val;
                    },
                    isReadOnly: false,
                  ),
                if (selectedTabIndex.value == 0)
                  ...listInvoiceDetail.value.map((model) {
                    final idx = listInvoiceDetail.value.indexOf(model);
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FxInvoiceProductInfo(
                        model: model,
                        isFirst: idx == 0,
                        onDelete: lastLhdnStatus.value == "N" &&
                                isInEditMode.value
                            ? () {
                                ref.read(deleteDetailProvider.notifier).delete(
                                      invoiceDetailID: model.invoiceDetailID,
                                      invoiceID: invoiceID,
                                    );
                              }
                            : null,
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
