import 'dart:async';

import 'package:fast_barcode_scanner/fast_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app/app_route.dart';
import '../../app/constants.dart';
import '../../model/sor_user_model.dart';
import '../../widgets/end_drawer.dart';
import '../login/login_provider.dart';

class CheckInScanScreen extends HookConsumerWidget {
  const CheckInScanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginModel = useState<SorUser?>(null);
    final isInit = useState(true);

    final isLoading = useState(false);
    final errorMessage = useState("");
    final selectedStore = useState<Map<String, dynamic>?>(null);
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
    final scanCode = useState("");
    double barcodeCameraHeight = MediaQuery.of(context).size.height / 2;
    if (barcodeCameraHeight > 200) {
      barcodeCameraHeight = 200;
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          "Scan Barcode",
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
      ),
      endDrawer: const EndDrawer(),
      body: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height - 81,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                height: barcodeCameraHeight,
                child: BarcodeCamera(
                    types: const [
                      BarcodeType.qr,
                      BarcodeType.code128,
                    ],
                    resolution: Resolution.sd480,
                    framerate: Framerate.fps30,
                    mode: DetectionMode.pauseVideo,
                    onScan: (code) {
                      scanCode.value =
                          "${code.type.toString()} | ${code.value.toString()}";
                      Timer(const Duration(seconds: 4), () {
                        scanCode.value = "";
                      });
                    },
                    onError: (ctx, err) {
                      return Text("Scan Error : ${err.toString()}\n");
                    },
                    children: const [
                      MaterialPreviewOverlay(animateDetection: false),
                      BlurPreviewOverlay(),
                    ]),
              ),
              const Spacer(),
              if (scanCode.value != "")
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    scanCode.value,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Constants.greenDark,
                    ),
                  ),
                ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      CameraController.instance.pauseDetector();
                      Navigator.of(context).pop();
                    },
                    child: const Text("Done"),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                    onPressed: () => CameraController.instance.resumeDetector(),
                    child: const Text("Resume"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
