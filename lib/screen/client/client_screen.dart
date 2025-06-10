import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app/app_route.dart';
import '../../app/constants.dart';
import '../../model/client_model.dart'; // Import client model
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_black_text.dart';
import '../../widgets/fx_text_field.dart';
import 'client_search_provider.dart';

class ClientScreen extends HookConsumerWidget {
  // Renamed class
  const ClientScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrlSearch = useTextEditingController(text: "");
    final errorMessage = useState("");
    final isLoading = useState(false);
    final isInitLoading = useState(true); // Added for initial search

    final listClient =
        useState<List<ClientModel>>(List.empty()); // Use ClientModel

    // Perform initial search
    if (isInitLoading.value) {
      isInitLoading.value = false;
      WidgetsBinding.instance.addPostFrameCallback((tmr) {
        ref.read(clientSearchProvider.notifier).search(query: ctrlSearch.text);
      });
    }

    // Listen to client search provider
    ref.listen(clientSearchProvider, (prev, next) {
      if (next is ClientSearchStateLoading) {
        isLoading.value = true;
      } else if (next is ClientSearchStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
        Timer(const Duration(seconds: 3), () {
          errorMessage.value = "";
        });
      } else if (next is ClientSearchStateDone) {
        isLoading.value = false;
        listClient.value = next.model;
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          "Client", // Changed title
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Constants.grey,
        foregroundColor: Colors.white,
        shape: const CircleBorder(
          side: BorderSide(
            color: Constants.greenDark,
            width: 2.0,
          ),
        ),
        onPressed: () {
          // Navigate to client edit route
          Navigator.of(context).pushNamed(
            clientEditRoute, // Assuming clientEditRoute exists
            arguments: {
              "query": ctrlSearch.text,
              "client": ClientModel(evClientID: "0")
            },
          );
        },
        child: Image.asset(
          "images/icon_add_green.png",
          width: 32,
          height: 32,
        ),
      ),
      endDrawer: const EndDrawer(),
      body: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height,
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
                ctrl: ctrlSearch,
                labelText: "Search Name", // Changed label
                width: MediaQuery.of(context).size.width,
                suffix: InkWell(
                  onTap: () {
                    ref
                        .read(clientSearchProvider.notifier)
                        .search(query: ctrlSearch.text);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: 1300, // Adjust width as needed
                    child: Column(
                      children: [
                        const _Header(), // Keep _Header structure, will modify below
                        const Divider(
                          color: Constants.greenDark,
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: listClient.value.length,
                            itemBuilder: (context, idx) {
                              final client =
                                  listClient.value[idx]; // Use client
                              return InkWell(
                                  // Added InkWell for tapping rows
                                  onTap: () {
                                    final param = {
                                      "client": client, // Pass client
                                      "query": ctrlSearch.text
                                    };
                                    Navigator.of(context).pushNamed(
                                        clientEditRoute, // Navigate to client edit
                                        arguments: param);
                                  },
                                  child: _ClientDetailRow(
                                    // Use _ClientDetailRow
                                    isOdd: (idx % 2 == 0),
                                    client: client, // Pass client
                                  ));
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              // Display error message if not empty
              if (errorMessage.value.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    errorMessage.value,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              // Show loading indicator
              if (isLoading.value)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper widget for header row
class _Header extends StatelessWidget {
  const _Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
            child: FxBlackText(
          title: "Name",
          color: Constants.greenDark,
          isBold: false,
        )),
        SizedBox(
            width: 200,
            child: FxBlackText(
              title: "Address",
              color: Constants.greenDark,
              isBold: false,
            )),
        SizedBox(
            width: 150,
            child: FxBlackText(
              title: "Business Reg No",
              color: Constants.greenDark,
              isBold: false,
            )),
        SizedBox(
            width: 150,
            child: FxBlackText(
              title: "SST No",
              color: Constants.greenDark,
              isBold: false,
            )),
        SizedBox(
            width: 150,
            child: FxBlackText(
              title: "TIN No",
              color: Constants.greenDark,
              isBold: false,
            )),
        SizedBox(
            width: 150,
            child: FxBlackText(
              title: "PIC",
              color: Constants.greenDark,
              isBold: false,
            )),
        SizedBox(
            width: 150,
            child: FxBlackText(
              title: "Phone",
              color: Constants.greenDark,
              isBold: false,
            )),
        SizedBox(
            width: 200,
            child: FxBlackText(
              title: "Email",
              color: Constants.greenDark,
              isBold: false,
            )),
      ],
    );
  }
}

// Helper widget for client detail row
class _ClientDetailRow extends StatelessWidget {
  final ClientModel client; // Use ClientModel
  final bool isOdd;
  const _ClientDetailRow({
    Key? key,
    required this.client,
    required this.isOdd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String address = client.evClientAddr1 ?? "";
    address += " ";
    address += client.evClientAddr2 ?? "";
    address = "${address.trim()} ";
    address += client.evClientAddr3 ?? "";
    address = address.trim();
    return Container(
      color: isOdd ? null : Constants.greenLight.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Row(
          children: [
            Expanded(
                child: FxBlackText(
              title: client.evClientName ?? "",
              isBold: false,
            )),
            SizedBox(
                width: 200,
                child: FxBlackText(
                  title: address,
                  isBold: false,
                )),
            SizedBox(
                width: 150,
                child: FxBlackText(
                  title: client.evClientBusinessRegNo ?? "",
                  isBold: false,
                )),
            SizedBox(
                width: 150,
                child: FxBlackText(
                  title: client.evClientSstNo ?? "",
                  isBold: false,
                )),
            SizedBox(
                width: 150,
                child: FxBlackText(
                  title: client.evClientTinNo ?? "",
                  isBold: false,
                )),
            SizedBox(
                width: 150,
                child: FxBlackText(
                  title: client.evClientPic ?? "",
                  isBold: false,
                )),
            SizedBox(
                width: 150,
                child: FxBlackText(
                  title: client.evClientPhone ?? "",
                  isBold: false,
                )),
            SizedBox(
                width: 200,
                child: FxBlackText(
                  title: client.evClientEmail ?? "",
                  isBold: false,
                )),
          ],
        ),
      ),
    );
  }
}

// Removed _MaterialMdDetail and _RoField widgets
