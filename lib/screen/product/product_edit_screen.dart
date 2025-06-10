import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sor_inventory/model/product_model.dart';
import 'package:sor_inventory/screen/product/product_edit_provider.dart';
import '../../app/constants.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_button.dart';
import '../../widgets/fx_gray_dark_text.dart';
import '../../widgets/fx_text_field.dart';

class ProductEditScreen extends HookConsumerWidget {
  final ProductModel product;
  final String query; // Used to refresh the list after saving
  const ProductEditScreen({
    Key? key,
    required this.product,
    this.query = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final errorMessage = useState("");

    final ctrlName =
        useTextEditingController(text: product.evProductDescription);
    final ctrlUnit = useTextEditingController(text: product.evProductUnit);
    final ctrlPrice = useTextEditingController(text: product.evProductPrice);

    ref.listen(productEditProvider, (prev, next) {
      if (next is ProductEditStateLoading) {
        isLoading.value = true;
      } else if (next is ProductEditStateError) {
        errorMessage.value = next.message;
        isLoading.value = false;
      } else if (next is ProductEditStateDone) {
        isLoading.value = false;
        Navigator.of(context).pop(); // Pop screen on successful save
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text(
          product.evProductID == "0" ? "New Product" : "Edit Product",
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
                FxTextField(
                  ctrl: ctrlName,
                  labelText: "Description",
                  hintText: "Description",
                  width: double.infinity,
                  // Add validation indicator if needed
                ),
                const SizedBox(height: 10),
                FxTextField(
                  ctrl: ctrlUnit,
                  labelText: "Unit",
                  hintText: "Unit",
                  width: double.infinity,
                ),
                const SizedBox(height: 10),
                FxTextField(
                  ctrl: ctrlPrice,
                  labelText: "Price",
                  hintText: "Price",
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
                            errorMessage.value = "Product Name is mandatory";
                            return;
                          }
                          // More validation can be added here for other fields

                          // Clear previous error message on attempting save
                          errorMessage.value = "";

                          ref.read(productEditProvider.notifier).edit(
                                evProductID: product.evProductID ??
                                    "0", // Convert ID to int
                                evProductDescription: ctrlName.text.trim(),
                                evProductUnit: ctrlUnit.text.trim(),
                                evProductPrice: ctrlPrice.text.trim(),
                                query: query, // Pass the original search query
                              );
                        },
                      ),
                    ),
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
