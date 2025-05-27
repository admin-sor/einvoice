import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/app_route.dart';
import '../../app/constants.dart';
import '../../model/material_status_response_model.dart';
import '../../model/sor_user_model.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_floating_ab_print.dart';
import '../login/login_provider.dart';
import 'material_status_provider.dart';

class MaterialStatusScreen extends HookConsumerWidget {
  const MaterialStatusScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final header = [
      "Code",
      "Description",
      // "BOQ",
      "PO",
      "DO",
      "Issue",
      "Return",
      "Store",
      "Count",
      "Diff"
    ];
    final double moneyWidth = 100.00;
    final List<double> headerWidth = [
      120,
      400,
      // moneyWidth,
      moneyWidth,
      moneyWidth,
      moneyWidth,
      moneyWidth,
      moneyWidth,
      moneyWidth,
      moneyWidth,
    ];

    final loginModel = useState<SorUser?>(null);
    final isInit = useState(true);
    final isInitList = useState(true);
    final isLoading = useState(false);
    final errorMessage = useState("");
    final statusIsRm = useState(false);
    final listStatus =
        useState<List<MaterialStatusResponseModel>>(List.empty());

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
      return Scaffold(
        body: Container(
          color: Colors.white,
        ),
      );
    }

    Size size = MediaQuery.of(context).size;
    if (isInitList.value) {
      isInitList.value = false;
      WidgetsBinding.instance.addPostFrameCallback((tmr) {
        ref.read(materialStatusProvider.notifier).list();
      });
    }
    ref.listen(materialStatusProvider, (prev, next) {
      if (next is MaterialStatusStateLoading) {
        isLoading.value = true;
      } else if (next is MaterialStatusStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
        Timer(const Duration(seconds: 3), () {
          errorMessage.value = "";
        });
      } else if (next is MaterialStatusStateDone) {
        isLoading.value = false;
        listStatus.value = next.list;
      }
    });
    double maxWidth = headerWidth.fold(
        0, (previousValue, element) => (previousValue) + element);
    final myScrollCtrl = ScrollController();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          "Material Status",
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
      // floatingActionButton: FxFloatingABPrint(
      //   errorMessage: errorMessage,
      //   preUrl: "https://${Constants.host}/reports/material_status.php?",
      // ),
      endDrawer: const EndDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(
              height: Constants.paddingTopContent,
            ),
            Row(
              children: [
                const Spacer(),
                InkWell(
                  onTap: () {
                    statusIsRm.value = !statusIsRm.value;
                  },
                  child: Image.asset(
                    statusIsRm.value
                        ? "images/icon_matstat_rm.png"
                        : "images/icon_matstat_qty.png",
                    height: 32,
                  ),
                ),
              ],
            ),
            if (errorMessage.value != "")
              Text(
                errorMessage.value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Constants.red,
                ),
              ),
            if (isLoading.value)
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(),
              ),
            const SizedBox(height: 5),
            Expanded(
              child: SizedBox(
                width: kIsWeb ? Constants.webWidth : size.width,
                child: Scrollbar(
                  thumbVisibility: true,
                  thickness: 10,
                  controller: myScrollCtrl, 
                  child: Padding(
                    padding: const EdgeInsets.only(bottom:15.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: myScrollCtrl,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const SizedBox(height: 5),
                          StatusHeader(
                            header: header,
                            headerWidth: headerWidth,
                          ),
                          Expanded(
                            child: SizedBox(
                              width: maxWidth,
                              child: StatusDetail(
                                detail: listStatus.value,
                                headerWidth: headerWidth,
                                isRm: statusIsRm.value,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusDetail extends StatelessWidget {
  const StatusDetail({
    Key? key,
    required this.detail,
    required this.headerWidth,
    required this.isRm,
  }) : super(key: key);

  final List<MaterialStatusResponseModel> detail;
  final List<double> headerWidth;
  final bool isRm;

  String nbfFormat(String inp) {
    final nbf = NumberFormat("###,##0");
    try {
      return nbf.format(double.parse(inp));
    } catch (_) {
      return inp;
    }
  }

  String nbfFormatAmount(String inp) {
    final nbf = NumberFormat("###,##0.00");
    try {
      return nbf.format(double.parse(inp));
    } catch (_) {
      return inp;
    }
  }

  @override
  Widget build(BuildContext context) {
    final nbf = NumberFormat("###,##0");
    final nbfAmount = NumberFormat("###,##0.00");
    return ListView.builder(
      itemCount: detail.length,
      itemBuilder: (context, idx) {
        final status = detail[idx];
        String bookQty = "0";
        String bookAmount = "0.00";
        String actualQty = "0";
        String actualAmount = "0.00";
        String diffQty = "0";
        String diffAmount = "0.00";

        Color? color;

        double dBookQty = 0;
        ;
        double dBookAmount = 0;
        try {
          dBookQty = nbf.parse(status.bookQty).toDouble();
          dBookAmount = nbf.parse(status.bookAmount).toDouble();

          bookQty = nbf.format(dBookQty);
          bookAmount = nbfAmount.format(dBookAmount);
          if (dBookQty < 0) {
            color = Constants.red;
          }
        } catch (_) {}

        try {
          double dDiffQty = nbf.parse(status.actualQty) - dBookQty;
          double dDiffAmount = nbf.parse(status.actualAmount) - dBookAmount;

          diffQty = nbf.format(dDiffQty);
          diffAmount = nbfAmount.format(dDiffAmount);
          if (dDiffQty.round() != 0) {
            color = Constants.red;
          }
        } catch (_) {}

        if (isRm) {
          return Row(
            children: [
              StatusCell(
                  headerWidth: headerWidth[0],
                  label: status.code,
                  textAlign: TextAlign.center),
              StatusCell(
                  headerWidth: headerWidth[1],
                  label: status.description,
                  textAlign: TextAlign.left),
              // StatusCell(
              //   headerWidth: headerWidth[2],
              //   label: nbfFormatAmount(status.boqAmount),
              // ),
              StatusCell(
                headerWidth: headerWidth[2],
                label: nbfFormatAmount(status.poAmount),
              ),
              StatusCell(
                headerWidth: headerWidth[3],
                label: nbfFormatAmount(status.doAmount),
              ),
              StatusCell(
                headerWidth: headerWidth[4],
                label: nbfFormatAmount(status.issueAmount),
              ),
              StatusCell(
                headerWidth: headerWidth[5],
                label: nbfFormatAmount(status.returnAmount),
              ),
              StatusCell(
                headerWidth: headerWidth[6],
                label: nbfFormatAmount(status.bookAmount),
              ),
              StatusCell(
                headerWidth: headerWidth[7],
                label: nbfFormatAmount(status.actualAmount),
              ),
              StatusCell(
                headerWidth: headerWidth[8],
                label: nbfFormatAmount(diffAmount),
                color: color,
                textAlign: TextAlign.right,
              ),
            ],
          );
        }
        return Row(
          children: [
            StatusCell(
                headerWidth: headerWidth[0],
                label: status.code,
                textAlign: TextAlign.center),
            StatusCell(
                headerWidth: headerWidth[1],
                label: status.description,
                textAlign: TextAlign.left),
            // StatusCell(
            //   headerWidth: headerWidth[2],
            //   label: nbfFormat(status.boqQty),
            // ),
            StatusCell(
              headerWidth: headerWidth[2],
              label: nbfFormat(status.poQty),
            ),
            StatusCell(
              headerWidth: headerWidth[3],
              label: nbfFormat(status.doQty),
            ),
            StatusCell(
              headerWidth: headerWidth[4],
              label: nbfFormat(status.issueQty),
            ),
            StatusCell(
              headerWidth: headerWidth[5],
              label: nbfFormat(status.returnQty),
            ),
            StatusCell(
              headerWidth: headerWidth[6],
              label: nbfFormat(bookQty),
            ),
            StatusCell(
              headerWidth: headerWidth[7],
              label: nbfFormat(status.actualQty),
            ),
            StatusCell(
              headerWidth: headerWidth[8],
              label: nbfFormat(diffQty),
              color: color,
              textAlign: TextAlign.right,
            ),
          ],
        );
      },
    );
  }
}

class StatusCell extends StatelessWidget {
  const StatusCell({
    Key? key,
    required this.headerWidth,
    required this.label,
    this.color,
    this.textAlign = TextAlign.right,
  }) : super(key: key);

  final double headerWidth;
  final String label;
  final TextAlign textAlign;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: headerWidth,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(
          label,
          textAlign: textAlign,
          style: TextStyle(
            fontSize: 16,
            color: color,
          ),
        ),
      ),
    );
  }
}

class StatusHeader extends StatelessWidget {
  const StatusHeader({
    Key? key,
    required this.header,
    required this.headerWidth,
  }) : super(key: key);

  final List<String> header;
  final List<double> headerWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(
        children: [
          ...header.map((h) {
            final idx = header.indexOf(h);
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                border: Border.all(color: Colors.black54, width: 0.2),
              ),
              width: headerWidth[idx],
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  h,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Constants.greenDark,
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
