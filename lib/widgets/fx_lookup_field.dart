import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../app/constants.dart';
import '../provider/dio_provider.dart';
import '../repository/base_repository.dart';

class FxLookupRepository extends BaseRepository {
  FxLookupRepository({required super.dio});
  Future<List<Map<String, dynamic>>> lookup(String service) async {
    final resp = await postWoToken(param: {}, service: service);
    final List<Map<String, dynamic>> result = List.empty(growable: true);
    resp["data"].forEach((e) {
      result.add(e);
    });
    return result;
  }
}

class FxLookupField extends HookConsumerWidget {
  final double? width;
  final String? hintText;
  final String? labelText;
  final Map<String, dynamic> initialValue;
  final String service;
  final String Function(Map<String, dynamic> value)? formatOption;
  final void Function(Map<String, dynamic>)? onChanged;

  const FxLookupField({
    Key? key,
    this.width,
    this.labelText,
    this.hintText,
    required this.initialValue,
    required this.service,
    this.formatOption,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxWidth = width == null ? 400.0 : width!;
    final isReady = useState(false);
    final isInit = useState(true);
    final selectedValue =
        useState<Map<String, dynamic>>({"id": 0, "name": "Loading"});
    final listValue =
        useState<List<Map<String, dynamic>>>([selectedValue.value]);
    final errorMessage = useState("");

    if (isInit.value) {
      isInit.value = false;
      Timer(const Duration(milliseconds: 300), () async {
        try {
          final resp = await FxLookupRepository(dio: ref.read(dioProvider))
              .lookup(service);
          if (resp.isNotEmpty) {
            listValue.value = resp;
            selectedValue.value = listValue.value[0];
            if (onChanged != null) onChanged!(selectedValue.value);
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
    return ConstrainedBox(
      constraints: BoxConstraints.loose(
        Size(maxWidth, 200),
      ),
      child: Container(
        width: maxWidth,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
          border: Border.all(
            color: Constants.greenDark,
          ),
        ),
        child: isReady.value
            ? DropdownButton<Map<String, dynamic>>(
                icon: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Image.asset(
                    "images/icon_triangle_down.png",
                    height: 24,
                  ),
                ),
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
                onChanged: (value) {
                  if (value != null) selectedValue.value = value;
                  if (onChanged != null && value != null) onChanged!(value);
                },
                items: listValue.value
                    .map<DropdownMenuItem<Map<String, dynamic>>>(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Center(
                          child: Text(
                            (formatOption != null)
                                ? formatOption!(value)
                                : value["name"] ?? "-",
                            style: TextStyle(
                              color: value["id"] == "0"
                                  ? Constants.greenDark.withOpacity(0.6)
                                  : Constants.greenDark,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              )
            : Padding(
                padding: const EdgeInsets.all(
                  10.0,
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
                              fontSize: 20,
                              color: Constants.greenDark,
                            ),
                          )
                        : Text(
                            "Error ${errorMessage.value}",
                            style: const TextStyle(
                              fontSize: 20,
                              color: Constants.red,
                            ),
                          )
                  ],
                ),
              ),
      ),
    );
  }
}
