import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../app/constants.dart';

class FxPdfViewer extends StatelessWidget {
  final String url;
  const FxPdfViewer({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        centerTitle: true,
        title: Text(
          "${Constants.appTitle} ${Constants.appSubTitle}",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Constants.colorAppBar,
          ),
        ),
        iconTheme: const IconThemeData(color: Constants.colorAppBar),
      ),
      body: FutureBuilder<Uint8List?>(
        future: _fetchPdfContent(url),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return PdfPreview(
              allowPrinting: false,
              allowSharing: false,
              canChangePageFormat: false,
              build: (format) {
                return snapshot.data as Uint8List;
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Future<Uint8List?> _fetchPdfContent(final String url) async {
    try {
      final Response<List<int>> response = await Dio().get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.data != null) {
        return Uint8List.fromList(response.data!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
