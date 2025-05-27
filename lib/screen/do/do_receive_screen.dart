/* import 'dart:async'; */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sor_inventory/screen/do/check_do_no_provider.dart';
import 'package:sor_inventory/widgets/fx_auto_completion_vendor_po.dart';
import 'package:sor_inventory/widgets/fx_store_lk.dart';

import '../../app/constants.dart';
import '../../model/ac_material_model.dart';
import '../../model/do_model.dart';
import '../../model/sor_user_model.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_auto_completion_material.dart';
import '../../widgets/fx_auto_completion_pack_unit.dart';
import '../../widgets/fx_auto_completion_po.dart';
import '../../widgets/fx_auto_completion_unit.dart';
import '../../widgets/fx_auto_completion_vendor.dart';
import '../../widgets/fx_button.dart';
import '../../widgets/fx_date_field.dart';
import '../../widgets/fx_do_detail.dart';
import '../../widgets/fx_text_field.dart';
import '../list_do/selected_do_provider.dart';
import '../login/login_provider.dart';
import 'delete_detail_provider.dart';
import 'get_do_provider.dart';
import 'save_do_provider.dart';

class DoReceiveScreen extends HookConsumerWidget {
  final bool fromSummary;
  const DoReceiveScreen({Key? key, required this.fromSummary})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginModel = useState<SorUser?>(null);
    final isInit = useState(true);
    final isDoNoEmpty = useState(true);

    final isDoneRequested = useState(false);

    final ctrlDoNumber = useTextEditingController(text: "");
    double screenWidth = MediaQuery.of(context).size.width;

    final isConfirmReady = useState(false);
    final selectedPo = useState<DummyPo?>(null);
    final selectedDoID = useState<String>("0");
    final selectedMaterial = useState<AcMaterialModel?>(null);
    final listDoDetail = useState<List<DoDetailModel>>(List.empty());
    final selectedStore = useState<Map<String, dynamic>?>(null);
    final selectedDate = useState<DateTime>(DateTime.now());
    final selectedVendor = useState<VendorModel?>(null);
    final selectedPackUnit = useState<UnitModel?>(null);

    final isLoading = useState(false);
    final errorMessageDo = useState("");
    final errorMessagePo = useState("");
    final errorMessageVendor = useState("");
    final errorMessageMaterial = useState("");
    final errorMessageDrumNo = useState("");
    final errorMessageQty = useState("");
    final errorMessagePackQty = useState("");
    final ctrlMaterial = useTextEditingController(text: "");
    final ctrlDrumNum = useTextEditingController(text: "");
    final ctrlTotalItem = useTextEditingController(text: "");
    final ctrlTotalQty = useTextEditingController(text: "");
    final ctrlUnit = useTextEditingController(text: "");
    final ctrlPackQty = useTextEditingController(text: "");
    final fcPackUnit = useFocusNode();
    final ctrlPackUnit = useTextEditingController(text: "");
    final fcMaterial = useFocusNode(canRequestFocus: true);
    final ctrlMaterialDesc = useTextEditingController(text: "");

    final ctrlTotalAmount = useTextEditingController(text: " ");

    final ctrlPo = useTextEditingController(text: "");
    final fcPo = useFocusNode();
    final fcDo = useFocusNode();
    final fcTotalItem = useFocusNode();
    final fcPackQty = useFocusNode();
    final fcDrumNum = useFocusNode();

    final errorMessageLoadDo = useState("");

    final ivVendor = useState<TextEditingValue?>(null);
    final ivPackUnit = useState<TextEditingValue?>(null);

    final showAddMaterial = useState(false);
    final addMaterialReady = useState(false);
    final errorMessageTotalQty = useState("");
    void resetPoMaterial() {
      selectedMaterial.value = null;
      ctrlMaterial.text = "";
      ctrlDrumNum.text = "";
      ctrlTotalQty.text = "";
      ctrlTotalItem.text = "";
      ctrlPackQty.text = "";
      ctrlPackUnit.text = "";
      selectedMaterial.value = null;
      errorMessageDo.value = "";
      errorMessageVendor.value = "";
      errorMessageMaterial.value = "";
      errorMessageQty.value = "";
      errorMessageDrumNo.value = "";
      errorMessagePackQty.value = "";
    }

    final fcDateField = useFocusNode();

    final nbf = NumberFormat("###,##0", "en_US");
    final nbfDec = NumberFormat("###,##0.000", "en_US");
    final nbfDecTotal = NumberFormat("###,##0.00", "en_US");

