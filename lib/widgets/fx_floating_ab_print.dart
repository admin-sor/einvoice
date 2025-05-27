import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../app/constants.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class FxFloatingABPrint extends StatelessWidget {
  const FxFloatingABPrint({
    Key? key,
    required this.preUrl,
    this.errorMessage,
  }) : super(key: key);

  final ValueNotifier<String>? errorMessage;
  final String preUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: FloatingActionButton(
        backgroundColor: Constants.grey,
        foregroundColor: Colors.white,
        shape: const CircleBorder(
          side: BorderSide(
            color: Constants.greenDark,
            width: 2.0,
          ),
        ),
        onPressed: () async {
          final snow = "&t=${DateTime.now().toIso8601String()}";
          final url = "$preUrl$snow";
          if (kIsWeb) {
            html.window.open(url, "rpttab");
            return;
          }
          /* print("Url : $url"); */
          try {
            await Printing.layoutPdf(
              name: "Material Return",
              onLayout: (fmt) async {
                final response = await Dio().get(
                  url,
                  options: Options(responseType: ResponseType.bytes),
                );
                return response.data;
              },
            );
          } catch (e) {
            if (errorMessage != null) {
              errorMessage!.value = "Error printing document";
              Timer(const Duration(seconds: 3), () {
                errorMessage!.value = "";
              });
            }
          }
        },
        child: Image.asset(
          "images/icon_printer.png",
          width: 32,
          height: 32,
        ),
      ),
    );
  }
}
