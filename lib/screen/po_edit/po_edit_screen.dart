import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sor_inventory/screen/po/check_po_provider.dart';
import 'package:sor_inventory/screen/po_summary/selected_po_provider.dart';
import 'package:sor_inventory/widgets/fx_ac_material_po.dart';
import 'package:sor_inventory/widgets/fx_floating_ab_print.dart';

import '../../app/constants.dart';
import '../../model/ac_material_model.dart';
import '../../model/payment_term_response_model.dart';
import '../../model/po_response_model.dart';
import '../../model/sor_user_model.dart';
import '../../provider/dio_provider.dart';
import '../../repository/po_repository.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_auto_completion_pack_unit.dart';
import '../../widgets/fx_auto_completion_unit.dart';
import '../../widgets/fx_auto_completion_vendor.dart';
import '../../widgets/fx_auto_completion_vendor_po.dart';
import '../../widgets/fx_button.dart';
import '../../widgets/fx_date_field.dart';
import '../../widgets/fx_payment_term_lk.dart';
import '../../widgets/fx_po_mat_info.dart';
import '../../widgets/fx_text_field.dart';
import '../login/login_provider.dart';
import '../po/delete_po_provider.dart';
import '../po/get_po_provider.dart';
import '../po/save_po_provider.dart';
import '../po/selected_payment_term.dart';

class PoEditScreen extends HookConsumerWidget {
  const PoEditScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginModel = useState<SorUser?>(null);
    final isInit = useState(true);

