import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sor_inventory/model/supplier_model.dart';
import 'package:sor_inventory/screen/supplier/supplier_delete_provider.dart';
import 'package:sor_inventory/screen/supplier/supplier_edit_provider.dart';
import 'package:sor_inventory/widgets/fx_id_type_lk.dart';
import '../../app/constants.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_button.dart';
import '../../widgets/fx_gray_dark_text.dart';
import '../../widgets/fx_text_field.dart';

class SupplierEditScreen extends HookConsumerWidget {
  final SupplierModel supplier;
  final String query; // Used to refresh the list after saving
  const SupplierEditScreen({
    Key? key,
    required this.supplier,
    this.query = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final errorMessage = useState("");
    final isInvoiceSupplier = useState(supplier.evSupplierType == "O");

    final ctrlName = useTextEditingController(text: supplier.evSupplierName);
    final ctrlBusinessRegNo =
        useTextEditingController(text: supplier.evSupplierBusinessRegNo);
    final ctrlSstNo = useTextEditingController(text: supplier.evSupplierSstNo);
    final ctrlTinNo = useTextEditingController(text: supplier.evSupplierTinNo);
    final ctrlAddr1 = useTextEditingController(text: supplier.evSupplierAddr1);
    final ctrlAddr2 = useTextEditingController(text: supplier.evSupplierAddr2);
    final ctrlAddr3 = useTextEditingController(text: supplier.evSupplierAddr3);
    final ctrlPic = useTextEditingController(text: supplier.evSupplierPic);
    final ctrlEmail = useTextEditingController(text: supplier.evSupplierEmail);
    final ctrlPhone = useTextEditingController(text: supplier.evSupplierPhone);

    ref.listen(supplierEditProvider, (prev, next) {
      if (next is SupplierEditStateLoading) {
        isLoading.value = true;
      } else if (next is SupplierEditStateError) {
        errorMessage.value = next.message;
        isLoading.value = false;
      } else if (next is SupplierEditStateDone) {
        isLoading.value = false;
        Navigator.of(context).pop(); // Pop screen on successful save
      }
    });

    final ctrlIdType = useTextEditingController(
        text: supplier.evSupplierBusinessRegType ?? "BRN");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text(
          supplier.evSupplierID == "0" ? "New Supplier" : "Edit Supplier",
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
      body: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: Constants.paddingTopContent),
                FxTextField(
                  ctrl: ctrlName,
                  labelText: "Supplier Name",
                  hintText: "Supplier Name",
                  width: double.infinity,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: isInvoiceSupplier.value,
                      onChanged: (value) {
                        if (value == null) return;
                        isInvoiceSupplier.value = value;
                      },
                    ),
                    const Text("Invoice Supplier"),
                  ],
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
                    const SizedBox(width: 20),
                    Expanded(
                      child: FxFilterIdTypeLk(
                        labelText: "Type",
                        hintText: "Type",
                        initialValue: IdTypeLkModel(
                            supplier.evSupplierBusinessRegType ?? "BRN",
                            supplier.evSupplierBusinessRegType ?? "BRN"),
                        onChanged: (m) {
                          ctrlIdType.text = m.code;
                        },
                      ),
                    ),
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
                ),
                const SizedBox(height: 10),
                FxTextField(
                  ctrl: ctrlPhone,
                  labelText: "Phone",
                  hintText: "Phone",
                  width: double.infinity,
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
                    const Expanded(
                      child: SizedBox(width: 10),
                    ),
                    const SizedBox(width: 20),
                    if (supplier.evSupplierID != null &&
                        supplier.evSupplierID != "0")
                      Expanded(
                        child: FxButton(
                          title: "Delete",
                          color: Constants.red,
                          onPress: () {
                            ref.read(supplierDeleteProvider.notifier).delete(
                                  supplierId:
                                      int.parse(supplier.evSupplierID!),
                                  query: query,
                                );
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    if (supplier.evSupplierID != null &&
                        supplier.evSupplierID != "0")
                      const SizedBox(width: 20),
                    Expanded(
                      child: FxButton(
                        title: "Save",
                        color: Constants.greenDark,
                        isLoading: isLoading.value,
                        onPress: () {
                          if (ctrlName.text.trim().isEmpty) {
                            errorMessage.value = "Supplier Name is mandatory";
                            return;
                          }

                          errorMessage.value = "";

                          ref.read(supplierEditProvider.notifier).edit(
                                evSupplierID: int.tryParse(
                                        supplier.evSupplierID ?? "0") ??
                                    0,
                                evSupplierType:
                                    isInvoiceSupplier.value ? "O" : "",
                                evSupplierBusinessRegType: ctrlIdType.text,
                                evSupplierName: ctrlName.text.trim(),
                                evSupplierBusinessRegNo:
                                    ctrlBusinessRegNo.text.trim(),
                                evSupplierSstNo: ctrlSstNo.text.trim(),
                                evSupplierTinNo: ctrlTinNo.text.trim(),
                                evSupplierAddr1: ctrlAddr1.text.trim(),
                                evSupplierAddr2: ctrlAddr2.text.trim(),
                                evSupplierAddr3: ctrlAddr3.text.trim(),
                                evSupplierPic: ctrlPic.text.trim(),
                                evSupplierEmail: ctrlEmail.text.trim(),
                                evSupplierPhone: ctrlPhone.text.trim(),
                                query: query,
                              );
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