    // if (selectedMaterial.value != null) {
    //   if (selectedMaterial.value!.isCable == "Y") {
    //     ctrlTotalItem.text = nbf.format(1);
    //     ctrlTotalQty.text = nbf.format(1);
    //   }
    // }
    fcPo.addListener(() {
      if (!fcPo.hasFocus) {
        if (selectedPo.value == null) {
          errorMessagePo.value = "PO No. is mandatory";
        } else {
          errorMessagePo.value = "";
        }
      }
    });
    ctrlMaterial.addListener(() {
      if (ctrlMaterial.text.length < 9) {
        selectedMaterial.value = null;
      }
    });
    fcMaterial.addListener(() {
      if (!fcMaterial.hasFocus) {
        if (selectedMaterial.value == null) {
          errorMessageMaterial.value = "Compulsory";
        } else {
          errorMessageMaterial.value = "";
        }
      }
    });

    fcTotalItem.addListener(() {
      if (!fcTotalItem.hasFocus) {
        if (ctrlTotalItem.text == "") {
          errorMessageQty.value = "Total item is mandatory";
        } else {
          errorMessageQty.value = "";
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

    final doIsTouched = useState(false);
    final checkDoIsLoading = useState(false);
    fcDo.addListener(() {
      if (!fcDo.hasFocus) {
        doIsTouched.value = true;
        errorMessageDo.value = "";
        if (checkDoIsLoading.value == false && !fromSummary) {
          ref.read(checkDoNoProvider.notifier).check(doNo: ctrlDoNumber.text);
        }
      }
    });

    ref.listen(checkDoNoProvider, (previous, next) {
      if (next is CheckDoNoStateError) {
        errorMessageDo.value = next.message;
        checkDoIsLoading.value = false;
      } else if (next is CheckDoNoStateDone) {
        errorMessageDo.value = "";
        checkDoIsLoading.value = false;
      } else if (next is CheckDoNoStateLoading) {
        checkDoIsLoading.value = true;
      }
    });
    String validCode = "00";
    bool checkIsConfirmValid() {
      bool haveError = true;
      validCode = "00";
      if (ctrlDoNumber.text == "") {
        isConfirmReady.value = false;
        errorMessageDo.value = "This field is mandatory";
        haveError = true;
        validCode = "1";
      } else {
        errorMessageDo.value = "";
      }
      if (selectedPo.value == null) {
        isConfirmReady.value = false;
        haveError = true;
        validCode = "2";
      } else {
        errorMessagePo.value = "";
      }
      if (selectedVendor.value == null) {
        isConfirmReady.value = false;
        /* errorMessageVendor.value = "Vendor is mandatory"; */
        validCode = "3";
        haveError = true;
      } else {
        errorMessageVendor.value = "";
      }
      if (ctrlDoNumber.text != "" && selectedVendor.value == null) {
        /* errorMessageDo.value = "Vendor is mandatory"; */
        validCode = "4";
        addMaterialReady.value = true;
      } else {
        addMaterialReady.value = false;
      }
      if (selectedMaterial.value == null) {
        isConfirmReady.value = false;
        /* errorMessageMaterial.value = "Material is mandatory"; */
        haveError = true;
        validCode = "5";
      } else {
        errorMessageMaterial.value = "";
      }
      if (ctrlTotalItem.text == "") {
        isConfirmReady.value = false;
        /* errorMessageQty.value = "Total Item is mandatory"; */
        haveError = true;
        validCode = "6";
      } else {
        errorMessageQty.value = "";
      }
      if (ctrlDrumNum.text == "" && selectedMaterial.value?.isCable == "Y") {
        isConfirmReady.value = false;
        errorMessageDrumNo.value = "Drum No. is mandatory";
        haveError = true;
        validCode = "7";
      } else {
        errorMessageDrumNo.value = "";
      }
      if (ctrlPackQty.text == "") {
        /* errorMessagePackQty.value = "Pack Size is mandatory"; */
        validCode = "8";
        haveError = true;
      } else {
        errorMessagePackQty.value = "";
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
        } catch (_) {}
      }
    }

    final alreadyHaveDo = useState(false);
    final selectedStoreID = useState("0");
    if (ref.read(selectedDoProvider) != null) {
      final selectedDoModel = ref.read(selectedDoProvider);
      selectedStoreID.value = selectedDoModel?.storeID ?? "0";
      ctrlDoNumber.text = selectedDoModel!.doNo;
      ctrlPo.text = selectedDoModel.poNo;
      alreadyHaveDo.value = true;
      selectedDoID.value = selectedDoModel.doID;
      try {
        selectedPo.value = DummyPo(
          id: int.parse(selectedDoModel.poID),
          poNo: selectedDoModel.poNo,
        );
        selectedPo.value = null;
      } catch (_) {}
      try {
        final sdf = DateFormat("yyyy-MM-dd");
        final newDate = sdf.parse(selectedDoModel.doDate);
        selectedDate.value = newDate;
      } catch (_) {}
      selectedVendor.value = selectedDoModel.vendorModel;
      ivVendor.value = TextEditingValue(text: selectedVendor.value!.vendorName);
      selectedMaterial.value = null;
      addMaterialReady.value = false;
      showAddMaterial.value = false;
      /* useEffect(() { */
      /*   return () { */
      /*     WidgetsBinding.instance.addPostFrameCallback((tmr) { */
      /*       ref.read(selectedDoProvider.notifier).state = null; */
      /*     }); */
      /*   }; */
      /* }); */
      // only first time load
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        ref.read(selectedDoProvider.notifier).state = null;
      });
    } else {
      if (isInit.value) {
        ctrlDoNumber.text = "";
        selectedVendor.value = null;
        ivVendor.value = const TextEditingValue(text: "");
        addMaterialReady.value = false;
      }
    }
    ctrlDoNumber.addListener(checkIsConfirmValid);
    ctrlDrumNum.addListener(checkIsConfirmValid);
    ctrlPackQty.addListener(checkIsConfirmValid);
    ctrlTotalItem.addListener(checkIsConfirmValid);
    ctrlPackQty.addListener(calcTotalQty);
    ctrlTotalItem.addListener(calcTotalQty);
    selectedPo.addListener(checkIsConfirmValid);

    ref.listen(getDoDetailStateProvider, (prev, next) {
      if (next is GetDoStateDone) {
        listDoDetail.value = next.doResponseModel.detail;
        final sdf = DateFormat("yyyy-MM-dd");
        try {
          final xd = sdf.parse(next.doResponseModel.doModel.date);
          selectedDate.value = xd;
        } catch (_) {}
      } else if (next is GetDoStateLoading) {
        listDoDetail.value = List.empty();
        resetPoMaterial();
      } else if (next is GetDoStateError) {
        errorMessageLoadDo.value = "Error Load DO :${next.message}";
        Timer(const Duration(seconds: 12), () {
          errorMessageLoadDo.value = "";
        });
      }
    });
    ref.listen(saveDoProvider, (prev, next) {
      if (next is SaveDoStateLoading) {
        isConfirmReady.value = false;
        isLoading.value = true;
      } else if (next is SaveDoStateDone) {
        isLoading.value = false;
        listDoDetail.value = next.doResponseModel.detail;
        selectedDoID.value = next.doResponseModel.doModel.doID;
        resetPoMaterial();
        showAddMaterial.value = true;
        selectedMaterial.value = null;
        if (isDoneRequested.value) {
          Navigator.of(context).pop();
        }
      } else if (next is SaveDoStateError) {
        isLoading.value = false;
        errorMessagePo.value = next.message;
        Timer(const Duration(seconds: 3), () {
          errorMessagePo.value = "";
          resetPoMaterial();
        });
      }
    });
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

    const horiSpace = SizedBox(width: 10);
    const materialCodeWidth = 115.0;
    final ctrlUnitPrice = useTextEditingController(text: " ");
    double pageWidth = MediaQuery.of(context).size.width - 45;
    if (pageWidth > Constants.webWidth - 45) {
      pageWidth = Constants.webWidth - 45;
    }
    double width25 = (pageWidth - materialCodeWidth - 30) / 3;
    double width50 = width25 * 2 + 10;

    Size gSize = MediaQuery.of(context).size;
    ctrlTotalItem.addListener(() {
      if (selectedMaterial.value == null) return;
      var totalItem = double.tryParse(ctrlTotalItem.text.replaceAll(",", ""));
      if (totalItem == null) {
        isConfirmReady.value = false;
        return;
      }
      var packQty = double.tryParse(ctrlPackQty.text.replaceAll(",", ""));
      if (packQty == null) {
        isConfirmReady.value = false;
        return;
      }

      var availQty = double.tryParse(
          selectedMaterial.value!.remainingItemQty.replaceAll(",", ""));
      if (availQty == null) {
        isConfirmReady.value = false;
        return;
      }
      if (availQty < totalItem * packQty) {
        isConfirmReady.value = false;
        errorMessageTotalQty.value =
            "Exceeded available qty : ${nbf.format(availQty)}";
        return;
      } else {
        errorMessageTotalQty.value = "";
      }
      isConfirmReady.value = true;
    });

    ctrlPackQty.addListener(() {
      if (selectedMaterial.value == null) return;
      var totalItem = double.tryParse(ctrlTotalItem.text.replaceAll(",", ""));
      if (totalItem == null) {
        isConfirmReady.value = false;
        return;
      }
      var packQty = double.tryParse(ctrlPackQty.text.replaceAll(",", ""));
      if (packQty == null) {
        isConfirmReady.value = false;
        return;
      }

      var availQty = double.tryParse(
          selectedMaterial.value!.remainingItemQty.replaceAll(",", ""));
      if (availQty == null) {
        isConfirmReady.value = false;
        return;
      }
      if (availQty < totalItem * packQty) {
        isConfirmReady.value = false;
        errorMessageTotalQty.value =
            "Exceeded available qty : ${nbf.format(availQty)}";
        return;
      } else {
        errorMessageTotalQty.value = "";
      }
      isConfirmReady.value = true;
    });

    ctrlTotalQty.addListener(() {
      if (selectedMaterial.value == null) return;
      var totalItem = double.tryParse(ctrlTotalItem.text.replaceAll(",", ""));
      if (totalItem == null) {
        isConfirmReady.value = false;
        return;
      }
      var packQty = double.tryParse(ctrlPackQty.text.replaceAll(",", ""));
      if (packQty == null) {
        isConfirmReady.value = false;
        return;
      }

      var availQty = double.tryParse(
          selectedMaterial.value!.remainingItemQty.replaceAll(",", ""));
      if (availQty == null) {
        isConfirmReady.value = false;
        return;
      }
      if (availQty < totalItem * packQty) {
        isConfirmReady.value = false;
        errorMessageTotalQty.value =
            "Exceeded available qty : ${nbf.format(availQty)}";
        return;
      } else {
        errorMessageTotalQty.value = "";
      }
      isConfirmReady.value = true;
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          "Goods Receive",
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
                const SizedBox(
                  height: Constants.paddingTopContent,
                ),
                Row(
                  children: [
                    Expanded(
                      child: FxACVendorPo(
                        initialValue: ivVendor.value,
                        width: double.infinity,
                        readOnly: alreadyHaveDo.value,
                        contentPadding: EdgeInsets.all(19),
                        labelText: "Vendor",
                        hintText: "Vendor",
                        value: selectedVendor.value?.vendorName ?? "",
                        onSelected: (model) {
                          selectedVendor.value = model;
                        },
                        errorMessage: errorMessageVendor.value,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    (alreadyHaveDo.value && selectedStoreID.value == "0")
                        ? Expanded(
                            child: FxTextField(
                              labelText: "Store",
                              ctrl: TextEditingController(
                                  text: "No Store Selected"),
                              readOnly: true,
                              enabled: false,
                            ),
                          )
                        : Expanded(
                            child: FxStoreLk(
                              labelText: "Store Location",
                              hintText: "Select Store",
                              readOnly: alreadyHaveDo.value,
                              initialValueId: selectedStoreID.value,
                              onChanged: (model) {
                                selectedStore.value = {
                                  "id": model.storeID,
                                  "name": model.storeName
                                };
                              },
                            ),
                          )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                if (selectedVendor.value != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: FxDateField(
                          fcNode: fcDateField,
                          labelText: "Date Received",
                          hintText: "Date Received",
                          readOnly: alreadyHaveDo.value,
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
                      horiSpace,
                      (selectedVendor.value == null)
                          ? const Expanded(
                              child: SizedBox(width: 20),
                            )
                          : Expanded(
                              child: FxTextField(
                                readOnly: alreadyHaveDo.value ||
                                    selectedDoID.value != "0",
                                width: double.infinity,
                                focusNode: fcDo,
                                errorMessage: doIsTouched.value
                                    ? errorMessageDo.value
                                    : "",
                                ctrl: ctrlDoNumber,
                                labelText: "DO No.",
                                hintText: "DO No.",
                                onChanged: (v) {
                                  if (v != "") {
                                    isDoNoEmpty.value = false;
                                  } else {
                                    isDoNoEmpty.value = true;
                                  }
                                },
                                textCapitalization:
                                    TextCapitalization.characters,
                              ),
                            ),
                    ],
                  ),
                if (selectedVendor.value != null)
                  const SizedBox(
                    height: 10,
                  ),
                if (selectedVendor.value != null &&
                    errorMessageDo.value == "" &&
                    ctrlDoNumber.text != "")
                  FxAutoCompletionPo(
                    withReset: selectedPo.value != null,
                    onReset: () {
                      ctrlPo.text = "";
                      selectedPo.value = null;
                      showAddMaterial.value = false;
                      selectedMaterial.value = null;
                    },
                    width: double.infinity,
                    fc: fcPo,
                    ctrl: ctrlPo,
                    labelText: "PO No.",
                    hintText: "PO No.",
                    value: selectedPo.value?.poNo ?? "",
                    vendorID: selectedVendor.value?.vendorID ?? "0",
                    onSelected: (dPo) {
                      if (dPo.id == 0) {
                        selectedPo.value = null;
                        showAddMaterial.value = false;
                        return;
                      }
                      selectedPo.value = dPo;
                      FocusScope.of(context).requestFocus(FocusNode());
                      showAddMaterial.value = true;
                      addMaterialReady.value = true;
                      checkIsConfirmValid();
                    },
                    errorMessage: errorMessagePo.value,
                  ),
                // if (selectedVendor.value != null &&
                //     ref.read(selectedDoProvider) != null &&
                //     selectedPo.value != null)
                //   FxTextField(
                //     width: double.infinity,
                //     ctrl: TextEditingController(text: selectedPo.value!.poNo),
                //     readOnly: true,
                //     enabled: false,
                //     hintText: "PO No.",
                //     labelText: "PO No.",
                //   ),
                if (selectedVendor.value != null)
                  const SizedBox(
                    height: 10,
                  ),
                if (showAddMaterial.value)
                  Stack(
                    alignment: Alignment.topLeft,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Container(
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
                                const SizedBox(height: 5),
                                if (selectedPo.value != null &&
                                    selectedMaterial.value == null)
                                  FxAutoCompletionMaterial(
                                    width: Constants.webWidth - 40,
                                    ctrl: ctrlMaterial,
                                    fc: fcMaterial,
                                    errorMessage: errorMessageMaterial.value,
                                    labelText: selectedMaterial.value == null
                                        ? "Material Code/Description"
                                        : "Material Code",
                                    hintText: "Material Code / Description",
                                    poID:
                                        selectedPo.value?.id.toString() ?? "0",
                                    value:
                                        selectedMaterial.value?.materialCode ??
                                            "",
                                    onSelectedMaterial: (model) {
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
                                      if (model == null) {
                                        ctrlPackQty.text = "";
                                        ctrlPackUnit.text = "";
                                        selectedMaterial.value = null;
                                        ctrlUnitPrice.text = "";
                                      } else {
                                        selectedMaterial.value = model;
                                        ctrlPackQty.text = model.packQty;
                                        num? packQty;
                                        num? remainingItemQty;

                                        try {
                                          ctrlPackQty.text = nbf
                                              .format(nbf.parse(model.packQty));
                                          packQty = nbf.parse(model.packQty);
                                        } catch (_) {}
                                        ctrlUnit.text = model.unit;
                                        ctrlPackUnit.text = model.packUnit;
                                        try {
                                          ctrlUnitPrice.text = nbfDec.format(
                                              nbfDec.parse(model.unitPrice));
                                        } catch (_) {}

                                        try {
                                          remainingItemQty =
                                              nbf.parse(model.remainingItemQty);
                                        } catch (_) {}

                                        try {
                                          if (model.isCable == "Y") {
                                            ctrlTotalItem.text = nbf.format(1);
                                          } else {
                                            ctrlTotalItem.text = nbf.format(
                                                nbf.parse(model.remainingQty));
                                          }
                                        } catch (_) {}

                                        try {
                                          ctrlTotalAmount
                                              .text = nbfDecTotal.format(nbf
                                                  .parse(ctrlTotalQty.text) *
                                              nbfDec.parse(ctrlUnitPrice.text));
                                        } catch (_) {}
                                        num? poDetailItemQty;
                                        try {
                                          poDetailItemQty =
                                              nbf.parse(model.poDetailItemQty);
                                        } catch (_) {}

                                        if (poDetailItemQty != null &&
                                            remainingItemQty != null &&
                                            model.isCable == "N") {
                                          if (poDetailItemQty.toInt() !=
                                              remainingItemQty.toInt()) {
                                            var reminingItemQty =
                                                remainingItemQty.toInt();
                                            var poPackSizeQty =
                                                packQty!.toInt();
                                            if ((reminingItemQty %
                                                    poPackSizeQty) ==
                                                0) {
                                              ctrlPackQty.text =
                                                  nbf.format(packQty);
                                              ctrlTotalItem.text = nbf.format(
                                                  remainingItemQty /
                                                      poPackSizeQty);
                                              ctrlTotalQty.text =
                                                  nbf.format(remainingItemQty);
                                            } else {
                                              ctrlPackQty.text =
                                                  nbf.format(remainingItemQty);
                                              ctrlTotalItem.text =
                                                  nbf.format(1);
                                              ctrlTotalQty.text =
                                                  nbf.format(remainingItemQty);
                                            }
                                          }
                                        }
                                        selectedPackUnit.value = UnitModel(
                                          unit: model.packUnit,
                                          unitId: model.packUnitId,
                                          unitDesc: model.packUnitDesc,
                                        );
                                      }
                                      ctrlMaterialDesc.text =
                                          model?.description ?? "";
                                      checkIsConfirmValid();
                                    },
                                  ),
                                if (selectedPo.value != null &&
                                    selectedMaterial.value != null)
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      FxAutoCompletionMaterial(
                                        width: (selectedMaterial.value == null)
                                            ? Constants.webWidth - 42
                                            : materialCodeWidth,
                                        ctrl: ctrlMaterial,
                                        fc: fcMaterial,
                                        errorMessage:
                                            errorMessageMaterial.value,
                                        labelText:
                                            selectedMaterial.value == null
                                                ? "Material Code/Description"
                                                : "Material Code",
                                        hintText: "Search",
                                        poID: selectedPo.value?.id.toString() ??
                                            "0",
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
                                            ctrlUnitPrice.text = "";
                                          } else {
                                            selectedMaterial.value = model;
                                            ctrlPackQty.text = model.packQty;
                                            try {
                                              ctrlPackQty.text = nbf.format(
                                                  nbf.parse(model.packQty));
                                            } catch (_) {}
                                            ctrlUnit.text = model.unit;
                                            ctrlPackUnit.text = model.packUnit;
                                            try {
                                              ctrlUnitPrice.text =
                                                  nbfDec.format(nbfDec
                                                      .parse(model.unitPrice));
                                            } catch (_) {}
                                            try {
                                              ctrlTotalItem.text = nbf.format(
                                                  nbf.parse(
                                                      model.remainingQty));
                                            } catch (_) {}

                                            try {
                                              ctrlTotalAmount.text =
                                                  nbfDec.format(nbf.parse(
                                                          ctrlTotalQty.text) *
                                                      nbfDec.parse(
                                                          ctrlUnitPrice.text));
                                            } catch (_) {}
                                            selectedPackUnit.value = UnitModel(
                                              unit: model.packUnit,
                                              unitId: model.packUnitId,
                                              unitDesc: model.packUnitDesc,
                                            );
                                          }
                                          ctrlMaterialDesc.text =
                                              model?.description ?? "";
                                          checkIsConfirmValid();
                                        },
                                      ),
                                      if (selectedMaterial.value != null)
                                        horiSpace,
                                      if (selectedMaterial.value != null)
                                        Expanded(
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
                                if (selectedPo.value != null)
                                  const SizedBox(
                                    height: 10,
                                  ),
                                if (selectedPo.value != null &&
                                    selectedMaterial.value?.isCable == "Y")
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 10.0),
                                    child: FxTextField(
                                      focusNode: fcDrumNum,
                                      width: double.infinity,
                                      errorMessage: errorMessageDrumNo.value,
                                      enabled:
                                          selectedMaterial.value?.isCable ==
                                              "Y",
                                      forceHighlight:
                                          selectedMaterial.value?.isCable ==
                                              "Y",
                                      ctrl: ctrlDrumNum,
                                      hintText: "Drum No.",
                                      labelText: "Drum No.",
                                    ),
                                  ),
                                if (selectedMaterial.value != null)
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 10.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        FxTextField(
                                          width: materialCodeWidth,
                                          focusNode: fcTotalItem,
                                          textAlign: TextAlign.end,
                                          readOnly:
                                              selectedMaterial.value?.isCable ==
                                                  "Y",
                                          enabled:
                                              selectedMaterial.value?.isCable !=
                                                  "Y",
                                          errorMessage: errorMessageQty.value,
                                          ctrl: ctrlTotalItem,
                                          hintText: "Total Item",
                                          labelText: "Total Item",
                                          forceHighlight:
                                              selectedMaterial.value?.isCable !=
                                                  "Y",
                                          textInputType: TextInputType.number,
                                          // enabled: selectedMaterial
                                          //         .value?.isCable !=
                                          //     "Y",
                                          // readOnly: selectedMaterial
                                          //         .value?.isCable ==
                                          //     "Y"),
                                        ),
                                        horiSpace,
                                        FxAutoCompletionPackUnit(
                                          enabled: false,
                                          readOnly: true,
                                          ctrl: ctrlPackUnit,
                                          fc: fcPackUnit,
                                          width: width25,
                                          labelText: "Pack Unit",
                                          hintText: "Pack Unit",
                                          onSelected: (model) {
                                            FocusScope.of(context)
                                                .requestFocus(FocusNode());
                                            selectedPackUnit.value = model;
                                            ivPackUnit.value = TextEditingValue(
                                                text: model.unit);
                                          },
                                        ),
                                        horiSpace,
                                        FxTextField(
                                          width: width25,
                                          focusNode: fcPackQty,
                                          // readOnly: true,
                                          // enabled: false,
                                          textAlign: TextAlign.end,
                                          textInputType: TextInputType.number,
                                          errorMessage:
                                              errorMessagePackQty.value,
                                          ctrl: ctrlPackQty,
                                          forceHighlight: true,
                                          hintText: "Pack Size",
                                          labelText: "Pack Size",
                                        ),
                                        horiSpace,
                                        FxTextField(
                                          width: width25,
                                          enabled: false,
                                          ctrl: ctrlUnit,
                                          hintText: "UOM",
                                          labelText: "UOM",
                                        ),
                                      ],
                                    ),
                                  ),
                                if (selectedMaterial.value != null)
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      FxTextField(
                                        width: materialCodeWidth,
                                        textAlign: TextAlign.end,
                                        ctrl: ctrlUnitPrice,
                                        enabled: false,
                                        hintText: "Unit Price",
                                        labelText: "Unit price",
                                        readOnly: true,
                                      ),
                                      horiSpace,
                                      FxTextField(
                                        width: width25,
                                        textAlign: TextAlign.end,
                                        ctrl: ctrlTotalQty,
                                        readOnly: true,
                                        enabled: false,
                                        hintText: "Total Qty",
                                        errorMessage:
                                            errorMessageTotalQty.value,
                                        labelText:
                                            "Total Qty (Total Item x Pack Size)",
                                      ),
                                      horiSpace,
                                      FxTextField(
                                        width: width50,
                                        textAlign: TextAlign.end,
                                        ctrl: ctrlTotalAmount,
                                        readOnly: true,
                                        enabled: false,
                                        hintText: "Total Amount (RM)",
                                        labelText: "Total Amount (RM)",
                                      ),
                                    ],
                                  ),
                                const SizedBox(
                                  height: 10,
                                ),
                                if (selectedMaterial.value != null)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: FxButton(
                                          prefix: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10.0),
                                            child: Image.asset(
                                              "images/add_icon.png",
                                              width: 22,
                                              height: 22,
                                            ),
                                          ),
                                          isLoading: isLoading.value,
                                          title: "Add Material",
                                          onPress: isConfirmReady.value &&
                                                  double.tryParse(ctrlTotalItem.text.replaceAll(",", "")) !=
                                                      null &&
                                                  double.tryParse(ctrlTotalItem.text.replaceAll(",", ""))! >
                                                      0.0 &&
                                                  double.tryParse(selectedMaterial
                                                          .value!.remainingQty
                                                          .replaceAll(
                                                              ",", "")) !=
                                                      null &&
                                                  double.parse(ctrlTotalItem.text
                                                          .replaceAll(
                                                              ",", "")) <=
                                                      double.parse(selectedMaterial
                                                          .value!
                                                          .remainingItemQty
                                                          .replaceAll(",", ""))
                                              ? () {
                                                  String drumNum = "";
                                                  if (selectedMaterial
                                                          .value?.isCable ==
                                                      "Y") {
                                                    drumNum = ctrlDrumNum.text;
                                                  }
                                                  if (!checkIsConfirmValid()) {
                                                    return;
                                                  }
                                                  ref.read(saveDoProvider.notifier).save(
                                                      doID: selectedDoID.value,
                                                      doNo: ctrlDoNumber.text,
                                                      date: selectedDate.value,
                                                      poNo: selectedPo
                                                          .value!.poNo,
                                                      poID: selectedPo.value!.id
                                                          .toString(),
                                                      materialID:
                                                          selectedMaterial
                                                              .value!
                                                              .materialId,
                                                      drumNo: drumNum,
                                                      storeID: selectedStore
                                                          .value!["id"]
                                                          .toString(),
                                                      qty: ctrlTotalItem.text
                                                          .replaceAll(",", ""),
                                                      vendorID: selectedVendor
                                                          .value!.vendorID,
                                                      packUnitID:
                                                          selectedPackUnit
                                                                  .value?.unitId
                                                                  .toString() ??
                                                              "0",
                                                      packQty: ctrlPackQty.text
                                                          .replaceAll(",", ""),
                                                      poPackQty:
                                                          selectedMaterial
                                                              .value!.packQty);
                                                }
                                              : null,
                                        ),
                                      ),
                                      horiSpace,
                                      Expanded(
                                        child: FxButton(
                                          prefix: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10.0),
                                            child: Image.asset(
                                              "images/tick_icon.png",
                                              width: 22,
                                              height: 22,
                                            ),
                                          ),
                                          title: "Done",
                                          color: Constants.greenDark,
                                          onPress: listDoDetail
                                                      .value.isNotEmpty &&
                                                  isConfirmReady.value &&
                                                  double.tryParse(
                                                          ctrlTotalItem.text) !=
                                                      null &&
                                                  double.tryParse(
                                                          ctrlTotalItem.text)! >
                                                      0.0 &&
                                                  double.tryParse(
                                                          selectedMaterial
                                                              .value!
                                                              .remainingQty) !=
                                                      null &&
                                                  double.parse(
                                                          ctrlTotalItem.text) <=
                                                      double.tryParse(
                                                          selectedMaterial
                                                              .value!
                                                              .remainingQty)!
                                              ? () {
                                                  /* Navigator.of(context).pop(); */
                                                  String drumNum = "";
                                                  if (selectedMaterial
                                                          .value?.isCable ==
                                                      "Y") {
                                                    drumNum = ctrlDrumNum.text;
                                                  }
                                                  ref
                                                      .read(saveDoProvider
                                                          .notifier)
                                                      .save(
                                                        doID:
                                                            selectedDoID.value,
                                                        doNo: ctrlDoNumber.text,
                                                        date:
                                                            selectedDate.value,
                                                        poNo: selectedPo
                                                            .value!.poNo,
                                                        poID: selectedPo
                                                            .value!.id
                                                            .toString(),
                                                        materialID:
                                                            selectedMaterial
                                                                .value!
                                                                .materialId,
                                                        drumNo: drumNum,
                                                        storeID: selectedStore
                                                            .value!["id"]
                                                            .toString(),
                                                        qty: ctrlTotalItem.text,
                                                        vendorID: selectedVendor
                                                            .value!.vendorID,
                                                        packUnitID:
                                                            selectedPackUnit
                                                                    .value
                                                                    ?.unitId
                                                                    .toString() ??
                                                                "0",
                                                        packQty:
                                                            ctrlPackQty.text,
                                                      );
                                                  isDoneRequested.value = true;
                                                }
                                              : null,
                                        ),
                                      )
                                    ],
                                  ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 10,
                        child: Container(
                          width: 120,
                          height: 20,
                          color: Colors.white,
                          child: const Padding(
                            padding: EdgeInsets.only(left: 5.0, top: 2.0),
                            child: Text(
                              "Receivable Material",
                              style: TextStyle(
                                color: Constants.greenDark,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                if (errorMessageLoadDo.value != "")
                  Text(
                    errorMessageLoadDo.value,
                    style: const TextStyle(color: Colors.red),
                  ),
                if (listDoDetail.value.isNotEmpty)
                  ...(listDoDetail.value).map((det) {
                    final idx = listDoDetail.value.indexOf(det);
                    return Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: FxDoDetail(
                          isFirst: idx == 0,
                          model: det,
                          onDelete: det.isAllowDelete != "Y" ? null :  () {
                            ref.read(deleteDetailProvider.notifier).delete(
                                  doDetailID: det.doDetailID,
                                  storeID: selectedStore.value!["id"],
                                  doNo: ctrlDoNumber.text,
                                  vendorID: selectedVendor.value!.vendorID,
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
