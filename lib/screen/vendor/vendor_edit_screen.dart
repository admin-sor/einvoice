import 'dart:async';

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sor_inventory/model/payment_term_response_model.dart';
import 'package:sor_inventory/model/vendor_model.dart';
import 'package:sor_inventory/screen/vendor/vendor_save_provider.dart';
import 'package:sor_inventory/widgets/fx_button.dart';
import 'package:sor_inventory/widgets/fx_gray_dark_text.dart';
import 'package:sor_inventory/widgets/fx_payment_term_all_lk.dart';
import 'package:sor_inventory/widgets/fx_text_field.dart';

import '../../app/app_route.dart';
import '../../app/constants.dart';
import '../../model/sor_user_model.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_black_text.dart';
import '../../widgets/fx_green_dark_text.dart';
import '../../widgets/fx_multiline_text_field.dart';
import '../login/login_provider.dart';
import '../vendor_material/vendor_material_selected_provider.dart';
import 'vendor_delete_provider.dart';

class VendorEditScreen extends HookConsumerWidget {
  final bool isNew;
  final String query;
  final VendorModel? vendor;
  const VendorEditScreen({
    Key? key,
    required this.isNew,
    required this.query,
    this.vendor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginModel = useState<SorUser?>(null);
    final isInit = useState(true);
    final ctrlVendor = useTextEditingController(text: vendor?.vendorName ?? "");
    final ctrlAddr1 = useTextEditingController(text: vendor?.vendorAdd1 ?? "");
    final ctrlAddr2 = useTextEditingController(text: vendor?.vendorAdd2 ?? "");
    final ctrlAddr3 = useTextEditingController(text: vendor?.vendorAdd3 ?? "");
    final ctrlRegNo = useTextEditingController(text: vendor?.vendorRegNo ?? "");
    final ctrlPicName =
        useTextEditingController(text: vendor?.vendorPicName ?? "");
    final ctrlPicPhone =
        useTextEditingController(text: vendor?.vendorPicPhone ?? "");
    final ctrlPicEmail =
        useTextEditingController(text: vendor?.vendorPicEmail ?? "");

    final stVendorTnc = useState<String>(vendor?.vendorTerm ?? "");
    final errorMessage = useState("");
    final isLoading = useState(false);
    final isInEditMode = useState(false);
    final PaymentTermResponseModel? initPaymentTerm = null;
    final selectedPaymentTerm =
        useState<PaymentTermResponseModel?>(initPaymentTerm);

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
      useEffect(() {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
      });
      return Scaffold(
        body: Container(
          color: Colors.white,
        ),
      );
    }
    const horiSpace = SizedBox(width: 10);
    ref.listen(vendorSaveProvider, (previous, next) {
      if (next is VendorSaveStateLoading) {
        isLoading.value = true;
      } else if (next is VendorSaveStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
      } else if (next is VendorSaveStateDone) {
        isLoading.value = false;
        Navigator.of(context).pop();
      }
    });
    // final isMultilineFocused = useState(false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text(
          isNew ? "Add Vendor" : "Edit Vendor",
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
          height: MediaQuery.of(context).size.height + 590,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: Constants.paddingTopContent,
                ),
                FxTextField(
                  ctrl: ctrlVendor,
                  labelText: "Vendor Name",
                  width: double.infinity,
                ),
                const SizedBox(
                  height: 10,
                ),
                FxTextField(
                  ctrl: ctrlRegNo,
                  labelText: "Reg. No",
                  width: double.infinity,
                ),
                const SizedBox(
                  height: 10,
                ),
                FxTextField(
                  ctrl: ctrlAddr1,
                  labelText: "1st Address",
                  width: double.infinity,
                ),
                const SizedBox(
                  height: 10,
                ),
                FxTextField(
                  ctrl: ctrlAddr2,
                  labelText: "2nd Address",
                  width: double.infinity,
                ),
                const SizedBox(
                  height: 10,
                ),
                FxTextField(
                  ctrl: ctrlAddr3,
                  labelText: "3rd Address",
                  width: double.infinity,
                ),
                const SizedBox(
                  height: 10,
                ),
                FxTextField(
                  ctrl: ctrlPicName,
                  labelText: "Person in charge",
                  width: double.infinity,
                ),
                const SizedBox(
                  height: 10,
                ),
                FxTextField(
                  ctrl: ctrlPicEmail,
                  labelText: "Email",
                  width: double.infinity,
                ),
                const SizedBox(
                  height: 10,
                ),
                FxTextField(
                  ctrl: ctrlPicPhone,
                  labelText: "Phone",
                  width: double.infinity,
                ),
                const SizedBox(
                  height: 15,
                ),
                FxPaymentTermAllLk(
                  width: double.infinity,
                  hintText: "Payment Term",
                  labelText: "Payment Term",
                  initialValue: initPaymentTerm,
                  paymentTermID: vendor?.vendorPaymentTermID ?? "",
                  onChanged: (val) {
                    selectedPaymentTerm.value = val;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: FxMultilineTextField(
                        initialValue: stVendorTnc.value,
                        isReadOnly: !isInEditMode.value,
                        onChange: (val) {
                          stVendorTnc.value = val;
                        },
                      ),
                    ),
                    Positioned(
                      left: 10,
                      child: Container(
                          color: Colors.white, height: 20, width: 120),
                    ),
                    Positioned(
                        left: 10,
                        child: FxGreenDarkText(
                          title: "Term & Condition",
                          fontSize: 14,
                        ))
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                if (vendor != null && !isInEditMode.value)
                  Row(
                    children: [
                      Expanded(
                        child: FxButton(
                          title: "Material",
                          color: Constants.orange,
                          onPress: () {
                            ref
                                .read(vendorMaterialSelectedVendorProvider
                                    .notifier)
                                .state = vendor;
                            Navigator.of(context)
                                .pushNamed(vendorMaterialRoute);
                          },
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: FxButton(
                          title: "Edit ",
                          color: Constants.greenDark,
                          onPress: () {
                            isInEditMode.value = !isInEditMode.value;
                          },
                        ),
                      ),
                    ],
                  ),
                if (errorMessage.value != "")
                  FxGrayDarkText(
                    color: Constants.red,
                    title: errorMessage.value,
                  ),
                if (isInEditMode.value || isNew)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (!isNew)
                        Expanded(
                          child: FxButton(
                            color: Constants.red,
                            title: "Delete",
                            onPress: () async {
                              if (await confirm(context,
                                  title: FxBlackText(
                                      title: "Confirm delete " +
                                          vendor!.vendorName +
                                          "?"),
                                  content: Text(
                                      "${vendor!.vendorAdd1} ${vendor!.vendorAdd2}\n${vendor!.vendorAdd3}"))) {
                                ref.read(vendorDeleteProvider.notifier).delete(
                                    vendorID: vendor!.vendorID, query: query);
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                        ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: FxButton(
                          title: "Cancel",
                          onPress: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: FxButton(
                          title: "Save",
                          color: Constants.greenDark,
                          isLoading: isLoading.value,
                          onPress: () {
                            if (selectedPaymentTerm.value == null) {
                              errorMessage.value = "Payment Term not selected";
                              return;
                            }
                            ref.read(vendorSaveProvider.notifier).save(
                                vendorID:
                                    isNew ? "0" : vendor!.vendorID.toString(),
                                vendorName: ctrlVendor.text,
                                vendorAdd1: ctrlAddr1.text,
                                vendorPaymentTermID:
                                    selectedPaymentTerm.value!.paymentTermID,
                                vendorAdd2: ctrlAddr2.text,
                                vendorAdd3: ctrlAddr3.text,
                                vendorRegNo: ctrlRegNo.text,
                                vendorPicEmail: ctrlPicEmail.text,
                                vendorPicName: ctrlPicName.text,
                                vendorPicPhone: ctrlPicPhone.text,
                                vendorTerm: stVendorTnc.value,
                                query: query);
                          },
                        ),
                      ),
                    ],
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
