import 'dart:async';

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sor_inventory/model/regional_office_model.dart';
import 'package:sor_inventory/widgets/fx_button.dart';
import 'package:sor_inventory/widgets/fx_gray_dark_text.dart';
import 'package:sor_inventory/widgets/fx_regional_office_lk.dart';
import 'package:sor_inventory/widgets/fx_text_field.dart';

import '../../app/app_route.dart';
import '../../app/constants.dart';
import '../../model/sor_user_model.dart';
import '../../model/store_model.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_black_text.dart';
import '../login/login_provider.dart';
import 'store_delete_provider.dart';
import 'store_save_provider.dart';

class StoreEditScreen extends HookConsumerWidget {
  final bool isNew;
  final String query;
  final StoreModel? store;
  const StoreEditScreen({
    Key? key,
    required this.isNew,
    required this.query,
    this.store,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginModel = useState<SorUser?>(null);
    final isInit = useState(true);
    final ctrlStore = useTextEditingController(text: store?.storeName ?? "");
    final ctrlAddr1 =
        useTextEditingController(text: store?.storeAddress1 ?? "");
    final ctrlAddr2 =
        useTextEditingController(text: store?.storeAddress2 ?? "");
    final ctrlAddr3 =
        useTextEditingController(text: store?.storeAddress3 ?? "");
    final ctrlPicName = useTextEditingController(text: store?.storePIC ?? "");
    final ctrlPicPhone =
        useTextEditingController(text: store?.storePhone ?? "");
    final ctrlPicEmail =
        useTextEditingController(text: store?.storeEmail ?? "");
    final errorMessage = useState("");
    final isLoading = useState(false);
    final isInEditMode = useState(true);
    final selectedRegionOffice = useState<RegionalOfficeModel?>(null);
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
    ref.listen(storeSaveProvider, (previous, next) {
      if (next is StoreSaveStateLoading) {
        isLoading.value = true;
      } else if (next is StoreSaveStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
      } else if (next is StoreSaveStateDone) {
        isLoading.value = false;
        Navigator.of(context).pop();
      }
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text(
          isNew ? "Add Store" : "Edit Store",
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
          height: MediaQuery.of(context).size.height - 100,
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
                  ctrl: ctrlStore,
                  labelText: "Store Name",
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
                  height: 10,
                ),
                FxRegionalOfficeLk(
                  // width: 250,
                  hintText: "Select Region Office",
                  labelText: "Region Office",
                  initialValueId: store?.region_id,
                  readOnly: false,
                  onChanged: (model) {
                    selectedRegionOffice.value = model;
                  },
                ),
                Spacer(),
                if (errorMessage.value != "")
                  FxGrayDarkText(
                    color: Constants.red,
                    title: errorMessage.value,
                  ),
                if (isInEditMode.value || isNew)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // if (!isNew)
                      //   Expanded(
                      //     child: FxButton(
                      //       color: Constants.red,
                      //       title: "Delete",
                      //       onPress: () async {
                      //         if (await confirm(context,
                      //             title: FxBlackText(
                      //                 title: "Confirm delete " +
                      //                     store!.storeName! +
                      //                     "?"),
                      //             content: Text(
                      //                 "${store!.storeAddress1} ${store!.storeAddress2}\n${store!.storeAddress3}"))) {
                      //           ref.read(storeDeleteProvider.notifier).delete(
                      //               storeID: store!.storeID!, query: query);
                      //           Navigator.of(context).pop();
                      //         }
                      //       },
                      //     ),
                      //   ),
                      // SizedBox(
                      //   width: 20,
                      // ),
                      SizedBox(width:20),
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
                            ref.read(storeSaveProvider.notifier).save(
                                storeID:
                                    isNew ? "0" : store!.storeID.toString(),
                                storeName: ctrlStore.text,
                                storeAddress1: ctrlAddr1.text,
                                storeAddress2: ctrlAddr2.text,
                                storeAddress3: ctrlAddr3.text,
                                storeEmail: ctrlPicEmail.text,
                                storePIC: ctrlPicName.text,
                                storePhone: ctrlPicPhone.text,
                                regionID: selectedRegionOffice.value?.regionId ?? "0",
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
