import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sor_inventory/screen/store/store_search_provider.dart';
import 'package:sor_inventory/widgets/fx_black_text.dart';

import '../../app/app_route.dart';
import '../../app/constants.dart';
import '../../model/sor_user_model.dart';
import '../../model/store_model.dart';
import '../../widgets/end_drawer.dart';
import '../../widgets/fx_green_dark_text.dart';
import '../../widgets/fx_text_field.dart';
import '../login/login_provider.dart';

class StoreScreen extends HookConsumerWidget {
  const StoreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginModel = useState<SorUser?>(null);
    final isInit = useState(true);
    final isInitLoading = useState(true);
    final ctrlSearch = useTextEditingController(text: "");
    final errorMessage = useState("");
    final isLoading = useState(false);
    final allowAdd = useState(false);

    ref.listen(loginStateProvider, (prev, next) {
      if (next is LoginStateDone) {
        loginModel.value = next.loginModel;
      }
    });
    //no login
    if (loginModel.value == null) {
      if (isInit.value) {
        isInit.value = false;
        Timer(const Duration(milliseconds: 500), () {
          ref.read(loginStateProvider.notifier).checkLocalToken();
        });
      } else {
        Timer(const Duration(milliseconds: 500), () {
          isInit.value = true;
          if (loginModel.value == null) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(loginRoute, (args) => false);
          }
        });
      }
      return Scaffold(
        body: Container(
          color: Colors.white,
        ),
      );
    }

    const horiSpace = SizedBox(width: 10);
    final listStore = useState<List<StoreModel>>(List.empty());

    if (isInitLoading.value) {
      isInitLoading.value = false;
      WidgetsBinding.instance.addPostFrameCallback((tmr) {
        ref.read(storeSearchProvider.notifier).search(query: ctrlSearch.text);
      });
    }
    ref.listen(storeSearchProvider, (prev, next) {
      if (next is StoreSearchStateLoading) {
        isLoading.value = true;
      } else if (next is StoreSearchStateError) {
        isLoading.value = false;
        errorMessage.value = next.message;
      } else if (next is StoreSearchStateDone) {
        isLoading.value = false;
        listStore.value = next.list;
        if (listStore.value.isNotEmpty) {
          if (listStore.value[0].storeLimit != null &&
            listStore.value[0].storeLimit! > listStore.value.length) {
            allowAdd.value = true;
          } else {
            allowAdd.value = false;
          }
        }
      }
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.colorAppBarBg,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          "Store",
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
      floatingActionButton: allowAdd.value ? FloatingActionButton(
        backgroundColor: Constants.grey,
        foregroundColor: Colors.white,
        shape: const CircleBorder(
          side: BorderSide(
            color: Constants.greenDark,
            width: 2.0,
          ),
        ),
        onPressed: () {
          Navigator.of(context).pushNamed(
            storeEditRoute,
            arguments: {"query": ctrlSearch.text, "isNew": true},
          );
        },
        child: Image.asset(
          "images/icon_add_green.png",
          width: 32,
          height: 32,
        ),
      ) : null,
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
              Stack(
                alignment: Alignment.center,
                children: [
                  FxTextField(
                    ctrl: ctrlSearch,
                    labelText: "Search Store",
                    width: MediaQuery.of(context).size.width,
                    suffix: InkWell(
                      onTap: () {
                        ref
                            .read(storeSearchProvider.notifier)
                            .search(query: ctrlSearch.text);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.search),
                      ),
                    ),
                  ),
                  if (isLoading.value)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: const CircularProgressIndicator(),
                    )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: kIsWeb ? Constants.webWidth : 600,
                    child: Column(
                      children: [
                        const _StoreHeader(),
                        const Divider(
                          color: Constants.greenDark,
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: listStore.value.length,
                            itemBuilder: (context, idx) {
                              final store = listStore.value[idx];
                              return InkWell(
                                  onTap: () {
                                    final param = {
                                      "store": store,
                                      "query": ctrlSearch.text,
                                      "isNew": false,
                                    };
                                    Navigator.of(context).pushNamed(
                                        storeEditRoute,
                                        arguments: param);
                                  },
                                  child: _StoreDetailRow(
                                    isOdd: (idx % 2 == 0),
                                    store: store,
                                    query: ctrlSearch.text,
                                  ));
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreDetailRow extends StatelessWidget {
  final StoreModel store;
  final String query;
  final bool isOdd;
  const _StoreDetailRow({
    Key? key,
    required this.store,
    required this.query,
    this.isOdd = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isOdd ? Constants.greenLight.withOpacity(0.2) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Row(children: [
          SizedBox(
              width: 220,
              child: FxBlackText(
                title: store.storeName ?? "",
              )),
          const SizedBox(width: 10),
          Expanded(
              child: FxBlackText(
                  title:
                      "${store.storeAddress1 ?? ""} ${store.storeAddress2 ?? ""}  ${store.storeAddress3 ?? ""}")),
          const SizedBox(width: 10),
          Expanded(child: FxBlackText(title: "${store.region ?? ""}")),
        ]),
      ),
    );
  }
}

class _StoreHeader extends StatelessWidget {
  const _StoreHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Row(children: [
        SizedBox(width: 220, child: FxGreenDarkText(title: "Name")),
        SizedBox(width: 10),
        Expanded(child: FxGreenDarkText(title: "Address")),
        SizedBox(width: 10),
        Expanded(child: FxGreenDarkText(title: "Region Office")),
      ]),
    );
  }
}
