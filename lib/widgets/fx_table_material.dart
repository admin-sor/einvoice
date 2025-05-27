import 'package:data_table_2/data_table_2.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../app/app_route.dart';
import '../app/constants.dart';
import '../model/do_model.dart';
import 'fx_green_dark_text.dart';

class FxTableMaterial extends HookConsumerWidget {
  final List<DoDetailModel> list;
  const FxTableMaterial({
    Key? key,
    required this.list,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveBuilder(builder: (context, sizeInfo) {
      if (sizeInfo.isMobile) {
        return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, idx) {
              final model = list[idx];
              String itemQty = "-";
              try {
                itemQty = (double.parse(model.doDetailQty)).round().toString();
              } catch (e) {}
              String totalQty = "-";
              try {
                totalQty = (double.parse(model.doDetailQty) *
                        double.parse(model.doDetailPackQty))
                    .round()
                    .toString();
              } catch (e) {}

              return Padding(
                padding: EdgeInsets.only(
                  bottom: (idx == list.length - 1) ? 50.0 : 10.0,
                  top: (idx == 0) ? 10.0 : 0.0,
                ),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                    ),
                    /*   Column( */
                    /*   children: [ */
                    /*     Row( */
                    /*       children: [ */
                    /*         FxGreenDarkText( */
                    /*           title: "PO. ${model.doDetailPoNo}", */
                    /*         ), */
                    /*         FxGreenDarkText( */
                    /*           title: "Material Code ${model.materialCode}", */
                    /*         ), */
                    /*       ], */
                    /*     ), */
                    /*     const SizedBox(height: 5), */
                    /*     Align( */
                    /*       alignment: Alignment.centerRight, */
                    /*       child: InkWell( */
                    /*         child: Image.asset( */
                    /*           "images/print_barcode.png", */
                    /*           height: 40, */
                    /*         ), */
                    /*         onTap: () async { */
                    /*           final snow = */
                    /*               "&t=${DateTime.now().toIso8601String()}"; */
                    /*           final url = */
                    /*               "http://${Constants.host}/reports/sor_inv_material.php?c=${model.doDetailBarcode}$snow"; */

                    /*           print(url); */
                    /*           await Printing.layoutPdf( */
                    /*             onLayout: (fmt) async { */
                    /*               final response = await Dio().get( */
                    /*                 url, */
                    /*                 options: Options( */
                    /*                     responseType: ResponseType.bytes), */
                    /*               ); */
                    /*               return response.data; */
                    /*             }, */
                    /*           ); */
                    /*           /* Navigator.of(context) */ */
                    /*           /*     .pushNamed(pdfViewer, arguments: url); */ */
                    /*         }, */
                    /*       ), */
                    /*     ), */
                    /*   ], */
                    /* ), */
                  ),
                ),
              );
            });
      }
      if (sizeInfo.isDesktop || sizeInfo.isTablet) {
        return _DataTableDesktop(list: list);
      }
      return Text("Platform ${sizeInfo.toString()} not available yet");
    });
  }
}

class _DataTableDesktop extends StatelessWidget {
  const _DataTableDesktop({
    Key? key,
    required this.list,
  }) : super(key: key);

  final List<DoDetailModel> list;

  @override
  Widget build(BuildContext context) {
    return PaginatedDataTable2(
      columnSpacing: 10,
      columns: const <DataColumn2>[
        DataColumn2(
          fixedWidth: 120,
          label: Text(
            "PO No.",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w200),
          ),
        ),
        DataColumn2(
          fixedWidth: 120,
          label: Text(
            "Code",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w200),
          ),
        ),
        DataColumn2(
          label: Text(
            "Description",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w200),
          ),
        ),
        DataColumn2(
          fixedWidth: 70,
          label: Text(
            "Units",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w200),
          ),
        ),
        DataColumn2(
          fixedWidth: 100,
          label: Text(
            "Qty",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w200),
          ),
        ),
        DataColumn2(
          fixedWidth: 50,
          label: Text(
            "",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w200),
          ),
        ),
      ],
      source: FxDataSourceMaterial(list: list),
    );
  }
}

class FxDataSourceMaterial extends DataTableSource {
  final List<DoDetailModel> list;
  FxDataSourceMaterial({
    required this.list,
  });

  @override
  DataRow? getRow(int index) {
    final model = list[index];

    return DataRow(cells: [
      DataCell(Text(model.doDetailPoNo)),
      DataCell(Text(model.materialCode)),
      DataCell(Text(model.description)),
      DataCell(Text(model.unit)),
      DataCell(
        Text(model.doDetailQty),
      ),
      DataCell(
          Image.asset(
            "images/icon_pdf.png",
            height: 40,
          ), onTap: () {
        launchUrlString(
          "https://${Constants.host}/reports/sor_inv_material.php?c=${model.doDetailBarcode}",
        );
      }),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => list.length;

  @override
  int get selectedRowCount => 0;
}
