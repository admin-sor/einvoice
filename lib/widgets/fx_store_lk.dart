import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sor_inventory/repository/store_repository.dart';
import 'package:sor_inventory/screen/dispose/dispose_store_provider.dart';
import 'package:sor_inventory/widgets/fx_green_dark_text.dart';

import '../app/constants.dart';
import '../model/store_model.dart';
import '../provider/dio_provider.dart';
import '../provider/shared_preference_provider.dart';
import '../repository/base_repository.dart';

class FxStoreLk extends HookConsumerWidget {
  final double? width;
  final String? hintText;
  final String? labelText;
  final String? initialValueId;
  final String Function(StoreModel)? formatOption;
  final void Function(StoreModel)? onChanged;
  final bool withAll;
  final bool forceAll;
  final String? allText;
  final bool readOnly;
  final bool isGrey;
  final bool isAll;
  final bool isTo;
  const FxStoreLk({
    Key? key,
    this.width,
    this.labelText,
    this.hintText,
    this.initialValueId,
    this.formatOption,
    this.onChanged,
    this.isTo = false,
    this.withAll = false,
    this.forceAll = false,
    this.allText = "All Store",
    this.readOnly = false,
    this.isGrey = false,
    this.isAll = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxWidth = width == null ? double.infinity : width!;
    final isReady = useState(false);
    final isInit = useState(true);
    final selectedValue = useState<StoreModel?>(null);
    final listValue = useState<List<StoreModel>>(List.empty());
    final errorMessage = useState("");

    if (isInit.value) {
      isInit.value = false;
      WidgetsBinding.instance.addPostFrameCallback((tmr) async {
        try {
          final loginModel = await ref.read(localAuthProvider.future);
          final resp = await StoreRepository(dio: ref.read(dioProvider))
              .getStoreByUser(token: loginModel?.token ?? "", isAll: isAll);
          if (resp.isNotEmpty) {
            var xlist = List<StoreModel>.empty(growable: true);
            if (withAll) {
              xlist.add(StoreModel(
                storeID: "0",
                storeName: allText,
              ));
              xlist.addAll(resp);
            } else {
              xlist = resp;
            }
            listValue.value = xlist;

            if (forceAll) {
              selectedValue.value = listValue.value[0];
            } else {
              if (isTo && listValue.value.length > 1) {
                selectedValue.value = listValue.value[1];
              } else {
                selectedValue.value = listValue.value[0];
              }
              if (initialValueId != null && initialValueId != "0") {
                try {
                  selectedValue.value = listValue.value
                      .firstWhere((e) => e.storeID == initialValueId);
                } catch (e) {}
              } else {
                if (listValue.value.length > 1) {
                  for (var store in listValue.value) {
                    if (store.isDefault == "Y") {
                      selectedValue.value = store;
                    }
                  }
                }
              }
            }
            if (onChanged != null && selectedValue.value != null) {
              onChanged!(selectedValue.value!);
            }
            isReady.value = true;
          }
        } catch (e) {
          if (e is BaseRepositoryException) {
            errorMessage.value = e.message;
          } else {
            errorMessage.value = e.toString();
          }
        }
      });
    }
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Container(
            width: maxWidth,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(10),
              ),
              border: Border.all(
                color: isGrey ? Colors.grey : Constants.greenDark,
                width: isGrey ? 0.8 : 1.0,
              ),
            ),
            child: isReady.value
                ? ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButton<StoreModel>(
                      icon: Image.asset(
                        "images/icon_triangle_down.png",
                        height: 36,
                      ),
                      onTap: null,
                      hint: Text(
                        hintText ?? "",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      value: selectedValue.value,
                      underline: const SizedBox.shrink(),
                      isExpanded: true,
                      onChanged: readOnly
                          ? null
                          : (value) {
                              if (value != null) selectedValue.value = value;
                              if (onChanged != null && value != null)
                                onChanged!(value);
                            },
                      items: listValue.value
                          .map<DropdownMenuItem<StoreModel>>(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(
                                (formatOption != null)
                                    ? formatOption!(value)
                                    : value.storeName! == "All"
                                        ? "All"
                                        : value.storeName!,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  /* color: Constants.greenDark, */
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(
                      15.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (errorMessage.value == "")
                          const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(),
                          ),
                        const SizedBox(width: 10),
                        (errorMessage.value == "")
                            ? Text(
                                "Loading $labelText",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Constants.greenDark,
                                ),
                              )
                            : Text(
                                "Error ${errorMessage.value}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Constants.red,
                                ),
                              )
                      ],
                    ),
                  ),
          ),
        ),
        Positioned(
          left: 10,
          top: -2,
          child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  hintText ?? "Store Location",
                  style: TextStyle(
                    fontSize: 14,
                    color: Constants.greenDark,
                  ),
                ),
              )),
        ),
      ],
    );
  }
}

