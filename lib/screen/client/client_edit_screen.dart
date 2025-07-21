import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sor_inventory/model/client_model.dart';
import 'package:sor_inventory/screen/client/client_edit_provider.dart';
import 'package:sor_inventory/widgets/fx_id_type_lk.dart';
import '../../app/constants.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_button.dart';
import '../../widgets/fx_gray_dark_text.dart';
import '../../widgets/fx_text_field.dart';
import 'client_delete_provider.dart';

class ClientEditScreen extends HookConsumerWidget {
  final ClientModel client;
  final String query; // Used to refresh the list after saving
  const ClientEditScreen({
    Key? key,
    required this.client,
    this.query = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final errorMessage = useState("");

    final ctrlName = useTextEditingController(text: client.evClientName);
    final ctrlBusinessRegNo =
        useTextEditingController(text: client.evClientBusinessRegNo);
    final ctrlSstNo = useTextEditingController(text: client.evClientSstNo);
    final ctrlTinNo = useTextEditingController(text: client.evClientTinNo);
    final ctrlAddr1 = useTextEditingController(text: client.evClientAddr1);
    final ctrlAddr2 = useTextEditingController(text: client.evClientAddr2);
    final ctrlAddr3 = useTextEditingController(text: client.evClientAddr3);
    final ctrlPic = useTextEditingController(text: client.evClientPic);
    final ctrlEmail = useTextEditingController(text: client.evClientEmail);
    final ctrlPhone = useTextEditingController(text: client.evClientPhone);

    ref.listen(clientEditProvider, (prev, next) {
      if (next is ClientEditStateLoading) {
        isLoading.value = true;
      } else if (next is ClientEditStateError) {
        errorMessage.value = next.message;
        isLoading.value = false;
      } else if (next is ClientEditStateDone) {
        isLoading.value = false;
        Navigator.of(context).pop(); // Pop screen on successful save
      }
    });
    final ctrlIdType =
        useTextEditingController(text: client.evClientBusinessRegType ?? "BRN");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text(
          client.evClientID == "0" ? "New Client" : "Edit Client",
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
                  "images/icon_menu.png", // Placeholder, replace if necessary
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
      endDrawer: const EndDrawer(), // Assuming EndDrawer is a common widget
      body: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            // Use SingleChildScrollView for long forms
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: Constants.paddingTopContent),
                // Read-only Client ID if editing, maybe hidden for new
                // if (client.evClientID != "0")
                //   FxTextField(
                //     readOnly: true,
                //     enabled: false,
                //     labelText: "Client ID",
                //     hintText: client.evClientID,
                //     ctrl: TextEditingController(
                //         text: client.evClientID), // Displaying ID
                //     width: double.infinity,
                //   ),
                // const SizedBox(height: 10),
                FxTextField(
                  ctrl: ctrlName,
                  labelText: "Client Name",
                  hintText: "Client Name",
                  width: double.infinity,
                  // Add validation indicator if needed
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: FxTextField(
                        ctrl: ctrlBusinessRegNo,
                        labelText: "Business Reg No",
                        hintText: "Business Reg No",
                        width: double.infinity,
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                        child: FxFilterIdTypeLk(
                      labelText: "Type",
                      hintText: "Type",
                      initialValue: IdTypeLkModel(
                          client.evClientBusinessRegType ?? "BRN",
                          client.evClientBusinessRegType ?? "BRN"),
                      onChanged: (m) {
                        ctrlIdType.text = m.code;
                      },
                    )),
                  ],
                ),
                const SizedBox(height: 10),
                FxTextField(
                  ctrl: ctrlSstNo,
                  labelText: "SST No",
                  hintText: "SST No",
                  width: double.infinity,
                ),
                const SizedBox(height: 10),
                FxTextField(
                  ctrl: ctrlTinNo,
                  labelText: "TIN No",
                  hintText: "TIN No",
                  width: double.infinity,
                ),
                const SizedBox(height: 10),
                FxTextField(
                  ctrl: ctrlAddr1,
                  labelText: "Address Line 1",
                  hintText: "Address Line 1",
                  width: double.infinity,
                ),
                const SizedBox(height: 10),
                FxTextField(
                  ctrl: ctrlAddr2,
                  labelText: "Address Line 2",
                  hintText: "Address Line 2",
                  width: double.infinity,
                ),
                const SizedBox(height: 10),
                FxTextField(
                  ctrl: ctrlAddr3,
                  labelText: "Address Line 3",
                  hintText: "Address Line 3",
                  width: double.infinity,
                ),
                const SizedBox(height: 10),
                FxTextField(
                  ctrl: ctrlPic,
                  labelText: "Person in Charge",
                  hintText: "Person in Charge",
                  width: double.infinity,
                ),
                const SizedBox(height: 10),
                FxTextField(
                  ctrl: ctrlEmail,
                  labelText: "Email",
                  hintText: "Email",
                  width: double.infinity,
                  // Add email validation if needed
                ),
                const SizedBox(height: 10),
                FxTextField(
                  ctrl: ctrlPhone,
                  labelText: "Phone",
                  hintText: "Phone",
                  width: double.infinity,
                  // Add phone validation if needed
                ),
                const SizedBox(height: 20),

                if (errorMessage.value != "")
                  FxGrayDarkText(
                    color: Constants.red,
                    title: errorMessage.value,
                  ),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: FxButton(
                        title: "Cancel",
                        color: Constants.red,
                        onPress: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: FxButton(
                        title: "Save",
                        color: Constants.greenDark,
                        isLoading: isLoading.value,
                        onPress: () {
                          // Basic validation
                          if (ctrlName.text.trim().isEmpty) {
                            errorMessage.value = "Client Name is mandatory";
                            return;
                          }
                          // More validation can be added here for other fields

                          // Clear previous error message on attempting save
                          errorMessage.value = "";

                          ref.read(clientEditProvider.notifier).edit(
                                evClientID:
                                    int.tryParse(client.evClientID ?? "0") ??
                                        0, // Convert ID to int
                            evClientBusinessRegType: ctrlIdType.text,
                                evClientName: ctrlName.text.trim(),
                                evClientBusinessRegNo:
                                    ctrlBusinessRegNo.text.trim(),
                                evClientSstNo: ctrlSstNo.text.trim(),
                                evClientTinNo: ctrlTinNo.text.trim(),
                                evClientAddr1: ctrlAddr1.text.trim(),
                                evClientAddr2: ctrlAddr2.text.trim(),
                                evClientAddr3: ctrlAddr3.text.trim(),
                                evClientPic: ctrlPic.text.trim(),
                                evClientEmail: ctrlEmail.text.trim(),
                                evClientPhone: ctrlPhone.text.trim(),
                                query: query, // Pass the original search query
                              );
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    if (client.evClientID != null)
                      Expanded(
                        child: FxButton(
                          title: "Delete",
                          color: Constants.red,
                          onPress: () {
                            ref.read(clientDeleteProvider.notifier).delete(
                                  clientId: int.parse(client.evClientID!),
                                  query: query,
                                );
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    if (client.evClientID != null) const SizedBox(width: 20),
                  ],
                ),
                const SizedBox(height: 20), // Add some space at the bottom
              ],
            ),
          ),
        ),
      ),
    );
  }
}
