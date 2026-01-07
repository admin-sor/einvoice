import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../app/constants.dart';
import '../../model/invoice_model.dart';
import '../../model/invoice_v2_model.dart';
import '../../model/payment_term_response_model.dart';
import '../../model/product_model.dart';
import '../../model/sor_user_model.dart';
import '../../model/supplier_model.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_ac_supplier.dart';
import '../../widgets/fx_auto_completion_product.dart';
import '../../widgets/fx_button.dart';
import '../../widgets/fx_date_field.dart';
import '../../widgets/fx_invoice_product_info.dart';
import '../../widgets/fx_multiline_text_field.dart';
import '../../widgets/fx_payment_term_lk.dart';
import '../../widgets/fx_tab_button.dart';
import '../../widgets/fx_text_area_field.dart';
import '../../widgets/fx_text_field.dart';
import '../login/login_provider.dart';
import '../invoice_v2/lhdn_validation.dart';
import '../invoice_v2/submit_lhdn_provider.dart';
import 'self_bill_add_detail_provider.dart';
import 'self_bill_id_provider.dart';

class SelfBillScreen extends HookConsumerWidget {
  final bool fromSummary;
  final InvoiceModel? invoiceModel;
  final List<InvoiceDetailModel>? detail;
  const SelfBillScreen({
    Key? key,
    this.fromSummary = false,
    this.invoiceModel,
    this.detail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginModel = useState<SorUser?>(null);
    final isInit = useState(true);
    final initialSupplier = fromSummary && invoiceModel != null
        ? SupplierModel(
            evSupplierID: invoiceModel?.evInvoiceSupplierID,
            evSupplierName: invoiceModel?.evInvoiceSupplierName,
          )
        : null;
    final selectedSupplier = useState<SupplierModel?>(initialSupplier);
    double screenWidth = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      screenWidth = Constants.webWidth - 20;
    }
    final errorMessageSupplier = useState<String>("");
    final ctrlInvoiceDate = useTextEditingController(
      text: fromSummary ? (invoiceModel?.evInvoiceIssueDate ?? "") : "",
    );
    final ctrlInvoiceNo = useTextEditingController(
      text: fromSummary ? (invoiceModel?.evInvoiceNo ?? "") : "",
    );
    final ctrlPaymentTerm = useTextEditingController(text: "");
    final selectedPaymentTerm = useState<PaymentTermResponseModel?>(null);
    final selectedProduct = useState<ProductModel?>(null);
    final ctrlProduct = useTextEditingController(text: "");
    final ctrlProductDesc = useTextEditingController(text: "");
    final ctrlUom = useTextEditingController(text: "");
    final ctrlTotalItem = useTextEditingController(text: "1");
    final ctrlPrice = useTextEditingController(text: "0.00");
    final ctrlTotalAmount = useTextEditingController(text: "0.00");
    final fcProduct = useFocusNode();
    final fcTotalItem = useFocusNode();
    final fcPrice = useFocusNode();
    final errorMessageProduct = useState("");
    final errorMessageQty = useState("");
    final errorMessagePrice = useState("");
    final showTotalQtyAmount = useState(false);
    final nbf = NumberFormat("###,##0", "en_US");
    final nbfDec = NumberFormat("###,##0.00", "en_US");
    final selectedTabIndex = useState<int>(0);
    final showAddProduct = useState(false);
    final fromDate = useState<DateTime>(DateTime.now());
    final toDate = useState<DateTime>(DateTime.now());
    final terms = useState("");
    List<_SelfBillProduct> mapDetailToProduct(
        List<InvoiceDetailModel>? detail) {
      if (detail == null || detail.isEmpty) {
        return List.empty();
      }
      return detail.map((item) {
        final product = ProductModel(
          evProductID: item.invoiceDetailEvProductID,
          evProductCode: item.evProductCode,
          evProductDescription: item.evProductDescription,
          evProductUnit: item.invoiceDetailUnit,
          evProductPrice: item.invoiceDetailPrice,
        );
        return _SelfBillProduct(
          product: product,
          description: item.evProductDescription,
          qty: item.invoiceDetailQty,
          unitPrice: item.invoiceDetailPrice,
          uom: item.invoiceDetailUnit,
          total: "0.00",
          dateFrom: DateTime.now(),
          dateTo: DateTime.now(),
        );
      }).toList();
    }

    final listProduct = useState<List<_SelfBillProduct>>(
      fromSummary ? mapDetailToProduct(detail) : List.empty(),
    );
    final isInEditMode = useState(!fromSummary);
    final addProductReady = useState(true);
    final isLoadingSubmitLhdn = useState(false);
    final isLoadingEdit = useState(false);
    final lastLhdnStatus =
        useState(fromSummary ? (invoiceModel?.evInvoiceStatus ?? "N") : "N");
    final validationDate = useState(
      fromSummary ? (invoiceModel?.evInvoiceValidationDate ?? "") : "",
    );
    final lastLhdnStatusUpdated = useState<String?>(
      fromSummary ? invoiceModel?.evInvoiceLastSubmissionDate : null,
    );
    final selfBillID = ref.watch(selfBillIDProvider);
    final pendingProduct = useState<_SelfBillProduct?>(null);
    final errorMessageSave = useState("");
    final isLoadingSave = useState(false);
    final sdf = DateFormat("yyyy-MM-dd HH:mm:ss");
    final sdfMan = DateFormat("dd MMM yyyy");

    ref.listen(loginStateProvider, (prev, next) {
      if (next is LoginStateDone) {
        loginModel.value = next.loginModel;
      }
    });
    useEffect(() {
      if (fromSummary && invoiceModel != null) {
        ref.read(selfBillIDProvider.notifier).state =
            invoiceModel?.evInvoiceID ?? "0";
      }
      return null;
    }, [fromSummary, invoiceModel?.evInvoiceID]);

    // Keep the login bootstrap flow consistent with InvoiceV2Screen.
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

    const horiSpace = SizedBox(width: 10);
    void doCalcTotal(String price, String qty) {
      ctrlTotalAmount.text = "0.00";
      try {
        ctrlTotalAmount.text =
            nbfDec.format(nbfDec.parse(price) * nbf.parse(qty));
      } catch (_) {}
    }

    bool isDetailValid({bool withMessage = false}) {
      bool result = true;
      if (ctrlUom.text.trim().isEmpty) {
        result = false;
        if (withMessage) errorMessageSave.value = "UOM is Mandatory";
      }
      try {
        nbfDec.parse(ctrlPrice.text);
      } catch (_) {
        result = false;
        if (withMessage) errorMessageSave.value = "Invalid Price";
      }
      try {
        nbf.parse(ctrlTotalItem.text);
      } catch (_) {
        result = false;
        if (withMessage) errorMessageSave.value = "Invalid Qty";
      }
      if (!result && withMessage) {
        Timer(const Duration(seconds: 3), () {
          errorMessageSave.value = "";
        });
      }
      return result;
    }

    ref.listen(selfBillAddDetailProvider, (prev, next) {
      if (next is SelfBillAddDetailStateLoading) {
        isLoadingSave.value = true;
        errorMessageSave.value = "";
      } else if (next is SelfBillAddDetailStateError) {
        isLoadingSave.value = false;
        errorMessageSave.value = next.message;
        Timer(const Duration(seconds: 3), () {
          errorMessageSave.value = "";
        });
      } else if (next is SelfBillAddDetailStateDone) {
        isLoadingSave.value = false;
        if (pendingProduct.value != null) {
          listProduct.value = [...listProduct.value, pendingProduct.value!];
          pendingProduct.value = null;
        }
        showAddProduct.value = false;
        selectedProduct.value = null;
        ctrlProduct.text = "";
        ctrlProductDesc.text = "";
        ctrlTotalItem.text = "1";
        ctrlPrice.text = "0.00";
        ctrlTotalAmount.text = "0.00";
        ctrlUom.text = "";
      }
    });
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
                .validate(invoiceID: selfBillID);
          });
        }
        if (next.model.getError() != "" && errorMessageSave.value == "") {
          errorMessageSave.value = next.model.getError();
          Timer(const Duration(seconds: 3), () {
            if (errorMessageSave.value == next.model.getError()) {
              errorMessageSave.value = "";
            }
          });
        }
      }
    });

    String submittedDate = "";
    try {
      if (lastLhdnStatusUpdated.value?.isNotEmpty ?? false) {
        submittedDate = sdfMan.format(sdf.parse(validationDate.value ?? ""));
      }
    } catch (_) {}

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          "Self Bill",
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
          width: MediaQuery.of(context).size.width,
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
                      child: FxAcSupplier(
                        initialValue: TextEditingValue(
                          text: selectedSupplier.value?.evSupplierName ?? "",
                        ),
                        contentPadding: const EdgeInsets.all(14),
                        labelText: "Supplier",
                        hintText: "Supplier",
                        value: selectedSupplier.value?.evSupplierName ?? "",
                        onSelected: (model) {
                          selectedSupplier.value = model;
                          showAddProduct.value = true;
                          selectedTabIndex.value = 0;
                        },
                        errorMessage: errorMessageSupplier.value,
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
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                if (selectedSupplier.value != null)
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: FxTextField(
                              labelText: "Invoice No.",
                              readOnly: true,
                              enabled: false,
                              ctrl: ctrlInvoiceNo,
                            ),
                          ),
                          horiSpace,
                          Expanded(
                            child: FxPaymentTermLk(
                              hintText: "Payment Type",
                              labelText: "Payment Type",
                              initialValue: selectedPaymentTerm.value,
                              readOnly: true,
                              vendorID:
                                  selectedSupplier.value?.evSupplierID ?? "0",
                              onChanged: (val) {},
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const SizedBox(height: 10),
                      FxTabButton(
                        tabs: const ["List of Product", "Terms & Conditions"],
                        selectedIndex: selectedTabIndex.value,
                        onSelectedTab: (tabIndex) {
                          selectedTabIndex.value = tabIndex;
                        },
                      ),
                      const SizedBox(height: 10),
                      if (selfBillID != "0")
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            if (isInEditMode.value)
                              Expanded(
                                child: FxButton(
                                  title: "Add Product",
                                  color: Constants.orange,
                                  onPress: addProductReady.value
                                      ? () {
                                          selectedTabIndex.value = 0;
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
                                child: Text("Pending LHDN"),
                              )),
                            if (validationDate.value != "")
                              Expanded(
                                  child: Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Text("Submittied " + submittedDate),
                              )),
                            if (!isInEditMode.value &&
                                lastLhdnStatus.value != "Y")
                              Expanded(
                                child: FxButton(
                                  isLoading: isLoadingSubmitLhdn.value,
                                  title: "Submit to LHDN",
                                  color: Constants.colorPurple,
                                  onPress: () {
                                    ref
                                        .read(submitLhdnProvider.notifier)
                                        .submit(invoiceID: selfBillID);
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
                                  onPress: () {
                                    isInEditMode.value = true;
                                  },
                                ),
                              ),
                            if (!fromSummary && isInEditMode.value)
                              Expanded(
                                child: FxButton(
                                  title: "Done",
                                  color: Constants.greenDark,
                                  onPress: () {
                                    isInEditMode.value = false;
                                    showAddProduct.value = false;
                                  },
                                ),
                              ),
                            if (listProduct.value.isNotEmpty) horiSpace,
                            if (listProduct.value.isNotEmpty)
                              Expanded(
                                child: FxButton(
                                  title: "Print Invoice",
                                  color: Constants.buttonBlue,
                                  onPress: () {
                                    final snow =
                                        "&t=${DateTime.now().toIso8601String()}";
                                    final preUrl =
                                        "https://${Constants.host}/reports/einvoice_sb.php?id=$selfBillID";
                                    final url = "$preUrl$snow";
                                    launchUrlString(url);
                                  },
                                ),
                              ),
                          ],
                        ),
                      // if (errorMessageSave.value.isNotEmpty)
                      //   Padding(
                      //     padding:
                      //         const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      //     child: SizedBox(
                      //       width: double.infinity,
                      //       child: Text(
                      //         errorMessageSave.value,
                      //         style: const TextStyle(
                      //           color: Constants.red,
                      //           fontSize: 16,
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      const SizedBox(height: 10),
                      if (showAddProduct.value)
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Constants.greenDark),
                            borderRadius: BorderRadius.circular(10),
                            color: Constants.greenLight.withOpacity(0.05),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: screenWidth,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: FxAutoCompletionProduct(
                                            ctrl: ctrlProduct,
                                            fc: fcProduct,
                                            errorMessage:
                                                errorMessageProduct.value,
                                            invoiceID: "0",
                                            labelText: "Product",
                                            hintText: "Search",
                                            value: selectedProduct
                                                    .value?.evProductCode ??
                                                "",
                                            onSelectedProduct: (model) {
                                              FocusScope.of(context)
                                                  .requestFocus(FocusNode());
                                              selectedProduct.value = model;
                                              if (model == null) {
                                                ctrlProductDesc.text = "";
                                                ctrlUom.text = "";
                                                ctrlTotalItem.text = "0";
                                                ctrlPrice.text = "0.00";
                                                ctrlTotalAmount.text = "0.00";
                                                showTotalQtyAmount.value =
                                                    false;
                                              } else {
                                                ctrlProductDesc.text = model
                                                        .evProductDescription ??
                                                    "";
                                                ctrlUom.text =
                                                    model.evProductUnit ?? "";
                                                ctrlTotalItem.text = "1";
                                                final price =
                                                    model.evProductPrice ??
                                                        "0.00";
                                                ctrlPrice.text = nbfDec.format(
                                                    nbfDec.parse(price));
                                                ctrlTotalAmount.text =
                                                    nbfDec.format(
                                                        nbfDec.parse(price));
                                                showTotalQtyAmount.value = true;
                                              }
                                            },
                                          ),
                                        ),
                                        if (selectedProduct.value != null)
                                          horiSpace,
                                        if (selectedProduct.value != null)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5),
                                            child: FxTextField(
                                              width: 80,
                                              focusNode: fcTotalItem,
                                              textAlign: TextAlign.end,
                                              onChanged: (val) {
                                                try {
                                                  num xval = nbf.parse(
                                                      ctrlTotalItem.text);
                                                  showTotalQtyAmount.value =
                                                      xval > 0;
                                                } catch (_) {
                                                  showTotalQtyAmount.value =
                                                      false;
                                                }
                                                doCalcTotal(
                                                    ctrlPrice.text, val);
                                              },
                                              errorMessage:
                                                  errorMessageQty.value,
                                              showErrorMessage: true,
                                              ctrl: ctrlTotalItem,
                                              hintText: "Total Item",
                                              labelText: "Total Item",
                                              textInputType:
                                                  TextInputType.number,
                                            ),
                                          ),
                                        if (selectedProduct.value != null)
                                          horiSpace,
                                        if (selectedProduct.value != null)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5.0),
                                            child: FxTextField(
                                              focusNode: fcPrice,
                                              textAlign: TextAlign.end,
                                              width: 100,
                                              ctrl: ctrlPrice,
                                              enabled: true,
                                              hintText: "Unit Price",
                                              labelText: "Unit Price",
                                              onChanged: (val) {
                                                doCalcTotal(
                                                    val, ctrlTotalItem.text);
                                              },
                                              readOnly: false,
                                              errorMessage:
                                                  errorMessagePrice.value,
                                            ),
                                          ),
                                        if (selectedProduct.value != null)
                                          horiSpace,
                                        if (selectedProduct.value != null)
                                          (!showTotalQtyAmount.value)
                                              ? SizedBox(width: 120)
                                              : Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5.0),
                                                  child: FxTextField(
                                                    width: 130,
                                                    textAlign: TextAlign.end,
                                                    ctrl: ctrlTotalAmount,
                                                    readOnly: true,
                                                    enabled: false,
                                                    hintText:
                                                        "Total Amount(RM)",
                                                    labelText:
                                                        "Total Amount(RM)",
                                                  ),
                                                ),
                                      ],
                                    ),
                                    if (selectedProduct.value != null)
                                      const SizedBox(height: 10),
                                    if (selectedProduct.value != null)
                                      Row(
                                        children: [
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
                                    const SizedBox(height: 10),
                                    FxButton(
                                      maxWidth: double.infinity,
                                      title: "Save",
                                      color: Constants.orange,
                                      isLoading: isLoadingSave.value,
                                      onPress: selectedProduct.value == null
                                          ? null
                                          : () {
                                              if (isDetailValid(
                                                      withMessage: true) &&
                                                  selectedProduct.value !=
                                                      null &&
                                                  selectedSupplier.value !=
                                                      null) {
                                                final productToAdd =
                                                    _SelfBillProduct(
                                                  product:
                                                      selectedProduct.value!,
                                                  description:
                                                      ctrlProductDesc.text,
                                                  qty: ctrlTotalItem.text,
                                                  unitPrice: ctrlPrice.text,
                                                  uom: ctrlUom.text,
                                                  total: ctrlTotalAmount.text,
                                                  dateFrom: fromDate.value,
                                                  dateTo: toDate.value,
                                                );
                                                pendingProduct.value =
                                                    productToAdd;
                                                ref
                                                    .read(
                                                        selfBillAddDetailProvider
                                                            .notifier)
                                                    .add(
                                                      selfBillID: selfBillID,
                                                      invoiceNo:
                                                          ctrlInvoiceNo.text,
                                                      invoiceDate:
                                                          DateTime.now(),
                                                      invoiceTerm:
                                                          ctrlPaymentTerm.text,
                                                      dateFrom: fromDate.value,
                                                      dateTo: toDate.value,
                                                      paymentTermID:
                                                          selectedPaymentTerm
                                                                  .value
                                                                  ?.paymentTermID ??
                                                              "0",
                                                      supplierID: selectedSupplier
                                                              .value
                                                              ?.evSupplierID ??
                                                          "0",
                                                      productID: selectedProduct
                                                              .value
                                                              ?.evProductID ??
                                                          "0",
                                                      productDescription:
                                                          ctrlProductDesc.text,
                                                      taxPercent: selectedProduct
                                                              .value
                                                              ?.evProductTaxPercent ??
                                                          "0",
                                                      qty: ctrlTotalItem.text,
                                                      price: ctrlPrice.text,
                                                      uom: ctrlUom.text,
                                                    );
                                              }
                                            },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (errorMessageSave.value.isNotEmpty)
                        Align(
                          alignment: Alignment.topLeft,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 700),
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 4,
                              ),
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
                                "Error: ${errorMessageSave.value}",
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Constants.red,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (selectedTabIndex.value == 0)
                        ...listProduct.value.asMap().entries.map((entry) {
                          final item = entry.value;
                          final qty = item.qty.isEmpty
                              ? "0"
                              : item.qty.replaceAll(",", "");
                          final price = item.unitPrice.isEmpty
                              ? "0"
                              : item.unitPrice.replaceAll(",", "");
                          final description = item.description.isNotEmpty
                              ? item.description
                              : (item.product.evProductDescription ?? "");
                          final model = InvoiceDetailModel(
                            invoiceDetailID: "",
                            invoiceDetailInvoiceID: selfBillID,
                            invoiceDetailEvProductID:
                                item.product.evProductID ?? "",
                            evProductCode: item.product.evProductCode ?? "",
                            invoiceDetailQty: qty,
                            invoiceDetailPrice: price,
                            invoiceDetailUnit: item.uom,
                            invoiceDetailIsActive:
                                item.product.evProductIsActive ?? "",
                            evProductDescription: description,
                          );
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FxInvoiceProductInfo(
                              model: model,
                              isFirst: entry.key == 0,
                            ),
                          );
                        }),
                      if (selectedTabIndex.value == 1)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            FxButton(
                              title: "Save Terms",
                              color: Constants.greenDark,
                              onPress: () {},
                            ),
                            const SizedBox(height: 10),
                            FxMultilineTextField(
                              initialValue: terms.value,
                              onChange: (val) {
                                terms.value = val;
                              },
                              isReadOnly: false,
                            ),
                          ],
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelfBillProduct {
  final ProductModel product;
  final String description;
  final String qty;
  final String unitPrice;
  final String uom;
  final String total;
  final DateTime dateFrom;
  final DateTime dateTo;

  _SelfBillProduct({
    required this.product,
    required this.description,
    required this.qty,
    required this.unitPrice,
    required this.uom,
    required this.total,
    required this.dateFrom,
    required this.dateTo,
  });
}