class FxStoreLkBare extends HookConsumerWidget {
  final double? width;
  final String? hintText;
  final String? labelText;
  final String? initialValueId;
  final String Function(StoreModel)? formatOption;
  final void Function(StoreModel)? onChanged;
  final bool withAll;
  final String? allText;
  final bool readOnly;
  final bool isGrey;
  const FxStoreLkBare({
    Key? key,
    this.width,
    this.labelText,
    this.hintText,
    this.initialValueId,
    this.formatOption,
    this.onChanged,
    this.withAll = false,
    this.allText = "All Store",
    this.readOnly = false,
    this.isGrey = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isReady = useState(false);
    final isInit = useState(true);
    final selectedValue = useState<StoreModel?>(null);
    final listValue = useState<List<StoreModel>>(List.empty());
    final errorMessage = useState("");

    if (isInit.value) {
      isInit.value = false;
      WidgetsBinding.instance.addPostFrameCallback((tmr) async {
        try {
          final loginModel = await ref.read(localAuthProvider.future);
          final resp = await StoreRepository(dio: ref.read(dioProvider))
              .getStoreByUser(token: loginModel?.token ?? "");
          if (resp.isNotEmpty) {
            var xlist = List<StoreModel>.empty(growable: true);
            if (withAll) {
              xlist.add(StoreModel(
                storeID: "0",
                storeName: allText,
              ));
              xlist.addAll(resp);
            } else {
              xlist = resp;
            }
            listValue.value = xlist;

            selectedValue.value = listValue.value[0];
            if (initialValueId != null && initialValueId != "0") {
              try {
                selectedValue.value = listValue.value
                    .firstWhere((e) => e.storeID == initialValueId);
              } catch (e) {}
            } else {
              if (listValue.value.length > 1) {
                for (var store in listValue.value) {
                  if (store.isDefault == "Y") {
                    selectedValue.value = store;
                  }
                }
              }
            }
            if (onChanged != null && selectedValue.value != null) {
              onChanged!(selectedValue.value!);
            }
            isReady.value = true;
          }
        } catch (e) {
          if (e is BaseRepositoryException) {
            errorMessage.value = e.message;
          } else {
            errorMessage.value = e.toString();
          }
        }
      });
    }
    return isReady.value
        ? MediaQuery.removePadding(
            context: context,
            removeLeft: true,
            removeTop: true,
            removeBottom: true,
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<StoreModel>(
                isDense: true,
                padding: const EdgeInsets.all(0),
                icon: Image.asset(
                  "images/v3_dropdown_arrod.png",
                  height: 14,
                  width: 14,
                ),
                onTap: null,
                focusColor: Colors.transparent,
                value: selectedValue.value,
                underline: const SizedBox.shrink(),
                isExpanded: false,
                onChanged: readOnly
                    ? null
                    : (value) {
                        if (value != null) selectedValue.value = value;
                        if (onChanged != null && value != null) {
                          onChanged!(value);
                        }
                      },
                items: listValue.value
                    .map<DropdownMenuItem<StoreModel>>(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(
                          (formatOption != null)
                              ? formatOption!(value)
                              : value.storeName! == "All"
                                  ? "All"
                                  : value.storeName!,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (errorMessage.value == "")
                const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(),
                ),
              const SizedBox(width: 10),
              (errorMessage.value == "")
                  ? Text(
                      "Loading $labelText",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Constants.greenDark,
                      ),
                    )
                  : Text(
                      "Error ${errorMessage.value}",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Constants.red,
                      ),
                    )
            ],
          );
  }
}