    double screenWidth = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      screenWidth = Constants.webWidth;
    }
    final isConfirmReady = useState(false);
    final selectedMaterial = useState<AcMaterialModel?>(null);
    final listPoDetail = useState<List<PoDetailResponseModel>>(List.empty());
    final selectedStore = useState<Map<String, dynamic>?>(null);
    final selectedDate = useState<DateTime>(DateTime.now());
    final selectedDeliveryDate = useState<DateTime>(DateTime.now());
    final poIsNotEmpty = useState(false);
    final paymentTermLooseFocus = useState(false);

    final selectedVendor = useState<VendorModel?>(null);
    final selectedPackUnit = useState<UnitModel?>(null);
    final getPoID = useState<String>("0");

    final isLoading = useState(false);
    final errorMessageSave = useState("");
    final errorMessageVendor = useState("");
    final errorMessageMaterial = useState("");
    final errorMessageQty = useState("");
    final errorMessagePackQty = useState("");
    final errorMessagePackUnit = useState("");

    final errorMessagePrice = useState("");
    final errorMessagePo = useState("");
    final ctrlMaterial = useTextEditingController(text: "");
    final ctrlTotalItem = useTextEditingController(text: "");
    final ctrlTotalQty = useTextEditingController(text: "");
    final ctrlPrice = useTextEditingController(text: "");
    final ctrlTotalAmount = useTextEditingController(text: "");
    final ctrlUnit = useTextEditingController(text: "");
    final ctrlPackQty = useTextEditingController(text: "");
    final ctrlPo = useTextEditingController(text: "");
    final fcPackUnit = useFocusNode();
    final ctrlPackUnit = useTextEditingController(text: "");
    final fcMaterial = useFocusNode(canRequestFocus: true);
    final ctrlMaterialDesc = useTextEditingController(text: "");
    final ctrlDrumNum = useTextEditingController(text: "");

    final fcTotalItem = useFocusNode();
    final fcPackQty = useFocusNode();
    final fcPrice = useFocusNode();
    final fcPo = useFocusNode();
    final defaultPaymentTermID = useState("3");

    final ivVendor = useState<TextEditingValue?>(null);
    final ivPackUnit = useState<TextEditingValue?>(null);

    final showAddMaterial = useState(false);
    final addMaterialReady = useState(false);

    final selectedPaymentTerm = useState<PaymentTermResponseModel?>(null);
    final showTotalQtyAmount = useState(false);
    final duplicatePoNo = useState(false);

    void resetPoMaterial() {
      selectedMaterial.value = null;
      ctrlMaterial.text = "";
      ctrlTotalQty.text = "";
      ctrlTotalItem.text = "";
      ctrlPackQty.text = "";
      ctrlPackUnit.text = "";
      ctrlPrice.text = "";
      selectedMaterial.value = null;
      errorMessagePo.value = "";
      errorMessageVendor.value = "";
      errorMessageMaterial.value = "";
      errorMessageQty.value = "";
      errorMessagePackQty.value = "";
      errorMessagePackUnit.value = "";
      errorMessagePrice.value = "";
      showTotalQtyAmount.value = false;
    }

    final fcDateField = useFocusNode();
    /* final fcDeliveryDate = useFocusNode(); */
    if (ref.read(selectedPoProvider) != null) {
      final selectedPoModel = ref.read(selectedPoProvider);
      ctrlPo.text = selectedPoModel!.poNo;
      selectedVendor.value = selectedPoModel.vendorModel;
      ivVendor.value = TextEditingValue(text: selectedVendor.value!.vendorName);
      addMaterialReady.value = true;
      if (selectedPoModel.poNo != "") {
        poIsNotEmpty.value = true;
      }
      useEffect(() {
        if (selectedPoModel.vendorModel.vendorID != "") {
          WidgetsBinding.instance.addPostFrameCallback((tmr) {
            ref.read(getPoProvider.notifier).get(
                poNo: selectedPoModel.poNo,
                vendorID: selectedPoModel.vendorModel.vendorID);
          });
        }
        return () {
          WidgetsBinding.instance.addPostFrameCallback((tmr) {
            ref.read(selectedPoProvider.notifier).state = null;
            ref.read(getPoProvider.notifier).reset();
          });
        };
      });
    }
    fcMaterial.addListener(() {
      if (!fcMaterial.hasFocus) {
        if (selectedMaterial.value == null) {
          errorMessageMaterial.value = "Material is mandatory";
        } else {
          errorMessageMaterial.value = "";
        }
      }
    });

    final nbf = NumberFormat("###,##0", "en_US");
    final nbfDec = NumberFormat("###,##0.00", "en_US");
    final nbfDecThree = NumberFormat("###,##0.000", "en_US");

    fcTotalItem.addListener(() {
      if (!fcTotalItem.hasFocus) {
        if (ctrlTotalItem.text == "") {
          errorMessageQty.value = "Total item is mandatory";
        } else {
          errorMessageQty.value = "";
          String sAmount = "";
          try {
            sAmount = nbfDec.format(nbf.parse(ctrlTotalItem.text) *
                nbf.parse(ctrlPackQty.text) *
                nbfDec.parse(ctrlPrice.text));
          } catch (_) {}
          ctrlTotalAmount.text = sAmount;
        }
      }
    });

    fcPackQty.addListener(() {
      if (!fcPackQty.hasFocus) {
        if (ctrlPackQty.text == "") {
          errorMessagePackQty.value = "Pack Size is mandatory";
        } else {
          errorMessagePackQty.value = "";
        }
      }
    });

    bool checkIsConfirmValid() {
      bool haveError = false;
      if (selectedVendor.value == null) {
        isConfirmReady.value = false;
        errorMessageVendor.value = "Vendor is mandatory";
        haveError = true;
      } else {
        errorMessageVendor.value = "";
      }
      if (selectedMaterial.value == null) {
        isConfirmReady.value = false;
        errorMessageMaterial.value = "Material is mandatory";
        haveError = true;
      } else {
        errorMessageMaterial.value = "";
      }
      if (ctrlTotalItem.text == "") {
        isConfirmReady.value = false;
        errorMessageQty.value = "Total Item is mandatory";
        haveError = true;
      } else {
        errorMessageQty.value = "";
      }
      if (ctrlPackQty.text == "") {
        errorMessagePackQty.value = "Pack Size is mandatory";
        haveError = true;
      } else {
        errorMessagePackQty.value = "";
      }
      if (selectedPackUnit.value == null) {
        errorMessagePackUnit.value = "Pack Unit is mandatory";
        haveError = true;
      } else {
        if (selectedPackUnit.value!.unitId == "0") {
          errorMessagePackUnit.value = "Pack Unit is mandatory";
          haveError = true;
        } else {
          errorMessagePackUnit.value = "";
        }
      }
      if (!haveError) {
        isConfirmReady.value = true;
      }
      return haveError;
    }

    void calcTotalQty() {
      if (ctrlPackQty.text != "" && ctrlTotalItem.text != "") {
        try {
          num packQty = nbf.parse(ctrlPackQty.text);
          num totalItem = nbf.parse(ctrlTotalItem.text);
          num totalQty = packQty * totalItem;
          ctrlTotalQty.text = nbf.format(totalQty);
          num price = nbf.parse(ctrlPrice.text);
          num totalAmount = totalQty * price;
          ctrlTotalAmount.text = nbfDec.format(totalAmount);
        } catch (_) {
          /* print("Error ${e.toString()}"); */
        }
      }
    }

    /* ctrlPackQty.addListener(checkIsConfirmValid); */
    /* ctrlTotalItem.addListener(checkIsConfirmValid); */
    ctrlPackQty.addListener(calcTotalQty);
    ctrlTotalItem.addListener(calcTotalQty);

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
        /* Timer(const Duration(milliseconds: 500), () { */
        /*   isInit.value = true; */
        /*   Navigator.of(context) */
        /*       .pushNamedAndRemoveUntil(loginRoute, (args) => false); */
        /* }); */
      }
      return Scaffold(
        body: Container(
          color: Colors.white,
        ),
      );
    }

    if (selectedVendor.value != null) {
      WidgetsBinding.instance.addPostFrameCallback((tmr) {
        addMaterialReady.value = true;
      });
    }
    ref.listen(savePoProvider, (prev, next) {
      if (next is SavePoStateLoading) {
        isLoading.value = true;
      } else if (next is SavePoStateError) {
        isLoading.value = false;
        if (next.message.contains("already exist")) {
          errorMessagePo.value = next.message;
          Timer(const Duration(seconds: 3), () {
            errorMessagePo.value = "";
          });
        } else {
          errorMessageSave.value = next.message;
          Timer(const Duration(seconds: 3), () {
            errorMessageSave.value = "";
          });
        }
      } else if (next is SavePoStateDone) {
        isLoading.value = false;
        listPoDetail.value = next.model.detail;
        getPoID.value = next.model.po.poID;
        resetPoMaterial();
      }
    });

    ref.listen(getPoProvider, (prev, next) {
      if (next is GetPoStateLoading) {
        getPoID.value = "0";
      } else if (next is GetPoStateError) {
        errorMessageSave.value = next.message;
        Timer(const Duration(seconds: 10), () {
          errorMessageSave.value = "";
        });
      } else if (next is GetPoStateDone) {
        listPoDetail.value = next.model.detail;
        getPoID.value = next.model.po.poID;
        selectedPaymentTerm.value ??= PaymentTermResponseModel(
          paymentTermCode: "",
          paymentTermDays: "0",
          paymentTermID: next.model.po.paymentTermID,
          paymentTermIsActive: "Y",
          paymentTermName: next.model.po.paymentTermName,
        );
        final sdf = DateFormat("yyyy-MM-dd");
        listPoDetail.value = next.model.detail;
        selectedDate.value = sdf.parse(next.model.po.date);
        selectedDeliveryDate.value = sdf.parse(next.model.po.deliveryDate);
      }
    });
    const horiSpace = SizedBox(width: 10);
    const materialCodeWidth = 115.0;

    double pageWidth = MediaQuery.of(context).size.width - 45;
    if (kIsWeb) {
      pageWidth = Constants.webWidth - 45;
    }
    double width25 = (pageWidth - materialCodeWidth - 30) / 3;
    double width50 = width25 * 2 + 10;
    ref.listen(checkPoProvider, ((previous, next) {
      if (next is CheckPoStateError) {
        errorMessagePo.value = next.message;
        duplicatePoNo.value = true;
        showAddMaterial.value = false;
      } else if (next is CheckPoStateDone) {
        errorMessagePo.value = "";
        duplicatePoNo.value = false;
      }
    }));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          "PO",
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
      floatingActionButton: listPoDetail.value.isNotEmpty
          ? FxFloatingABPrint(
              preUrl:
                  "https://${Constants.host}/reports/po.php?id=${getPoID.value}")
          : null,
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
                      child: FxACVendorPo(
                        initialValue: ivVendor.value,
                        labelText: "Vendor",
                        hintText: "Vendor",
                        value: selectedVendor.value?.vendorName ?? "",
                        onSelected: (model) {
                          selectedVendor.value = model;
                          addMaterialReady.value = true;

                          model.vendorID;
                          if (ctrlPo.text == "") {
                            // ignore: prefer_function_declarations_over_variables
                            final getPo = () async {
                              if (selectedVendor.value?.autoPo == "Y") {
                                try {
                                  final autoPoNo = await PoRepository(
                                          dio: ref.read(dioProvider))
                                      .autoPo(vendorID: model.vendorID);
                                  ctrlPo.text = autoPoNo;
                                  addMaterialReady.value = true;
                                  poIsNotEmpty.value = true;
                                } catch (e) {
                                  /* if (e is BaseRepositoryException) { */
                                  /*   print("ERR : ${e.message}"); */
                                  /* } else { */
                                  /*   print("Err : ${e}"); */
                                  /* } */
                                }
                              }
                            };
                            getPo();
                          } else {
                            poIsNotEmpty.value = true;
                          }
                        },
                        errorMessage: errorMessageVendor.value,
                      ),
                    ),
                    horiSpace,
                    Expanded(
                      child: FxDateField(
                        fcNode: fcDateField,
                        hintText: "PO Date",
                        dateValue: selectedDate.value,
                        firstDate: DateTime.now().subtract(
                          const Duration(
                            days: 365,
                          ),
                        ),
                        lastDate: DateTime.now().add(
                          const Duration(
                            days: 30,
                          ),
                        ),
                        onDateChange: (dt) {
                          selectedDate.value = dt;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                if (selectedVendor.value != null)
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: FxTextField(
                          focusNode: fcPo,
                          errorMessage: errorMessagePo.value,
                          ctrl: ctrlPo,
                          hintText: "PO No.",
                          labelText: "PO No.",
                          enabled: getPoID.value == "0",
                          onChanged: (v) {
                            if (v == "") {
                              poIsNotEmpty.value = false;
                            } else {
                              poIsNotEmpty.value = true;
                            }
                          },
                          /* suffix: selectedVendor.value == null */
                          /*     ? null */
                          /*     : InkWell( */
                          /*         child: Padding( */
                          /*           padding: const EdgeInsets.all(8.0), */
                          /*           child: Image.asset("images/icon_search.png", */
                          /*               width: 14, height: 14), */
                          /*         ), */
                          /*         onTap: () { */
                          /*           if (ctrlPo.text == "") { */
                          /*             return; */
                          /*           } */
                          /*           ref.read(getPoProvider.notifier).get( */
                          /*                 poNo: ctrlPo.text, */
                          /*                 vendorID: */
                          /*                     selectedVendor.value!.vendorID, */
                          /*               ); */
                          /*         }), */
                        ),
                      ),
                      horiSpace,
                      Expanded(
                        child: FxPaymentTermLk(
                            hintText: "Payment Term",
                            labelText: "Payment Term",
                            initialValue: selectedPaymentTerm.value,
                            vendorID: selectedVendor.value!.vendorID,
                            looseFocus: paymentTermLooseFocus.value,
                            onChanged: (val) {
                              selectedPaymentTerm.value = val;
                            }),
                      ),
                    ],
                  ),
                if (selectedVendor.value != null)
                  const SizedBox(
                    height: 10,
                  ),
                if (!showAddMaterial.value &&
                    selectedVendor.value != null &&
                    poIsNotEmpty.value)
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: FxButton(
                          prefix: Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Image.asset(
                              "images/add_icon.png",
                              width: 18,
                              height: 18,
                            ),
                          ),
                          title: "Add Material",
                          color: Constants.orange,
                          onPress: addMaterialReady.value
                              ? () {
                                  showAddMaterial.value = true;
                                  fcMaterial.requestFocus();
                                  paymentTermLooseFocus.value = true;
                                  Timer(const Duration(seconds: 3), () {
                                    paymentTermLooseFocus.value = false;
                                  });
                                  if (getPoID.value == "0") {
                                    duplicatePoNo.value = false;
                                    errorMessagePo.value = "";
                                    ref
                                        .read(checkPoProvider.notifier)
                                        .check(poNo: ctrlPo.text);
                                  }
                                }
                              : null,
                        ),
                      ),
                      horiSpace,
                      Expanded(
                        child: FxButton(
                          prefix: Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Image.asset(
                              "images/tick_icon.png",
                              width: 18,
                              height: 18,
                            ),
                          ),
                          title: "Done",
                          color: Constants.greenDark,
                          onPress: listPoDetail.value.isNotEmpty
                              ? () {
                                  Navigator.of(context).pop();
                                }
                              : null,
                        ),
                      )
                    ],
                  ),
                if (errorMessageSave.value != "")
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        errorMessageSave.value,
                        style:
                            const TextStyle(color: Constants.red, fontSize: 16),
                      ),
                    ),
                  ),
                if (!showAddMaterial.value)
                  const SizedBox(
                    height: 10,
                  ),
                if (showAddMaterial.value)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Constants.greenDark),
                      borderRadius: BorderRadius.circular(10),
                      color: Constants.greenLight.withOpacity(0.01),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              selectedMaterial.value == null
                                  ? FxAutoCompletionMaterialPo(
                                      width: screenWidth,
                                      ctrl: ctrlMaterial,
                                      fc: fcMaterial,
                                      vendorID: selectedVendor.value?.vendorID,
                                      errorMessage: errorMessageMaterial.value,
                                      poID: getPoID.value,
                                      labelText: "Material Code/Description",
                                      hintText: "Search",
                                      value: selectedMaterial
                                              .value?.materialCode ??
                                          "",
                                      onSelectedMaterial: (model) {
                                        FocusScope.of(context)
                                            .requestFocus(FocusNode());
                                        if (model == null) {
                                          ctrlPackQty.text = "";
                                          ctrlPackUnit.text = "";
                                          selectedMaterial.value = null;
                                          ctrlPrice.text = "0.00";
                                        } else {
                                          selectedMaterial.value = model;
                                          ctrlPackQty.text = model.packQty;
                                          try {
                                            ctrlPackQty.text = nbf.format(
                                                nbf.parse(model.packQty));
                                          } catch (_) {}
                                          ctrlUnit.text = model.unit;
                                          ctrlPackUnit.text = model.packUnit;
                                          ctrlTotalItem.text =
                                              model.remainingQty;
                                          try {
                                            ctrlTotalItem.text = nbf.format(
                                                nbf.parse(model.remainingQty));
                                          } catch (_) {}
                                          selectedPackUnit.value = UnitModel(
                                            unit: model.packUnit,
                                            unitId: model.packUnitId,
                                            unitDesc: model.packUnitDesc,
                                          );
                                          ctrlPrice.text = "0.00";
                                          try {
                                            ctrlPrice.text = nbfDecThree.format(
                                                nbf.parse(model.unitPrice));
                                          } catch (_) {}
                                          String totalAmount = "";
                                          try {
                                            totalAmount = nbf.format(nbf
                                                    .parse(model.unitPrice) *
                                                nbf.parse(model.packQty) *
                                                nbf.parse(ctrlTotalItem.text));
                                          } catch (_) {}
                                          ctrlTotalAmount.text = totalAmount;
                                          if (model.unitPrice == "0.00") {
                                            errorMessagePrice.value =
                                                "Price not set";
                                            Timer(const Duration(seconds: 3),
                                                () {
                                              errorMessagePrice.value = "";
                                            });
                                          } else {
                                            errorMessagePrice.value = "";
                                          }
                                        }
                                        ctrlMaterialDesc.text =
                                            model?.description ?? "";
                                        checkIsConfirmValid();
                                      },
                                    )
                                  : FxAutoCompletionMaterialPo(
                                      width: materialCodeWidth,
                                      ctrl: ctrlMaterial,
                                      fc: fcMaterial,
                                      vendorID: selectedVendor.value?.vendorID,
                                      errorMessage: errorMessageMaterial.value,
                                      poID: getPoID.value,
                                      labelText: "Material Code/Description",
                                      hintText: "Material Code/Description",
                                      value: selectedMaterial
                                              .value?.materialCode ??
                                          "",
                                      onSelectedMaterial: (model) {
                                        FocusScope.of(context)
                                            .requestFocus(FocusNode());
                                        if (model == null) {
                                          ctrlPackQty.text = "";
                                          ctrlPackUnit.text = "";
                                          selectedMaterial.value = null;
                                          ctrlPrice.text = "0.00";
                                        } else {
                                          selectedMaterial.value = model;
                                          ctrlPackQty.text = model.packQty;
                                          try {
                                            ctrlPackQty.text = nbf.format(
                                                nbf.parse(model.packQty));
                                          } catch (_) {}
                                          ctrlUnit.text = model.unit;
                                          ctrlPackUnit.text = model.packUnit;
                                          ctrlTotalItem.text =
                                              model.remainingQty;
                                          try {
                                            ctrlTotalItem.text = nbf.format(
                                                nbf.parse(model.remainingQty));
                                          } catch (_) {}
                                          selectedPackUnit.value = UnitModel(
                                            unit: model.packUnit,
                                            unitId: model.packUnitId,
                                            unitDesc: model.packUnitDesc,
                                          );
                                          ctrlPrice.text = "0.00";
                                          try {
                                            ctrlPrice.text = nbfDec.format(
                                                nbf.parse(model.unitPrice));
                                          } catch (_) {}
                                          String totalAmount = "";
                                          try {
                                            totalAmount = nbf.format(nbf
                                                    .parse(model.unitPrice) *
                                                nbf.parse(model.packQty) *
                                                nbf.parse(ctrlTotalItem.text));
                                          } catch (_) {}
                                          ctrlTotalAmount.text = totalAmount;
                                          if (model.unitPrice == "0.00") {
                                            errorMessagePrice.value =
                                                "Price not set";
                                            Timer(const Duration(seconds: 3),
                                                () {
                                              errorMessagePrice.value = "";
                                            });
                                          } else {
                                            errorMessagePrice.value = "";
                                          }
                                        }
                                        ctrlMaterialDesc.text =
                                            model?.description ?? "";
                                        checkIsConfirmValid();
                                      },
                                    ),
                              if (selectedMaterial.value != null) horiSpace,
                              selectedMaterial.value == null
                                  ? const Expanded(child: SizedBox(width: 10))
                                  : Expanded(
                                      child: FxTextField(
                                        hintText: "Description",
                                        labelText: "Description",
                                        ctrl: ctrlMaterialDesc,
                                        readOnly: true,
                                        enabled: false,
                                      ),
                                    ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          /* if (false && selectedMaterial.value != null) */
                          /*   /* FxTextField( */ */
                          /*   /*   width: double.infinity, */ */
                          /*   /*   enabled: false, */ */
                          /*   /*   readOnly: true, */ */
                          /*   /*   ctrl: ctrlDrumNum, */ */
                          /*   /*   hintText: "Drum No.", */ */
                          /*   /*   labelText: "Drum No.", */ */
                          /*   /* ), */ */
                          /*   const SizedBox( */
                          /*     height: 10, */
                          /*   ), */
                          if (selectedMaterial.value != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  FxTextField(
                                    width: materialCodeWidth,
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
                                    },
                                    errorMessage: errorMessageQty.value,
                                    ctrl: ctrlTotalItem,
                                    hintText: "Total Item",
                                    labelText: "Total Item",
                                  ),
                                  horiSpace,
                                  FxAutoCompletionPackUnit(
                                    ctrl: ctrlPackUnit,
                                    width: width25,
                                    errorMessage: errorMessagePackUnit.value,
                                    fc: fcPackUnit,
                                    labelText: "Pack Unit",
                                    hintText: "Pack Unit",
                                    onSelected: (model) {
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
                                      selectedPackUnit.value = model;
                                      ivPackUnit.value =
                                          TextEditingValue(text: model.unit);
                                      checkIsConfirmValid();
                                    },
                                  ),
                                  horiSpace,
                                  FxTextField(
                                    width: width25,
                                    isMoney: true,
                                    focusNode: fcPackQty,
                                    textAlign: TextAlign.end,
                                    errorMessage: errorMessagePackQty.value,
                                    ctrl: ctrlPackQty,
                                    hintText: "Pack Size",
                                    labelText: "Pack Size",
                                  ),
                                  horiSpace,
                                  Expanded(
                                    child: FxTextField(
                                      enabled: false,
                                      ctrl: ctrlUnit,
                                      hintText: "UOM",
                                      labelText: "UOM",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (selectedMaterial.value != null)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                FxTextField(
                                  focusNode: fcPrice,
                                  textAlign: TextAlign.end,
                                  width: materialCodeWidth,
                                  ctrl: ctrlPrice,
                                  enabled: true,
                                  hintText: "Unit Price",
                                  labelText: "Unit Price",
                                  readOnly: false,
                                  errorMessage: errorMessagePrice.value,
                                ),
                                horiSpace,
                                (!showTotalQtyAmount.value)
                                    ? SizedBox(width: width25)
                                    : FxTextField(
                                        width: width25,
                                        textAlign: TextAlign.end,
                                        ctrl: ctrlTotalQty,
                                        readOnly: true,
                                        enabled: false,
                                        hintText: "Total Qty",
                                        labelText: "Total Qty",
                                      ),
                                horiSpace,
                                (!showTotalQtyAmount.value)
                                    ? SizedBox(width: width50)
                                    : FxTextField(
                                        width: width50,
                                        readOnly: true,
                                        enabled: false,
                                        textAlign: TextAlign.end,
                                        ctrl: ctrlTotalAmount,
                                        hintText: "Total Amount",
                                        labelText: "Total Amount (RM)",
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
                            onPress: selectedVendor.value == null ||
                                    selectedMaterial.value == null ||
                                    ctrlPo.text == "" ||
                                    selectedPackUnit.value == null ||
                                    ctrlPackQty.text == "" ||
                                    ctrlTotalAmount.text == "" ||
                                    double.tryParse(ctrlTotalItem.text) ==
                                        null ||
                                    double.tryParse(ctrlTotalItem.text) == 0.0
                                ? null
                                : () {
                                    if (checkIsConfirmValid()) {
                                      return;
                                    }
                                    try {
                                      if (nbf.parse(ctrlPrice.text) <= 0.0) {
                                        errorMessagePrice.value =
                                            "Price not set by vendor";
                                        Timer(const Duration(seconds: 3), () {
                                          errorMessagePrice.value = "";
                                        });
                                        return;
                                      }
                                    } catch (_) {
                                      errorMessagePrice.value =
                                          "Price Error : ${ctrlPrice.text}";
                                      Timer(const Duration(seconds: 3), () {
                                        errorMessagePrice.value = "";
                                      });
                                      return;
                                    }
                                    ref.read(savePoProvider.notifier).save(
                                          date: selectedDate.value,
                                          poID: getPoID.value,
                                          poNo: ctrlPo.text,
                                          storeID: selectedStore.value!["id"],
                                          vendorID:
                                              selectedVendor.value!.vendorID,
                                          paymentTermID: selectedPaymentTerm
                                              .value!.paymentTermID,
                                          paymentTermName: selectedPaymentTerm
                                              .value!.paymentTermName,
                                          deliveryDate: DateTime.now(),
                                          materialID: selectedMaterial
                                              .value!.materialId,
                                          fromVendor: selectedMaterial
                                              .value!.fromVendor,
                                          packUnitID:
                                              selectedPackUnit.value!.unitId,
                                          packQty: ctrlPackQty.text,
                                          qty: ctrlTotalItem.text,
                                          price: ctrlPrice.text,
                                        );
                                    showAddMaterial.value = false;
                                  },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ...listPoDetail.value.map((model) {
                  final idx = listPoDetail.value.indexOf(model);
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FxPoMaterialInfo(
                        model: model,
                        isFirst: idx == 0,
                        onDelete: () {
                          final poNo = ctrlPo.text;
                          final vendorID = selectedVendor.value!.vendorID;
                          ref.read(deletePoProvider.notifier).delete(
                                poNo: poNo,
                                vendorID: vendorID,
                                poDetailID: model.poDetailID,
                              );
                        }),
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
