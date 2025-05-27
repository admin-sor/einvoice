import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sor_inventory/widgets/fx_button.dart';

import '../../app/app_route.dart';
import '../../app/constants.dart';
import '../../model/barcode_scan_response.dart';
import '../../model/sor_user_model.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_scan_info.dart';
import '../../widgets/fx_text_field.dart';
import '../login/login_provider.dart';
import 'scan_barcode_provider.dart';

class CheckInScreen extends HookConsumerWidget {
  const CheckInScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginModel = useState<SorUser?>(null);
    final isInit = useState(true);

    final ctrlBarcode = useTextEditingController(text: "");
    final isLoading = useState(false);
    final errorMessage = useState("");
    final selectedStore = useState<Map<String, dynamic>?>(null);
    final listBarcode = useState<List<String>>(List.empty());
    final listScanned = useState<List<String>>(List.empty());
    final listResponseModel =
        useState<List<BarcodeScanResponseModel>>(List.empty());
    final fcBarcode = FocusNode();
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
    useEffect(() {
      Timer? timer;
      listBarcode.addListener(() {
        if (timer != null && timer!.isActive) {
          timer!.cancel();
        }
        timer = Timer(const Duration(seconds: 1), () {
          final barcodes = listBarcode.value;
          if (barcodes.isEmpty) return;
          List<String> param = List.empty();
          if (listScanned.value.isNotEmpty) {
            param = barcodes
                .where((barcode) =>
                    listScanned.value
                        .indexWhere((scanned) => scanned == barcode) ==
                    -1)
                .toList();
          } else {
            param = barcodes;
          }
          if (param.isEmpty) return;
          ref.read(scanBarcodeStateProvider.notifier).scan(barcode: param);
        });
      });

      return () {
        if (timer != null) timer!.cancel();
      };
    }, []);

    ref.listen(scanBarcodeStateProvider, (prev, next) {
      if (next is ScanBarcodeStateLoading) {
        isLoading.value = true;
      } else if (next is ScanBarcodeStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
        Timer(const Duration(seconds: 3), () {
          errorMessage.value = "";
        });
      } else if (next is ScanBarcodeStateDone) {
        isLoading.value = false;
        errorMessage.value = next.message;
        if (next.scanBarcode.isNotEmpty) {
          final List<String> newScanned = List.empty(growable: true);
          if (listScanned.value.isNotEmpty) {
            newScanned.addAll(listScanned.value);
            for (var str in next.scanBarcode) {
              newScanned.add(str);
            }
            listScanned.value = newScanned;
          } else {
            listScanned.value = next.scanBarcode;
          }
        }
        if (next.list.isNotEmpty) {
          final List<BarcodeScanResponseModel> xlist =
              List.empty(growable: true);
          xlist.addAll(next.list);
          xlist.addAll(listResponseModel.value);
          listResponseModel.value = xlist;
        }
        Timer(const Duration(seconds: 3), () {
          errorMessage.value = "";
        });
      }
    });
    fcBarcode.requestFocus();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          "Stock In",
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
          canRequestFocus: false,
          child: const Icon(Icons.arrow_back),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      endDrawer: const EndDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  child: FxTextField(
                    focusNode: fcBarcode,
                    ctrl: ctrlBarcode,
                    labelText: "Scan Barcode",
                    hintText: "Scan Barcode",
                    onSubmitted: (val) {
                      final List<String> list = List.empty(growable: true);
                      list.addAll(listBarcode.value);
                      list.add(val);
                      listBarcode.value = list;
                      ctrlBarcode.text = "";
                      fcBarcode.requestFocus();
                    },
                    suffix: isLoading.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator())
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset("images/icon_scan_barcode.png",
                                width: 18, height: 18),
                          ),
                  ),
                ),
                /* const SizedBox(width: 10), */
                /* InkWell( */
                /*   onTap: () { */
                /*     Navigator.of(context).pushNamed(checkinScan); */
                /*   }, */
                /*   child: Image.asset( */
                /*     "images/icon_barcode.png", */
                /*     width: 48, */
                /*   ), */
                /* ), */
              ],
            ),
            if (errorMessage.value != "")
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(errorMessage.value),
                  ),
                ),
              ),
            if (listResponseModel.value.isNotEmpty) const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                  itemCount: listResponseModel.value.length,
                  itemBuilder: (context, idx) {
                    final m = listResponseModel.value[idx];
                    return FxScanInfo(model: m, isFirst: idx == 0);
                  }),
            ),
            FxButton(
              maxWidth: double.infinity,
              title: "Done",
              onPress: () {
                Navigator.of(context).pop();
              },
              color: Constants.orange,
            ),
          ],
        ),
      ),
    );
  }
}
