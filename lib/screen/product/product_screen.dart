import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sor_inventory/app/app_route.dart';

import '../../app/constants.dart';
import '../../model/product_model.dart'; // Import product model
import 'package:intl/intl.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_black_text.dart';
import '../../widgets/fx_text_field.dart';
import 'product_search_provider.dart';

class ProductScreen extends HookConsumerWidget {
  // Renamed class
  const ProductScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrlSearch = useTextEditingController(text: "");
    final errorMessage = useState("");
    final isLoading = useState(false);
    final isInitLoading = useState(true); // Added for initial search

    final listProduct =
        useState<List<ProductModel>>(List.empty()); // Use ProductModel

    // Perform initial search
    if (isInitLoading.value) {
      isInitLoading.value = false;
      WidgetsBinding.instance.addPostFrameCallback((tmr) {
        ref.read(productSearchProvider.notifier).search(query: ctrlSearch.text);
      });
    }

    // Listen to product search provider
    ref.listen(productSearchProvider, (prev, next) {
      if (next is ProductSearchStateLoading) {
        isLoading.value = true;
      } else if (next is ProductSearchStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
        Timer(const Duration(seconds: 3), () {
          errorMessage.value = "";
        });
      } else if (next is ProductSearchStateDone) {
        isLoading.value = false;
        listProduct.value = next.model;
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          "Product", // Changed title
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
          // Navigate to product edit route
          Navigator.of(context).pushNamed(
            productEditRoute, // Assuming productEditRoute exists
            arguments: {
              "query": ctrlSearch.text,
              "product": ProductModel(evProductID: "0")
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
                        .read(productSearchProvider.notifier)
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
                    width: 800, // Adjust width as needed
                    child: Column(
                      children: [
                        const _Header(), // Keep _Header structure, will modify below
                        const Divider(
                          color: Constants.greenDark,
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: listProduct.value.length,
                            itemBuilder: (context, idx) {
                              final product =
                                  listProduct.value[idx]; // Use product
                              return InkWell(
                                  // Added InkWell for tapping rows
                                  onTap: () {
                                    final param = {
                                      "product": product, // Pass product
                                      "query": ctrlSearch.text
                                    };
                                    Navigator.of(context).pushNamed(
                                      productEditRoute, // Navigate to product edit
                                      arguments: param,
                                    );
                                  },
                                  child: _ProductDetailRow(
                                    // Use _ProductDetailRow
                                    isOdd: (idx % 2 == 0),
                                    product: product, // Pass product
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
          title: "Description",
          color: Constants.greenDark,
          isBold: false,
        )),
        SizedBox(
            width: 200,
            child: FxBlackText(
              title: "Unit",
              color: Constants.greenDark,
              isBold: false,
            )),
        SizedBox(
            width: 150,
            child: FxBlackText(
              title: "Price",
              color: Constants.greenDark,
              isBold: false,
            )),
      ],
    );
  }
}

// Helper widget for product detail row
class _ProductDetailRow extends StatelessWidget {
  final ProductModel product; // Use ProductModel
  final bool isOdd;
  const _ProductDetailRow({
    Key? key,
    required this.product,
    required this.isOdd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var fmtPrice = "";
    try {
      if (product.evProductPrice != null) {
        final price = double.parse(product.evProductPrice!);
        final formatter = NumberFormat("#,##0.00", "en_US");
        fmtPrice = formatter.format(price);
      }
    } catch (_) {
      fmtPrice = product.evProductPrice ?? "";
    }
    return Container(
      color: isOdd ? null : Constants.greenLight.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Row(
          children: [
            Expanded(
                child: FxBlackText(
              title: product.evProductDescription ?? "",
              isBold: false,
            )),
            SizedBox(
                width: 200,
                child: FxBlackText(
                  title: product.evProductUnit ?? "",
                  isBold: false,
                )),
            SizedBox(
                width: 150,
                child: FxBlackText(
                  title: fmtPrice,
                  isBold: false,
                )),
          ],
        ),
      ),
    );
  }
}

// Removed _MaterialMdDetail and _RoField widgets
